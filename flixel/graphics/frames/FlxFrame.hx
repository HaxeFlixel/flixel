package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
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
	
	public var name:String;
	/**
	 * Region of image to render
	 */
	public var frame:FlxRect;
	
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
	public var type(default, null):FlxFrameType;
	
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
	 * Draws frame on specified BitmapData object (all underlying pixels become unvisible).
	 * 
	 * @param	bmd	BitmapData object to draw this frame on. If bmd is null or doesn't have the same size as frame then new BitmapData created
	 * @return	Modified or newly created BitmapData with frame image on it
	 */
	// TODO: use point argument...
	// TODO: maybe add merge alpha argument...
	public function paintOnBitmap(bmd:BitmapData = null, point:Point = null):BitmapData
	{
		var result:BitmapData = null;
		
		if (bmd != null && (bmd.width >= sourceSize.x && bmd.height >= sourceSize.y))
		{
			result = bmd;
			
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(0, 0, sourceSize.x, sourceSize.y);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		else if (bmd != null)
		{
			bmd.dispose();
		}
		
		if (result == null)
		{
			result = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		if (angle == FlxFrameAngle.ANGLE_0)
		{
			offset.copyToFlash(FlxPoint.point);
			result.copyPixels(parent.bitmap, frame.copyToFlash(FlxRect.rect), FlxPoint.point);
		}
		else
		{
			var matrix:Matrix = FlxMatrix.matrix;
			matrix.identity();
			matrix.translate( -(frame.x + 0.5 * frame.width), -(frame.y + 0.5 * frame.height));
			matrix.rotate(angle * FlxAngle.TO_RAD);
			matrix.translate(offset.x + 0.5 * frame.height, offset.y + 0.5 * frame.width);
			FlxRect.rect.setTo(offset.x, offset.y, frame.height, frame.width);
			result.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		}
		
		return result;
	}
	
	// TODO: use point argument...
	// TODO: maybe add merge alpha argument...
	public function paintFlipped(bmd:BitmapData = null, point:Point = null, flipX:Bool = false, flipY:Bool = false):BitmapData
	{
		var result:BitmapData = null;
		
		if (bmd != null && (bmd.width >= sourceSize.x && bmd.height >= sourceSize.y))
		{
			result = bmd;
			
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(0, 0, sourceSize.x, sourceSize.y);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		else if (bmd != null)
		{
			bmd.dispose();
		}
		
		if (result == null)
		{
			result = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		var scaleX:Int = flipX ? -1 : 1;
		var scaleY:Int = flipY ? -1 : 1;
		
		var w:Float = frame.width;
		var h:Float = frame.height;
		
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			w = frame.height;
			h = frame.width;
		}
		
		// TODO: test this method...
		
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
		
		FlxRect.rect.width = w;
		FlxRect.rect.height = h;
		
		result.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		return result;
	}
	
	public function destroy():Void
	{
		name = null;
		frame = null;
		parent = null;
		sourceSize = FlxDestroyUtil.put(sourceSize);
		offset = FlxDestroyUtil.put(offset);
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("name", name)]);
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
}