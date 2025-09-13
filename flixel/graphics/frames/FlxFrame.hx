package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;
import haxe.ds.ArraySort;
import haxe.ds.Vector;
import openfl.display.BitmapData;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Base class for all frame types
 */
class FlxFrame implements IFlxDestroyable
{
	/**
	 * Temp point helper, used internally
	 */
	static var _point = new Point();
	
	/**
	 * Temp rect helper, used internally
	 */
	static var _rect = new Rectangle();
	
	/**
	 * Temp matrix helper, used internally
	 */
	static var _matrix = new FlxMatrix();
	
	/**
	 * Sorts frames based on the value of the frames' name between the prefix and suffix.
	 * Uses `Std.parseInt` to parse the value, if the result is `null`, 0 is used, if the result
	 * is a negative number, the absolute valute is used.
	 * 
	 * @param frames  The list of frames to sort
	 * @param prefix  Everything in the frames' name *before* the order
	 * @param suffix  Everything in the frames' name *after* the order
	 * @param warn    Whether to warn on invalid names
	 */
	public static inline function sortFrames(frames:Array<FlxFrame>, prefix:String, ?suffix:String, warn = true):Void
	{
		sortHelper(frames, prefix.length, suffix == null ? 0 : suffix.length, warn);
	}
	
	/**
	 * Sorts frames based on the value of the frames' name between the prefix and suffix.
	 * Uses `Std.parseInt` to parse the value, if the result is `null`, 0 is used, if the result
	 * is a negative number, the absolute valute is used.
	 * 
	 * @param frames  The list of frames to sort
	 * @param prefix  Everything in the frames' name *before* the order
	 * @param suffix  Everything in the frames' name *after* the order
	 * @param warn    Whether to warn on invalid names
	 */
	public static function sort(frames:Array<FlxFrame>, prefixLength:Int, suffixLength:Int, warn = true):Void
	{
		sortHelper(frames, prefixLength, suffixLength, warn);
	}
	
	static function sortHelper(frames:Array<FlxFrame>, prefixLength:Int, suffixLength:Int, warn = true):Void
	{
		if (warn)
		{
			for (frame in frames)
				checkValidName(frame.name, prefixLength, suffixLength);
		}
		
		ArraySort.sort(frames, sortByName.bind(_, _, prefixLength, suffixLength));
	}
	
	static inline function checkValidName(name:String, prefixLength:Int, suffixLength:Int)
	{
		final nameSub = name.substring(prefixLength, name.length - suffixLength);
		final num:Null<Int> = Std.parseInt(nameSub);
		if (num == null)
			FlxG.log.warn('Could not parse frame number of "$nameSub" in frame named "$name"');
		else if (num < 0)
			FlxG.log.warn('Found negative frame number "$nameSub" in frame named "$name"');
	}
	
	public static function sortByName(frame1:FlxFrame, frame2:FlxFrame, prefixLength:Int, suffixLength:Int):Int
	{
		inline function getNameOrder(name:String):Int
		{
			final num:Null<Int> = Std.parseInt(name.substring(prefixLength, name.length - suffixLength));
			return if (num == null) 0 else FlxMath.absInt(num);
		}
		
		return getNameOrder(frame1.name) - getNameOrder(frame2.name);
	}

	public var name:String;

	/**
	 * Region of the image to render.
	 */
	public var frame(default, set):FlxRect;

	/**
	 * UV coordinates for this frame.
	 */
	public var uv:FlxUVRect;

	public var parent:FlxGraphic;

	/**
	 * Rotation angle of this frame.
	 * Required for packed atlas images.
	 */
	public var angle:FlxFrameAngle;

	public var flipX:Bool;
	public var flipY:Bool;

	/**
	 * Original (uncropped) image size.
	 */
	public var sourceSize(default, null):FlxPoint;

	/**
	 * Frame offset from top left corner of original image.
	 */
	public var offset(default, null):FlxPoint;

	/**
	 * The duration of this frame in seconds. If 0, the anim controller will decide the duration
	 */
	public var duration:Float;

	/**
	 * The type of this frame.
	 */
	public var type:FlxFrameType;

	/** Internal cache used to draw this frame **/
	var tileMatrix:MatrixVector;
	
	/** Internal cache used to draw this frame **/
	var blitMatrix:MatrixVector;

