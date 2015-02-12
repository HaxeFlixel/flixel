package flixel.graphics.frames;

import flash.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Empty frame, doing a lot less stuff than regular frame.
 * useful for tilemaps (and possibly other classes, which have similar rendering methods).
 */
class FlxEmptyFrame extends FlxFrame
{
	@:allow(flixel)
	private function new(parent:FlxGraphic) 
	{
		super(parent);
		type = FlxFrameType.EMPTY;
	}
	
	override public function paint(bmd:BitmapData = null, point:Point = null, mergeAlpha:Bool = false):BitmapData 
	{
		if (point == null)
		{
			point = FlxPoint.point1;
			point.setTo(0, 0);
		}
		
		if (bmd == null)
		{
			return new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		else if (bmd != null && !mergeAlpha)
		{
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(point.x, point.y, sourceSize.x, sourceSize.y);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		
		return bmd;
	}
	
	override public function paintFlipped(bmd:BitmapData = null, point:Point = null, flipX:Bool = false, flipY:Bool = false, mergeAlpha:Bool = false):BitmapData 
	{
		return paint(bmd);
	}
}