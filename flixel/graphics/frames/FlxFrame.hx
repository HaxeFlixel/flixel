package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;
import haxe.ds.ArraySort;
import haxe.ds.Vector;

/**
 * Base class for all frame types
 */
class FlxFrame implements IFlxDestroyable
{
	var point1:Point = new Point();
	var point2:Point = new Point();
	var rect:Rectangle = new Rectangle();
	var matrix:FlxMatrix = new FlxMatrix();

	/**
	 * Sorts an array of `FlxFrame` objects by their name, e.g.
	 * `["tiles-001.png", "tiles-003.png", "tiles-002.png"]`
	 * with `"tiles-".length == prefixLength` and `".png".length == postfixLength`.
	 */
	public static function sort(frames:Array<FlxFrame>, prefixLength:Int, postfixLength:Int):Void
	{
		ArraySort.sort(frames, sortByName.bind(_, _, prefixLength, postfixLength));
	}

	public static function sortByName(frame1:FlxFrame, frame2:FlxFrame, prefixLength:Int, postfixLength:Int):Int
	{
		var name1:String = frame1.name;
		var name2:String = frame2.name;
		var num1:Null<Int> = Std.parseInt(name1.substring(prefixLength, name1.length - postfixLength));
		var num2:Null<Int> = Std.parseInt(name2.substring(prefixLength, name2.length - postfixLength));
		if (num1 == null)
			num1 = 0;
		if (num2 == null)
			num2 = 0;

		return num1 - num2;
	}

	public var name:String;

	/**
	 * Region of the image to render.
	 */
	public var frame(default, set):FlxRect;

	/**
	 * UV coordinates for this frame.
	 * WARNING: For optimization purposes, width and height of this rect
	 * contain right and bottom coordinates (`x + width` and `y + height`).
	 */
	public var uv:FlxRect;

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

	var tileMatrix:Vector<Float>;

	var blitMatrix:Vector<Float>;

	@:allow(flixel.graphics.FlxGraphic)
	@:allow(flixel.graphics.frames.FlxFramesCollection)
	function new(parent:FlxGraphic, angle = FlxFrameAngle.ANGLE_0, flipX = false, flipY = false, duration = 0.0)
	{
		this.parent = parent;
		this.angle = angle;
		this.flipX = flipX;
		this.flipY = flipY;
		this.duration = duration;

		type = FlxFrameType.REGULAR;

		sourceSize = FlxPoint.get();
		offset = FlxPoint.get();

		blitMatrix = new Vector<Float>(6);
		if (FlxG.renderTile)
			tileMatrix = new Vector<Float>(6);
	}

	@:allow(flixel.graphics.frames.FlxFramesCollection)
	@:allow(flixel.graphics.frames.FlxBitmapFont)
	function cacheFrameMatrix():Void
	{
		prepareBlitMatrix(matrix, true);
		blitMatrix[0] = matrix.a;
		blitMatrix[1] = matrix.b;
		blitMatrix[2] = matrix.c;
		blitMatrix[3] = matrix.d;
		blitMatrix[4] = matrix.tx;
		blitMatrix[5] = matrix.ty;

		if (FlxG.renderTile)
		{
			prepareBlitMatrix(matrix, false);
			tileMatrix[0] = matrix.a;
			tileMatrix[1] = matrix.b;
			tileMatrix[2] = matrix.c;
			tileMatrix[3] = matrix.d;
			tileMatrix[4] = matrix.tx;
			tileMatrix[5] = matrix.ty;
		}
	}

	/**
	 * Applies frame rotation to the specified matrix, which should be used for tiling or blitting.
	 * Required for rotated frame support.
	 *
	 * @param   mat    Matrix to transform / rotate
	 * @param   blit   Whether specified matrix will be used for blitting or for tile rendering.
	 * @return  Transformed matrix.
	 */
	inline function prepareBlitMatrix(mat:FlxMatrix, blit:Bool = true):FlxMatrix
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
	 * Rotates and flips matrix. This method expects matrix which was prepared by `prepareBlitMatrix()`.
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
		mat = fillBlitMatrix(mat);
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

