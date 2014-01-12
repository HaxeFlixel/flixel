package flixel.system.resolution;

import flixel.FlxG;
import flixel.system.resolution.IFlxResolutionPolicy;
import flixel.util.FlxPoint;

class FillResolutionPolicy extends BaseResolutionPolicy
{
	override private function updateGamePosition():Void 
	{
		FlxG.game.x = FlxG.game.y = 0;
	}
}