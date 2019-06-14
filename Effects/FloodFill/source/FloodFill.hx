package;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * "Creates a flood fill effect FlxSprite, useful for bringing in images in cool ways"
 *
 * A HaxeFlixel port of Photonstorm's 'FloodFillFX':
 * https://github.com/photonstorm/Flixel-Power-Tools/blob/master/src/org/flixel/plugin/photonstorm/FX/FloodFillFX.as
 */
class FloodFill extends FlxSprite
{
	var complete:Bool = false;
	var dropRect:Rectangle;
	var dropPoint:Point;
	var dropY:Int;
	var srcBitmapData:BitmapData;
	var fillDelay:Float = .05;
	var fillClock:Float = 0;

	/**
	 * How many pixels to drop per update
	 */
	var fillOffset:Int = 1;

	/**
	 * @param x The effect's x-position.
	 * @param x The effect's y-position.
	 * @param srcBmd The image data used for the effect.
	 * @param width The width of the effect.
	 * @param height The height of the effect (a value larger than the source image makes the effect taller!).
	 * @param fillLinesPerUpdate Number of lines per update to fill the effect with.
	 * @param delayPerUpdate The time delay between each update.
	 */
	public function new(x:Float, y:Float, srcBmd:BitmapData, width:Int = 0, height:Int = 0, fillLinesPerUpdate:Int = 1, delayPerUpdate:Float = 0.05)
	{
		super(x, y);

		if ((width != 0 && width != srcBmd.width) || (height != 0 && height != srcBmd.height))
		{
			srcBitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
			srcBitmapData.copyPixels(srcBmd, new Rectangle(0, 0, srcBmd.width, srcBmd.height), new Point(0, height - srcBmd.height));
		}
		else
		{
			srcBitmapData = srcBmd;
		}

		makeGraphic(srcBitmapData.width, srcBitmapData.height, FlxColor.TRANSPARENT, true);

		fillDelay = delayPerUpdate;
		fillOffset = fillLinesPerUpdate;

		dropRect = new Rectangle(0, srcBitmapData.height - fillOffset, srcBitmapData.width, fillOffset);
		dropPoint = new Point();
		dropY = srcBitmapData.height;
	}

	override public function update(elapsed:Float)
	{
		if (!complete)
		{
			fillClock += elapsed;

			if (dropRect.y >= 0 && fillClock >= fillDelay)
			{
				pixels.lock();

				var fillY:Int = 0;
				while (fillY < dropY)
				{
					dropPoint.y = fillY;
					pixels.copyPixels(srcBitmapData, dropRect, dropPoint);
					fillY += fillOffset;
				}

				dropY -= fillOffset;
				dropRect.y -= fillOffset;

				dirty = true;
				pixels.unlock();
				fillClock = 0;

				if (dropY <= 0)
					complete = true;
			}
		}

		super.update(elapsed);
	}

	override public function destroy():Void
	{
		super.destroy();

		srcBitmapData = FlxDestroyUtil.dispose(srcBitmapData);
		dropPoint = null;
		dropRect = null;
	}
}