		mat.a = tileMatrix[0];
		mat.b = tileMatrix[1];
		mat.c = tileMatrix[2];
		mat.d = tileMatrix[3];
		mat.tx = tileMatrix[4];
		mat.ty = tileMatrix[5];

		var doFlipX = flipX != this.flipX;
		var doFlipY = flipY != this.flipY;

		if (rotation == FlxFrameAngle.ANGLE_0 && !doFlipX && !doFlipY)
			return mat;

		return rotateAndFlip(mat, rotation, doFlipX, doFlipY);
	}

	inline function fillBlitMatrix(mat:FlxMatrix):FlxMatrix
	{
		mat.a = blitMatrix[0];
		mat.b = blitMatrix[1];
		mat.c = blitMatrix[2];
		mat.d = blitMatrix[3];
		mat.tx = blitMatrix[4];
		mat.ty = blitMatrix[5];
		return mat;
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
	public function paint(?bmd:BitmapData, ?point:Point, mergeAlpha:Bool = false, disposeIfNotEqual:Bool = false):BitmapData
	{
		if (point == null)
		{
			point = point1;
			point.setTo(0, 0);
		}

		bmd = checkInputBitmap(bmd, point, FlxFrameAngle.ANGLE_0, mergeAlpha, disposeIfNotEqual);

		if (type == FlxFrameType.EMPTY)
			return bmd;

		if (angle == FlxFrameAngle.ANGLE_0)
		{
			offset.copyToFlash(point2);
			point2.x += point.x;
			point2.y += point.y;
			bmd.copyPixels(parent.bitmap, frame.copyToFlash(rect), point2, null, null, mergeAlpha);
		}
		else
		{
			fillBlitMatrix(matrix);
			matrix.translate(point.x, point.y);
			var rect:Rectangle = getDrawFrameRect(matrix);
			bmd.draw(parent.bitmap, matrix, null, null, rect);
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

		if (point == null)
		{
			point = point2;
			point.setTo(0, 0);
		}

		bmd = checkInputBitmap(bmd, point, rotation, mergeAlpha, disposeIfNotEqual);

		if (type == FlxFrameType.EMPTY)
			return bmd;

		var doFlipX = flipX != this.flipX;
		var doFlipY = flipY != this.flipY;

		prepareTransformedBlitMatrix(matrix, rotation, doFlipX, doFlipY);
		matrix.translate(point.x, point.y);
		var rect:Rectangle = getDrawFrameRect(matrix);
		bmd.draw(parent.bitmap, matrix, null, null, rect);
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
	inline function checkInputBitmap(?bmd:BitmapData, ?point:Point, rotation:FlxFrameAngle = FlxFrameAngle.ANGLE_0, mergeAlpha:Bool = false,
			disposeIfNotEqual:Bool = false):BitmapData
	{
		var w:Int = Std.int(sourceSize.x);
		var h:Int = Std.int(sourceSize.y);

		if (rotation != FlxFrameAngle.ANGLE_0)
		{
			var t:Int = w;
			w = h;
			h = t;
		}

		if (bmd != null && disposeIfNotEqual)
			bmd = FlxDestroyUtil.disposeIfNotEqual(bmd, w, h);

		if (bmd != null && !mergeAlpha)
		{
			rect.setTo(point.x, point.y, w, h);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
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
	 * @return  Clipping rectangle which will be used for frame blitting.
	 */
	inline function getDrawFrameRect(mat:FlxMatrix):Rectangle
	{
		var p1:FlxPoint = FlxPoint.weak(frame.x, frame.y);
		var p2:FlxPoint = FlxPoint.weak(frame.right, frame.bottom);

		p1.transform(mat);
		p2.transform(mat);

		var flxRect = FlxRect.get().fromTwoPoints(p1, p2);
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
			frameToFill.offset.set(frameRect.x, frameRect.y).subtract(rect.x, rect.y).addPoint(offset);

			var p1 = FlxPoint.weak(frameRect.x, frameRect.y);
			var p2 = FlxPoint.weak(frameRect.right, frameRect.bottom);

			matrix.identity();

			if (angle == FlxFrameAngle.ANGLE_NEG_90)
			{
				matrix.rotateByPositive90();
				matrix.translate(frame.width, 0);
			}
			else if (angle == FlxFrameAngle.ANGLE_90)
			{
				matrix.rotateByNegative90();
				matrix.translate(0, frame.height);
			}

			if (angle != FlxFrameAngle.ANGLE_0)
			{
				p1.transform(matrix);
				p2.transform(matrix);
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
		var rect = FlxRect.get(border.x, border.y, sourceSize.x - 2 * border.x, sourceSize.y - 2 * border.y);
		frameToFill = this.subFrameTo(rect, frameToFill);
		frameToFill.name = name;
		rect = FlxDestroyUtil.put(rect);
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
	public function clipTo(clip:FlxRect, ?clippedFrame:FlxFrame):FlxFrame
	{
		if (clippedFrame == null)
		{
			clippedFrame = new FlxFrame(parent, angle);
		}
		else
		{
			clippedFrame.parent = parent;
			clippedFrame.angle = angle;
			clippedFrame.frame = FlxDestroyUtil.put(clippedFrame.frame);
		}

		clippedFrame.sourceSize.copyFrom(sourceSize);
		clippedFrame.name = name;

		// no need to make all calculations if original frame is empty...
		if (type == FlxFrameType.EMPTY)
		{
			clippedFrame.type = FlxFrameType.EMPTY;
			clippedFrame.offset.set(0, 0);
			return clippedFrame;
		}

		var clippedRect:FlxRect = FlxRect.get(0, 0).setSize(frame.width, frame.height);
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			clippedRect.width = frame.height;
			clippedRect.height = frame.width;
		}

		clip.offset(-offset.x, -offset.y);
		var frameRect:FlxRect = clippedRect.intersection(clip);
		clippedRect = FlxDestroyUtil.put(clippedRect);

		if (frameRect.isEmpty)
		{
			clippedFrame.type = FlxFrameType.EMPTY;
			frameRect.set(0, 0, 0, 0);
			clippedFrame.frame = frameRect;
			clippedFrame.offset.set(0, 0);
		}
		else
		{
			clippedFrame.type = FlxFrameType.REGULAR;
			clippedFrame.offset.set(frameRect.x, frameRect.y).addPoint(offset);

			var p1 = FlxPoint.weak(frameRect.x, frameRect.y);
			var p2 = FlxPoint.weak(frameRect.right, frameRect.bottom);

			matrix.identity();

			if (angle == FlxFrameAngle.ANGLE_NEG_90)
			{
				matrix.rotateByPositive90();
				matrix.translate(frame.width, 0);
			}
			else if (angle == FlxFrameAngle.ANGLE_90)
			{
				matrix.rotateByNegative90();
				matrix.translate(0, frame.height);
			}

			if (angle != FlxFrameAngle.ANGLE_0)
			{
				p1.transform(matrix);
				p2.transform(matrix);
			}

			frameRect.fromTwoPoints(p1, p2);
			frameRect.offset(frame.x, frame.y);
			clippedFrame.frame = frameRect;
			clippedFrame.cacheFrameMatrix();
		}

		clip.offset(offset.x, offset.y);
		return clippedFrame;
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
		if (value != null)
		{
			if (uv == null)
				uv = FlxRect.get();

			uv.set(value.x / parent.width, value.y / parent.height, value.right / parent.width, value.bottom / parent.height);
		}

		return frame = value;
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