	public function new(parent:FlxGraphic, angle = FlxFrameAngle.ANGLE_0, flipX = false, flipY = false, duration = 0.0)
	{
		this.parent = parent;
		this.angle = angle;
		this.flipX = flipX;
		this.flipY = flipY;
		this.duration = duration;

		type = FlxFrameType.REGULAR;

		sourceSize = FlxPoint.get();
		offset = FlxPoint.get();

		blitMatrix = new MatrixVector();
		if (FlxG.renderTile)
			tileMatrix = new MatrixVector();
	}

	@:allow(flixel.graphics.frames.FlxFramesCollection)
	@:allow(flixel.graphics.frames.FlxBitmapFont)
	function cacheFrameMatrix():Void
	{
		blitMatrix.copyFrom(this, true);

		if (FlxG.renderTile)
			tileMatrix.copyFrom(this, false);
	}
	
	/**
	 * Applies frame rotation to the specified matrix, which should be used for tiling or blitting.
	 * Required for rotated frame support.
	 *
	 * @param   mat    Matrix to transform / rotate
	 * @param   blit   Whether specified matrix will be used for blitting or for tile rendering.
	 * @return  Transformed matrix.
	 */
	inline function prepareBlitMatrix(mat:FlxMatrix, blit = true):FlxMatrix
	{
		mat.identity();

		if (blit)
			mat.translate(-frame.x, -frame.y);

		if (angle == FlxFrameAngle.ANGLE_90)
		{
			mat.rotateByPositive90();
			mat.translate(frame.height, 0);
		}
		else if (angle == FlxFrameAngle.ANGLE_NEG_90)
		{
			mat.rotateByNegative90();
			mat.translate(0, frame.width);
		}

		mat.translate(offset.x, offset.y);
		return mat;
	}

	/**
	 * Rotates and flips matrix. This method expects matrix which was prepared by `MatrixVector.copyTo()`.
	 * Internal use only.
	 *
	 * @param   mat        Matrix to transform
	 * @param   rotation   Rotation to apply to specified matrix.
	 * @param   flipX      Do we need to flip frame horizontally
	 * @param   flipY      Do we need to flip frame vertically
	 * @return  Transformed matrix with applied rotation and flipping
	 */
	inline function rotateAndFlip(mat:FlxMatrix, rotation:FlxFrameAngle = FlxFrameAngle.ANGLE_0, flipX:Bool = false, flipY:Bool = false):FlxMatrix
	{
		var w:Int = Std.int(sourceSize.x);
		var h:Int = Std.int(sourceSize.y);

		// rotate frame transformation matrix if rotation isn't zero
		if (rotation != FlxFrameAngle.ANGLE_0)
		{
			var t:Int = w;
			w = h;
			h = t;

			if (rotation == FlxFrameAngle.ANGLE_90)
			{
				mat.rotateByPositive90();
				mat.translate(sourceSize.y, 0);
			}
			else if (rotation == FlxFrameAngle.ANGLE_270 || rotation == FlxFrameAngle.ANGLE_NEG_90)
			{
				mat.rotateByNegative90();
				mat.translate(0, sourceSize.x);
			}
		}

		// flip frame transformation matrix
		if (flipX)
		{
			mat.scale(-1, 1);
			mat.translate(w, 0);
		}

		if (flipY)
		{
			mat.scale(1, -1);
			mat.translate(0, h);
		}

		return mat;
	}

	/**
	 * Prepares matrix for frame blitting (see `paint` methods).
	 *
	 * @param   mat        Matrix to transform/prepare.
	 * @param   rotation   Rotation to apply to specified matrix.
	 * @param   flipX      Do we need to flip frame horizontally.
	 * @param   flipY      Do we need to flip frame vertically.
	 * @return  Transformed matrix which can be used for frame painting.
	 */
	function prepareTransformedBlitMatrix(mat:FlxMatrix, rotation:FlxFrameAngle = FlxFrameAngle.ANGLE_0, flipX:Bool = false, flipY:Bool = false):FlxMatrix
	{
		blitMatrix.copyTo(mat);
		return rotateAndFlip(mat, rotation, flipX, flipY);
	}

