package;

import flixel.FlxG;
import flixel.math.FlxRandom;

/**
 * @author Masadow
 */
class GameSound
{
	public static var sfxExplosion:Array<String> = [
			"sounds/explosion-01.mp3", "sounds/explosion-02.mp3", "sounds/explosion-03.mp3", "sounds/explosion-04.mp3", 
			"sounds/explosion-05.mp3", "sounds/explosion-06.mp3", "sounds/explosion-07.mp3", "sounds/explosion-08.mp3"];
			
	public static var sfxShoot:Array<String> = ["sounds/shoot-01.mp3", "sounds/shoot-02.mp3", "sounds/shoot-03.mp3", "sounds/shoot-04.mp3"];
			
	public static var sfxSpawn:Array<String> = [
			"sounds/spawn-05.mp3", "sounds/spawn-06.mp3", "sounds/spawn-07.mp3", "sounds/spawn-08.mp3"];
			
	public static function create():Void
	{
		FlxG.sound.playMusic("music/Music.mp3", 0.4);
		FlxG.sound.volume = 0.5;
	}
	
	public static function randomSound(Sounds:Array<String>, VolumeMultiplier:Float = 1.0):Void
	{
		FlxG.sound.play(FlxG.random.getObject(Sounds), FlxG.sound.volume * VolumeMultiplier, false, false);
	}
}
