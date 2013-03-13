package org.flixel;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.BitmapInt32;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageDisplayState;
import nme.errors.Error;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.media.Sound;
import nme.media.SoundTransform;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.TileSheetData;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.plugin.TimerManager;
import org.flixel.system.FlxQuadTree;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;
import org.flixel.tweens.misc.MultiVarTween;

#if !FLX_NO_DEBUG
import org.flixel.system.FlxDebugger;
import org.flixel.plugin.DebugPathDisplay;
#end

import org.flixel.system.input.FlxInputs;

#if !FLX_NO_TOUCH
import org.flixel.system.input.FlxTouchManager;
#end
#if !FLX_NO_KEYBOARD
import org.flixel.system.input.FlxKeyboard;
#end
#if !FLX_NO_MOUSE
import org.flixel.system.input.FlxMouse;
#end
#if !FLX_NO_JOYSTICK
import org.flixel.system.input.FlxJoystickManager;
#end

/**
 * This is a global helper class full of useful functions for audio,
 * input, basic info, and the camera system among other things.
 * Utilities for maths and color and things can be found in <code>FlxU</code>.
 * <code>FlxG</code> is specifically for Flixel-specific properties.
 */
class FlxG 
{
	/**
	 * Indicates whether the current environment supports basic touch input, such as a single finger tap.
	 */
	public static var supportsTouchEvents:Bool = false;

	/**
	 * Global tweener for tweening between multiple worlds
	 */
	public static var tweener:FlxBasic = new FlxBasic();
	
	#if neko
	public static var bgColor(get_bgColor, set_bgColor):BitmapInt32;
	#else
	public static var bgColor(get_bgColor, set_bgColor):Int;
	#end
	
	public static var flashFramerate(get_flashFramerate, set_flashFramerate):Int;
	
	public function new() { }
	
	/**
	 * If you build and maintain your own version of flixel,
	 * you can give it your own name here.
	 */
	static public inline var LIBRARY_NAME:String = "HaxeFlixel";
	
	/**
	 * Assign a major version to your library.
	 * Appears before the decimal in the console.
	 */
	static public inline var LIBRARY_MAJOR_VERSION:String = "1";
	
	/**
	 * Assign a minor version to your library.
	 * Appears after the decimal in the console.
	 */
	static public inline var LIBRARY_MINOR_VERSION:String = "09";
	
	#if !FLX_NO_DEBUG
	/**
	 * Debugger overlay layout preset: Wide but low windows at the bottom of the screen.
	 */
	static public inline var DEBUGGER_STANDARD:Int = 0;
	
	/**
	 * Debugger overlay layout preset: Tiny windows in the screen corners.
	 */
	static public inline var DEBUGGER_MICRO:Int = 1;
	
	/**
	 * Debugger overlay layout preset: Large windows taking up bottom half of screen.
	 */
	static public inline var DEBUGGER_BIG:Int = 2;
	
	/**
	 * Debugger overlay layout preset: Wide but low windows at the top of the screen.
	 */
	static public inline var DEBUGGER_TOP:Int = 3;
	
	/**
	 * Debugger overlay layout preset: Large windows taking up left third of screen.
	 */
	static public inline var DEBUGGER_LEFT:Int = 4;
	
	/**
	 * Debugger overlay layout preset: Large windows taking up right third of screen.
	 */
	static public inline var DEBUGGER_RIGHT:Int = 5;
	#end
	
	/**
	 * Some handy color presets.  Less glaring than pure RGB full values.
	 * Primarily used in the visual debugger mode for bounding box displays.
	 * Red is used to indicate an active, movable, solid object.
	 */
	#if neko
	static public inline var RED:BitmapInt32 = { rgb: 0xff0012, a: 0xff };
	#else
	static public inline var RED:Int = 0xffff0012;
	#end
	/**
	 * Green is used to indicate solid but immovable objects.
	 */
	#if neko
	static public inline var GREEN:BitmapInt32 = { rgb: 0x00f225, a: 0xff };
	#else
	static public inline var GREEN:Int = 0xff00f225;
	#end
	/**
	 * Blue is used to indicate non-solid objects.
	 */
	#if neko
	static public inline var BLUE:BitmapInt32 = { rgb: 0x0090e9, a: 0xff };
	#else
	static public inline var BLUE:Int = 0xff0090e9;
	#end
	/**
	 * Pink is used to indicate objects that are only partially solid, like one-way platforms.
	 */
	#if neko
	static public inline var PINK:BitmapInt32 = { rgb: 0xf01eff, a: 0xff };
	#else
	static public inline var PINK:Int = 0xfff01eff;
	#end
	/**
	 * White... for white stuff.
	 */
	#if neko
	static public inline var WHITE:BitmapInt32 = { rgb: 0xffffff, a: 0xff };
	#else
	static public inline var WHITE:Int = 0xffffffff;
	#end
	/**
	 * And black too.
	 */
	#if neko
	static public inline var BLACK:BitmapInt32 = {rgb: 0x000000, a: 0xff};
	#else
	static public inline var BLACK:Int = 0xff000000;
	#end
	/**
	 * Totally transparent color. Usefull for creating transparent BitmapData
	 */
	#if neko
	static public inline var TRANSPARENT:BitmapInt32 = {rgb: 0x000000, a: 0x00};
	#else
	static public inline var TRANSPARENT:Int = 0x00000000;
	#end
	
	/**
	 * Useful for rad-to-deg and deg-to-rad conversion.
	 */
	static public inline var DEG:Float = 180 / Math.PI;
	static public inline var RAD:Float = Math.PI / 180;
	