	/**
	 * Prepares matrix for frame tile/triangles rendering.
	 *
	 * @param   mat        Matrix to transform/prepare
	 * @param   rotation   Rotation to apply to specified matrix.
	 * @param   flipX      Do we need to flip frame horizontally
	 * @param   flipY      Do we need to flip frame vertically
	 * @return  Transformed matrix which can be used for frame drawing.
	 */
	public function prepareMatrix(mat:FlxMatrix, rotation:FlxFrameAngle = FlxFrameAngle.ANGLE_0, flipX:Bool = false, flipY:Bool = false):FlxMatrix
	{
		if (FlxG.renderBlit)
		{
			mat.identity();
			return mat;
		}

		tileMatrix.copyTo(mat);

		var doFlipX = flipX != this.flipX;
		var doFlipY = flipY != this.flipY;

		if (rotation == FlxFrameAngle.ANGLE_0 && !doFlipX && !doFlipY)
			return mat;

		return rotateAndFlip(mat, rotation, doFlipX, doFlipY);
	}

	/**
	 * Draws frame on specified `BitmapData` object.
	 *
	 * @param   bmd                 `BitmapData` object to draw this frame on.
	 *                              If bmd is `null` then new a `BitmapData` is created.
	 * @param   point               Where to draw this frame on the specified `BitmapData` object.
	 * @param   mergeAlpha          Whether to merge alphas or not.
	 *                              (works like with `BitmapData`'s `copyPixels()` method).
	 * @param   disposeIfNotEqual   Whether dispose passed `bmd` or not if its size isn't
	 *                              equal to frame's original size (`sourceSize`)
	 * @return  Modified or newly created `BitmapData` with frame image on it.
	 */
	public function paint(?bmd:BitmapData, ?point:Point, mergeAlpha = false, disposeIfNotEqual = false):BitmapData
	{
		bmd = checkInputBitmap(bmd, point, FlxFrameAngle.ANGLE_0, mergeAlpha, disposeIfNotEqual);

		if (type == FlxFrameType.EMPTY)
			return bmd;

		if (angle == FlxFrameAngle.ANGLE_0)
		{
			offset.copyTo(_point);
			if (point != null)
				_point.offset(point.x, point.y);
				
			bmd.copyPixels(parent.bitmap, frame.copyToFlash(_rect), _point, null, null, mergeAlpha);
		}
		else
		{
			blitMatrix.copyTo(_matrix);
			if (point != null)
				_matrix.translate(point.x, point.y);
				
			bmd.draw(parent.bitmap, _matrix, null, null, getDrawFrameRect(_matrix, _rect));
		}

		return bmd;
	}

	/**
	 * Draws rotated and flipped frame on specified BitmapData object.
	 *
	 * @param   bmd                 BitmapData object to draw this frame on.
	 *                              If `bmd` is `null` then new `BitmapData` created.
	 * @param   point               Where to draw this frame on the specified `BitmapData` object
	 * @param   rotation            How much rotate the frame.
	 * @param   flipX               Do we need to flip frame horizontally.
	 * @param   flipY               Do we need to flip frame vertically.
	 * @param   mergeAlpha          Whether to merge alphas or not
	 *                              (works like with `BitmapData`'s `copyPixels()` method).
	 * @param   disposeIfNotEqual   Whether dispose passed `bmd` or not if its size isn't
	 *                              equal to frame's original size (`sourceSize`)
	 * @return  Modified or newly created `BitmapData` with frame image on it.
	 */
	public function paintRotatedAndFlipped(?bmd:BitmapData, ?point:Point, rotation:FlxFrameAngle = FlxFrameAngle.ANGLE_0, flipX:Bool = false,
			flipY:Bool = false, mergeAlpha:Bool = false, disposeIfNotEqual:Bool = false):BitmapData
	{
		if (type == FlxFrameType.EMPTY && rotation == FlxFrameAngle.ANGLE_0)
			return paint(bmd, point, mergeAlpha, disposeIfNotEqual);

		bmd = checkInputBitmap(bmd, point, rotation, mergeAlpha, disposeIfNotEqual);

		if (type == FlxFrameType.EMPTY)
			return bmd;

		final doFlipX = flipX != this.flipX;
		final doFlipY = flipY != this.flipY;
		
		prepareTransformedBlitMatrix(_matrix, rotation, doFlipX, doFlipY);
		
		if (point != null)
			_matrix.translate(point.x, point.y);
			
		bmd.draw(parent.bitmap, _matrix, null, null, getDrawFrameRect(_matrix, _rect));
		return bmd;
	}

