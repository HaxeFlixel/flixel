package org.flixel;

import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.errors.Error;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.media.SoundTransform;
import org.flixel.system.debug.Console;
import org.flixel.system.debug.LogStyle; 
import org.flixel.system.debug.Log;
import org.flixel.system.FlxWindow;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.TileSheetData;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.plugin.TimerManager;
import org.flixel.system.FlxQuadTree;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;
import org.flixel.tweens.misc.MultiVarTween;
import org.flixel.util.FlxArray;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxMath;
import org.flixel.util.FlxRandom;
import org.flixel.util.FlxRect;
import org.flixel.util.FlxPoint;
import org.flixel.util.FlxString;
import org.flixel.util.FlxArray;

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
 * Utilities for maths and color and things can be found in the util package.
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
	
	public static var bgColor(get_bgColor, set_bgColor):Int;
	
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
	static public inline var LIBRARY_MAJOR_VERSION:String = "2";
	
	/**
	 * Assign a minor version to your library.
	 * Appears after the decimal in the console.
	 */
	static public inline var LIBRARY_MINOR_VERSION:String = "0.0-alpha.2";
	
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
	 * Useful for rad-to-deg and deg-to-rad conversion.
	 */
	static public var DEG:Float = 180 / Math.PI;
	static public var RAD:Float = Math.PI / 180;
	
	/**
	 * Internal tracker for game object.
	 */
	static public var _game:FlxGame;
	/**
	 * Handy shared variable for implementing your own pause behavior.
	 */
	static public var paused:Bool;
	/**
	 * Whether the game should be paused when focus is lost or not. 
	 * Use FLX_NO_FOCUS_LOST_SCREEN if you only want to get rid of the default
	 * pause screen. Override onFocus() and onFocusLost() for your own 
	 * behaviour in your state
	 * @default true 
	 */
	static public var autoPause:Bool;
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
	/**
	 * Reference to the console on the debugging screen - use it to add commands,
	 * register objects and functions, etc.
	 */
	static public var console:Console;
	#end
	/**
	 * Setting this to true will disable/skip stuff that isn't necessary for mobile platforms like Android. [BETA]
	 */
	static public var mobile:Bool; 
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
	static public var _cache:Map<String, BitmapData>;
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
	/**
	 * The key codes used to open the debugger. (via flash.ui.Keyboard)
	 * @default [192, 220]
	 */
	static public var keyDebugger:Array<Int>;
	/**
	 * The key codes used to increase volume. (via flash.ui.Keyboard)
	 * @default [107, 187]
	 */
	static public var keyVolumeUp:Array<Int>;
	/**
	 * The key codes used to decrease volume. (via flash.ui.Keyboard)
	 * @default [109, 189]
	 */
	static public var keyVolumeDown:Array<Int>;
	/**
	 * The key codes used to mute / unmute the game. (via flash.ui.Keyboard)
	 * @default [48, 96]
	*/
	static public var keyMute:Array<Int>; 
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
	 * Log data to the debugger. Example: <code>FlxG.log("Test", "1", "2", "3");</code> - will turn into "Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	static public var log:Dynamic;
	
	static private inline function _log(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
			advancedLog(Data, Log.STYLE_NORMAL); 
		#end
	}
	
	/**
	 * Add a warning to the debugger. Example: <code>FlxG.warn("Test", "1", "2", "3");</code> - will turn into "[WARNING] Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	static public var warn:Dynamic;
	
	static private inline function _warn(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
			advancedLog(Data, Log.STYLE_WARNING); 
		#end
	}
	
	/**
	 * Add an error to the debugger. Example: <code>FlxG.error("Test", "1", "2", "3");</code> - will turn into "[ERROR] Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	static public var error:Dynamic;
	
	static private inline function _error(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
			advancedLog(Data, Log.STYLE_ERROR); 
		#end
	}
	
	/**
	 * Add a notice to the debugger. Example: <code>FlxG.notice("Test", "1", "2", "3");</code> - will turn into "[NOTICE] Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	static public var notice:Dynamic;
	
	static private inline function _notice(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
			advancedLog(Data, Log.STYLE_NOTICE); 
		#end
	}
	
	/**
	 * Add an advanced log message to the debugger by also specifying a <code>LogStyle</code>. Backend to <code>FlxG.log(), FlxG.warn(), FlxG.error() and FlxG.notice()</code>.
	 * @param  Data  Any Data to log.
	 * @param  Style   The <code>LogStyle</code> to use, for example <code>Log.STYLE_WARNING</code>. You can also create your own by importing the <code>LogStyle</code> class.
	 */ 
	static public function advancedLog(Data:Dynamic, Style:LogStyle):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game.debugger != null))
		{
			if (!Std.is(Data, Array))
				Data = [Data]; 
			
			_game.debugger.log.add(Data, Style);
			
			if (Style.errorSound != null)
				FlxG.play(Style.errorSound);
			if (Style.openConsole) 
				_game.debugger.visible = _game._debuggerUp = true;
			if (Reflect.isFunction(Style.callbackFunction))
				Reflect.callMethod(null, Style.callbackFunction, []);
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
	
	/**
	 * Add or update a quickWatch entry to the watch list in the debugger.
	 * Extremely useful when called in <code>update()</code> functions when there 
	 * doesn't exist a variable for a value you want to watch - so you won't have to create one.
	 * @param	Name		The name of the quickWatch entry, for example "mousePressed".
	 * @param	NewValue	The new value for this entry, for example <code>FlxG.mouse.pressed()</code>.
	 */
	static public function quickWatch(Name:String, NewValue:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game._debugger != null))
		{
			_game.debugger.watch.updateQuickWatch(Name, NewValue);
		}
		#end
	}
	
	/**
	 * Remove a quickWatch entry from the watch list of the debugger.
	 * @param	Name	The name of the quickWatch entry you want to remove.
	 */
	static public function removeQuickWatch(Name:String):Void
	{
		#if !FLX_NO_DEBUG
		if ((_game != null) && (_game._debugger != null))
		{
			_game.debugger.watch.remove(null, null, Name);
		}
		#end
	}
	
	static public var framerate(get_framerate, set_framerate):Int;
	
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
		_game.requestNewState(Type.createInstance(Type.resolveClass(FlxString.getClassName(_game._state, false)), []));
		
		#if !FLX_NO_DEBUG
		if (Std.is(_game._requestedState, FlxSubState))
		{
			throw "You can't set FlxSubState class instance as the state for your game";
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
	 * @param	EmbeddedSound	The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param	Volume			How loud to play it (0 to 1).
	 * @param	Looped			Whether to loop this sound.
	 * @param	AutoDestroy		Whether to destroy this sound when it finishes playing.  Leave this value set to "false" if you want to re-use this <code>FlxSound</code> instance.
	 * @param	AutoPlay		Whether to play the sound.
	 * @param	URL				Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @return	A <code>FlxSound</code> object.
	 */
	static public function loadSound(EmbeddedSound:Dynamic = null, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = false, AutoPlay:Bool = false, URL:String = null, OnComplete:Void->Void = null):FlxSound
	{
		#if !js
		if((EmbeddedSound == null) && (URL == null))
		{
			FlxG.warn("FlxG.loadSound() requires either\nan embedded sound or a URL to work.");
			return null;
		}
		var sound:FlxSound = sounds.recycle(FlxSound);
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
	private static var _soundCache:Map<String, Sound> = new Map<String, Sound>();
	private static var _soundTransform:SoundTransform = new SoundTransform();
	
	/**
	 * Method for sound caching on Android target.
	 * Application may freeze for some time at first try to play sound if you don't use this method
	 * 
	 * @param	EmbeddedSound	Name of sound assets specified in your .nmml project file
	 * @return	Cached Sound object
	 */
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
	
	static public function play(EmbeddedSound:String, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true, OnComplete:Void->Void = null):FlxSound
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
	static public function play(EmbeddedSound:Dynamic, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true, OnComplete:Void->Void = null):FlxSound
	{
		#if !js
		return FlxG.loadSound(EmbeddedSound, Volume, Looped, AutoDestroy, true, null, OnComplete);
		#else
		return null;
		#end
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
	static public function stream(URL:String, Volume:Float = 1.0, Looped:Bool = false, AutoDestroy:Bool = true, OnComplete:Void->Void = null):FlxSound
	{
		#if !js
		return FlxG.loadSound(null, Volume, Looped, AutoDestroy, true, URL, OnComplete);
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
	public static var volume(default, set_volume):Float;
	
	/**
	 * @private
	 */
	static private function set_volume(Volume:Float):Float
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
	static public function createBitmap(Width:Int, Height:Int, Color:Int, Unique:Bool = false, Key:String = null):BitmapData
	{
		var key:String = Key;
		if (key == null)
		{
			key = Width + "x" + Height + ":" + Color;
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
	 * @param	FrameWidth
	 * @param	FrameHeight
	 * @param 	SpacingX
	 * @param 	SpacingY
	 * @return	The <code>BitmapData</code> we just created.
	 */
	static public function addBitmap(Graphic:Dynamic, Reverse:Bool = false, Unique:Bool = false, Key:String = null, FrameWidth:Int = 0, FrameHeight:Int = 0, SpacingX:Int = 1, SpacingY:Int = 1):BitmapData
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
		if (FrameWidth != 0 || FrameHeight != 0 || SpacingX != 1 || SpacingY != 1)
		{
			additionalKey = "FrameSize:" + FrameWidth + "_" + FrameHeight + "_Spacing:" + SpacingX + "_" + SpacingY;
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
				
				var tempBitmap:BitmapData = new BitmapData(bd.width + numHorizontalFrames * SpacingX, bd.height + numVerticalFrames * SpacingY, true, FlxColor.TRANSPARENT);
				
				var tempRect:Rectangle = new Rectangle(0, 0, FrameWidth, FrameHeight);
				var tempPoint:Point = new Point();
				
				for (i in 0...(numHorizontalFrames))
				{
					tempPoint.x = i * (FrameWidth + SpacingX);
					tempRect.x = i * FrameWidth;
					
					for (j in 0...(numVerticalFrames))
					{
						tempPoint.y = j * (FrameHeight + SpacingY);
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
				mtx.scale( -1, 1);
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
	 * Helper method for loading and modifying tilesheets for tilemaps and tileblocks. It should help resolve tilemap tearing issue for native targets
	 * @param	Graphic		The image file that you want to load.
	 * @param	Reverse		Whether to generate a flipped version.
	 * @param	Unique		Ensures that the bitmap data uses a new slot in the cache.
	 * @param	Key			Force the cache to use a specific Key to index the bitmap.
	 * @param	FrameWidth
	 * @param	FrameHeight
	 * @param	RepeatX
	 * @param	RepeatY
	 * @return
	 */
	static public function addTilemapBitmap(Graphic:Dynamic, Reverse:Bool = false, Unique:Bool = false, Key:String = null, FrameWidth:Int = 0, FrameHeight:Int = 0, RepeatX:Int = 1, RepeatY:Int = 1):BitmapData
	{
		var bitmap:BitmapData = FlxG.addBitmap(Graphic, Reverse, Unique, Key, FrameWidth, FrameHeight, RepeatX + 1, RepeatY + 1);
		
		// Now modify tilemap image - insert repeatable pixels
		var extendedFrameWidth:Int = FrameWidth + RepeatX + 1;
		var extendedFrameHeight:Int = FrameHeight + RepeatY + 1;
		var numCols:Int = Std.int(bitmap.width / extendedFrameWidth);
		var numRows:Int = Std.int(bitmap.height / extendedFrameHeight);
		var tempRect:Rectangle = new Rectangle();
		var tempPoint:Point = new Point();
		var pixelColor:Int;
		
		tempRect.y = 0;
		tempRect.width = 1;
		tempRect.height = bitmap.height;
		tempPoint.y = 0;
		for (i in 0...numCols)
		{
			var tempX:Int = i * extendedFrameWidth + FrameWidth;
			tempRect.x = tempX - 1;
			
			for (j in 0...RepeatX)
			{
				tempPoint.x = tempX + j;
				bitmap.copyPixels(bitmap, tempRect, tempPoint);
			}
		}
		
		tempRect.x = 0;
		tempRect.width = bitmap.width;
		tempRect.height = 1;
		tempPoint.x = 0;
		for (i in 0...numRows)
		{
			var tempY:Int = i * extendedFrameHeight + FrameHeight;
			tempRect.y = tempY - 1;
			
			for (j in 0...RepeatY)
			{
				tempPoint.y = tempY + j;
				bitmap.copyPixels(bitmap, tempRect, tempPoint);
			}
		}
		
		return bitmap;
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
		var cachedBitmapData:Map<String, BitmapData> = Assets.cachedBitmapData;
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
		_cache = new Map();
	}
	
	/**
	 * Clears flash.Assests.cachedBitmapData. Use it only when you need it and know what are you doing.
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
		_game.requestNewState(State); 
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
			var index = FlxArray.indexOf(FlxG.cameras, Camera);
			if(index >= 0)
				FlxG.cameras.splice(index, 1);
		}
		else
		{
			FlxG.error("Removing camera, not part of game.");
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
	static public function flash(Color:Int = 0xffffffff, Duration:Float = 1, OnComplete:Void->Void = null, Force:Bool = false):Void
	{
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
	static public function fade(Color:Int = 0xff000000, Duration:Float = 1, FadeIn:Bool = false, OnComplete:Void->Void = null, Force:Bool = false):Void
	{
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
	static private function get_bgColor():Int
	{
		if (FlxG.camera == null)
		{
			return FlxColor.BLACK;
		}
		else
		{
			return FlxG.camera.bgColor;
		}
	}
	
	static private function set_bgColor(Color:Int):Int
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
	inline static public function overlap(ObjectOrGroup1:FlxBasic = null, ObjectOrGroup2:FlxBasic = null, NotifyCallback:Dynamic->Dynamic->Void = null, ProcessCallback:Dynamic->Dynamic->Bool = null):Bool
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
	inline static public function collide(ObjectOrGroup1:FlxBasic = null, ObjectOrGroup2:FlxBasic = null, NotifyCallback:Dynamic->Dynamic->Void = null):Bool
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
		
		FlxG.mobile = false;
		
		log = Reflect.makeVarArgs(_log);
		warn = Reflect.makeVarArgs(_warn);
		error = Reflect.makeVarArgs(_error);
		notice = Reflect.makeVarArgs(_notice);
		
		#if !FLX_NO_DEBUG
		FlxG.visualDebug = false;
		#end
	}
	
	/**
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	static public function reset():Void
	{
		PxBitmapFont.clearStorage();
		Atlas.clearAtlasCache();
		TileSheetData.clear();
		
		FlxG.clearBitmapCache();
		FlxG.resetInput();
		FlxG.destroySounds(true);
		FlxG.paused = false;
		FlxG.timeScale = 1.0;
		FlxG.elapsed = 0;
		FlxRandom.globalSeed = Math.random();
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
			cam._debugLayer.graphics.clear();
			#end
			
			#if flash
			cam.fill(cam.bgColor);
			cam.screen.dirty = true;
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
	
#if !FLX_NO_DEBUG
	inline static public function drawDebugPlugins():Void
	{
		var plugin:FlxBasic;
		var pluginList:Array<FlxBasic> = FlxG.plugins;
		var i:Int = 0;
		var l:Int = pluginList.length;
		while(i < l)
		{
			plugin = pluginList[i++];
			if (plugin.exists && plugin.visible && !plugin.ignoreDrawDebug)
			{
				plugin.drawDebug();
			}
		}
	}
#end
	
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
	
	// TODO: Remove this reference at some point?
	/**
	 * Reference to <code>FlxRandom.float()</code> for backwards compatibility.
	 * Might or might not be removed some time in the future.
	 */
	inline static public function random():Float
	{
		return FlxRandom.float();
	}
}