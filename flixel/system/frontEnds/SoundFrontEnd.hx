package flixel.system.frontEnds;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSoundGroup;

#if !FLX_NO_SOUND_SYSTEM
import flash.media.Sound;
import flash.media.SoundTransform;
import flixel.FlxG;
import flixel.group.FlxGroup;
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
	 * Function should take the form myVolumeHandler(volume:Float).
	 */
	public var volumeHandler:Float->Void;
	
	#if !FLX_NO_KEYBOARD
	/**
	 * The key codes used to increase volume (see FlxG.keys for the keys available).
	 * Default keys: + (and numpad +). Set to null to deactivate.
	 */
	public var volumeUpKeys:Array<FlxKey> = [PLUS, NUMPADPLUS];
	/**
	 * The keys to decrease volume (see FlxG.keys for the keys available).
	 * Default keys: - (and numpad -). Set to null to deactivate.
	 */
	public var volumeDownKeys:Array<FlxKey> = [MINUS, NUMPADMINUS];
	/**
	 * The keys used to mute / unmute the game (see FlxG.keys for the keys available).
	 * Default keys: 0 (and numpad 0). Set to null to deactivate.
	 */
	public var muteKeys:Array<FlxKey> = [ZERO, NUMPADZERO]; 
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
	 * Collection of sound groups to which sounds may be added
	 */
	private var groups:Map<String, FlxSoundGroup> = new Map<String, FlxSoundGroup>();
	
	/**
	 * Set up and play a looping background soundtrack.
	 * 
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 * @param	Looped		Whether to loop this music.
	 * @param	GroupName   The name of the sound group to which this music belongs.
	 */
	public function playMusic(Music:FlxSoundAsset, Volume:Float = 1, Looped:Bool = true, ?GroupName:String):Void
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
		music.group = getGroup(GroupName);
		music.play();
	}
	
	/**
	 * Creates a new sound object. 
	 * 
	 * @param	EmbeddedSound	The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	GroupName       The name of the sound group to which this sound belongs
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param	AutoPlay		Whether to play the sound.
	 * @param	URL				Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @return	A FlxSound object.
	 */
	public function load(?EmbeddedSound:FlxSoundAsset, Volume:Float = 1, Looped:Bool = false, ?GroupName:String, AutoDestroy:Bool = false, AutoPlay:Bool = false, ?URL:String, ?OnComplete:Void->Void):FlxSound
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
		
		sound.group = getGroup(GroupName);
		
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
	#if (openfl <= "1.4.0")
	@:access(openfl.Assets)
	@:access(openfl.AssetType)
	#end
	public function cacheAll():Void
	{
		#if (openfl > "1.4.0")
		for (id in Assets.list(AssetType.SOUND)) 
		{
			cache(id);
		}
		#else
		Assets.initialize();
		
		var defaultLibrary = Assets.libraries.get("default");
		
		if (defaultLibrary == null) 
			return;
		
		var types:Map<String, Dynamic> = DefaultAssetLibrary.type;
		
		if (types == null) 
			return;
		
		for (key in types.keys())
		{
			if (types.get(key) == AssetType.SOUND)
			{
				cache(key);
			}
		}
		#end
	}
	#end
	
	/**
	 * Plays a sound from an embedded sound. Tries to recycle a cached sound first.
	 * 
	 * @param	EmbeddedSound	The sound you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	GroupName       The name of the sound group to which this sound belongs
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @return	The FlxSound object.
	 */
	public function play(EmbeddedSound:FlxSoundAsset, Volume:Float = 1, Looped:Bool = false, ?GroupName:String, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		if (Std.is(EmbeddedSound, String))
		{
			EmbeddedSound = cache(EmbeddedSound);
		}
		var sound = list.recycle(FlxSound).loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
		sound.group = getGroup(GroupName);
		sound.volume = Volume;
		return sound.play();
	}
	
	/**
	 * Creates a new sound object from a URL.
	 * NOTE: Just calls FlxG.loadSound() with AutoPlay == true.
	 * 
	 * @param	URL		   The URL of the sound you want to play.
	 * @param	Volume	   How loud to play it (0 to 1).
	 * @param	Looped	   Whether or not to loop this sound.
	 * @param	GroupName  The name of the sound group to which the sound belongs.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @return	A FlxSound object.
	 */
	public inline function stream(URL:String, Volume:Float = 1, Looped:Bool = false, ?GroupName:String, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		return load(null, Volume, Looped, GroupName, AutoDestroy, true, URL, OnComplete);
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
	
	/**
	 * Toggles muted, also activating the sound tray.
	 */ 
	public function toggleMuted():Void
	{
		muted = !muted;
		
		if (volumeHandler != null)
		{
			volumeHandler(muted ? 0 : volume);
		}
		
		showSoundTray();
	}
	
	/**
	 * Changes the volume by a certain amount, also activating the sound tray.
	 */ 
	public function changeVolume(Amount:Float):Void
	{
		muted = false;
		volume += Amount;
		showSoundTray();
	}
	
	/**
	 * Shows the sound tray if it is enabled.
	 */
	public function showSoundTray():Void
	{
		#if FLX_SOUND_TRAY
		if (FlxG.game.soundTray != null && soundTrayEnabled)
		{
			FlxG.game.soundTray.show();
		}
		#end
	}
	
	/**
	 * Add a new sound group
	 * @param	name          The name of the group
	 * @param	volume        The initial volume of the group
	 * @return The new sound group
	 */
	public function addGroup(name:String, volume:Float = 1):FlxSoundGroup
	{
		var group:FlxSoundGroup = new FlxSoundGroup(name, volume);
		groups.set(name, group);
		return group;
	}
	
	/**
	 * Get a named FlxSoundGroup instance
	 * @param	name   The name of the group to get
	 * @return The sound group
	 */
	public function getGroup(name:String):FlxSoundGroup
	{
		return groups.get(name);
	}
	
	/**
	 * Delete a sound group
	 * @param	name   The name fo the group to delete
	 * @return	True if group was succesfully deleted, false otherwise
	 */
	public function deleteGroup(name:String):Bool
	{
		if (groups.exists(name))
		{
			for (sound in groups.get(name).sounds)
			{
				sound.group = null;
			}
		}
		return groups.remove(name);
	}
	
	private function new()
	{
		loadSavedPrefs();
	}
	
	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	private function update(elapsed:Float):Void
	{
		if (music != null && music.active)
			music.update(elapsed);
		
		if (list != null && list.active)
			list.update(elapsed);
		
		#if !FLX_NO_KEYBOARD
		if (FlxG.keys.anyJustReleased(muteKeys))
			toggleMuted();
		else if (FlxG.keys.anyJustReleased(volumeUpKeys))
			changeVolume(0.1);
		else if (FlxG.keys.anyJustReleased(volumeDownKeys))
			changeVolume(-0.1);
		#end
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
		
		if (FlxG.save.data.mute != null)
		{
			muted = FlxG.save.data.mute;
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