	/**
	 * Internal method which runs few checks on specified `BitmapData` object.
	 *
	 * @param   bmd                 `BitmapData` object to check against.
	 * @param   point               Optional point for mergeAlpha checks
	 * @param   rotation            How much we will rotate the frame when we will be
	 *                              drawing it on specified `BitmapData`.
	 * @param   mergeAlpha          Whether to merge alphas or not
	 *                              (works like with `BitmapData`'s `copyPixels()` method).
	 * @param   disposeIfNotEqual   Whether dispose passed bmd or not if its size isn't
	 *                              equal to frame's original size (`sourceSize`).
	 * @return  Prepared `BitmapData` for further frame blitting. Output `BitmapData` could be a different object.
	 */
	inline function checkInputBitmap(?bmd:BitmapData, ?point:Point, rotation = FlxFrameAngle.ANGLE_0, mergeAlpha = false, disposeIfNotEqual = false):BitmapData
	{
		final flipXY = rotation != FlxFrameAngle.ANGLE_0;
		final w = Std.int(flipXY ? sourceSize.y : sourceSize.x);
		final h = Std.int(flipXY ? sourceSize.x : sourceSize.y);

		if (bmd != null && disposeIfNotEqual)
			bmd = FlxDestroyUtil.disposeIfNotEqual(bmd, w, h);

		if (bmd != null && !mergeAlpha)
		{
			if (point != null)
				_rect.setTo(point.x, point.y, w, h);
			else
				_rect.setTo(0, 0, w, h);
				
			bmd.fillRect(_rect, FlxColor.TRANSPARENT);
		}
		else if (bmd == null)
		{
			bmd = new BitmapData(w, h, true, FlxColor.TRANSPARENT);
		}

		return bmd;
	}

	/**
	 * Internal method which prepares frame rect for blitting.
	 * Required for rotated frames support.
	 *
	 * @param   mat   Frame transformation matrix (rotated / flipped / translated).
	 * @param   rect  The output rectangle
	 * @return  Clipping rectangle which will be used for frame blitting.
	 */
	inline function getDrawFrameRect(mat:FlxMatrix, rect:Rectangle):Rectangle
	{
		final p1 = FlxPoint.weak(frame.x, frame.y);
		final p2 = FlxPoint.weak(frame.right, frame.bottom);

		p1.transform(mat);
		p2.transform(mat);

		final flxRect = FlxRect.get().fromTwoPoints(p1, p2);
		flxRect.copyToFlash(rect);
		flxRect.put();
		return rect;
	}

	/**
	 * Generates frame with specified subregion of this frame.
	 *
	 * @param   rect          Frame region to generate frame for.
	 * @param   frameToFill   Frame to fill with data. If `null` then a new frame will be created.
	 * @return  Specified `frameToFill` object but filled with data.
	 */
	public function subFrameTo(rect:FlxRect, ?frameToFill:FlxFrame):FlxFrame
	{
		if (frameToFill == null)
		{
			frameToFill = new FlxFrame(parent, angle);
		}
		else
		{
			frameToFill.parent = parent;
			frameToFill.angle = angle;
			frameToFill.frame = FlxDestroyUtil.put(frameToFill.frame);
		}

		frameToFill.sourceSize.set(rect.width, rect.height);

		// no need to make all calculations if original frame is empty...
		if (type == FlxFrameType.EMPTY)
		{
			frameToFill.type = FlxFrameType.EMPTY;
			frameToFill.offset.set(0, 0);
			return frameToFill;
		}

		var clippedRect:FlxRect = FlxRect.get().setSize(frame.width, frame.height);
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			clippedRect.width = frame.height;
			clippedRect.height = frame.width;
		}

		var ox:Float = Math.max(offset.x, 0);
		var oy:Float = Math.max(offset.y, 0);

		rect.offset(-ox, -oy);
		var frameRect:FlxRect = clippedRect.intersection(rect);
		clippedRect = FlxDestroyUtil.put(clippedRect);
		rect.offset(ox, oy);

