package;

import flixel.FlxG;
import flixel.math.FlxRandom;
import flixel.system.FlxAssets;

/**
 * @author Masadow
 */
class GameSound
{
	public static var sfxExplosion:Array<FlxSoundAsset> = [for (i in 1...9) 'sounds/explosion-0$i.mp3'];
	public static var sfxShoot:Array<FlxSoundAsset> = [for (i in 1...5) 'sounds/shoot-0$i.mp3'];
	public static var sfxSpawn:Array<FlxSoundAsset> = [for (i in 1...9) 'sounds/spawn-0$i.mp3'];

	public static function create():Void
	{
		FlxG.sound.playMusic("music/Music.mp3", 0.4);
		FlxG.sound.volume = 0.5;
	}
	
	public static function randomSound(Sounds:Array<FlxSoundAsset>, VolumeMultiplier:Float = 1.0):Void
	{
		FlxG.sound.play(FlxG.random.getObject(Sounds), FlxG.sound.volume * VolumeMultiplier, false, false);
	}
}