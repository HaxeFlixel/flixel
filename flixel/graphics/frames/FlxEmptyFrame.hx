package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.geom.Rectangle;

/**
 * Empty frame, doing a lot less stuff than regular frame.
 * Usefull for tilemaps (and possibly other classes, which have similar rendering methods).
 */
class FlxEmptyFrame extends FlxFrame
{
	public function new(parent:FlxGraphic) 
	{
		super(parent);
		type = FlxFrameType.EMPTY;
		#if FLX_RENDER_TILE
		tileID = -1;
		#end
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
			return new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		var rect:Rectangle = FlxRect.rect;
		rect.setTo(0, 0, result.width, result.height);
		bmd.fillRect(rect, FlxColor.TRANSPARENT);
		
		return result;
	}
	
	override public function getHReversedBitmap():BitmapData 
	{
		return getBitmap();
	}
	
	override public function getVReversedBitmap():BitmapData 
	{
		return getBitmap();
	}
	
	override public function getHVReversedBitmap():BitmapData 
	{
		return getBitmap();
	}
}