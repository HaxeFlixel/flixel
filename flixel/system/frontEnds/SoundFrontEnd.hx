package flixel.system.frontEnds;

#if FLX_SOUND_SYSTEM
import flash.media.Sound;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSoundGroup;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.input.keyboard.FlxKey;
import openfl.Assets;
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end

/**
 * Accessed via `FlxG.sound`.
 */
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

	/**
	 * The group sounds played via playMusic() are added to unless specified otherwise.
	 */
	public var defaultMusicGroup:FlxSoundGroup = new FlxSoundGroup();

	/**
	 * The group sounds in load() / play() / stream() are added to unless specified otherwise.
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

	/**
	 * Set up and play a looping background soundtrack.
	 *
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 * @param	Looped		Whether to loop this music.
	 * @param	Group		The group to add this sound to.
	 */
	public function playMusic(Music:FlxSoundAsset, Volume:Float = 1, Looped:Bool = true, ?Group:FlxSoundGroup):Void
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
		music.group = (Group == null) ? defaultMusicGroup : Group;
		music.play();
	}

	/**
	 * Creates a new FlxSound object.
	 *
	 * @param	EmbeddedSound	The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	Group			The group to add this sound to.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.
	 * 							Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param	AutoPlay		Whether to play the sound.
	 * @param	URL				Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @param	OnComplete		Called when the sound finished playing.
	 * @param	OnLoad			Called when the sound finished loading.  Called immediately for succesfully loaded embedded sounds.
	 * @return	A FlxSound object.
	 */
	public function load(?EmbeddedSound:FlxSoundAsset, Volume:Float = 1, Looped:Bool = false, ?Group:FlxSoundGroup, AutoDestroy:Bool = false,
			AutoPlay:Bool = false, ?URL:String, ?OnComplete:Void->Void, ?OnLoad:Void->Void):FlxSound
	{
		if ((EmbeddedSound == null) && (URL == null))
		{
			FlxG.log.warn("FlxG.sound.load() requires either\nan embedded sound or a URL to work.");
			return null;
		}

		var sound:FlxSound = list.recycle(FlxSound);

		if (EmbeddedSound != null)
		{
			sound.loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
			loadHelper(sound, Volume, Group, AutoPlay);
			// Call OnlLoad() because the sound already loaded
			if (OnLoad != null && sound._sound != null)
				OnLoad();
		}
		else
		{
			var loadCallback = OnLoad;
			if (AutoPlay)
			{
				// Auto play the sound when it's done loading
				loadCallback = function()
				{
					sound.play();

					if (OnLoad != null)
						OnLoad();
				}
			}

			sound.loadStream(URL, Looped, AutoDestroy, OnComplete, loadCallback);
			loadHelper(sound, Volume, Group);
		}

		return sound;
	}

	function loadHelper(sound:FlxSound, Volume:Float, Group:FlxSoundGroup, AutoPlay:Bool = false):FlxSound
	{
		sound.volume = Volume;

		if (AutoPlay)
		{
			sound.play();
		}

		sound.group = (Group == null) ? defaultSoundGroup : Group;
		return sound;
	}

	/**
	 * Method for sound caching (especially useful on mobile targets). The game may freeze
	 * for some time the first time you try to play a sound if you don't use this method.
	 *
	 * @param	EmbeddedSound	Name of sound assets specified in your .xml project file
	 * @return	Cached Sound object
	 */
	public inline function cache(EmbeddedSound:String):Sound
	{
		// load the sound into the OpenFL assets cache
		if (Assets.exists(EmbeddedSound, AssetType.SOUND) || Assets.exists(EmbeddedSound, AssetType.MUSIC))
			return Assets.getSound(EmbeddedSound, true);
		FlxG.log.error('Could not find a Sound asset with an ID of \'$EmbeddedSound\'.');
		return null;
	}

	/**
	 * Calls FlxG.sound.cache() on all sounds that are embedded.
	 * WARNING: can lead to high memory usage.
	 */
	public function cacheAll():Void
	{
		for (id in Assets.list(AssetType.SOUND))
		{
			cache(id);
		}
	}

	/**
	 * Plays a sound from an embedded sound. Tries to recycle a cached sound first.
	 *
	 * @param	EmbeddedSound	The embedded sound resource you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	Group			The group to add this sound to.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.
	 * 							Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param	OnComplete		Called when the sound finished playing
	 * @return	A FlxSound object.
	 */
	public function play(EmbeddedSound:FlxSoundAsset, Volume:Float = 1, Looped:Bool = false, ?Group:FlxSoundGroup,
			AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxSound
	{
		if ((EmbeddedSound is String))
		{
			EmbeddedSound = cache(EmbeddedSound);
		}
		var sound = list.recycle(FlxSound).loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
		return loadHelper(sound, Volume, Group, true);
	}

	/**
	 * Plays a sound from a URL. Tries to recycle a cached sound first.
	 * NOTE: Just calls FlxG.sound.load() with AutoPlay == true.
	 *
	 * @param	URL				Load a sound from an external web resource instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	Group			The group to add this sound to.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.
	 * 							Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param	OnComplete		Called when the sound finished playing
	 * @param	OnLoad			Called when the sound finished loading.
	 * @return	A FlxSound object.
	 */
	public function stream(URL:String, Volume:Float = 1, Looped:Bool = false, ?Group:FlxSoundGroup,
			AutoDestroy:Bool = true, ?OnComplete:Void->Void, ?OnLoad:Void->Void):FlxSound
	{
		return load(null, Volume, Looped, Group, AutoDestroy, true, URL, OnComplete, OnLoad);
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
			destroySound(music);
			music = null;
		}

		for (sound in list.members)
		{
			if (sound != null && (ForceDestroy || !sound.persist))
			{
				destroySound(sound);
			}
		}
	}

	function destroySound(sound:FlxSound):Void
	{
		defaultMusicGroup.remove(sound);
		defaultSoundGroup.remove(sound);
		sound.destroy();
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

	function new()
	{
		loadSavedPrefs();
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
		if (FlxG.keys.anyJustReleased(muteKeys))
			toggleMuted();
		else if (FlxG.keys.anyJustReleased(volumeUpKeys))
			changeVolume(0.1);
		else if (FlxG.keys.anyJustReleased(volumeDownKeys))
			changeVolume(-0.1);
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

	/**
	 * Loads saved sound preferences if they exist.
	 */
	function loadSavedPrefs():Void
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

	function set_volume(Volume:Float):Float
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
