package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * `FillScaleMode` is a scaling mode which stretches and squashes the game to exactly fit the provided window.
 * This may result in the graphics of your game being distorted if the user resizes their game window.
 * 
 * To enable it in your project, use `FlxG.scaleMode = new FillScaleMode();`.
 */
class FillScaleMode extends BaseScaleMode
{
	override function updateGamePosition():Void
	{
		FlxG.game.x = FlxG.game.y = 0;
	}
}
