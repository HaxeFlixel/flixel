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

#if (cpp || neko)
import org.flixel.system.input.JoystickManager;
#end

import org.flixel.system.input.TouchManager;
import nme.ui.Multitouch;

import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.system.input.Keyboard;
import org.flixel.system.input.Mouse;
import org.flixel.system.tileSheet.TileSheetManager;
import org.flixel.tweens.misc.MultiVarTween;

import org.flixel.plugin.DebugPathDisplay;
import org.flixel.plugin.TimerManager;
import org.flixel.system.FlxDebugger;
import org.flixel.system.FlxQuadTree;

import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * This is a global helper class full of useful functions for audio,
 * input, basic info, and the camera system among other things.
 * Utilities for maths and color and things can be found in <code>FlxU</code>.
 * <code>FlxG</code> is specifically for Flixel-specific properties.
 */
class FlxG 
{
	
	/**
	 * The maximum number of concurrent touch points supported by the current device.
	 */
	public static var maxTouchPoints:Int = 0;
	
	/**
	 * Indicates whether the current environment supports basic touch input, such as a single finger tap.
	 */
	public static var supportsTouchEvents:Bool = false;
	
	/**
	 * A reference to a <code>TouchManager</code> object. Useful for devices with multitouch support
	 */
	public static var touchManager:TouchManager;
	
	#if (cpp || neko)
	/**
	 * A reference to a <code>JoystickManager</code> object. Important for input!
	 */
	public static var joystickManager:JoystickManager;
	#end
	
	/**
	 * Global tweener for tweening between multiple worlds
	 */
	public static var tweener:FlxBasic = new FlxBasic();
	
	#if flash
	public static var bgColor(getBgColor, setBgColor):UInt;
	#else
	public static var bgColor(getBgColor, setBgColor):BitmapInt32;
	#end
	
	public static var flashFramerate(getFlashFramerate, setFlashFramerate):Int;
	
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
	static public inline var LIBRARY_MINOR_VERSION:String = "06";
	
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
	
	/**
	 * Some handy color presets.  Less glaring than pure RGB full values.
	 * Primarily used in the visual debugger mode for bounding box displays.
	 * Red is used to indicate an active, movable, solid object.
	 */
	#if flash
	static public inline var RED:UInt = 0xffff0012;
	#elseif (cpp || js)
	static public inline var RED:BitmapInt32 = 0xffff0012;
	#elseif neko
	static public inline var RED:BitmapInt32 = {rgb: 0xff0012, a: 0xff};
	#end
	/**
	 * Green is used to indicate solid but immovable objects.
	 */
	#if flash
	static public inline var GREEN:UInt = 0xff00f225;
	#elseif (cpp || js)
	static public inline var GREEN:BitmapInt32 = 0xff00f225;
	#elseif neko
	static public inline var GREEN:BitmapInt32 = {rgb: 0x00f225, a: 0xff};
	#end
	/**
	 * Blue is used to indicate non-solid objects.
	 */
	#if flash
	static public inline var BLUE:UInt = 0xff0090e9;
	#elseif (cpp || js)
	static public inline var BLUE:BitmapInt32 = 0xff0090e9;
	#elseif neko
	static public inline var BLUE:BitmapInt32 = {rgb: 0x0090e9, a: 0xff};
	#end
	/**
	 * Pink is used to indicate objects that are only partially solid, like one-way platforms.
	 */
	#if flash
	static public inline var PINK:UInt = 0xfff01eff;
	#elseif (cpp || js)
	static public inline var PINK:BitmapInt32 = 0xfff01eff;
	#elseif neko
	static public inline var PINK:BitmapInt32 = {rgb: 0xf01eff, a: 0xff};
	#end
	/**
	 * White... for white stuff.
	 */
	#if flash
	static public inline var WHITE:UInt = 0xffffffff;
	#elseif (cpp || js)
	static public inline var WHITE:BitmapInt32 = 0xffffffff;
	#elseif neko
	static public inline var WHITE:BitmapInt32 = {rgb: 0xffffff, a: 0xff};
	#end
	/**
	 * And black too.
	 */
	#if flash
	static public inline var BLACK:UInt = 0xff000000;
	#elseif (cpp || js)
	static public inline var BLACK:BitmapInt32 = 0xff000000;
	#elseif neko
	static public inline var BLACK:BitmapInt32 = {rgb: 0x000000, a: 0xff};
	#end

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
	/**
	 * Whether to show visual debug displays or not.
	 * Default = false.
	 */
	static public var visualDebug:Bool;
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
	 * A reference to a <code>FlxMouse</code> object.  Important for input!
	 */
	static public var mouse:Mouse;
	/**
	 * A reference to a <code>FlxKeyboard</code> object.  Important for input!
	 */
	static public var keys:Keyboard;
	
