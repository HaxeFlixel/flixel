package flixel.system.scaleModes;

import flixel.FlxG;

class FillScaleMode extends BaseScaleMode
{
	override function updateGamePosition():Void
	{
		FlxG.game.x = FlxG.game.y = 0;
	}
}
