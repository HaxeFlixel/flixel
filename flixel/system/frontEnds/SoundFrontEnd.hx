package flixel.system.frontEnds;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.system.FlxAssets;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxInputText;
import flixel.util.FlxSignal;
import openfl.media.Sound;

/**
 * Accessed via `FlxG.sound`.
 */
@:allow(flixel.FlxG)
@:access(flixel.sound.FlxSound)
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
	@:deprecated("volumeHandler is deprecated, use onVolumeChange, instead")
	public var volumeHandler:Float->Void;

	/**
	 * A signal that gets dispatched whenever the volume changes.
	 */
	public var onVolumeChange(default, null):FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

	#if FLX_KEYBOARD
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
	
	#if FLX_SOUND_TRAY
	/**
	 * The sound tray display container.
	 * A getter for `FlxG.game.soundTray`.
	 */
	public var soundTray(get, never):FlxSoundTray;
	
	inline function get_soundTray()
	{
		return FlxG.game.soundTray;
	}
	#end

	/**
	 * The group sounds played via playMusic() are added to unless specified otherwise.
	 */
	public var defaultMusicGroup:FlxSoundGroup = new FlxSoundGroup();

	/**
	 * The group sounds in load() / loadFromURL() / play() are added to unless specified otherwise.
	 */
	public var defaultSoundGroup:FlxSoundGroup = new FlxSoundGroup();

	/**
	 * A list of all the sounds being played in the game.
	 */
	public var list(default, null):FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();

	/**
	 * Set this to a number between 0 and 1 to change the global volume.
	 */
	public var volume(default, set):Float = 1;
	
	function recycle(?group:FlxSoundGroup)
	{
		final sound = list.recycle(FlxSound);
		sound.cleanup(true);
		sound.exists = true;
		(group != null ? group : defaultSoundGroup).add(sound);
		return sound;
	}
	
	function recycleMusic(group:Null<FlxSoundGroup>)
	{
		if (group == null)
			group = defaultMusicGroup;
		
		if (music == null)
		{
			music = recycle(group);
		}
		else if (music.active)
		{
			music.stop();
			group.add(music);
		}
		
		return music;
	}

	/**
	 * Set up and play a looping background soundtrack.
	 *
	 * **Note:** If the `FLX_DEFAULT_SOUND_EXT` flag is enabled, you may omit the file extension
	 *
	 * @param   assetId  The sound file you want to loop in the background.
	 * @param   volume   How loud the sound should be, from 0 to 1.
	 * @param   loop     Whether to loop this music.
	 * @param   group    The group to manage this sound, if `null`, `defaultMusicGroup` is used.
	 */
	@:deprecated("playMusic(id, volume, loop, group) is deprecated, use playMusic(id, group, volume, loop), instead")
	overload public inline extern function playMusic(assetId, volume = 1.0, loop = true, group:Null<FlxSoundGroup>):Void
	{
		playMusic(assetId, group, volume, loop);
	}
	
	/**
	 * Set up and play a looping background soundtrack.
	 *
	 * **Note:** If the `FLX_DEFAULT_SOUND_EXT` flag is enabled, you may omit the file extension
	 *
	 * @param   asset       The sound file you want to loop in the background.
	 * @param   group       The group to manage this sound, if `null`, `defaultMusicGroup` is used.
	 * @param   volume      How loud the sound should be, from 0 to 1.
	 * @param   loop        Whether to loop this music.
	 * @param   onComplete  Called when the sound finishes playing, before it checks whether to to loop.
	 */
	overload public inline extern function playMusic(asset:FlxSoundAsset, ?group, volume = 1.0, loop = true, ?onComplete):FlxSound
	{
		return recycleMusic(group)
			.loadHelper(asset)
			.setup(volume, loop, false, onComplete)
			.play();
	}
	
	/**
	 * Creates a new FlxSound object.
	 *
	 * **Note:** If the `FLX_DEFAULT_SOUND_EXT` flag is enabled, you may omit the file extension

	 * @param   assetId      The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param   volume       How loud to play it (0 to 1).
	 * @param   loop         Whether to loop this sound.
	 * @param   group        The group to manage this sound, if `null`, `defaultSoundGroup` is used.
	 * @param   autoDestroy  Whether to destroy this sound when it finishes playing.
	 *                       Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param   autoPlay     Whether to play the sound.
	 * @param   url          Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @param   onComplete   Called when the sound finishes playing, before it checks whether to to loop.
	 * @param   onLoad       Called when the sound finishes loading.  Called immediately for succesfully loaded embedded sounds.
	 * @return  A FlxSound object.
	 */
	@:deprecated("FlxG.sound.load is deprecated, use either loadFromURL() or create(assetId).setup(...).play()")
	public function load(?asset, volume = 1.0, loop = false, ?group, autoDestroy = false, autoPlay = false,
			?url, ?onComplete, ?onLoad)
	{
		return if (asset == null && url == null)
		{
			FlxG.log.warn("FlxG.sound.load() requires either\nan embedded sound or a URL to work.");
			null;
		}
		else if (asset == null && url != null)
		{
			if (autoPlay)
			{
				playFromURL(url, group, onLoad, volume, loop, autoDestroy, onComplete);
			}
			else
			{
				final sound = loadFromURL(url, group, onLoad);
				sound.setup(volume, loop, autoDestroy, onComplete);
				if (autoPlay)
					sound.play();
				
				sound;
			}
		}
		else
		{
			if (url != null)
				FlxG.log.warn("FlxG.sound.load() received both an embedded asset and a url, ignoring url.");
			
			final sound = recycle(group)
				.loadHelper(asset)
				.setup(volume, loop, autoDestroy, onComplete);
			
			if (autoPlay)
				sound.play();
			
			// Call OnLoad() because the sound already loaded
			if (onLoad != null && sound._sound != null)
				onLoad();
			
			sound;
		}
	}
	
	/**
	 * Creates a new FlxSound object. It's recommended to set up sounds using chainging, for
	 * instance:
	 * ```haxe
	 * FlxG.sound.create("assets/sounds/mySound").setup(1.0, true).play();
	 * ```
	 *
	 * @param   asset       The embedded sound resource you want to play. Accepts various types,
	 *                      typically an asset ID, you may omit the file extension
	 * @param   group       The group to manage this sound, if `null`, `defaultSoundGroup` is used
	 * @param   allowCache  Useed for asset IDs, Whether to use the asset caching system
	 * @return  This `FlxSound` instance
	 * 
	 * @since 6.2.0
	 */
	public function create(asset:FlxSoundAsset, ?group:FlxSoundGroup, allowCache = true):FlxSound
	{
		return recycle(group).loadHelper(asset, false, allowCache, true);
	}
	
	#if FLX_STREAM_SOUND
	/**
	 * Streams a sound from the given file path. Unlike the `load` method, this will load and
	 * unload chunks of data as the sound plays, keeping memory usage low. This is recommended for
	 * longer sounds, like music tracks. For shorter sounds like sound effects, it is better to
	 * use the `load` method, which loads the entire sound into memory before playing it.
	 * 
	 * Due to a backend limitation, audio streaming is currently only available on native targets 
	 * and OGG/Vorbis audio files.
	 * 
	 * @param   assetId  The ID or asset path to the sound asset. You may omit the file extension
	 * @param   group    The group to manage this sound, if `null`, `defaultSoundGroup` is used
	 * @return  This `FlxSound` instance (nice for chaining stuff together, if you're into that)
	 * 
	 * @since 6.2.0
	 */
	public function createStreamed(assetId:String, ?group:FlxSoundGroup):FlxSound
	{
		return recycle(group)
			.loadStreamedHelper(assetId, false);
	}
	
	/**
	 * Streams a sound from the given file path. Unlike the `play` method, this will load and
	 * unload chunks of data as the sound plays, keeping memory usage low. This is recommended for
	 * longer sounds, like music tracks. For shorter sounds like sound effects, it is better to
	 * use the `play` method, which loads the entire sound into memory before playing it.
	 * 
	 * Due to a backend limitation, audio streaming is currently only available on native targets 
	 * and OGG/Vorbis audio files.
	 * 
	 * @param   assetId  The ID or asset path to the sound asset. You may omit the file extension
	 * @param   group    The group to manage this sound, if `null`, `defaultSoundGroup` is used
	 * @param   volume   How loud to play it (0 to 1).
	 * @param   loop     Whether or not this sound should loop endlessly.
	 * @param   autoDestroy  Whether or not this FlxSound instance should be destroyed when the sound finishes playing.
	 * @param   onComplete   Called when the sound finishes playing, before it checks whether to to loop.
	 * @return  This FlxSound instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @since 6.2.0
	 */
	public function playStreamed(assetId, ?group, volume = 1.0, loop = false, autoDestroy = false, ?onComplete):FlxSound 
	{
		return createStreamed(assetId, group)
			.setup(volume, loop, autoDestroy, onComplete)
			.play();
	}
	#end

	/**
	 * Method for sound caching (especially useful on mobile targets). The game may freeze
	 * for some time the first time you try to play a sound if you don't use this method.
	 *
	 * @param   assetId  Name of sound assets specified in your .xml project file
	 * @return  Cached Sound object
	 */
	public inline function cache(assetId:String):Null<Sound>
	{
		return FlxG.assets.getSound(assetId, true, FlxG.log.styles.error);
	}

	/**
	 * Calls FlxG.sound.cache() on all sounds that are embedded.
	 * WARNING: can lead to high memory usage.
	 */
	public function cacheAll():Void
	{
		for (id in FlxG.assets.list(SOUND))
		{
			cache(id);
		}
	}

	/**
	 * Plays a sound from an embedded sound. Tries to recycle a cached sound first.
	 *
	 * **Note:** If the `FLX_DEFAULT_SOUND_EXT` flag is enabled, you may omit the file extension
	 *
	 * @param   assetId      The embedded sound resource you want to play.
	 * @param   volume       How loud to play it (0 to 1).
	 * @param   loop         Whether to loop this sound.
	 * @param   group        The group to manage this sound, if `null`, `defaultSoundGroup` is used.
	 * @param   autoDestroy  Whether to destroy this sound when it finishes playing.
	 *                       Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param   onComplete   Called when the sound finishes playing, before it checks whether to to loop.
	 * @return  A FlxSound object.
	 */
	public function play(asset:FlxSoundAsset, volume = 1.0, loop = false, ?group:FlxSoundGroup, autoDestroy = true, ?onComplete):FlxSound
	{
		return recycle(group)
			.loadHelper(asset)
			.setup(volume, loop, autoDestroy, onComplete)
			.play();
	}
	
	function attemptCache(asset:FlxSoundAsset):Null<FlxSoundAsset>
	{
		if ((asset is String))
		{
			final cachedAsset = cache(cast asset);
			if (cachedAsset != null)
				return cachedAsset;
		}
		
		return asset;
	}

	/**
	 * Plays a sound from a URL. Tries to recycle a cached sound first
	 *
	 * @param   url     A link to an external web resource
	 * @param   group   The group to manage this sound, if `null`, `defaultSoundGroup` is used
	 * @param   onLoad  Called when the sound finishes loading
	 * @return  A FlxSound object.
	 * 
	 * @since 6.2.0
	 */
	public function loadFromURL(url:String, ?group:FlxSoundGroup, ?onLoad:()->Void):FlxSound
	{
		return recycle(group)
			.loadFromURL(url, onLoad);
	}

	/**
	 * Plays a sound from a URL. Tries to recycle a cached sound first
	 *
	 * @param   url          A link to an external web resource
	 * @param   group        The group to manage this sound, if `null`, `defaultSoundGroup` is used
	 * @param   onLoad       Called when the sound finishes loading
	 * @param   volume       How loud to play it (0 to 1)
	 * @param   loop         Whether to loop this sound
	 * @param   autoDestroy  Whether to destroy this sound when it finishes playing.
	 *                       Leave this value set to "false" if you want to re-use this FlxSound instance
	 * @param   onLoad       Called when the sound finishes playing, before it checks whether to to loop
	 * @return  A FlxSound object.
	 * @since 6.2.0
	 */
	public function playFromURL(url:String, ?group:FlxSoundGroup, ?onLoad:()->Void, volume = 1.0, loop = false,
			autoDestroy = false, ?onComplete:()->Void):FlxSound
	{
		final sound = recycle(group);
		// Auto play the sound when it's done loading
		function playOnLoad()
		{
			sound.play();

			if (onLoad != null)
				onLoad();
		}
		
		return sound.loadFromURL(url, playOnLoad)
			.setup(volume, loop, autoDestroy, onComplete)
			.play();
	}

	/**
	 * Plays a sound from a URL. Tries to recycle a cached sound first.
	 * NOTE: Just calls FlxG.sound.load() with AutoPlay == true.
	 *
	 * @param   url          A link to an external web resource.
	 * @param   volume       How loud to play it (0 to 1).
	 * @param   loop         Whether to loop this sound.
	 * @param   group        The group to manage this sound, if `null`, `defaultSoundGroup` is used.
	 * @param   autoDestroy  Whether to destroy this sound when it finishes playing.
	 *                       Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param   onComplete   Called when the sound finishes playing, before it checks whether to to loop.
	 * @param   onLoad       Called when the sound finishes loading.
	 * @return  A FlxSound object.
	 */
	@:deprecated("FlxG.sound.stream() is deprecated, use FlxG.sound.loadFromURL() or playFromURL(), instead")
	public function stream(url:String, volume = 1.0, loop = false, ?group:FlxSoundGroup, autoDestroy = true,
			?onComplete:()->Void, ?onLoad:()->Void):FlxSound
	{
		return playFromURL(url, group, onLoad, volume, loop, autoDestroy, onComplete);
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
	 * @param   forceDestroy  Kill sounds even if persist is true.
	 */
	public function destroy(forceDestroy = false):Void
	{
		if (music != null && (forceDestroy || !music.persist))
		{
			music.destroy();
			music = null;
		}

		for (sound in list.members)
		{
			if (sound != null && (forceDestroy || !sound.persist))
			{
				sound.destroy();
			}
		}
	}

	/**
	 * Toggles muted, also activating the sound tray.
	 */
	@:haxe.warning("-WDeprecated")
	public function toggleMuted():Void
	{
		muted = !muted;

		if (volumeHandler != null)
		{
			volumeHandler(muted ? 0 : volume);
		}

		onVolumeChange.dispatch(muted ? 0 : volume);

		showSoundTray(true);
	}

	/**
	 * Changes the volume by a certain amount, also activating the sound tray.
	 */
	public function changeVolume(Amount:Float):Void
	{
		muted = false;
		volume += Amount;
		showSoundTray(Amount > 0);
	}

	/**
	 * Shows the sound tray if it is enabled.
	 * @param up Whether or not the volume is increasing.
	 */
	public function showSoundTray(up:Bool = false):Void
	{
		#if FLX_SOUND_TRAY
		if (FlxG.game.soundTray != null && soundTrayEnabled)
		{
			if (up)
				FlxG.game.soundTray.showIncrement();
			else
				FlxG.game.soundTray.showDecrement();
		}
		#end
	}
	
	/**
	 * Takes the volume scale used by Flixel fields and gives the final transformed volume that is
	 * actually used to play the sound. To reverse this operation, use `reverseSoundCurve`. This
	 * field is `dynamic` and can be overwritten. 
	 */
	public dynamic function applySoundCurve(volume:Float)
	{
		return volume;
		
		// Example of linear to logarithmic sound curve:
		// final clampedVolume = Math.max(0, Math.min(1, volume));
		// return Math.exp(Math.log(0.001) * (1 - clampedVolume));
	}
	
	/**
	 * Takes a transformed volume and returns the corresponding volume scale used by Flixel fields.
	 * Used to reverse the operation of `applySoundCurve`. This field is `dynamic` and can be
	 * set to a custom function.
	 */
	public dynamic function reverseSoundCurve(curvedVolume:Float)
	{
		return curvedVolume;
		
		// Example of logarithmic to linear sound curve:
		// final clampedVolume = Math.max(0.001, Math.min(1, curvedVolume));
		// return 1 - (Math.log(clampedVolume) / Math.log(0.001));
	}
	
	function new()
	{
		#if FLX_SAVE
		loadSavedPrefs();
		#end
	}

	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	@:allow(flixel.FlxGame)
	function update(elapsed:Float):Void
	{
		if (music != null && music.active)
			music.update(elapsed);

		if (list != null && list.active)
			list.update(elapsed);

		#if FLX_KEYBOARD
		if (!FlxInputText.globalManager.isTyping)
		{
			if (FlxG.keys.anyJustReleased(muteKeys))
				toggleMuted();
			else if (FlxG.keys.anyJustReleased(volumeUpKeys))
				changeVolume(0.1);
			else if (FlxG.keys.anyJustReleased(volumeDownKeys))
				changeVolume(-0.1);
		}
		#end
	}

	@:allow(flixel.FlxGame)
	function onFocusLost():Void
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

	@:allow(flixel.FlxGame)
	function onFocus():Void
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

	#if FLX_SAVE
	/**
	 * Loads saved sound preferences if they exist.
	 */
	function loadSavedPrefs():Void
	{
		if (!FlxG.save.isBound)
			return;

		if (FlxG.save.data.volume != null)
		{
			volume = FlxG.save.data.volume;
		}

		if (FlxG.save.data.mute != null)
		{
			muted = FlxG.save.data.mute;
		}
	}
	#end

	@:haxe.warning("-WDeprecated")
	function set_volume(Volume:Float):Float
	{
		volume = FlxMath.bound(Volume, 0, 1);

		if (volumeHandler != null)
		{
			volumeHandler(muted ? 0 : volume);
		}

		onVolumeChange.dispatch(muted ? 0 : volume);

		return volume;
	}
}
#end