		if (frameRect.isEmpty)
		{
			frameToFill.type = FlxFrameType.EMPTY;
			frameRect.set(0, 0, 0, 0);
			frameToFill.frame = frameRect;
			frameToFill.offset.set(0, 0);
		}
		else
		{
			frameToFill.type = FlxFrameType.REGULAR;
			frameToFill.offset.set(frameRect.x, frameRect.y).subtract(rect.x, rect.y).add(offset);

			final p1 = FlxPoint.weak(frameRect.x, frameRect.y);
			final p2 = FlxPoint.weak(frameRect.right, frameRect.bottom);

			_matrix.identity();

			if (angle == FlxFrameAngle.ANGLE_NEG_90)
			{
				_matrix.rotateByPositive90();
				_matrix.translate(frame.width, 0);
			}
			else if (angle == FlxFrameAngle.ANGLE_90)
			{
				_matrix.rotateByNegative90();
				_matrix.translate(0, frame.height);
			}

			if (angle != FlxFrameAngle.ANGLE_0)
			{
				p1.transform(_matrix);
				p2.transform(_matrix);
			}

			frameRect.fromTwoPoints(p1, p2);
			frameRect.offset(frame.x, frame.y);
			frameToFill.frame = frameRect;
			frameToFill.cacheFrameMatrix();
		}

		return frameToFill;
	}

	/**
	 * Just a helper method for some frame adjusting.
	 * Try to not use it, since it may cause memory leaks.
	 *
	 * @param   border   Amount to clip from frame
	 * @return  Clipped frame
	 */
	public function setBorderTo(border:FlxPoint, ?frameToFill:FlxFrame):FlxFrame
	{
		final rect = FlxRect.get(border.x, border.y, sourceSize.x - 2 * border.x, sourceSize.y - 2 * border.y);
		frameToFill = this.subFrameTo(rect, frameToFill);
		frameToFill.name = name;
		FlxDestroyUtil.put(rect);
		return frameToFill;
	}

	/**
	 * Frame clipping
	 *
	 * @param   clip           Clipping rectangle to apply on frame
	 * @param   clippedFrame   The frame which will contain result of original frame clipping.
	 *                         If `null`, a new frame will be created.
	 * @return  Result of applying frame clipping
	 */
	public function clipTo(rect:FlxRect, ?clippedFrame:FlxFrame):FlxFrame
	{
		if (clippedFrame == null)
			clippedFrame = new FlxFrame(parent, angle);

		copyTo(clippedFrame);
		return clippedFrame.clip(rect);
	}
	
	/**
	 * Whether there is any overlap between this frame and the given rect. If clipping this frame to
	 * the given rect would result in an empty frame, the result is `false`
	 * @since 6.1.0
	 */
	public function overlaps(rect:FlxRect)
	{
		rect.x += frame.x - offset.x;
		rect.y += frame.y - offset.y;
		final result = rect.overlaps(frame);
		rect.x -= frame.x - offset.x;
		rect.y -= frame.y - offset.y;
		return result;
	}
	
	
	/**
	 * Whether this frame fully contains the given rect. If clipping this frame to
	 * the given rect would result in a smaller frame, the result is `false`
	 * @since 6.1.0
	 */
	public function contains(rect:FlxRect)
	{
		rect.x += frame.x - offset.x;
		rect.y += frame.y - offset.y;
		final result = frame.contains(rect);
		rect.x -= frame.x - offset.x;
		rect.y -= frame.y - offset.y;
		return result;
	}
	
	/**
	 * Whether this frame is fully contained by the given rect. If clipping this frame to
	 * the given rect would result in a smaller frame, the result is `false`
	 * @since 6.1.0
	 */
	public function isContained(rect:FlxRect)
	{
		rect.x += frame.x - offset.x;
		rect.y += frame.y - offset.y;
		final result = rect.contains(frame);
		rect.x -= frame.x - offset.x;
		rect.y -= frame.y - offset.y;
		return result;
	}
	
	/**
	 * Clips this frame to the desired rect
	 *
	 * @param   rect  Clipping rectangle to apply
	 */
	public function clip(rect:FlxRect)
	{
		// no need to make all calculations if original frame is empty...
		if (type == FlxFrameType.EMPTY)
			return this;
		
		final clippedRect = FlxRect.get(0, 0, frame.width, frame.height);
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			clippedRect.width = frame.height;
			clippedRect.height = frame.width;
		}
		
		rect.offset(-offset.x, -offset.y);
		final frameRect:FlxRect = clippedRect.intersection(rect);
		rect.offset(offset.x, offset.y);
		clippedRect.put();
		
		if (frameRect.isEmpty)
		{
			type = FlxFrameType.EMPTY;
			frame.set(0, 0, 0, 0);
			offset.set(0, 0);
		}
		else
		{
			type = FlxFrameType.REGULAR;
			offset.add(frameRect.x, frameRect.y);
			
			if (angle != FlxFrameAngle.ANGLE_0)
			{
				final p1 = FlxPoint.weak(frameRect.x, frameRect.y);
				final p2 = FlxPoint.weak(frameRect.right, frameRect.bottom);
				
				_matrix.identity();
				
				if (angle == FlxFrameAngle.ANGLE_NEG_90)
				{
					_matrix.rotateByPositive90();
					_matrix.translate(frame.width, 0);
				}
				else if (angle == FlxFrameAngle.ANGLE_90)
				{
					_matrix.rotateByNegative90();
					_matrix.translate(0, frame.height);
				}
				
				p1.transform(_matrix);
				p2.transform(_matrix);
				frameRect.fromTwoPoints(p1, p2);
			}
			
			frameRect.offset(frame.x, frame.y);
			frame.copyFrom(frameRect);
			cacheFrameMatrix();
		}
		
		updateUV();
		
		frameRect.put();
		return this;
	}

	/**
	 * Copies data from this frame into specified frame.
	 *
	 * @param   clone   Frame to fill data with. If `null`, a new frame will be created.
	 * @return  Frame with data of this frame.
	 */
	public function copyTo(?clone:FlxFrame):FlxFrame
	{
		if (clone == null)
		{
			clone = new FlxFrame(parent, angle);
		}
		else
		{
			clone.parent = parent;
			clone.angle = angle;
			clone.frame = FlxDestroyUtil.put(clone.frame);
		}

		clone.offset.copyFrom(offset);
		clone.flipX = flipX;
		clone.flipY = flipY;
		clone.sourceSize.copyFrom(sourceSize);
		clone.frame = FlxRect.get().copyFrom(frame);
		clone.type = type;
		clone.name = name;
		clone.duration = duration;
		clone.cacheFrameMatrix();
		return clone;
	}

	public function destroy():Void
	{
		name = null;
		parent = null;
		sourceSize = FlxDestroyUtil.put(sourceSize);
		offset = FlxDestroyUtil.put(offset);
		frame = FlxDestroyUtil.put(frame);
		uv = FlxDestroyUtil.put(uv);
		blitMatrix = null;
		tileMatrix = null;
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("name", name)]);
	}

	function set_frame(value:FlxRect):FlxRect
	{
		frame = value;
		updateUV();
		
		return value;
	}
	
	function updateUV()
	{
		if (frame == null)
			return;
		
		if (uv == null)
			uv = FlxUVRect.get();

		uv.setFromFrameRect(frame, parent);
	}
}

