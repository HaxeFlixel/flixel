package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;

/**
 * Just a special frame for handling bitmap fonts
 */
class GlyphFrame extends FlxFrame
{
	/**
	 * How much to jump after drawing this glyph.
	 */
	public var xAdvance:Int = 0;
	
	public function new(parent:FlxGraphic) 
	{
		super(parent);
		type = FrameType.GLYPH;
	}
	
	override public function paintOnBitmap(bmd:BitmapData = null):BitmapData
	{
		if (sourceSize.x == 0 || sourceSize.y == 0)
		{
			return null;
		}
		
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
		
		FlxPoint.POINT.setTo(0, 0);
		result.copyPixels(parent.bitmap, frame.copyToFlash(FlxRect.RECT), FlxPoint.POINT);
		
		return result;
	}
}