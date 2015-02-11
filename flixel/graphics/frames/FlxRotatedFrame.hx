package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.math.FlxMatrix;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

/**
 * Rotated frame. It uses more math for rendering, that's why it has been moved in separate class.
 */
class FlxRotatedFrame extends FlxFrame
{
	@:allow(flixel)
	private function new(parent:FlxGraphic, angle:Int) 
	{
		super(parent);
		type = FlxFrameType.ROTATED;
		this.angle = angle;
	}
	
	/**
	 * Appends additional rotation (if required) to the sprite matrix.
	 * 
	 * @param	mat		Sprite matrix to transform.
	 * @return	Tranformed sprite matrix.
	 */
	#if FLX_RENDER_TILE
	override public function prepareFrameMatrix(mat:FlxMatrix):FlxMatrix 
	{
		mat.identity();
		
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
	#end
	
	override public function paintOnBitmap(bmd:BitmapData = null):BitmapData 
	{
		var result:BitmapData = null;
		
		if (bmd != null && (bmd.width == sourceSize.x && bmd.height == sourceSize.y))
		{
			result = bmd;
			FlxRect.rect.setTo(0, 0, sourceSize.x, sourceSize.y);
			result.fillRect(FlxRect.rect, FlxColor.TRANSPARENT);
		}
		else if (bmd != null)
		{
			bmd.dispose();
		}
		
		if (result == null)
		{
			result = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		var matrix:Matrix = FlxMatrix.matrix;
		matrix.identity();
		matrix.translate( -(frame.x + 0.5 * frame.width), -(frame.y + 0.5 * frame.height));
		matrix.rotate(angle * FlxAngle.TO_RAD);
		matrix.translate(offset.x + 0.5 * frame.height, offset.y + 0.5 * frame.width);
		FlxRect.rect.setTo(offset.x, offset.y, frame.height, frame.width);
		result.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		return result;
	}
	
	override public function paintFlipped(bmd:BitmapData = null, flipX:Bool = false, flipY:Bool = false):BitmapData
	{
		var result:BitmapData = null;
		
		if (bmd != null && (bmd.width == sourceSize.x && bmd.height == sourceSize.y))
		{
			result = bmd;
			
			var w:Int = bmd.width;
			var h:Int = bmd.height;
			
			if (w > frame.width || h > frame.height)
			{
				var rect:Rectangle = FlxRect.rect;
				rect.setTo(0, 0, w, h);
				bmd.fillRect(rect, FlxColor.TRANSPARENT);
			}
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
		
		// TODO: test this method...
		
		var matrix:Matrix = FlxMatrix.matrix;
		matrix.identity();
		matrix.translate( -(frame.x + 0.5 * frame.height), -(frame.y + 0.5 * frame.width));
		matrix.rotate(angle * FlxAngle.TO_RAD);
		matrix.scale(scaleX, scaleY);
		
		if (flipX)
		{
			matrix.translate(sourceSize.x - offset.x - 0.5 * frame.height, 0);
			FlxRect.rect.x = sourceSize.x - offset.x - frame.height;
		}
		else
		{
			matrix.translate(offset.x + 0.5 * frame.height, 0);
			FlxRect.rect.x = offset.x;
		}
		
		if (flipY)
		{
			matrix.translate(0, sourceSize.y - offset.y - 0.5 * frame.width);
			FlxRect.rect.y = sourceSize.y - offset.y - frame.width;
		}
		else
		{
			matrix.translate(0, offset.y + 0.5 * frame.width);
			FlxRect.rect.y = offset.y;
		}
		
		FlxRect.rect.width = frame.height;
		FlxRect.rect.height = frame.width;
		
		result.draw(parent.bitmap, matrix, null, null, FlxRect.rect);
		return result;
	}
}