/**
 * Just enumeration of all types of frames.
 * Added for faster type detection with less usage of casting.
 */
enum abstract FlxFrameType(Int)
{
	var REGULAR = 0;
	var EMPTY = 2;
	var GLYPH = 3;
}

enum abstract FlxFrameAngle(Int) from Int to Int
{
	var ANGLE_0 = 0;
	var ANGLE_90 = 90;
	var ANGLE_NEG_90 = -90;
	var ANGLE_270 = -90;
}

/**
 * FlxRect, but instead of `x`, `y`, `width` and `height`, it takes a `left`, `right`, `top` and
 * `bottom`. This is for optimization reasons, to reduce arithmetic when drawing vertices
 */
@:forward(put)
abstract FlxUVRect(FlxRect) from FlxRect to flixel.util.FlxPool.IFlxPooled
{
	public var left(get, set):Float;
	inline function get_left():Float { return this.x; }
	inline function set_left(value):Float { return this.x = value; }
	
	/** Top */
	public var right(get, set):Float;
	inline function get_right():Float { return this.width; }
	inline function set_right(value):Float { return this.width = value; }
	
	/** Right */
	public var top(get, set):Float;
	inline function get_top():Float { return this.y; }
	inline function set_top(value):Float { return this.y = value; }
	
	/** Bottom */
	public var bottom(get, set):Float;
	inline function get_bottom():Float { return this.height; }
	inline function set_bottom(value):Float { return this.height = value; }
	
	public inline function set(l, t, r, b)
	{
		this.set(l, t, r, b);
	}
	
	public inline function setFromFrameRect(frame:FlxRect, parent:FlxGraphic)
	{
		this.set(frame.x / parent.width, frame.y / parent.height, frame.right / parent.width, frame.bottom / parent.height);
	}
	
	public inline function copyTo(uv:FlxUVRect)
	{
		uv.set(left, top, right, bottom);
	}
	
	public inline function copyFrom(uv:FlxUVRect)
	{
		set(uv.left, uv.top, uv.right, uv.bottom);
	}
	
	public inline function toString()
	{
		return return FlxStringUtil.getDebugString([
			LabelValuePair.weak("l", left),
			LabelValuePair.weak("t", top),
			LabelValuePair.weak("r", right),
			LabelValuePair.weak("b", bottom)
		]);
	}
	
	public static function get(l = 0.0, t = 0.0, r = 0.0, b = 0.0)
	{
		return FlxRect.get(l, t, r, b);
	}
}

