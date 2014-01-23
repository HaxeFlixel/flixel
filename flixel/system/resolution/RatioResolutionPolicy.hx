package flixel.system.resolution;

import flixel.FlxG;

class RatioResolutionPolicy extends BaseResolutionPolicy
{
	override private function updateGameSize(Width:Int, Height:Int):Void 
	{
		var ratio:Float = FlxG.width / FlxG.height;
		var realRatio:Float = Width / Height;
		
		if (realRatio < ratio)
		{
			gameSize.x = Width;
			gameSize.y = Math.floor(gameSize.x / ratio);
		}
		else
		{
			gameSize.y = Height;
			gameSize.x = Math.floor(gameSize.y * ratio);
		}
	}
}