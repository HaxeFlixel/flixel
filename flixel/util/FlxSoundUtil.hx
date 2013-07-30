package flixel.util;

import flixel.FlxG;
import flixel.system.FlxSound;
import haxe.ds.ObjectMap;

class FlxSoundUtil
{
	static private var timerCallbackMap:ObjectMap<FlxTimer, Void->Void> = new ObjectMap<FlxTimer, Void->Void>();
	
	static public function playWithCallback(EmbeddedSound:String, ?OnComplete:Void->Void, Duration:Float = 0, Volume:Float = 1):FlxSound
	{
		var sound = FlxG.sound.play(EmbeddedSound, Volume, false, true, OnComplete);
		#if !(flash || desktop)
		timerCallbackMap.set(FlxTimer.start(Duration, timerCallback), OnComplete);
		#end
		return sound;
	}
	
	static public function clear():Void
	{
		timerCallbackMap = new ObjectMap<FlxTimer, Void->Void>();
	}
	
	static private function timerCallback(timer:FlxTimer):Void
	{
		if (timerCallbackMap.exists(timer))
		{
			var callback:Void->Void = timerCallbackMap.get(timer);
			callback();
			timerCallbackMap.remove(timer);
			timer.destroy();
		}
	}
}