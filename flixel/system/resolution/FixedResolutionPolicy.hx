package flixel.system.resolution;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.system.resolution.IFlxResolutionPolicy;
import flixel.util.FlxPoint;

class FixedResolutionPolicy extends BaseResolutionPolicy
{
	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		gameSize.x = FlxG.width;
		gameSize.y = FlxG.height;
	}
}