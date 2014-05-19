package flixel.system.frontEnds;

#if !FLX_NO_SOUND_SYSTEM
import flash.media.Sound;
import flash.media.SoundTransform;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import openfl.Assets;

@:allow(flixel.FlxGame)
@:allow(flixel.FlxG)
class SoundFrontEnd
{
	/**
	 * A handy container for a background music object.
	 */
	public var music:FlxSound;
	/**
	 * Whether or not the game sounds are muted.
	 */
	public var muted:Bool = false;
	/**
	 * Set this hook to get a callback whenever the volume changes.
	 * Function should take the form myVolumeHandler(Volume:Number).
	 */
	public var volumeHandler:Float->Void;
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to increase volume (see FlxG.keys for the keys available).
	 * Default keys: + (and numpad +). Set to null to deactivate.
	 */
	public var volumeUpKeys:Array<String> = ["PLUS", "NUMPADPLUS"];
	/**
	 * The keys to decrease volume (see FlxG.keys for the keys available).
	 * Default keys: - (and numpad -). Set to null to deactivate.
	 */
	public var volumeDownKeys:Array<String> = ["MINUS", "NUMPADMINUS"];
	/**
	 * The keys used to mute / unmute the game (see FlxG.keys for the keys available).
	 * Default keys: 0 (and numpad 0). Set to null to deactivate.
	 */
	public var muteKeys:Array<String> = ["ZERO", "NUMPADZERO"]; 
	#end
	
	/**
	 * Whether or not the soundTray should be shown when any of the
	 * volumeUp-, volumeDown- or muteKeys is pressed.
	 */ 
	public var soundTrayEnabled:Bool = true;
	
	/**
	 * A list of all the sounds being played in the game.
	 */
	public var list(default, null):FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();
	/**
	 * Set this to a number between 0 and 1 to change the global volume.
	 */
	public var volume(default, set):Float = 1;
	
	/**
	 * Set up and play a looping background soundtrack.
	 * 
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 * @param	Looped		Whether to loop this music.
	 */
	public function playMusic(Music:FlxSoundAsset, Volume:Float = 1, Looped:Bool = true):Void
	{
		if (music == null)
		{
			music = new FlxSound();
		}
		else if (music.active)
		{
			music.stop();
		}
		
		music.loadEmbedded(Music, Looped);
		music.volume = Volume;
		music.persist = true;
		music.play();
	}
	
	/**
	 * Creates a new sound object. 
	 * 
	 * @param	EmbeddedSound	The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param	AutoPlay		Whether to play the sound.
	 * @param	URL				Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @return	A FlxSound object.
	 */
	public function load(?EmbeddedSound:FlxSoundAsset, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = false, AutoPlay:Bool = false, ?URL:String, ?OnComplete:Void->Void):FlxSound
	{
		if ((EmbeddedSound == null) && (URL == null))
		{
			FlxG.log.warn("FlxG.loadSound() requires either\nan embedded sound or a URL to work.");
			return null;
		}
		
		var sound:FlxSound = list.recycle(FlxSound);
		
		if (EmbeddedSound != null)
		{
			sound.loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
		}
		else
		{
			sound.loadStream(URL, Looped, AutoDestroy, OnComplete);
		}
		
		sound.volume = Volume;
		
		if (AutoPlay)
		{
			sound.play();
		}
		
		return sound;
	}
	
	/**
	 * Method for sound caching (especially useful on mobile targets). The game may freeze
	 * for some time the first time yout try to play a sound if you don't use this method.
	 * 
	 * @param	EmbeddedSound	Name of sound assets specified in your .xml project file
	 * @return	Cached Sound object
	 */
	public inline function cache(EmbeddedSound:String):Sound
	{
		// load the sound into the OpenFL assets cache
		return Assets.getSound(EmbeddedSound, true);
	}
	
