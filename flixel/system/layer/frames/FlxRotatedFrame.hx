package flixel.system.layer.frames;

import flash.display.BitmapData;
import flixel.util.FlxAngle;
import flixel.util.FlxColor;

class FlxRotatedFrame extends FlxFrame
{
	public function new(tileSheet:TileSheetData) 
	{
		super(tileSheet);
		
		type = FrameType.ROTATED;
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
		FlxFrame.POINT.x = FlxFrame.POINT.y = 0;
		temp.copyPixels(_tileSheet.bitmap, frame, FlxFrame.POINT);
		
		FlxFrame.MATRIX.identity();
		FlxFrame.MATRIX.translate( -0.5 * frame.width, -0.5 * frame.height);
		FlxFrame.MATRIX.rotate(-90.0 * FlxAngle.TO_RAD);
		FlxFrame.MATRIX.translate(offset.x + 0.5 * frame.height, offset.y + 0.5 * frame.width);
		
		result = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		result.draw(temp, FlxFrame.MATRIX);
		temp.dispose();
		
		return result;
	}
}