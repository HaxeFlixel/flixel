package flixel.system.scaleModes;

import flixel.FlxG;

class FixedScaleMode extends BaseScaleMode
{
	override function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}
}
