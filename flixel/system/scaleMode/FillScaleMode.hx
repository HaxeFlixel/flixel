package flixel.system.scaleMode;

import flixel.FlxG;

class FillScaleMode extends BaseScaleMode
{
	override private function updateGamePosition():Void 
	{
		FlxG.game.x = FlxG.game.y = 0;
	}
}