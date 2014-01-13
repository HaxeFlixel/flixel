package flixel.system.resolution;

import flixel.FlxG;

class FixedResolutionPolicy extends BaseResolutionPolicy
{
	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}
}