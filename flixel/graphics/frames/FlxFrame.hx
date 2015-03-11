package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxStringUtil;

/**
 * Base class for all frame types
 */
class FlxFrame implements IFlxDestroyable
{
	/**
	 * Sorting function for Array<FlxFrame>#sort(),
	 * e.g. "tiles-001.png", "tiles-003.png", "tiles-002.png".
	 */
	public static function sortByName(frame1:FlxFrame, frame2:FlxFrame, prefixLength:Int, postfixLength:Int):Int
	{
		var name1:String = frame1.name;
		var name2:String = frame2.name;
		
		var num1:Int = Std.parseInt(name1.substring(prefixLength, name1.length - postfixLength));
		var num2:Int = Std.parseInt(name2.substring(prefixLength, name2.length - postfixLength));
		
		return num1 - num2;
	}
	
	/**
	 * Frame clipping
	 * @param	original		Original frame to clip
	 * @param	clip			Clipping rectangle to apply on frame
	 * @param	clippedFrame	The frame which will contain result of original frame clipping. If null then new frame will be created.
	 * @return	Result of applying frame clipping
	 */
	public static function clipTo(original:FlxFrame, clip:FlxRect, clippedFrame:FlxFrame = null):FlxFrame
	{
		// TODO: maybe rewrite it...
		
		var angle:FlxFrameAngle = original.angle;
		
		if (clippedFrame == null)
		{
			clippedFrame = new FlxFrame(original.parent, angle);
		}
		else
		{
			clippedFrame.parent = original.parent;
			clippedFrame.angle = angle;
			clippedFrame.frame = FlxDestroyUtil.put(clippedFrame.frame);
			clippedFrame.uv = FlxDestroyUtil.put(clippedFrame.uv);
		}
		
		clippedFrame.sourceSize.copyFrom(original.sourceSize);
		
		// no need to make all calculations if original frame is empty...
		if (original.type == FlxFrameType.EMPTY)
		{
			clippedFrame.type = FlxFrameType.EMPTY;
			clippedFrame.offset.set(0, 0);
			return clippedFrame;
		}
		
		var helperRect:FlxRect = FlxRect.get(0, 0, original.sourceSize.x, original.sourceSize.y);
		var clippedRect1:FlxRect = FlxRect.get(original.offset.x, original.offset.y, original.frame.width, original.frame.height);
		
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			clippedRect1.width = original.frame.height;
			clippedRect1.height = original.frame.width;
		}
		
		var clippedRect2:FlxRect = clippedRect1.intersection(clip);		
		var frameRect:FlxRect = clippedRect2.intersection(helperRect);
		
		if (frameRect.width == 0 || frameRect.height == 0 || 
				clippedRect2.width == 0 || clippedRect2.height == 0)
		{
			clippedFrame.type = FlxFrameType.EMPTY;
			frameRect.set(0, 0, 0, 0);
			clippedFrame.frame = frameRect;
			clippedFrame.offset.set(0, 0);
		}
		else
		{
			clippedFrame.type = FlxFrameType.REGULAR;
			clippedFrame.offset.set(clippedRect2.x, clippedRect2.y);
			
			var x:Float = frameRect.x;
			var y:Float = frameRect.y;
			var w:Float = frameRect.width;
			var h:Float = frameRect.height;
			
			if (angle == FlxFrameAngle.ANGLE_0)
			{
				frameRect.x -= clippedRect1.x;
				frameRect.y -= clippedRect1.y;
			}
			else if (angle == FlxFrameAngle.ANGLE_NEG_90)
			{
				frameRect.x = clippedRect1.bottom - y - h;
				frameRect.y = x - clippedRect1.x;
				frameRect.width = h;
				frameRect.height = w;
			}
			else if (angle == FlxFrameAngle.ANGLE_90)
			{
				frameRect.x = y - clippedRect1.y;
				frameRect.y = clippedRect1.right - x - w;
				frameRect.width = h;
				frameRect.height = w;
			}
			
			frameRect.x += original.frame.x;
			frameRect.y += original.frame.y;
			
			clippedFrame.frame = frameRect;
		}
		
		helperRect.put();
		clippedRect1.put();
		clippedRect2.put();
		