	/**
	 * A handy container for a background music object.
	 */
	static public var music:FlxSound;
	/**
	 * A list of all the sounds being played in the game.
	 */
	static public var sounds:FlxGroup;
	/**
	 * Whether or not the game sounds are muted.
	 */
	static public var mute:Bool;
	/**
	 * Internal volume level, used for global sound control.
	 */
	static private var _volume:Float;

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
	//static private var _cache:Hash<BitmapData>;
	static public var _cache:Hash<BitmapData>;
	
	static public function getLibraryName():String
	{
		return FlxG.LIBRARY_NAME + " v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION;
	}
	
	/**
	 * Log data to the debugger.
	 * @param	Data		Anything you want to log to the console.
	 */
	static public function log(Data:Dynamic):Void
	{
		if ((_game != null) && (_game.debugger != null))
		{
			_game.debugger.log.add((Data == null) ? "ERROR: null object" : (Std.is(Data, Array) ? FlxU.formatArray(cast(Data, Array<Dynamic>)):Data.toString()));
		}
	}
	
	/**
	 * Add a variable to the watch list in the debugger.
	 * This lets you see the value of the variable all the time.
	 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 * @param	DisplayName		Optional, display your own string instead of the class name + variable name: e.g. "enemy count".
	 */
	static public function watch(AnyObject:Dynamic, VariableName:String, ?DisplayName:String = null):Void
	{
		if ((_game != null) && (_game._debugger != null))
		{
			_game._debugger.watch.add(AnyObject, VariableName, DisplayName);
		}
	}
	
	/**
	 * Remove a variable from the watch list in the debugger.
	 * Don't pass a Variable Name to remove all watched variables for the specified object.
	 * @param	AnyObject		A reference to any object in your game, e.g. Player or Robot or this.
	 * @param	VariableName	The name of the variable you want to watch, in quotes, as a string: e.g. "speed" or "health".
	 */
	static public function unwatch(AnyObject:Dynamic, ?VariableName:String = null):Void
	{
		if ((_game != null) && (_game._debugger != null))
		{
			_game._debugger.watch.remove(AnyObject, VariableName);
		}
	}
	
	public static var framerate(getFramerate, setFramerate):Int;
	
	/**
	 * How many times you want your game to update each second.
	 * More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the Flash Player framerate!
	 */
	static public function getFramerate():Int
	{
		return Std.int(1000 / _game._step);
	}
		