/**
 * Used internally instead of a FlxMatrix, for some unknown reason.
 * Perhaps improves performance, tbh, I'm skeptical
 */
abstract MatrixVector(Vector<Float>)
{
	public var a(get, set):Float;
	inline function get_a() return this[0];
	inline function set_a(value:Float) return this[0] = value;
	
	public var b(get, set):Float;
	inline function get_b() return this[1];
	inline function set_b(value:Float) return this[1] = value;
	
	public var c(get, set):Float;
	inline function get_c() return this[2];
	inline function set_c(value:Float) return this[2] = value;
	
	public var d(get, set):Float;
	inline function get_d() return this[3];
	inline function set_d(value:Float) return this[3] = value;
	
	public var tx(get, set):Float;
	inline function get_tx() return this[4];
	inline function set_tx(value:Float) return this[4] = value;
	
	public var ty(get, set):Float;
	inline function get_ty() return this[5];
	inline function set_ty(value:Float) return this[5] = value;
	
	
	public inline function new ()
	{
		this = new Vector<Float>(6);
		identity();
	}
	
	public inline function identity()
	{
		a = 1;
		b = 0;
		c = 0;
		d = 1;
		tx = 0;
		ty = 0;
	}
	
	public #if !hl inline #end function set(a = 1.0, b = 0.0, c = 0.0, d = 1.0, tx = 0.0, ty = 0.0)
	{
		set_a(a);
		set_b(b);
		set_c(c);
		set_d(d);
		set_tx(tx);
		set_ty(ty);
		return this;
	}
	
	public inline function translate(dx:Float, dy:Float)
	{
		tx += dx;
		ty += dy;
		return this;
	}
	
	public inline function scale(sx:Float, sy:Float)
	{
		a *= sx;
		b *= sy;
		c *= sx;
		d *= sy;
		tx *= sx;
		ty *= sy;
		return this;
	}
	
	overload public inline extern function copyFrom(frame:FlxFrame, forBlit = true):MatrixVector
	{
		identity();

		if (forBlit)
			translate(-frame.frame.x, -frame.frame.y);

		if (frame.angle == FlxFrameAngle.ANGLE_90)
		{
			set(-b, a, -d, c, -ty, tx);
			translate(frame.frame.height, 0);
		}
		else if (frame.angle == FlxFrameAngle.ANGLE_NEG_90)
		{
			set(b, -a, d, -c, ty, -tx);
			translate(0, frame.frame.width);
		}

		translate(frame.offset.x, frame.offset.y);
		return cast this;
	}
	
	overload public inline extern function copyFrom(mat:FlxMatrix):MatrixVector
	{
		a = mat.a;
		b = mat.b;
		c = mat.c;
		d = mat.d;
		tx = mat.tx;
		ty = mat.ty;
		return cast this;
	}
	
	public inline function copyTo(mat:FlxMatrix):FlxMatrix
	{
		mat.a = a;
		mat.b = b;
		mat.c = c;
		mat.d = d;
		mat.tx = tx;
		mat.ty = ty;
		return mat;
	}
}