		return clippedFrame;
	}
	
	public var name:String;
	/**
	 * Region of image to render
	 */
	public var frame(default, set):FlxRect;
	
	public var uv:FlxRect;
	
	public var parent:FlxGraphic;
	
	/**
	 * Rotation angle of this frame. 
	 * Required for packed atlas images.
	 */
	public var angle:FlxFrameAngle;
	
	/**
	 * Original (uncropped) image size.
	 */
	public var sourceSize(default, null):FlxPoint;
	/**
	 * Frame offset from top left corner of original image.
	 */
	public var offset(default, null):FlxPoint;
	
	/**
	 * The type of this frame.
	 */
	public var type:FlxFrameType;
	
	@:allow(flixel)
	private function new(parent:FlxGraphic, angle:Int = 0)
	{
		this.parent = parent;
		this.angle = angle;
		type = FlxFrameType.REGULAR;
		
		sourceSize = FlxPoint.get();
		offset = FlxPoint.get();
	}
	
	/**
	 * Transforms specified matrix for further rendering.
	 * Required for rotated frame support.
	 * 
	 * @param	mat	Matrix to transform / rotate
	 * @return	Transformed matrix.
	 */
	public function prepareFrameMatrix(mat:FlxMatrix):FlxMatrix
	{
		mat.identity();
		#if FLX_RENDER_TILE
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
		#end
		return mat;
	}
	
	/**
	 * Draws frame on specified BitmapData object.
	 * 
	 * @param	bmd			BitmapData object to draw this frame on. If bmd is null then new BitmapData created
	 * @param	point		Where to draw this frame on specified BitmapData object
	 * @param	mergeAlpha	Whether to merge alphas or not (works like with BitmapData's copyPixels() method). Default value is false
	 * @return	Modified or newly created BitmapData with frame image on it
	 */
	public function paint(bmd:BitmapData = null, point:Point = null, mergeAlpha:Bool = false):BitmapData
	{
		if (point == null)
		{
			point = FlxPoint.point1;
			point.setTo(0, 0);
		}
		
		if (bmd != null && !mergeAlpha)
		{
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(point.x, point.y, sourceSize.x, sourceSize.y);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		else if (bmd == null)
		{
			bmd = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		if (type == FlxFrameType.EMPTY)
		{
			return bmd;
		}
		
		if (angle == FlxFrameAngle.ANGLE_0)
		{
			offset.copyToFlash(FlxPoint.point2);
			FlxPoint.point2.x += point.x;
			FlxPoint.point2.y += point.y;
			bmd.copyPixels(parent.bitmap, frame.copyToFlash(FlxRect.rect), FlxPoint.point2, null, null, mergeAlpha);
		}
		else
		{
			var matrix:Matrix = FlxMatrix.matrix;
			matrix.identity();
			matrix.translate( -(frame.x + 0.5 * frame.width), -(frame.y + 0.5 * frame.height));
			matrix.rotate(angle * FlxAngle.TO_RAD);
			matrix.translate(offset.x + point.x + 0.5 * frame.height, offset.y + point.y + 0.5 * frame.width);
			FlxRect.rect.setTo(offset.x + point.x, offset.y + point.y, frame.height, frame.width);
			bmd.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		}
		
		return bmd;
	}
	
	/**
	 * Draws flipped frame on specified BitmapData object.
	 * 
	 * @param	bmd			BitmapData object to draw this frame on. If bmd is null then new BitmapData created
	 * @param	point		Where to draw this frame on specified BitmapData object
	 * @param	flipX		Do we need to flip frame horizontally
	 * @param	flipY		Do we need to flip frame vertically
	 * @param	mergeAlpha	Whether to merge alphas or not (works like with BitmapData's copyPixels() method). Default value is false
	 * @return	Modified or newly created BitmapData with frame image on it
	 */
	public function paintFlipped(bmd:BitmapData = null, point:Point = null, flipX:Bool = false, flipY:Bool = false, mergeAlpha:Bool = false):BitmapData
	{
		// TODO: maybe rewrite it...
		
		if (type == FlxFrameType.EMPTY)
		{
			return paint(bmd, point, mergeAlpha);
		}
		
		if (point == null)
		{
			point = FlxPoint.point2;
			point.setTo(0, 0);
		}
		
		if (bmd != null && !mergeAlpha)
		{
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(point.x, point.y, sourceSize.x, sourceSize.y);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		else if (bmd == null)
		{
			bmd = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		var w:Float = frame.width;
		var h:Float = frame.height;
		
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			w = frame.height;
			h = frame.width;
		}
		
		var matrix:FlxMatrix = FlxMatrix.matrix;
		matrix.identity();
		matrix.translate( -(frame.x + 0.5 * frame.width), -(frame.y + 0.5 * frame.height));
		
		if (angle == FlxFrameAngle.ANGLE_90)
		{
			matrix.rotateByPositive90();
		}
		else if (angle == FlxFrameAngle.ANGLE_NEG_90)
		{
			matrix.rotateByNegative90();
		}
		
		var scaleX:Int = flipX ? -1 : 1;
		var scaleY:Int = flipY ? -1 : 1;
		
		matrix.scale(scaleX, scaleY);
		
		if (flipX)
		{
			matrix.translate(sourceSize.x - offset.x - 0.5 * w, 0);
			FlxRect.rect.x = sourceSize.x - offset.x - w;
		}
		else
		{
			matrix.translate(offset.x + 0.5 * w, 0);
			FlxRect.rect.x = offset.x;
		}
		
		if (flipY)
		{
			matrix.translate(0, sourceSize.y - offset.y - 0.5 * h);
			FlxRect.rect.y = sourceSize.y - offset.y - h;
		}
		else
		{
			matrix.translate(0, offset.y + 0.5 * h);
			FlxRect.rect.y = offset.y;
		}
		
		matrix.translate(point.x, point.y);
		FlxRect.rect.x += point.x;
		FlxRect.rect.y += point.y;
		
		FlxRect.rect.width = w;
		FlxRect.rect.height = h;
		
		bmd.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		return bmd;
	}
	
	// TODO: implement it...
	/**
	 * Draws rotated and flipped frame on specified BitmapData object.
	 * 
	 * @param	bmd			BitmapData object to draw this frame on. If bmd is null then new BitmapData created
	 * @param	point		Where to draw this frame on specified BitmapData object
	 * @param	angle		How much rotate the frame. Works only with 0, 90 and -90 (or 270) values
	 * @param	flipX		Do we need to flip frame horizontally
	 * @param	flipY		Do we need to flip frame vertically
	 * @param	mergeAlpha	Whether to merge alphas or not (works like with BitmapData's copyPixels() method). Default value is false
	 * @return	Modified or newly created BitmapData with frame image on it
	 */
	public function paintRotatedAndFlipped(bmd:BitmapData = null, point:Point = null, rotation:FlxFrameAngle = 0, flipX:Bool = false, flipY:Bool = false, mergeAlpha:Bool = false):BitmapData
	{
		if (type == FlxFrameType.EMPTY)
		{
			return paint(bmd, point, mergeAlpha);
		}
		
		if (point == null)
		{
			point = FlxPoint.point2;
			point.setTo(0, 0);
		}
		
		var w:Int = Std.int(sourceSize.x);
		var h:Int = Std.int(sourceSize.y);
		
		if (rotation != FlxFrameAngle.ANGLE_0)
		{
			var t:Int = w;
			w = h;
			h = t;
		}
		
		if (bmd != null && !mergeAlpha)
		{
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(point.x, point.y, w, h);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		else if (bmd == null)
		{
			bmd = new BitmapData(w, h, true, FlxColor.TRANSPARENT);
		}
		
		var fw:Float = frame.width;
		var fh:Float = frame.height;
		
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			fw = frame.height;
			fh = frame.width;
		}
		
		var matrix:FlxMatrix = FlxMatrix.matrix;
		matrix.identity();
		matrix.translate( -(frame.x + 0.5 * frame.width), -(frame.y + 0.5 * frame.height));
		
		if (angle == FlxFrameAngle.ANGLE_90)
		{
			matrix.rotateByPositive90();
		}
		else if (angle == FlxFrameAngle.ANGLE_NEG_90)
		{
			matrix.rotateByNegative90();
		}
		
		if (rotation == FlxFrameAngle.ANGLE_90)
		{
			matrix.rotateByPositive90();
			// TODO: don't forget to apply additional translation...
		}
		else if (rotation == FlxFrameAngle.ANGLE_NEG_90)
		{
			matrix.rotateByNegative90();
			// TODO: don't forget to apply additional translation...
		}
		
		var scaleX:Int = flipX ? -1 : 1;
		var scaleY:Int = flipY ? -1 : 1;
		
		matrix.scale(scaleX, scaleY);
		
		// TODO: continue from here...
		/*
		if (flipX)
		{
			matrix.translate(sourceSize.x - offset.x - 0.5 * w, 0);
			FlxRect.rect.x = sourceSize.x - offset.x - w;
		}
		else
		{
			matrix.translate(offset.x + 0.5 * w, 0);
			FlxRect.rect.x = offset.x;
		}
		
		if (flipY)
		{
			matrix.translate(0, sourceSize.y - offset.y - 0.5 * h);
			FlxRect.rect.y = sourceSize.y - offset.y - h;
		}
		else
		{
			matrix.translate(0, offset.y + 0.5 * h);
			FlxRect.rect.y = offset.y;
		}
		
		matrix.translate(point.x, point.y);
		FlxRect.rect.x += point.x;
		FlxRect.rect.y += point.y;
		
		FlxRect.rect.width = w;
		FlxRect.rect.height = h;
		*/
		bmd.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		return bmd;
	}
	
	// TODO: implement it...
	/**
	 * Generates frame with specified subregion of this frame
	 * 
	 * @param	rect			frame region to generate frame for
	 * @param	frameToFill		frame to fill with data. If null then new frame will be created
	 * @return	Specified frameToFill object but filled with data
	 */
	public function subFrameTo(rect:FlxRect, frameToFill:FlxFrame = null):FlxFrame
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
		
		// TODO: continue from here...
		
		return frameToFill;
	}
	
	public function copyTo(clone:FlxFrame):FlxFrame
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
		clone.sourceSize.copyFrom(sourceSize);
		clone.frame = FlxRect.get().copyFrom(frame);
		clone.type = type;
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
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("name", name)]);
	}
	
	private function set_frame(value:FlxRect):FlxRect
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
@:enum
abstract FlxFrameType(Int) 
{
	var REGULAR		= 0;
	var EMPTY		= 2;
	var GLYPH		= 3;
}

@:enum
abstract FlxFrameAngle(Int) from Int to Int
{
	var ANGLE_0			= 0;
	var ANGLE_90		= 90;
	var ANGLE_NEG_90	= -90;
	var ANGLE_270		= -90;
}