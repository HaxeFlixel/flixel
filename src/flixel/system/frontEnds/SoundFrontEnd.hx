package flixel.system.frontEnds;

import flash.media.Sound;
import flash.media.SoundTransform;
import flixel.FlxG;
import flixel.FlxSound;
import flixel.group.FlxTypedGroup;
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
	public var list:FlxTypedGroup<FlxSound>;
	/**
	 * Whether or not the game sounds are muted.
	 */
	public var mute:Bool;
	/**
	 * Set this hook to get a callback whenever the volume changes.
	 * Function should take the form <code>myVolumeHandler(Volume:Number)</code>.
	 */
	public var volumeHandler:Float->Void;
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to increase volume. (via flash.ui.Keyboard)
	 * @default [107, 187]
	 */
	public var keyVolumeUp:Array<Int>;
	/**
	 * The key codes used to decrease volume. (via flash.ui.Keyboard)
	 * @default [109, 189]
	 */
	public var keyVolumeDown:Array<Int>;
	/**
	 * The key codes used to mute / unmute the game. (via flash.ui.Keyboard)
	 * @default [48, 96]
	*/
	public var keyMute:Array<Int>; 
	#end
	
	public function new() 
	{
		#if !FLX_NO_KEYBOARD
		//Assign default values to the keys used by core flixel
		keyVolumeUp = [107, 187];
		keyVolumeDown = [109, 189];
		keyMute = [48, 96]; 
		#end
		
		mute = false;
		volume = 0.5;
		list = new FlxTypedGroup<FlxSound>();
		volumeHandler = null;
		
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
	public function playMusic(Music:Dynamic, Volume:Float = 1.0):Void
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
	public function load(EmbeddedSound:Dynamic = null, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = false, AutoPlay:Bool = false, URL:String = null, OnComplete:Void->Void = null):FlxSound
	{
		#if !js
		if((EmbeddedSound == null) && (URL == null))
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
	
	public function play(EmbeddedSound:String, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true, OnComplete:Void->Void = null):FlxSound
	{
		var sound:Sound = null;
		
		_soundTransform.volume = (FlxG.sound.mute ? 0 : 1) * FlxG.sound.volume * Volume;
		_soundTransform.pan = 0;
		
		if (_soundCache.exists(EmbeddedSound))
		{
			_soundCache.get(EmbeddedSound).play(0, 0, _soundTransform);
		}
		else
		{
			sound = Assets.getSound(EmbeddedSound);
			
			_soundCache.set(EmbeddedSound, sound);
			sound.play(0, 0, _soundTransform);
		}
		
		return null;
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
	public function play(EmbeddedSound:Dynamic, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true, OnComplete:Void->Void = null):FlxSound
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
	public function stream(URL:String, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true, OnComplete:Void->Void = null):FlxSound
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
	public var volume(default, set_volume):Float;
	
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
			var param:Float = FlxG.sound.mute ? 0 : volume;
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
		if((music != null) && (ForceDestroy || !music.survive))
		{
			music.destroy();
			music = null;
		}
		var i:Int = 0;
		var sound:FlxSound;
		var l:Int = list.members.length;
		while(i < l)
		{
			sound = list.members[i++];
			if ((sound != null) && (ForceDestroy || !sound.survive))
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
		if ((music != null) && music.active)
		{
			music.update();
		}
		if ((list != null) && list.active)
		{
			list.update();
		}
	}
	
	/**
	 * Pause all sounds currently playing.
	 */
	public function pauseSounds():Void
	{
		if ((music != null) && music.exists && music.active)
		{
			music.pause();
		}
		var i:Int = 0;
		var sound:FlxSound;
		var l:Int = list.length;
		while(i < l)
		{
			sound = list.members[i++];
			if ((sound != null) && sound.exists && sound.active)
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
		if ((music != null) && music.exists)
		{
			music.play();
		}
		var i:Int = 0;
		var sound:FlxSound;
		var l:Int = list.length;
		while(i < l)
		{
			sound = list.members[i++];
			if ((sound != null) && sound.exists)
			{
				sound.resume();
			}
		}
	}
}