	/**
	 * Internal tracker for game object.
	 */
	static public var _game:FlxGame;
	/**
	 * Handy shared variable for implementing your own pause behavior.
	 */
	static public var paused:Bool;
	/**
	 * Whether you are running in Debug or Release mode.
	 * Set automatically by <code>FlxPreloader</code> during startup.
	 */
	static public var debug:Bool;
	/**
	 * Represents the amount of time in seconds that passed since last frame.
	 */
	static public var elapsed:Float;
	/**
	 * How fast or slow time should pass in the game; default is 1.0.
	 */
	static public var timeScale:Float;
	/**
	 * The width of the screen in game pixels.
	 */
	static public var width:Int;
	/**
	 * The height of the screen in game pixels.
	 */
	static public var height:Int;
	/**
	 * The dimensions of the game world, used by the quad tree for collisions and overlap checks.
	 */
	static public var worldBounds:FlxRect;
	/**
	 * How many times the quad tree should divide the world on each axis.
	 * Generally, sparse collisions can have fewer divisons,
	 * while denser collision activity usually profits from more.
	 * Default value is 6.
	 */
	static public var worldDivisions:Int;
	#if !FLX_NO_DEBUG
	/**
	 * Whether to show visual debug displays or not.
	 * Default = false.
	 */
	static public var visualDebug:Bool;
	#end
	/**
	 * Setting this to true will disable/skip stuff that isn't necessary for mobile platforms like Android. [BETA]
	 */
	static public var mobile:Bool; 
	/**
	 * The global random number generator seed (for deterministic behavior in recordings and saves).
	 */
	static public var globalSeed:Float;
	/**
	 * <code>FlxG.levels</code> and <code>FlxG.scores</code> are generic
	 * global variables that can be used for various cross-state stuff.
	 */
	static public var levels:Array<Dynamic>;
	static public var level:Int;
	static public var scores:Array<Dynamic>;
	static public var score:Int;
	/**
	 * <code>FlxG.saves</code> is a generic bucket for storing
	 * FlxSaves so you can access them whenever you want.
	 */
	static public var saves:Array<Dynamic>; 
	static public var save:Int;
	
	/**
	 * A handy container for a background music object.
	 */
	static public var music:FlxSound;
	/**
	 * A list of all the sounds being played in the game.
	 */
	static public var sounds:FlxTypedGroup<FlxSound>;
	/**
	 * Whether or not the game sounds are muted.
	 */
	static public var mute:Bool;

	/**
	 * An array of <code>FlxCamera</code> objects that are used to draw stuff.
	 * By default flixel creates one camera the size of the screen.
	 */
	static public var cameras:Array<FlxCamera>;
	/**
	 * By default this just refers to the first entry in the cameras array
	 * declared above, but you can do what you like with it.
	 */
	static public var camera:FlxCamera;
	/**
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's <code>draw()</code> call.
	 * @default false
	 */
	static public var useBufferLocking:Bool;
	/**
	 * Internal helper variable for clearing the cameras each frame.
	 */
	static private var _cameraRect:Rectangle;
	
	/**
	 * An array container for plugins.
	 * By default flixel uses a couple of plugins:
	 * DebugPathDisplay, and TimerManager.
	 */
	static public var plugins:Array<FlxBasic>;
	 
	/**
	 * Set this hook to get a callback whenever the volume changes.
	 * Function should take the form <code>myVolumeHandler(Volume:Number)</code>.
	 */
	static public var volumeHandler:Float->Void;
	
	/**
	 * Useful helper objects for doing Flash-specific rendering.
	 * Primarily used for "debug visuals" like drawing bounding boxes directly to the screen buffer.
	 */
	static public var flashGfxSprite:Sprite;
	static public var flashGfx:Graphics;

	/**
	 * Internal storage system to prevent graphics from being used repeatedly in memory.
	 */
	static public var _cache:Hash<BitmapData>;
	static public var _lastBitmapDataKey:String;

	#if !FLX_NO_MOUSE
	/**
	 * A reference to a <code>FlxMouse</code> object.  Important for input!
	 */
	static public var mouse:FlxMouse;
	#end

	#if !FLX_NO_KEYBOARD
	/**
	 * A reference to a <code>FlxKeyboard</code> object.  Important for input!
	 */
	static public var keys:FlxKeyboard;
	#end

	#if !FLX_NO_TOUCH
	/**
	 * A reference to a <code>TouchManager</code> object. Useful for devices with multitouch support
	 */
	public static var touchManager:FlxTouchManager;
	#end
	
	#if (!FLX_NO_JOYSTICK && (cpp||neko))
	/**
	 * A reference to a <code>JoystickManager</code> object. Important for input!
	 * Set the instance in the FlxInputs class
	 */
	public static var joystickManager:FlxJoystickManager;
	#end
	
	static public function getLibraryName():String
	{
		return FlxG.LIBRARY_NAME + " v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION;
	}
	
	/**
	 * Log data to the debugger.
	 * @param	Data		Anything you want to log to the console.
	 */
	static public inline function log(Data:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
		{
			_game.debugger.log.add((Data == null) ? "ERROR: null object" : (Std.is(Data, Array) ? FlxU.formatArray(cast(Data, Array<Dynamic>)):Std.string(Data)));
		}
		#end
	}
	
