package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * `PixelPerfectScaleMode` is a scaling mode which maintains the game's aspect ratio.
 * When you shrink or grow the window, the width and height of the game will adjust,
 * either scaling the game or adding black bars as needed.
 * 
 * However, it will only scale the game by integer factors, to maintain pixel perfect rendering.
 * This may cause the game window to be windowboxed on all sides, scaling the game up only when there is
 * enough room to exactly double the render scale.
 * 
 * To enable it in your project, use `FlxG.scaleMode = new PixelPerfectScaleMode();`.
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