	#if !doc
	/**
	 * Calls FlxG.sound.cache() on all sounds that are embedded.
	 * WARNING: can lead to high memory usage.
	 */
	@:access(openfl.Assets)
	public function cacheAll():Void
	{
		Assets.initialize();
		
		var defaultLibrary = Assets.libraries.get("default");
		
		if (defaultLibrary == null) 
			return;
		
		for (id in defaultLibrary.list(AssetType.SOUND)) 
		{
			cache(id);
		}
	}
	#end
	
	/**
	 * Plays a sound from an embedded sound. Tries to recycle a cached sound first.
	 * 
	 * @param	EmbeddedSound	The sound you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @return	The FlxSound object.
	 */
	public function play(EmbeddedSound:String, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		var sound:Sound = cache(EmbeddedSound);
		var flixelSound = list.recycle(FlxSound).loadEmbedded(sound, Looped, AutoDestroy, OnComplete);
		flixelSound.volume = Volume;
		return flixelSound.play();
	}
	
	/**
	 * Creates a new sound object from a URL.
	 * NOTE: Just calls FlxG.loadSound() with AutoPlay == true.
	 * 
	 * @param	URL		The URL of the sound you want to play.
	 * @param	Volume	How loud to play it (0 to 1).
	 * @param	Looped	Whether or not to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @return	A FlxSound object.
	 */
	public inline function stream(URL:String, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		return load(null, Volume, Looped, AutoDestroy, true, URL, OnComplete);
	}
	
	/**
	 * Pause all sounds currently playing.
	 */
	public function pause():Void
	{
		if (music != null && music.exists && music.active)
		{
			music.pause();
		}
		
		for (sound in list.members)
		{
			if (sound != null && sound.exists && sound.active)
			{
				sound.pause();
			}
		}
	}
	
	/**
	 * Resume playing existing sounds.
	 */
	public function resume():Void
	{
		if (music != null && music.exists)
		{
			music.resume();
		}
		
		for (sound in list.members)
		{
			if (sound != null && sound.exists)
			{
				sound.resume();
			}
		}
	}
	
	/**
	 * Called by FlxGame on state changes to stop and destroy sounds.
	 * 
	 * @param	ForceDestroy	Kill sounds even if persist is true.
	 */
	public function destroy(ForceDestroy:Bool = false):Void
	{
		if (music != null && (ForceDestroy || !music.persist))
		{
			music.destroy();
			music = null;
		}
		
		for (sound in list.members)
		{
			if (sound != null && (ForceDestroy || !sound.persist))
			{
				sound.destroy();
			}
		}
	}
	
	private function new() {}
	
	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	private function update():Void
	{
		if (music != null && music.active)
		{
			music.update();
		}
		
		if (list != null && list.active)
		{
			list.update();
		}
	}
	
	private function onFocusLost():Void
	{
		if (music != null)
		{
			music.onFocusLost();
		}
		
		for (sound in list.members)
		{
			if (sound != null)
			{
				sound.onFocusLost();
			}
		}
	}
	
	private function onFocus():Void
	{
		if (music != null)
		{
			music.onFocus();
		}
		
		for (sound in list.members)
		{
			if (sound != null)
			{
				sound.onFocus();
			}
		}
	}
	
	/**
	 * Loads saved sound preferences if they exist.
	 */
	private function loadSavedPrefs():Void
	{
		if (FlxG.save.data.volume != null)
		{
			volume = FlxG.save.data.volume;
		}
		else 
		{
			volume = 0.5; 
		}
		
		if (FlxG.save.data.mute != null)
		{
			muted = FlxG.save.data.mute;
		}
		else 
		{
			muted = false; 
		}
	}
	
	private function set_volume(Volume:Float):Float
	{
		Volume = FlxMath.bound(Volume, 0, 1);
		
		if (volumeHandler != null)
		{
			var param:Float = muted ? 0 : Volume;
			volumeHandler(param);
		}
		return volume = Volume;
	}
}
#end
