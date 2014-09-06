package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.math.FlxMatrix;
import openfl.geom.Matrix;

/**
 * Rotated frame. It uses more math for rendering, that's why it has been moved in separate class.
 */
class FlxRotatedFrame extends FlxFrame
{
	public function new(parent:FlxGraphic) 
	{
		super(parent);
		type = FrameType.ROTATED;
	}
	
	/**
	 * Appends additional rotation (if required) to the sprite matrix.
	 * 
	 * @param	mat		Sprite matrix to transform.
	 * @return	Tranformed sprite matrix.
	 */
	override public function prepareFrameMatrix(mat:FlxMatrix):FlxMatrix 
	{
		if (angle == 90)
		{
			mat.rotateByPositive90();
		}
		else if (angle == -90)
		{
			mat.rotateByNegative90();
		}
		
		return mat;
	}
	
	override public function paintOnBitmap(bmd:BitmapData = null):BitmapData 
	{
		var result:BitmapData = null;
		
		if (bmd != null && (bmd.width == sourceSize.x && bmd.height == sourceSize.y))
		{
			result = bmd;
		}
		else if (bmd != null)
		{
			bmd.dispose();
		}
		
		if (result == null)
		{
			result = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		var temp:BitmapData = new BitmapData(Std.int(frame.width), Std.int(frame.height), true, FlxColor.TRANSPARENT);
		FlxPoint.POINT.setTo(0, 0);
		temp.copyPixels(parent.bitmap, frame.copyToFlash(FlxRect.RECT), FlxPoint.POINT);
		
		var matrix:Matrix = FlxMatrix.MATRIX;
		matrix.identity();
		matrix.translate( -0.5 * frame.width, -0.5 * frame.height);
		matrix.rotate(angle * FlxAngle.TO_RAD);
		matrix.translate(offset.x + 0.5 * frame.height, offset.y + 0.5 * frame.width);
		
		result.draw(temp, matrix);
		temp.dispose();
		return result;
	}
}