	/**
	 * Clears the log output.
	 */
	static public function clearLog():Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
		{
			_game.debugger.log.clear();
		}
		#end
	}
	
	/**
	 * Add a variable to the watch list in the debugger.
	 * This lets you see the value of the variable all the time.
	 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 * @param	DisplayName		Optional, display your own string instead of the class name + variable name: e.g. "enemy count".
	 */
	static public function watch(AnyObject:Dynamic, VariableName:String, DisplayName:String = null):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game._debugger != null))
		{
			_game._debugger.watch.add(AnyObject, VariableName, DisplayName);
		}
		#end
	}
	
	/**
	 * Remove a variable from the watch list in the debugger.
	 * Don't pass a Variable Name to remove all watched variables for the specified object.
	 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 */
	static public function unwatch(AnyObject:Dynamic, VariableName:String = null):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game._debugger != null))
		{
			_game._debugger.watch.remove(AnyObject, VariableName);
		}
		#end
	}
	
	public static var framerate(get_framerate, set_framerate):Int;
	
	/**
	 * How many times you want your game to update each second.
	 * More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the Flash Player framerate!
	 */
	static private function get_framerate():Int
	{
		return Std.int(1000 / _game._step);
	}
		
	/**
	 * @private
	 */
	static private function set_framerate(Framerate:Int):Int
	{
		_game._step = Std.int(Math.abs(1000 / Framerate));
		_game._stepSeconds = (_game._step / 1000);
		if (_game._maxAccumulation < _game._step)
		{
			_game._maxAccumulation = _game._step;
		}
		return Framerate;
	}
	
	/**
	 * How many times you want your game to update each second.
	 * More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the Flash Player framerate!
	 */
	static private function get_flashFramerate():Int
	{
		if (_game.stage != null)
			return Std.int(_game.stage.frameRate);
		return 0;
	}
		
	/**
	 * @private
	 */
	static private function set_flashFramerate(Framerate:Int):Int
	{
		_game._flashFramerate = Std.int(Math.abs(Framerate));
		if (_game.stage != null)
		{
			_game.stage.frameRate = _game._flashFramerate;
		}
		_game._maxAccumulation = Std.int(2000 / _game._flashFramerate) - 1;
		if (_game._maxAccumulation < _game._step)
		{
			_game._maxAccumulation = _game._step;
		}
		return Framerate;
	}
	
	#if flash
	/**
	 * Switch to full-screen display.
	 */
	static public function fullscreen():Void
	{
		FlxG.stage.displayState = StageDisplayState.FULL_SCREEN;
		var fsw:Int = Std.int(FlxG.width * FlxG.camera.zoom);
		var fsh:Int = Std.int(FlxG.height * FlxG.camera.zoom);
		FlxG.camera.x = (FlxG.stage.fullScreenWidth - fsw) / 2;
		FlxG.camera.y = (FlxG.stage.fullScreenHeight - fsh) / 2;
	}
	#end
	
	/**
	 * Generates a random number.  Deterministic, meaning safe
	 * to use if you want to record replays in random environments.
	 * @return	A <code>Number</code> between 0 and 1.
	 */
	inline static public function random():Float
	{
		globalSeed = FlxU.srand(globalSeed);
		if (globalSeed <= 0) globalSeed += 1;
		return globalSeed;
	}
		
	/**
	 * Shuffles the entries in an array into a new random order.
	 * <code>FlxG.shuffle()</code> is deterministic and safe for use with replays/recordings.
	 * HOWEVER, <code>FlxU.shuffle()</code> is NOT deterministic and unsafe for use with replays/recordings.
	 * @param	A				A Flash <code>Array</code> object containing...stuff.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
	 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
	 */
	inline static public function shuffle(Objects:Array<Dynamic>, HowManyTimes:Int):Array<Dynamic>
	{
		HowManyTimes = Std.int(Math.max(HowManyTimes, 0));
		var i:Int = 0;
		var index1:Int;
		var index2:Int;
		var object:Dynamic;
		while (i < HowManyTimes)
		{
			index1 = Std.int(FlxG.random() * Objects.length);
			index2 = Std.int(FlxG.random() * Objects.length);
			object = Objects[index2];
			Objects[index2] = Objects[index1];
			Objects[index1] = object;
			i++;
		}
		return Objects;
	}
		
	/**
	 * Fetch a random entry from the given array.
	 * Will return null if random selection is missing, or array has no entries.
	 * <code>FlxG.getRandom()</code> is deterministic and safe for use with replays/recordings.
	 * HOWEVER, <code>FlxU.getRandom()</code> is NOT deterministic and unsafe for use with replays/recordings.
	 * @param	Objects		A Flash array of objects.
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	The random object that was selected.
	 */
	static public function getRandom(Objects:Array<Dynamic>, StartIndex:Int = 0, Length:Int = 0):Dynamic
	{
		if (Objects != null)
		{
			if (StartIndex < 0) StartIndex = 0;
			if (Length < 0) Length = 0;
			
			var l:Int = Length;
			if ((l == 0) || (l > Objects.length - StartIndex))
			{
				l = Objects.length - StartIndex;
			}
			if (l > 0)
			{
				return Objects[StartIndex + Std.int(FlxG.random() * l)];
			}
		}
		return null;
	}
		
	#if !FLX_NO_RECORD
	/**
	 * Load replay data from a string and play it back.
	 * @param	Data		The replay that you want to load.
	 * @param	State		Optional parameter: if you recorded a state-specific demo or cutscene, pass a new instance of that state here.
	 * @param	CancelKeys	Optional parameter: an array of string names of keys (see FlxKeyboard) that can be pressed to cancel the playback, e.g. ["ESCAPE","ENTER"].  Also accepts 2 custom key names: "ANY" and "MOUSE" (fairly self-explanatory I hope!).
	 * @param	Timeout		Optional parameter: set a time limit for the replay.  CancelKeys will override this if pressed.
	 * @param	Callback	Optional parameter: if set, called when the replay finishes.  Running to the end, CancelKeys, and Timeout will all trigger Callback(), but only once, and CancelKeys and Timeout will NOT call FlxG.stopReplay() if Callback is set!
	 */
	static public function loadReplay(Data:String, State:FlxState = null, CancelKeys:Array<String> = null, Timeout:Float = 0, Callback:Void->Void = null):Void
	{
		_game._replay.load(Data);
		if (State == null)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.switchState(State);
		}
		_game._replayCancelKeys = CancelKeys;
		_game._replayTimer = Std.int(Timeout * 1000);
		_game._replayCallback = Callback;
		_game._replayRequested = true;
	}
	#end

	/**
	 * Resets the game or state and replay requested flag.
	 * @param	StandardMode	If true, reload entire game, else just reload current game state.
	 */
	static public function reloadReplay(StandardMode:Bool = true):Void
	{
		if (StandardMode)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.resetState();
		}
		
		#if !FLX_NO_RECORD
		if (_game._replay.frameCount > 0)
		{
			_game._replayRequested = true;
		}
		#end
	}
	
	#if !FLX_NO_RECORD
	/**
	 * Stops the current replay.
	 */
	static public function stopReplay():Void
	{
		_game._replaying = false;
		#if !FLX_NO_DEBUG
		if (_game._debugger != null)
		{
			_game._debugger.vcr.stopped();
		}
		#end
		resetInput();
	}
		
	/**
	 * Resets the game or state and requests a new recording.
	 * @param	StandardMode	If true, reset the entire game, else just reset the current state.
	 */
	static public function recordReplay(StandardMode:Bool = true):Void
	{
		if (StandardMode)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.resetState();
		}
		_game._recordingRequested = true;
	}
	
	/**
	 * Stop recording the current replay and return the replay data.
	 * @return	The replay data in simple ASCII format (see <code>FlxReplay.save()</code>).
	 */
	static public function stopRecording():String
	{
		_game._recording = false;
		#if !FLX_NO_DEBUG
		if (_game._debugger != null)
		{
			_game._debugger.vcr.stopped();
		}
		#end
		return _game._replay.save();
	}
	#end
	
	/**
	 * Request a reset of the current game state.
	 */
	static public function resetState():Void
	{
		_game._requestedState = Type.createInstance(FlxU.getClass(FlxU.getClassName(_game._state, false)), []);
		#if !FLX_NO_DEBUG
		if (Std.is(_game._requestedState, FlxSubState))
		{
			throw "You can't set FlxSubState class instance as the state for you game";
		}
		#end
	}
	
	/**
	 * Like hitting the reset button a game console, this will re-launch the game as if it just started.
	 */
	static public function resetGame():Void
	{
		_game._requestedReset = true;
	}
	
	/**
	 * Reset the input helper objects (useful when changing screens or states)
	 */
	static public function resetInput():Void
	{
		FlxInputs.resetInputs();
	}
	
	// TODO: Return from Sound -> Class<Sound>
	/**
	 * Set up and play a looping background soundtrack.
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 */
	static public function playMusic(Music:Dynamic, Volume:Float = 1.0):Void
	{
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
	}
	
	/**
	 * Creates a new sound object. 
	 * @param	EmbeddedSound	The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @param	AutoPlay		Whether to play the sound.
	 * @param	URL				Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @return	A <code>FlxSound</code> object.
	 */
	static public function loadSound(EmbeddedSound:Dynamic = null, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = false, AutoPlay:Bool = false, URL:String = null):FlxSound
	{
		if((EmbeddedSound == null) && (URL == null))
		{
			FlxG.log("WARNING: FlxG.loadSound() requires either\nan embedded sound or a URL to work.");
			return null;
		}
		var sound:FlxSound = sounds.recycle(FlxSound);
		if (EmbeddedSound != null)
		{
			sound.loadEmbedded(EmbeddedSound, Looped, AutoDestroy);
		}
		else
		{
			sound.loadStream(URL, Looped, AutoDestroy);
		}
		sound.volume = Volume;
		if (AutoPlay)
		{
			sound.play();
		}
		return sound;
	}
	
	#if android
	private static var _soundCache:Hash<Sound> = new Hash<Sound>();
	private static var _soundTransform:SoundTransform = new SoundTransform();
	
	static public function addSound(EmbeddedSound:String):Sound
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
	
	static public function play(EmbeddedSound:String, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true):FlxSound
	{
		var sound:Sound = null;
		
		_soundTransform.volume = (FlxG.mute ? 0 : 1) * FlxG.volume * Volume;
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
	 * @param	EmbeddedSound	The sound you want to play.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @return	A <code>FlxSound</code> object.
	 */
	static public function play(EmbeddedSound:Dynamic, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true):FlxSound
	{
		return FlxG.loadSound(EmbeddedSound, Volume, Looped, AutoDestroy, true);
	}
	#end
		
	/**
	 * Creates a new sound object from a URL.
	 * NOTE: Just calls FlxG.loadSound() with AutoPlay == true.
	 * @param	URL		The URL of the sound you want to play.
	 * @param	Volume	How loud to play it (0 to 1).
	 * @param	Looped	Whether or not to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @return	A FlxSound object.
	 */
	static public function stream(URL:String, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true):FlxSound
	{
		return FlxG.loadSound(null, Volume, Looped, AutoDestroy, true, URL);
	}
	
	/**
	 * 
	 * Set <code>volume</code> to a number between 0 and 1 to change the global volume.
	 * 
	 * @default 0.5
	 */
	public static var volume(default, setVolume):Float;
	
	/**
	 * @private
	 */
	static private function setVolume(Volume:Float):Float
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
			var param:Float = FlxG.mute ? 0 : volume;
			volumeHandler(param);
		}
		return Volume;
	}

	/**
	 * Called by FlxGame on state changes to stop and destroy sounds.
	 * 
	 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
	 */
	static public function destroySounds(ForceDestroy:Bool = false):Void
	{
		if((music != null) && (ForceDestroy || !music.survive))
		{
			music.destroy();
			music = null;
		}
		var i:Int = 0;
		var sound:FlxSound;
		var l:Int = sounds.members.length;
		while(i < l)
		{
			sound = sounds.members[i++];
			if ((sound != null) && (ForceDestroy || !sound.survive))
			{
				sound.destroy();
			}
		}
	}
		
	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	static public function updateSounds():Void
	{
		if ((music != null) && music.active)
		{
			music.update();
		}
		if ((sounds != null) && sounds.active)
		{
			sounds.update();
		}
	}
	
	/**
	 * Pause all sounds currently playing.
	 */
	static public function pauseSounds():Void
	{
		if ((music != null) && music.exists && music.active)
		{
			music.pause();
		}
		var i:Int = 0;
		var sound:FlxSound;
		var l:Int = sounds.length;
		while(i < l)
		{
			sound = sounds.members[i++];
			if ((sound != null) && sound.exists && sound.active)
			{
				sound.pause();
			}
		}
	}
	
	/**
	 * Resume playing existing sounds.
	 */
	static public function resumeSounds():Void
	{
		if ((music != null) && music.exists)
		{
			music.play();
		}
		var i:Int = 0;
		var sound:FlxSound;
		var l:Int = sounds.length;
		while(i < l)
		{
			sound = sounds.members[i++];
			if ((sound != null) && sound.exists)
			{
				sound.resume();
			}
		}
	}
	
	/**
	 * Check the local bitmap cache to see if a bitmap with this key has been loaded already.
	 * @param	Key		The string key identifying the bitmap.
	 * @return	Whether or not this file can be found in the cache.
	 */
	static public function checkBitmapCache(Key:String):Bool
	{
		return (_cache.exists(Key) && _cache.get(Key) != null);
	}
		
	/**
	 * Generates a new <code>BitmapData</code> object (a colored square) and caches it.
	 * @param	Width	How wide the square should be.
	 * @param	Height	How high the square should be.
	 * @param	Color	What color the square should be (0xAARRGGBB)
	 * @param	Unique	Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key		Force the cache to use a specific Key to index the bitmap.
	 * @return	The <code>BitmapData</code> we just created.
	 */
	#if flash
	static public function createBitmap(Width:UInt, Height:UInt, Color:UInt, Unique:Bool = false, Key:String = null):BitmapData
	#else
	static public function createBitmap(Width:Int, Height:Int, Color:BitmapInt32, Unique:Bool = false, Key:String = null):BitmapData
	#end
	{
		var key:String = Key;
		if (key == null)
		{
			#if !neko
			key = Width + "x" + Height + ":" + Color;
			#else
			key = Width + "x" + Height + ":" + Color.a + "." + Color.rgb;
			#end
			if (Unique && checkBitmapCache(key))
			{
				key = getUniqueBitmapKey(key);
			}
		}
		if (!checkBitmapCache(key))
		{
			_cache.set(key, new BitmapData(Width, Height, true, Color));
		}
		_lastBitmapDataKey = key;
		return _cache.get(key);
	}
	
	/**
	 * Loads a bitmap from a file, caches it, and generates a horizontally flipped version if necessary.
	 * @param	Graphic		The image file that you want to load.
	 * @param	Reverse		Whether to generate a flipped version.
	 * @param	Unique		Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key			Force the cache to use a specific Key to index the bitmap.
	 * @return	The <code>BitmapData</code> we just created.
	 */
	static public function addBitmap(Graphic:Dynamic, Reverse:Bool = false, Unique:Bool = false, Key:String = null, FrameWidth:Int = 0, FrameHeight:Int = 0):BitmapData
	{
		if (Graphic == null)
		{
			return null;
		}
		
		var isClass:Bool = true;
		var isBitmap:Bool = true;
		if (Std.is(Graphic, Class))
		{
			isClass = true;
			isBitmap = false;
		}
		else if (Std.is(Graphic, BitmapData))
		{
			isClass = false;
			isBitmap = true;
		}
		else if (Std.is(Graphic, String))
		{
			isClass = false;
			isBitmap = false;
		}
		else
		{
			return null;
		}
		
		var additionalKey:String = "";
		#if !flash
		if (FrameWidth != 0 || FrameHeight != 0/* || isBitmap*/)
		{
			additionalKey = "FrameSize:" + FrameWidth + "_" + FrameHeight;
		}
		#end
		
		var key:String = Key;
		if (key == null)
		{
			if (isClass)
			{
				key = Type.getClassName(cast(Graphic, Class<Dynamic>));
			}
			else if (isBitmap)
			{
				if (!Unique)
				{
					key = FlxG.getCacheKeyFor(cast Graphic);
					if (key == null)
					{
						key = getUniqueBitmapKey();
					}
				}
			}
			else
			{
				key = Graphic;
			}
			key += (Reverse ? "_REVERSE_" : "");
			key += additionalKey;
			
			if (Unique)
			{
				key = getUniqueBitmapKey((key == null) ? "pixels" : key);
			}
		}
		
		var tempBitmap:BitmapData;
		
		// If there is no data for this key, generate the requested graphic
		if (!checkBitmapCache(key))
		{
			var bd:BitmapData = null;
			if (isClass)
			{
				bd = Type.createInstance(cast(Graphic, Class<Dynamic>), []).bitmapData;
			}
			else if (isBitmap)
			{
				bd = cast Graphic;
			}
			else
			{
				bd = FlxAssets.getBitmapData(Graphic);
			}
			
			#if !flash
			if (additionalKey != "")
			{
				var numHorizontalFrames:Int = (FrameWidth == 0) ? 1 : Std.int(bd.width / FrameWidth);
				var numVerticalFrames:Int = (FrameHeight == 0) ? 1 : Std.int(bd.height / FrameHeight);
				
				FrameWidth = (FrameWidth == 0) ? bd.width : FrameWidth;
				FrameHeight = (FrameHeight == 0) ? bd.height : FrameHeight;
				
				var tempBitmap:BitmapData = new BitmapData(bd.width + numHorizontalFrames, bd.height + numVerticalFrames, true, FlxG.TRANSPARENT);
				
				var tempRect:Rectangle = new Rectangle(0, 0, FrameWidth, FrameHeight);
				var tempPoint:Point = new Point();
				
				for (i in 0...(numHorizontalFrames))
				{
					tempPoint.x = i * (FrameWidth + 1);
					tempRect.x = i * FrameWidth;
					
					for (j in 0...(numVerticalFrames))
					{
						tempPoint.y = j * (FrameHeight + 1);
						tempRect.y = j * FrameHeight;
						tempBitmap.copyPixels(bd, tempRect, tempPoint);
					}
				}
				
				bd = tempBitmap;
			}
			#else
			if (Reverse)
			{
				var newPixels:BitmapData = new BitmapData(bd.width * 2, bd.height, true, 0x00000000);
				newPixels.draw(bd);
				var mtx:Matrix = new Matrix();
				mtx.scale(-1,1);
				mtx.translate(newPixels.width, 0);
				newPixels.draw(bd, mtx);
				bd = newPixels;
				
			}
			#end
			else if (Unique)	
			{
				bd = bd.clone();
			}
			
			_cache.set(key, bd);
		}
		
		_lastBitmapDataKey = key;
		return _cache.get(key);
	}
	
	/**
	 * Gets key from bitmap cache for specified bitmapdata
	 * @param	bmd	bitmapdata to find in cache
	 * @return	bitmapdata's key or null if there isn't such bitmapdata in cache
	 */
	public static function getCacheKeyFor(bmd:BitmapData):String
	{
		for (key in _cache.keys())
		{
			var data:BitmapData = _cache.get(key);
			if (data == bmd)
			{
				return key;
			}
		}
		return null;
	}
	
	/**
	 * Gets unique key for bitmap cache
	 * @param	baseKey	key's prefix
	 * @return	unique key
	 */
	public static function getUniqueBitmapKey(baseKey:String = "pixels"):String
	{
		if (checkBitmapCache(baseKey))
		{
			var inc:Int = 0;
			var ukey:String;
			do
			{
				ukey = baseKey + inc++;
			} while(checkBitmapCache(ukey));
			baseKey = ukey;
		}
		return baseKey;
	}
	
	private static function fromAssetsCache(bmd:BitmapData):Bool
	{
		var cachedBitmapData:Hash<BitmapData> = Assets.cachedBitmapData;
		if (cachedBitmapData != null)
		{
			for (key in cachedBitmapData.keys())
			{
				var cacheBmd:BitmapData = cachedBitmapData.get(key);
				if (cacheBmd == bmd)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * Removes bitmapdata from cache
	 * @param	Graphic	bitmapdata's key to remove
	 */
	public static function removeBitmap(Graphic:String):Void
	{
		if (_cache.exists(Graphic))
		{
			var bmd:BitmapData = _cache.get(Graphic);
			_cache.remove(Graphic);
			if (fromAssetsCache(bmd) == false)
			{
				bmd.dispose();
				bmd = null;
			}
		}
	}
	
	/**
	 * Dumps the cache's image references.
	 */
	static public function clearBitmapCache():Void
	{
		var bmd:BitmapData;
		if (_cache != null)
		{
			for (key in _cache.keys())
			{
				bmd = _cache.get(key);
				_cache.remove(key);
				if (bmd != null && fromAssetsCache(bmd) == false)
				{
					bmd.dispose();
					bmd = null;
				}
			}
		}
		_cache = new Hash();
	}
	
	/**
	 * Clears nme.Assests.cachedBitmapData. Use it only when you need it and know what are you doing.
	 */
	static public function clearAssetsCache():Void
	{
		for (key in Assets.cachedBitmapData.keys())
		{
			var bmd:BitmapData = Assets.cachedBitmapData.get(key);
			bmd.dispose();
			Assets.cachedBitmapData.remove(key);
		}
	}
	
	public static var stage(get_stage, null):Stage;
	
	/**
	 * Read-only: retrieves the Flash stage object (required for event listeners)
	 * Will be null if it's not safe/useful yet.
	 */
	static private function get_stage():Stage
	{
		if (_game.stage != null)
		{
			return _game.stage;
		}
		return null;
	}
	
	public static var state(get_state, null):FlxState;
	
	/**
	 * Read-only: access the current game state from anywhere.
	 */
	static private function get_state():FlxState
	{
		return _game._state;
	}
	
	/**
	 * Switch from the current game state to the one specified here.
	 */
	static public function switchState(State:FlxState):Void
	{
		_game._requestedState = State;
	}

	#if !FLX_NO_DEBUG
	/**
	 * Change the way the debugger's windows are laid out.
	 * @param	Layout		See the presets above (e.g. <code>DEBUGGER_MICRO</code>, etc).
	 */
	static public function setDebuggerLayout(Layout:Int):Void
	{
		_game._debugger.setLayout(Layout);
	}
	
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (<code>DEBUGGER_STANDARD</code> by default).
	 */
	static public function resetDebuggerLayout():Void
	{
		_game._debugger.resetLayout();
	}
	#end
	
	/**
	 * Add a new camera object to the game.
	 * Handy for PiP, split-screen, etc.
	 * @param	NewCamera	The camera you want to add.
	 * @return	This <code>FlxCamera</code> instance.
	 */
	static public function addCamera(NewCamera:FlxCamera):FlxCamera
	{
		FlxG._game.addChildAt(NewCamera._flashSprite, FlxG._game.getChildIndex(FlxG._game._inputContainer));
		FlxG.cameras.push(NewCamera);
		NewCamera.ID = FlxG.cameras.length - 1;
		return NewCamera;
	}
	
	/**
	 * Remove a camera from the game.
	 * @param	Camera	The camera you want to remove.
	 * @param	Destroy	Whether to call destroy() on the camera, default value is true.
	 */
	static public function removeCamera(Camera:FlxCamera, Destroy:Bool = true):Void
	{
		if (Camera != null && FlxG._game.contains(Camera._flashSprite))
		{
			FlxG._game.removeChild(Camera._flashSprite);
			var index = FlxU.ArrayIndexOf(FlxG.cameras, Camera);
			if(index >= 0)
				FlxG.cameras.splice(index, 1);
		}
		else
		{
			FlxG.log("Error removing camera, not part of game.");
		}
		
		#if !flash
		for (i in 0...(FlxG.cameras.length))
		{
			FlxG.cameras[i].ID = i;
		}
		#end
		
		if (Destroy)
		{
			Camera.destroy();
		}
	}
		
	/**
	 * Dumps all the current cameras and resets to just one camera.
	 * Handy for doing split-screen especially.
	 * 
	 * @param	NewCamera	Optional; specify a specific camera object to be the new main camera.
	 */
	static public function resetCameras(NewCamera:FlxCamera = null):Void
	{
		var cam:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		while(i < l)
		{
			cam = FlxG.cameras[i++];
			FlxG._game.removeChild(cam._flashSprite);
			cam.destroy();
		}
		FlxG.cameras.splice(0, FlxG.cameras.length);
		
		if (NewCamera == null)	
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		
		FlxG.camera = FlxG.addCamera(NewCamera);
		NewCamera.ID = 0;
	}
	
	/**
	 * All screens are filled with this color and gradually return to normal.
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	#if flash
	static public function flash(?Color:UInt = 0xffffffff, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
	#else
	static public function flash(?Color:BitmapInt32, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
	#end
	{
		#if !flash
		if (Color == null)
		{
			Color = WHITE;
		}
		#end
		
		var i:Int = 0;
		var l:Int = FlxG.cameras.length;
		while (i < l)
		{
			FlxG.cameras[i++].flash(Color, Duration, OnComplete, Force);
		}
	}
	
	/**
	 * The screen is gradually filled with this color.
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the fade to finish.
	 * @param 	FadeIn 		True fades from a color, false fades to it.
	 * @param	OnComplete	A function you want to run when the fade finishes.
	 * @param	Force		Force the effect to reset.
	 */
	#if flash
	static public function fade(?Color:UInt = 0xff000000, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
	#else
	static public function fade(?Color:BitmapInt32, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
	#end
	{
		#if !flash
		if (Color == null)
		{
			Color = FlxG.BLACK;
		}
		#end
		
		var i:Int = 0;
		var l:Int = FlxG.cameras.length;
		while (i < l)
		{
			FlxG.cameras[i++].fade(Color, Duration, FadeIn, OnComplete, Force);
		}
	}
	
	/**
	 * A simple screen-shake effect.
	 * @param	Intensity	Percentage of screen size representing the maximum distance that the screen can move while shaking.
	 * @param	Duration	The length in seconds that the shaking effect should last.
	 * @param	OnComplete	A function you want to run when the shake effect finishes.
	 * @param	Force		Force the effect to reset (default = true, unlike flash() and fade()!).
	 * @param	Direction	Whether to shake on both axes, just up and down, or just side to side (use class constants SHAKE_BOTH_AXES, SHAKE_VERTICAL_ONLY, or SHAKE_HORIZONTAL_ONLY).  Default value is SHAKE_BOTH_AXES (0).
	 */
	static public function shake(Intensity:Float = 0.05, Duration:Float = 0.5, OnComplete:Void->Void = null, Force:Bool = true, Direction:Int = 0):Void
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.length;
		while (i < l)
		{
			FlxG.cameras[i++].shake(Intensity, Duration, OnComplete, Force, Direction);
		}
	}
	
	/**
	 * Get and set the background color of the game.
	 * Get functionality is equivalent to FlxG.camera.bgColor.
	 * Set functionality sets the background color of all the current cameras.
	 */
	#if flash
	static private function get_bgColor():UInt
	#else
	static private function get_bgColor():BitmapInt32
	#end
	{
		if (FlxG.camera == null)
		{
			return FlxG.BLACK;
		}
		else
		{
			return FlxG.camera.bgColor;
		}
	}
	
	#if flash
	static private function set_bgColor(Color:UInt):UInt
	#else
	static private function set_bgColor(Color:BitmapInt32):BitmapInt32
	#end
	{
		var i:Int = 0;
		var l:Int = FlxG.cameras.length;
		while (i < l)
		{
			FlxG.cameras[i++].bgColor = Color;
		}
		return Color;
	}

	/**
	 * Call this function to see if one <code>FlxObject</code> overlaps another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a <code>FlxGroup</code> (or even bundling groups together!).
	 * <p>NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.</p>
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.
	 * @param	ProcessCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.  If a ProcessCallback is provided, then NotifyCallback will only be called if ProcessCallback returns true for those objects!
	 * @return	Whether any overlaps were detected.
	 */
	inline static public function overlap(ObjectOrGroup1:FlxBasic = null, ObjectOrGroup2:FlxBasic = null, NotifyCallback:FlxObject->FlxObject->Void = null, ProcessCallback:FlxObject->FlxObject->Bool = null):Bool
	{
		if (ObjectOrGroup1 == null)
		{
			ObjectOrGroup1 = FlxG.state;
		}
		if (ObjectOrGroup2 == ObjectOrGroup1)
		{
			ObjectOrGroup2 = null;
		}
		FlxQuadTree.divisions = FlxG.worldDivisions;
		var quadTree:FlxQuadTree = FlxQuadTree.recycle(FlxG.worldBounds.x, FlxG.worldBounds.y, FlxG.worldBounds.width, FlxG.worldBounds.height);
		quadTree.load(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
		var result:Bool = quadTree.execute();
		quadTree.destroy();
		return result;
	}
	
	/**
	 * Call this function to see if one <code>FlxObject</code> collides with another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a <code>FlxGroup</code> (or even bundling groups together!).
	 * <p>This function just calls FlxG.overlap and presets the ProcessCallback parameter to FlxObject.separate.
	 * To create your own collision logic, write your own ProcessCallback and use FlxG.overlap to set it up.</p>
	 * <p>NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.</p>
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.
	 * @return	Whether any objects were successfully collided/separated.
	 */
	inline static public function collide(ObjectOrGroup1:FlxBasic = null, ObjectOrGroup2:FlxBasic = null, NotifyCallback:FlxObject->FlxObject->Void = null):Bool
	{
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, FlxObject.separate);
	}
	
	/**
	 * Adds a new plugin to the global plugin array.
	 * @param	Plugin	Any object that extends FlxBasic. Useful for managers and other things.  See org.flixel.plugin for some examples!
	 * @return	The same <code>FlxBasic</code>-based plugin you passed in.
	 */
	static public function addPlugin(Plugin:FlxBasic):FlxBasic
	{
		//Don't add repeats
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var l:Int = pluginList.length;
		for (i in 0...l)
		{
			if (pluginList[i].toString() == Plugin.toString())
			{
				return Plugin;
			}
		}
		
		//no repeats! safe to add a new instance of this plugin
		pluginList.push(Plugin);
		return Plugin;
	}
	
	/**
	 * Retrieves a plugin based on its class name from the global plugin array.
	 * @param	ClassType	The class name of the plugin you want to retrieve. See the <code>FlxPath</code> or <code>FlxTimer</code> constructors for example usage.
	 * @return	The plugin object, or null if no matching plugin was found.
	 */
	static public function getPlugin(ClassType:Class<FlxBasic>):FlxBasic
	{
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			if (Std.is(pluginList[i], ClassType))
			{
				return plugins[i];
			}
			i++;
		}
		return null;
	}
	
	/**
	 * Removes an instance of a plugin from the global plugin array.
	 * @param	Plugin	The plugin instance you want to remove.
	 * @return	The same <code>FlxBasic</code>-based plugin you passed in.
	 */
	static public function removePlugin(Plugin:FlxBasic):FlxBasic
	{
		//Don't add repeats
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var i:Int = pluginList.length-1;
		while(i >= 0)
		{
			if (pluginList[i] == Plugin)
			{
				pluginList.splice(i, 1);
				return Plugin;
			}
			i--;
		}
		return Plugin;
	}
	
	/**
	 * Removes all instances of a plugin from the global plugin array.
	 * @param	ClassType	The class name of the plugin type you want removed from the array.
	 * @return	Whether or not at least one instance of this plugin type was removed.
	 */
	static public function removePluginType(ClassType:Class<FlxBasic>):Bool
	{
		//Don't add repeats
		var results:Bool = false;
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var i:Int = pluginList.length - 1;
		while(i >= 0)
		{
			if (Std.is(pluginList[i], ClassType))
			{
				pluginList.splice(i,1);
				results = true;
			}
			i--;
		}
		return results;
	}
	
	/**
	 * Called by <code>FlxGame</code> to set up <code>FlxG</code> during <code>FlxGame</code>'s constructor.
	 */
	static public function init(Game:FlxGame, Width:Int, Height:Int, Zoom:Float):Void
	{
		// TODO: check this later on real device
		//FlxAssets.cacheSounds();
		FlxG.clearBitmapCache();
		
		FlxG._game = Game;
		FlxG.width = Std.int(Math.abs(Width));
		FlxG.height = Std.int(Math.abs(Height));
		
		FlxG.mute = false;
		FlxG.volume = 0.5;
		FlxG.sounds = new FlxTypedGroup<FlxSound>();
		FlxG.volumeHandler = null;
		
		if(flashGfxSprite == null)
		{
			flashGfxSprite = new Sprite();
			flashGfx = flashGfxSprite.graphics;
		}

		FlxCamera.defaultZoom = Zoom;
		FlxG._cameraRect = new Rectangle();
		FlxG.cameras = new Array<FlxCamera>();
		useBufferLocking = false;
		
		plugins = new Array<FlxBasic>();
		
		#if !FLX_NO_DEBUG
		addPlugin(new DebugPathDisplay());
		#end
		
		addPlugin(new TimerManager());
		
		#if js
		FlxG.mobile = true;
		#else
		FlxG.mobile = false;
		#end

		FlxG.levels = new Array();
		FlxG.scores = new Array();
		
		#if !FLX_NO_DEBUG
		FlxG.visualDebug = false;
		#end
	}
	
	/**
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	static public function reset():Void
	{
		#if !flash
		PxBitmapFont.clearStorage();
		Atlas.clearAtlasCache();
		TileSheetData.clear();
		#end
		FlxG.clearBitmapCache();
		FlxG.resetInput();
		FlxG.destroySounds(true);
		FlxG.levels = [];
		FlxG.scores = [];
		FlxG.level = 0;
		FlxG.score = 0;
		FlxG.paused = false;
		FlxG.timeScale = 1.0;
		FlxG.elapsed = 0;
		FlxG.globalSeed = Math.random();
		FlxG.worldBounds = new FlxRect( -10, -10, FlxG.width + 20, FlxG.height + 20);
		FlxG.worldDivisions = 6;
		#if !FLX_NO_DEBUG
		var debugPathDisplay:DebugPathDisplay = cast(FlxG.getPlugin(DebugPathDisplay), DebugPathDisplay);
		if (debugPathDisplay != null)
		{
			debugPathDisplay.clear();
		}
		#end
	}
	
	/**
	 * Called by the game object to update all the inputs enabled in FlxInputs
	 */
	inline static public function updateInputs():Void
	{
		FlxInputs.updateInputs();
	}
	
	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	inline static public function lockCameras():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			
			#if flash
			if (useBufferLocking)
			{
				cam.buffer.lock();
			}
			#end
			
			#if !flash
			cam.clearDrawStack();
			cam._canvas.graphics.clear();
			// clearing camera's debug sprite
			cam._effectsLayer.graphics.clear();
			#end
			
			#if flash
			cam.fill(cam.bgColor);
			cam.screen.dirty = true;
			#elseif neko
			cam.fill(cam.bgColor, true, cam.bgColor.a / 255);
			#else
			cam.fill((cam.bgColor & 0x00ffffff), true, ((cam.bgColor >> 24) & 255) / 255);
			#end
		}
	}
	
	#if !flash
	inline static public function renderCameras():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			
			cam.render();
		}
	}
	#end
	
	/**
	 * Called by the game object to draw the special FX and unlock all the camera buffers.
	 */
	inline static public function unlockCameras():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			cam.drawFX();
			
			#if flash
			if (useBufferLocking)
			{
				cam.buffer.unlock();
			}
			#end
		}
	}
	
	/**
	 * Called by the game object to update the cameras and their tracking/special effects logic.
	 */
	inline static public function updateCameras():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras;
		var i:Int = 0;
		var l:Int = cams.length;
		while (i < l)
		{
			cam = cams[i++];
			if ((cam != null) && cam.exists)
			{
				if (cam.active)
				{
					cam.update();
				}

				if (cam.target == null) 
				{
					cam._flashSprite.x = cam.x + cam._flashOffsetX;
					cam._flashSprite.y = cam.y + cam._flashOffsetY;
				}
				
				cam._flashSprite.visible = cam.visible;
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>update()</code> on all the plugins.
	 */
	inline static public function updatePlugins():Void
	{
		var plugin:FlxBasic;
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			plugin = pluginList[i++];
			if (plugin.exists && plugin.active)
			{
				plugin.update();
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>draw()</code> on all the plugins.
	 */
	inline static public function drawPlugins():Void
	{
		var plugin:FlxBasic;
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			plugin = pluginList[i++];
			if (plugin.exists && plugin.visible)
			{
				plugin.draw();
			}
		}
	}
	/**
	 * Tweens numeric public properties of an Object. Shorthand for creating a MultiVarTween tween, starting it and adding it to a Tweener.
	 * @param	object		The object containing the properties to tween.
	 * @param	values		An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * 						tweener		The Tweener to add this Tween to.
	 * @return	The added MultiVarTween object.
	 *
	 * Example: FlxG.tween(object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, complete: onComplete } );
	 */
	public static function tween(object:Dynamic, values:Dynamic, duration:Float, options:Dynamic = null):MultiVarTween
	{
		var type:Int = FlxTween.ONESHOT,
			complete:CompleteCallback = null,
			ease:EaseFunction = null,
			tweener:FlxBasic = FlxG.tweener;
		if (Std.is(object, FlxBasic)) 
		{
			tweener = cast(object, FlxBasic);
		}
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
			if (Reflect.hasField(options, "tweener")) tweener = options.tweener;
		}
		var tween:MultiVarTween = new MultiVarTween(complete, type);
		tween.tween(object, values, duration, ease);
		tweener.addTween(tween);
		return tween;
	}
	
}