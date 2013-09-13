package flixel.system.frontEnds;

import flash.media.Sound;
import flash.media.SoundTransform;
import flixel.FlxG;
import flixel.group.FlxTypedGroup;
import flixel.system.FlxSound;
import openfl.Assets;

class SoundFrontEnd
{
	/**
	 * A handy container for a background music object.
	 */
	public var music:FlxSound;
	/**
	 * A list of all the sounds being played in the game.
	 */
	public var list(default, null):FlxTypedGroup<FlxSound>;
	/**
	 * Whether or not the game sounds are muted.
	 */
	public var muted:Bool = false;
	/**
	 * Set this hook to get a callback whenever the volume changes.
	 * Function should take the form <code>myVolumeHandler(Volume:Number)</code>.
	 */
	public var volumeHandler:Float->Void = null;
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to increase volume (see <code>FlxG.keys</code> for the keys available).
	 * Default keys: + (and numpad +). Set to <code>null</code> to deactivate.
	 * @default ["PLUS", "NUMPADPLUS"]
	 */
	public var volumeUpKeys:Array<String>;
	/**
	 * The keys to decrease volume (see <code>FlxG.keys</code> for the keys available).
	 * Default keys: - (and numpad -). Set to <code>null</code> to deactivate.
	 * @default ["MINUS", "NUMPASMINUS"]
	 */
	public var volumeDownKeys:Array<String>;
	/**
	 * The keys used to mute / unmute the game (see <code>FlxG.keys</code> for the keys available).
	 * Default keys: 0 (and numpad 0). Set to <code>null</code> to deactivate.
	 * @default ["ZERO", "NUMPADZERO"]
	*/
	public var muteKeys:Array<String>; 
	#end
	
	public function new() 
	{
		#if !FLX_NO_KEYBOARD
		// Assign default values to the keys used by core flixel
		volumeUpKeys = ["PLUS", "NUMPADPLUS"];
		volumeDownKeys = ["MINUS", "NUMPASMINUS"];
		muteKeys = ["ZERO", "NUMPADZERO"]; 
		#end
		
		list = new FlxTypedGroup<FlxSound>();
		
		#if android
		_soundCache = new Map<String, Sound>();
		_soundTransform = new SoundTransform();
		#end
	}
	
	// TODO: Return from Sound -> Class<Sound>
	/**
	 * Set up and play a looping background soundtrack.
	 * 
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 */
	public function playMusic(Music:Dynamic, Volume:Float = 1):Void
	{
		#if !js
		if (music == null)
		{
			music = new FlxSound();
		}
		else if (music.active)
		{
			music.stop();
		}
		
		music.loadEmbedded(Music, true);
		music.volume = Volume;
		music.survive = true;
		music.play();
		#end
	}
	
	/**
	 * Creates a new sound object. 
	 * 
	 * @param	EmbeddedSound	The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @param	AutoPlay		Whether to play the sound.
	 * @param	URL				Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @return	A <code>FlxSound</code> object.
	 */
	public function load(?EmbeddedSound:Dynamic, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = false, AutoPlay:Bool = false, ?URL:String, ?OnComplete:Void->Void):FlxSound
	{
		#if !js
		if (EmbeddedSound == null && URL == null)
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
		#else
		return null;
		#end
	}
	
	#if android
	private var _soundCache:Map<String, Sound>;
	private var _soundTransform:SoundTransform;
	
	/**
	 * Method for sound caching on Android target.
	 * Application may freeze for some time at first try to play sound if you don't use this method
	 * 
	 * @param	EmbeddedSound	Name of sound assets specified in your .nmml project file
	 * @return	Cached Sound object
	 */
	public function add(EmbeddedSound:String):Sound
	{
		if (_soundCache.exists(EmbeddedSound))
		{
			return _soundCache.get(EmbeddedSound);
		}
		else
		{
			var sound:Sound = Assets.getSound(EmbeddedSound);
			_soundCache.set(EmbeddedSound, sound);
			
			return sound;
		}
	}
	
	public function play(EmbeddedSound:String, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		var sound:Sound = null;
		
		_soundTransform.volume = (muted ? 0 : 1) * FlxG.sound.volume * Volume;
		_soundTransform.pan = 0;
		
		if (_soundCache.exists(EmbeddedSound))
		{
			sound = _soundCache.get(EmbeddedSound);
		}
		else
		{
			sound = Assets.getSound(EmbeddedSound);
			_soundCache.set(EmbeddedSound, sound);
		}
		var flixelSound = list.recycle(FlxSound).loadEmbedded(sound, Looped, AutoDestroy, OnComplete);
		flixelSound.play();
		return flixelSound;
	}
	#else
	/**
	 * Creates a new sound object from an embedded <code>Class</code> object.
	 * NOTE: Just calls FlxG.loadSound() with AutoPlay == true.
	 * 
	 * @param	EmbeddedSound	The sound you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @return	A <code>FlxSound</code> object.
	 */
	inline public function play(EmbeddedSound:Dynamic, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		#if !js
		return load(EmbeddedSound, Volume, Looped, AutoDestroy, true, null, OnComplete);
		#else
		return null;
		#end
	}
	#end
		
	/**
	 * Creates a new sound object from a URL.
	 * NOTE: Just calls FlxG.loadSound() with AutoPlay == true.
	 * 
	 * @param	URL		The URL of the sound you want to play.
	 * @param	Volume	How loud to play it (0 to 1).
	 * @param	Looped	Whether or not to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @return	A FlxSound object.
	 */
	inline public function stream(URL:String, Volume:Float = 1, Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		#if !js
		return load(null, Volume, Looped, AutoDestroy, true, URL, OnComplete);
		#else
		return null;
		#end
	}
	
	/**
	 * 
	 * Set <code>volume</code> to a number between 0 and 1 to change the global volume.
	 * 
	 * @default 0.5
	 */
	public var volume(default, set_volume):Float = 0.5;
	
	/**
	 * @private
	 */
	private function set_volume(Volume:Float):Float
	{
		volume = Volume;
		
		if (volume < 0)
		{
			volume = 0;
		}
		else if (volume > 1)
		{
			volume = 1;
		}
		
		if (volumeHandler != null)
		{
			var param:Float = muted ? 0 : volume;
			volumeHandler(param);
		}
		return Volume;
	}

	/**
	 * Called by FlxGame on state changes to stop and destroy sounds.
	 * 
	 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
	 */
	public function destroySounds(ForceDestroy:Bool = false):Void
	{
		if (music != null && (ForceDestroy || !music.survive))
		{
			music.destroy();
			music = null;
		}
		
		for (sound in list.members)
		{
			if (sound != null && (ForceDestroy || !sound.survive))
			{
				sound.destroy();
			}
		}
	}
		
	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	public function updateSounds():Void
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
	
	/**
	 * Pause all sounds currently playing.
	 */
	public function pauseSounds():Void
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
	public function resumeSounds():Void
	{
		if (music != null && music.exists)
		{
			music.play();
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
	 * Called by FlxG, you shouldn't need to.
	 * Loads saved sound preferences if they exist.
	 */
	public function loadSavedPrefs():Void
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
}