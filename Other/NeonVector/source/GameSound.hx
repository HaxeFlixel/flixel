package ;

import flixel.FlxG;

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
			"sounds/spawn-01.mp3", "sounds/spawn-02.mp3", "sounds/spawn-03.mp3", "sounds/spawn-04.mp3", 
			"sounds/spawn-05.mp3", "sounds/spawn-06.mp3", "sounds/spawn-07.mp3", "sounds/spawn-08.mp3"];
			
	public static function create():Void
	{
		//FlxG.playMusic(sfxMusic, 0.0);
		//FlxG.volume = 0.0;
		FlxG.sound.playMusic("music/Music.mp3", 0.4);
		FlxG.sound.volume = 0.5;
	}
	
	public static function randomSound(Sounds:Array<String>, VolumeMultiplier:Float = 1.0):Void
	{
		var _seed:Int = Math.floor(Sounds.length * Math.random());
		FlxG.sound.play(Sounds[_seed], FlxG.sound.volume * VolumeMultiplier, false, false);
	}
}