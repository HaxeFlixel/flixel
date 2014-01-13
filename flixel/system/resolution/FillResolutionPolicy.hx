package flixel.system.resolution;

import flixel.FlxG;

class FillResolutionPolicy extends BaseResolutionPolicy
{
	override private function updateGamePosition():Void 
	{
		FlxG.game.x = FlxG.game.y = 0;
	}
}