	/**
	 * @private
	 */
	static public function setFramerate(Framerate:Int):Int
	{
		_game._step = Math.floor(Math.abs(1000 / Framerate));
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
	static public function getFlashFramerate():Int
	{
		#if flash
		if (_game.root != null)
		#else
		if (_game.stage != null)
		#end
		{
			return Math.floor(_game.stage.frameRate);
		}
		else
		{
			return 0;
		}
	}
		
	/**
	 * @private
	 */
	static public function setFlashFramerate(Framerate:Int):Int
	{
		_game._flashFramerate = Math.floor(Math.abs(Framerate));
		#if flash
		if (_game.root != null)
		#else
		if (_game.stage != null)
		#end
		{
			_game.stage.frameRate = _game._flashFramerate;
		}
		_game._maxAccumulation = Math.floor(2000 / _game._flashFramerate) - 1;
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
	static public function random():Float
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
	static public function shuffle(Objects:Array<Dynamic>, HowManyTimes:Int):Array<Dynamic>
	{
		HowManyTimes = Math.floor(Math.max(HowManyTimes, 0));
		var i:Int = 0;
		var index1:Int;
		var index2:Int;
		var object:Dynamic;
		while(i < HowManyTimes)
		{
			index1 = Math.floor(FlxG.random() * Objects.length);
			index2 = Math.floor(FlxG.random() * Objects.length);
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
	static public function getRandom(Objects:Array<Dynamic>, ?StartIndex:Int = 0, ?Length:Int = 0):Dynamic
	{
		if(Objects != null)
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
		
	/**
	 * Load replay data from a string and play it back.
	 * @param	Data		The replay that you want to load.
	 * @param	State		Optional parameter: if you recorded a state-specific demo or cutscene, pass a new instance of that state here.
	 * @param	CancelKeys	Optional parameter: an array of string names of keys (see FlxKeyboard) that can be pressed to cancel the playback, e.g. ["ESCAPE","ENTER"].  Also accepts 2 custom key names: "ANY" and "MOUSE" (fairly self-explanatory I hope!).
	 * @param	Timeout		Optional parameter: set a time limit for the replay.  CancelKeys will override this if pressed.
	 * @param	Callback	Optional parameter: if set, called when the replay finishes.  Running to the end, CancelKeys, and Timeout will all trigger Callback(), but only once, and CancelKeys and Timeout will NOT call FlxG.stopReplay() if Callback is set!
	 */
	static public function loadReplay(Data:String, ?State:FlxState = null, ?CancelKeys:Array<String> = null, ?Timeout:Float = 0, ?Callback:Void->Void = null):Void
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
		_game._replayTimer = Math.floor(Timeout * 1000);
		_game._replayCallback = Callback;
		_game._replayRequested = true;
	}
		
	/**
	 * Resets the game or state and replay requested flag.
	 * @param	StandardMode	If true, reload entire game, else just reload current game state.
	 */
	static public function reloadReplay(?StandardMode:Bool = true):Void
	{
		if (StandardMode)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.resetState();
		}
		if (_game._replay.frameCount > 0)
		{
			_game._replayRequested = true;
		}
	}
		
	/**
	 * Stops the current replay.
	 */
	static public function stopReplay():Void
	{
		_game._replaying = false;
		if (_game._debugger != null)
		{
			_game._debugger.vcr.stopped();
		}
		resetInput();
	}
		
	/**
	 * Resets the game or state and requests a new recording.
	 * @param	StandardMode	If true, reset the entire game, else just reset the current state.
	 */
	static public function recordReplay(?StandardMode:Bool = true):Void
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
		if (_game._debugger != null)
		{
			_game._debugger.vcr.stopped();
		}
		return _game._replay.save();
	}
	
	/**
	 * Request a reset of the current game state.
	 */
	static public function resetState():Void
	{
		_game._requestedState = Type.createInstance(FlxU.getClass(FlxU.getClassName(_game._state, false)), []);
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
		keys.reset();
		mouse.reset();
		
		#if (cpp || neko)
		joystickManager.reset();
		#end
	}
	
	// TODO: Return from Sound -> Class<Sound>
	/**
	 * Set up and play a looping background soundtrack.
	 * @param	Music		The sound file you want to loop in the background.
	 * @param	Volume		How loud the sound should be, from 0 to 1.
	 */
	static public function playMusic(Music:Dynamic, ?Volume:Float = 1.0):Void
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
	static public function loadSound(?EmbeddedSound:Dynamic = null, ?Volume:Float = 1.0, ?Looped:Bool = false, ?AutoDestroy:Bool = false, ?AutoPlay:Bool = false, ?URL:String = null):FlxSound
	{
		if((EmbeddedSound == null) && (URL == null))
		{
			FlxG.log("WARNING: FlxG.loadSound() requires either\nan embedded sound or a URL to work.");
			return null;
		}
		var sound:FlxSound = cast(sounds.recycle(FlxSound), FlxSound);
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
	
	static public function play(EmbeddedSound:String, ?Volume:Float = 1.0, ?Looped:Bool = false, ?AutoDestroy:Bool = true):FlxSound
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
	static public function play(EmbeddedSound:Dynamic, ?Volume:Float = 1.0, ?Looped:Bool = false, ?AutoDestroy:Bool = true):FlxSound
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
	static public function stream(URL:String, ?Volume:Float = 1.0, ?Looped:Bool = false, ?AutoDestroy:Bool = true):FlxSound
	{
		return FlxG.loadSound(null, Volume, Looped, AutoDestroy, true, URL);
	}
	
	public static var volume(getVolume, setVolume):Float;
	
	/**
	 * Set <code>volume</code> to a number between 0 and 1 to change the global volume.
	 * 
	 * @default 0.5
	 */
	static public function getVolume():Float
	{
		return _volume;
	}
	
	/**
	 * @private
	 */
	static public function setVolume(Volume:Float):Float
	{
		_volume = Volume;
		if (_volume < 0)
		{
			_volume = 0;
		}
		else if (_volume > 1)
		{
			_volume = 1;
		}
		if (volumeHandler != null)
		{
			// volumeHandler(FlxG.mute ? 0 : _volume);
			var param:Float = FlxG.mute ? 0 : _volume;
			Reflect.callMethod(FlxG, Reflect.getProperty(FlxG, "volumeHandler"), [param]);
		}
		return Volume;
	}

	/**
	 * Called by FlxGame on state changes to stop and destroy sounds.
	 * 
	 * @param	ForceDestroy		Kill sounds even if they're flagged <code>survive</code>.
	 */
	static public function destroySounds(?ForceDestroy:Bool = false):Void
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
			if (Std.is(sounds.members[i], FlxSound))
			{
				sound = cast(sounds.members[i++], FlxSound);
				if ((sound != null) && (ForceDestroy || !sound.survive))
				{
					sound.destroy();
				}
			}
			else
			{
				i++;
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
			sound = cast(sounds.members[i++], FlxSound);
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
			sound = cast(sounds.members[i++], FlxSound);
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
	static public function createBitmap(Width:UInt, Height:UInt, Color:UInt, ?Unique:Bool = false, ?Key:String = null):BitmapData
	#else
	static public function createBitmap(Width:Int, Height:Int, Color:BitmapInt32, ?Unique:Bool = false, ?Key:String = null):BitmapData
	#end
	{
		var key:String = Key;
		if(key == null)
		{
			#if !neko
			key = Width + "x" + Height + ":" + Color;
			#else
			key = Width + "x" + Height + ":" + Color.a + "." + Color.rgb;
			#end
			if(Unique && checkBitmapCache(key))
			{
				var inc:Int = 0;
				var ukey:String;
				do
				{
					ukey = key + inc++;
				} while(checkBitmapCache(ukey));
				key = ukey;
			}
		}
		if (!checkBitmapCache(key))
		{
			_cache.set(key, new BitmapData(Width, Height, true, Color));
		}
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
	static public function addBitmap(Graphic:Dynamic, ?Reverse:Bool = false, ?Unique:Bool = false, ?Key:String = null, ?FrameWidth:Int = 0, ?FrameHeight:Int = 0):BitmapData
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
		else if (Std.is(Graphic, BitmapData) && Key != null)
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
		#if !(flash || js)
		if (FrameWidth != 0 || FrameHeight != 0)
		{
			additionalKey = "FrameSize:" + FrameWidth + "_" + FrameHeight;
		}
		#end
		
		var needReverse:Bool = false;
		var key:String = Key;
		if (key == null)
		{
			if (isClass)
			{
				key = Type.getClassName(cast(Graphic, Class<Dynamic>));
			}
			else
			{
				key = Graphic;
			}
			key += (Reverse ? "_REVERSE_" : "");
			key += additionalKey;
			
			if (Unique && checkBitmapCache(key))
			{
				var inc:Int = 0;
				var ukey:String;
				do
				{
					ukey = key + inc++;
				} while(checkBitmapCache(ukey));
				key = ukey;
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
				bd = cast(Graphic, BitmapData);
			}
			else
			{
				bd = Assets.getBitmapData(Graphic);
			}
			
			#if !(flash || js)
			if (additionalKey != "")
			{
				var numHorizontalFrames:Int = (FrameWidth == 0) ? 1 : Math.floor(bd.width / FrameWidth);
				var numVerticalFrames:Int = (FrameHeight == 0) ? 1 : Math.floor(bd.height / FrameHeight);
				
				FrameWidth = Math.floor(bd.width / numHorizontalFrames);
				FrameHeight = Math.floor(bd.height / numVerticalFrames);
				
				#if !neko
				var tempBitmap:BitmapData = new BitmapData(bd.width + numHorizontalFrames, bd.height + numVerticalFrames, true, 0x00000000);
				#else
				var tempBitmap:BitmapData = new BitmapData(bd.width + numHorizontalFrames, bd.height + numVerticalFrames, true, {rgb: 0x000000, a: 0x00});
				#end
				
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
			#end
			
			_cache.set(key, bd);
			if (Reverse)
			{
				needReverse = true;
			}
		}
		
		var pixels:BitmapData = _cache.get(key);
		
		#if (flash || js)
		if (isClass)
		{
			tempBitmap = Type.createInstance(Graphic, []).bitmapData;
		}
		else if (isBitmap)
		{
			tempBitmap = cast(Graphic, BitmapData);
		}
		else
		{
			tempBitmap = Assets.getBitmapData(Graphic);
		}
		
		if (!needReverse && Reverse && (pixels.width == tempBitmap.width))
		{
			needReverse = true;
		}
		
		if (needReverse)
		{
			var newPixels:BitmapData = new BitmapData(pixels.width * 2, pixels.height, true, 0x00000000);
			
			newPixels.draw(pixels);
			var mtx:Matrix = new Matrix();
			mtx.scale(-1,1);
			mtx.translate(newPixels.width, 0);
			newPixels.draw(pixels, mtx);
			pixels = newPixels;
			_cache.set(key, pixels);
		}
		#end
		
		return pixels;
	}
	
	public static function removeBitmap(Graphic:String):Void
	{
		if (_cache.exists(Graphic))
		{
			_cache.remove(Graphic);
		}
	}
		
	/**
	 * Dumps the cache's image references.
	 */
	static public function clearBitmapCache():Void
	{
		/*if (_cache != null)
		{
			for (bmd in _cache)
			{
				if (bmd != null)
				{
					bmd.dispose();
					bmd = null;
				}
			}
		}*/
		
		_cache = new Hash();
	}
	
	public static var stage(getStage, null):Stage;
	
	/**
	 * Read-only: retrieves the Flash stage object (required for event listeners)
	 * Will be null if it's not safe/useful yet.
	 */
	static public function getStage():Stage
	{
		#if flash
		if (_game.root != null)
		#else
		if (_game.stage != null)
		#end
		{
			return _game.stage;
		}
		return null;
	}
	
	public static var state(getState, null):FlxState;
	
	/**
	 * Read-only: access the current game state from anywhere.
	 */
	static public function getState():FlxState
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
		
	/**
	 * Change the way the debugger's windows are laid out.
	 * @param	Layout		See the presets above (e.g. <code>DEBUGGER_MICRO</code>, etc).
	 */
	static public function setDebuggerLayout(Layout:Int):Void
	{
		if (_game._debugger != null)
		{
			_game._debugger.setLayout(Layout);
		}
	}
		
	/**
	 * Just resets the debugger windows to whatever the last selected layout was (<code>DEBUGGER_STANDARD</code> by default).
	 */
	static public function resetDebuggerLayout():Void
	{
		if (_game._debugger != null)
		{
			_game._debugger.resetLayout();
		}
	}
	
	/**
	 * Add a new camera object to the game.
	 * Handy for PiP, split-screen, etc.
	 * @param	NewCamera	The camera you want to add.
	 * @return	This <code>FlxCamera</code> instance.
	 */
	static public function addCamera(NewCamera:FlxCamera):FlxCamera
	{
		FlxG._game.addChildAt(NewCamera._flashSprite, FlxG._game.getChildIndex(FlxG._game._mouse));
		FlxG.cameras.push(NewCamera);
		return NewCamera;
	}
	
	/**
	 * Remove a camera from the game.
	 * @param	Camera	The camera you want to remove.
	 * @param	Destroy	Whether to call destroy() on the camera, default value is true.
	 */
	static public function removeCamera(Camera:FlxCamera, ?Destroy:Bool = true):Void
	{
		try
		{
			FlxG._game.removeChild(Camera._flashSprite);
		}
		catch(E:Error)
		{
			FlxG.log("Error removing camera, not part of game.");
		}
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
	static public function resetCameras(?NewCamera:FlxCamera = null):Void
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
		//FlxG.cameras.length = 0;
		FlxG.cameras.splice(0, FlxG.cameras.length);
		
		if (NewCamera == null)
		{
			NewCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		}
		FlxG.camera = FlxG.addCamera(NewCamera);
	}
	
	/**
	 * All screens are filled with this color and gradually return to normal.
	 * @param	Color		The color you want to use.
	 * @param	Duration	How long it takes for the flash to fade.
	 * @param	OnComplete	A function you want to run when the flash finishes.
	 * @param	Force		Force the effect to reset.
	 */
	#if flash
	static public function flash(?Color:UInt = 0xffffffff, ?Duration:Float = 1, ?OnComplete:Void->Void = null, ?Force:Bool = false):Void
	#else
	static public function flash(?Color:BitmapInt32, ?Duration:Float = 1, ?OnComplete:Void->Void = null, ?Force:Bool = false):Void
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
	static public function fade(?Color:UInt = 0xff000000, ?Duration:Float = 1, ?FadeIn:Bool = false, ?OnComplete:Void->Void = null, ?Force:Bool = false):Void
	#else
	static public function fade(?Color:BitmapInt32, ?Duration:Float = 1, ?FadeIn:Bool = false, ?OnComplete:Void->Void = null, ?Force:Bool = false):Void
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
	static public function shake(?Intensity:Float = 0.05, ?Duration:Float = 0.5, ?OnComplete:Void->Void = null, ?Force:Bool = true, ?Direction:Int = 0):Void
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
	static public function getBgColor():UInt
	#else
	static public function getBgColor():BitmapInt32
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
	static public function setBgColor(Color:UInt):UInt
	#else
	static public function setBgColor(Color:BitmapInt32):BitmapInt32
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
	 * @return	Whether any oevrlaps were detected.
	 */
	static public function overlap(?ObjectOrGroup1:FlxBasic = null, ?ObjectOrGroup2:FlxBasic = null, ?NotifyCallback:FlxObject->FlxObject->Void = null, ?ProcessCallback:FlxObject->FlxObject->Bool = null):Bool
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
	static public function collide(?ObjectOrGroup1:FlxBasic = null, ?ObjectOrGroup2:FlxBasic = null, ?NotifyCallback:FlxObject->FlxObject->Void = null):Bool
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
		//var i:UInt = 0;
		var l:Int = pluginList.length;
		//while(i < l)
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
			//if(pluginList[i] is ClassType)
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
				pluginList.splice(i,1);
			}
			i--;
		}
		return Plugin;
	}
	
	/**
	 * Removes an instance of a plugin from the global plugin array.
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
			//if(pluginList[i] is ClassType)
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
		//FlxAssets.cacheSounds();
		
		FlxG._game = Game;
		FlxG.width = Math.floor(Math.abs(Width));
		FlxG.height = Math.floor(Math.abs(Height));
		
		FlxG.mute = false;
		FlxG._volume = 0.5;
		FlxG.sounds = new FlxGroup();
		FlxG.volumeHandler = null;
		
		FlxG.clearBitmapCache();
		
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
		addPlugin(new DebugPathDisplay());
		addPlugin(new TimerManager());
		
		FlxG.mouse = new Mouse(FlxG._game._mouse);
		FlxG.keys = new Keyboard();
		#if js
		FlxG.mobile = true;
		#else
		FlxG.mobile = false;
		#end
		
		#if (cpp || neko)
		FlxG.joystickManager = new JoystickManager();
		#end

		FlxG.levels = new Array();
		FlxG.scores = new Array();
		FlxG.visualDebug = false;
	}
	
	/**
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	static public function reset():Void
	{
		#if (cpp || neko)
		PxBitmapFont.clearStorage();
		TileSheetManager.clear();
		#end
		FlxG.clearBitmapCache();
		FlxG.resetInput();
		FlxG.destroySounds(true);
		//FlxG.levels.length = 0;
		FlxG.levels = [];
		//FlxG.scores.length = 0;
		FlxG.scores = [];
		FlxG.level = 0;
		FlxG.score = 0;
		FlxG.paused = false;
		FlxG.timeScale = 1.0;
		FlxG.elapsed = 0;
		FlxG.globalSeed = Math.random();
		FlxG.worldBounds = new FlxRect( -10, -10, FlxG.width + 20, FlxG.height + 20);
		FlxG.worldDivisions = 6;
		var debugPathDisplay:DebugPathDisplay = cast(FlxG.getPlugin(DebugPathDisplay), DebugPathDisplay);
		if (debugPathDisplay != null)
		{
			debugPathDisplay.clear();
		}
	}
	
	/**
	 * Called by the game object to update the keyboard and mouse input tracking objects.
	 */
	static public function updateInput():Void
	{
		FlxG.keys.update();
		if (!_game._debuggerUp || !_game._debugger.hasMouse)
		{
			FlxG.mouse.update(Math.floor(FlxG._game.mouseX), Math.floor(FlxG._game.mouseY));
		}
		
		if (FlxG.supportsTouchEvents)
		{
			FlxG.touchManager.update();
		}
		
		#if (cpp || neko)
		FlxG.joystickManager.update();
		#end
	}
	
	/**
	 * Called by the game object to lock all the camera buffers and clear them for the next draw pass.
	 */
	static public function lockCameras():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++]; //as FlxCamera;
			if ((cam == null) || !cam.exists || !cam.visible)
			{
				continue;
			}
			
			#if (flash || js)
			if (useBufferLocking)
			{
				cam.buffer.lock();
			}
			#end
			
			#if (cpp || neko)
			cam._canvas.graphics.clear();
			// clearing camera's debug sprite
			cam._debugLayer.graphics.clear();
			#end
			
			cam.fill(cam.bgColor);
			
			#if (flash || js)
			cam.screen.dirty = true;
			#end
		}
	}
	
	/**
	 * Called by the game object to draw the special FX and unlock all the camera buffers.
	 */
	static public function unlockCameras():Void
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
			
			#if (flash || js)
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
	static public function updateCameras():Void
	{
		var cam:FlxCamera;
		var cams:Array<FlxCamera> = FlxG.cameras;
		var i:Int = 0;
		var l:Int = cams.length;
		while(i < l)
		{
			cam = cams[i++];
			if((cam != null) && cam.exists)
			{
				if (cam.active)
				{
					cam.update();
				}
				cam._flashSprite.x = cam.x + cam._flashOffsetX;
				cam._flashSprite.y = cam.y + cam._flashOffsetY;
				
				cam._flashSprite.visible = cam.visible;
			}
		}
	}
	
	/**
	 * Used by the game object to call <code>update()</code> on all the plugins.
	 */
	static public function updatePlugins():Void
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
	static public function drawPlugins():Void
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
	public static function tween(object:Dynamic, values:Dynamic, duration:Float, ?options:Dynamic = null):MultiVarTween
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