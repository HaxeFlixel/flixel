package flixel.util;

import flixel.FlxG;
import flixel.system.FlxSound;
import haxe.ds.ObjectMap;

class FlxSoundUtil
{
	static public function playWithCallback(EmbeddedSound:String, ?OnComplete:Void->Void, Duration:Float = 0, Volume:Float = 1):FlxSound
	{
		var sound = FlxG.sound.play(EmbeddedSound, Volume, false, true, OnComplete);
		#if !(flash || desktop)
		var timer:FlxTimer = FlxTimer.start(Duration, timerCallback);
		timer.userData = OnComplete;
		#end
		return sound;
	}
	
	static private function timerCallback(timer:FlxTimer):Void
	{
		var callback:Void->Void = timer.userData();
		if (callback != null)
		{
			callback();
		}
	}
}