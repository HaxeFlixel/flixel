package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * `FixedScaleMode` is a scaling mode which maintains the game's scene at a fixed size.
 * This will clip off the edges of the scene for dimensions which are too small,
 * and leave black margins on the sides for dimensions which are too large.
 * 
 * To enable it in your project, use `FlxG.scaleMode = new FixedScaleMode();`.
 */
class FixedScaleMode extends BaseScaleMode
{
	override function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}
}
