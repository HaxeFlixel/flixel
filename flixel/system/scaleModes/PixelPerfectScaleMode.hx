package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * A scale mode which scales up the game to the highest integer factor it can,
 * maintains the aspect ratio, and windowboxes the game if necessary.
 */
class PixelPerfectScaleMode extends BaseScaleMode
{
	override function updateGameSize(Width:Int, Height:Int)
	{
		var scaleFactorX:Float = Width / FlxG.width;
		var scaleFactorY:Float = Height / FlxG.height;
		var scaleFactor:Int = Math.floor(Math.min(scaleFactorX, scaleFactorY));

		// If the scale factor is less than zero, set it to one and crop
		if (scaleFactor < 1)
			scaleFactor = 1;

		gameSize.x = FlxG.width * scaleFactor;
		gameSize.y = FlxG.height * scaleFactor;
	}
}
