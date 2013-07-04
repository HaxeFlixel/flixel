package flixel.util;

import flixel.FlxG;
import flixel.system.FlxSound;
import haxe.ds.ObjectMap;

class FlxSoundUtil
{
	private static var timerCallbackMap:ObjectMap<FlxTimer, Void->Void> = new ObjectMap<FlxTimer, Void->Void>();
	
	public static function playWithCallback(EmbeddedSound:String, OnComplete:Void->Void = null, Duration:Float = 0, Volume:Float = 1.0):FlxSound
	{
		var sound = FlxG.sound.play(EmbeddedSound, Volume, false, true, OnComplete);
		#if !(flash || desktop)
		var timer:FlxTimer = new FlxTimer().start(Duration, 1, timerCallback);
		FlxTimer.manager.add(timer);
		timerCallbackMap.set(timer, OnComplete);
		#end
		return sound;
	}
	
	public static function clear():Void
	{
		timerCallbackMap = new ObjectMap<FlxTimer, Void->Void>();
	}
	
	private static function timerCallback(timer:FlxTimer):Void
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