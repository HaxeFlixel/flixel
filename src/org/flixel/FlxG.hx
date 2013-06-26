package org.flixel;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.Stage;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.system.FlxQuadTree;
import org.flixel.system.frontEnds.BitmapFrontEnd;
import org.flixel.system.frontEnds.CameraFrontEnd;
import org.flixel.system.frontEnds.CameraFXFrontEnd;
import org.flixel.system.frontEnds.ConsoleFrontEnd;
import org.flixel.system.frontEnds.DebuggerFrontEnd;
import org.flixel.system.frontEnds.LogFrontEnd;
import org.flixel.system.frontEnds.PluginFrontEnd;
import org.flixel.system.frontEnds.SoundFrontEnd;
import org.flixel.system.frontEnds.VCRFrontEnd;
import org.flixel.system.frontEnds.WatchFrontEnd;
import org.flixel.system.input.FlxInputs;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.TileSheetData;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.misc.MultiVarTween;
import org.flixel.tweens.util.Ease.EaseFunction;
import org.flixel.util.FlxRandom;
import org.flixel.util.FlxRect;
import org.flixel.util.FlxString;

#if !FLX_NO_DEBUG
import org.flixel.system.FlxDebugger;
import org.flixel.plugin.DebugPathDisplay;
#end
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
	static public inline var LIBRARY_MINOR_VERSION:String = "0.0-alpha.3";
	
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
	 * Setting this to true will disable/skip stuff that isn't necessary for mobile platforms like Android. [BETA]
	 */
	static public var mobile:Bool;
	
	/**
	 * Useful helper objects for doing Flash-specific rendering.
	 * Primarily used for "debug visuals" like drawing bounding boxes directly to the screen buffer.
	 */
	static public var flashGfxSprite:Sprite;
	static public var flashGfx:Graphics;

	#if !FLX_NO_MOUSE
	/**
	 * A reference to a <code>FlxMouse</code> object. Important for input!
	 */
	static public var mouse:FlxMouse;
	#end

	#if !FLX_NO_KEYBOARD
	/**
	 * A reference to a <code>FlxKeyboard</code> object. Important for input!
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
	
	// From here on: frontEnds
	
	/**
	 * A reference to the <code>ConsoleFrontEnd</code> object. Use it to register functions and objects
	 * or add new commands to the console window.
	 */
	static public var console:ConsoleFrontEnd;
	/**
	 * A reference to the <code>LogFrontEnd</code> object. Use it to add messages to the log window.
	 */
	static public var log:LogFrontEnd;
	/**
	 * A reference to the <code>WatchFrontEnd</code> object. Use it to add or remove things to / from the 
	 * watch window.
	 */
	static public var watch:WatchFrontEnd;
	/**
	 * A reference to the <code>DebuggerFrontEnd</code> object. Use it to show / hide / toggle the debguger
	 * change its layout, activate visual debugging or change the key used to toggle it.
	 */
	static public var debugger:DebuggerFrontEnd;
	
	#if !FLX_NO_RECORD
	/**
	 * A reference to the <code>VCRFrontEnd</code> object. Contains all the functions needed for recording
	 * and replaying.
	 */
	static public var vcr:VCRFrontEnd;
	#end
	
	/**
	 * A reference to the <code>BitmapFrontEnd</code> object. Contains things related to bimtaps,
	 * for example regarding the bitmap cache and the cache itself.
	 */
	static public var bitmap:BitmapFrontEnd;
	/**
	 * A reference to the <code>CameraFrontEnd</code> object. Contains things related to cameras,
	 * a <code>list</code> of all cameras and the <code>defaultCamera</code> amongst other things.
	 */
	static public var cameras:CameraFrontEnd;
	/**
	 * A reference to the <code>CameraFXFrontEnd</code> object. Contains the <code>fade()</code>, 
	 * <code>flash()</code> and <code>shake()</code> effects.
	 */
	static public var cameraFX:CameraFXFrontEnd;
	/**
	 * A reference to the <code>PluginFrontEnd</code> object. Contains a <code>list</code> of all 
	 * plugins and the functions required to <code>add()</code>, <code>remove()</code> them etc.
	 */
	static public var plugins:PluginFrontEnd;
	/**
	 * A reference to the <code>SoundFrontEnd</code> object. Contains a <code>list</code> of all 
	 * sounds and other things to manage or <code>play()</code> sounds.
	 */
	static public var sound:SoundFrontEnd;
	
	/**
	 * Called by <code>FlxGame</code> to set up <code>FlxG</code> during <code>FlxGame</code>'s constructor.
	 */
	static public function init(Game:FlxGame, Width:Int, Height:Int, Zoom:Float):Void
	{	
		// TODO: check this later on real device
		//FlxAssets.cacheSounds();
		bitmap = new BitmapFrontEnd();
		
		FlxG._game = Game;
		FlxG.width = Std.int(Math.abs(Width));
		FlxG.height = Std.int(Math.abs(Height));
		
		FlxCamera.defaultZoom = Zoom;
		sound = new SoundFrontEnd();
		
		if (flashGfxSprite == null)
		{
			flashGfxSprite = new Sprite();
			flashGfx = flashGfxSprite.graphics;
		}

		cameras = new CameraFrontEnd();
		plugins = new PluginFrontEnd();
		
		FlxG.mobile = false;
		
		// Most of the front ends
		console = new ConsoleFrontEnd();
		log = new LogFrontEnd();
		watch = new WatchFrontEnd();
		debugger = new DebuggerFrontEnd();
		cameraFX = new CameraFXFrontEnd();
		sound = new SoundFrontEnd();
		
		#if !FLX_NO_RECORD
		vcr = new VCRFrontEnd();
		#end
	}
	
	/**
	 * The library name, which is "HaxeFlixel v.(major version).(minor version)"
	 */
	static public var libraryName(get, never):String;
	
	inline static private function get_libraryName():String
	{
		return FlxG.LIBRARY_NAME + " v" + FlxG.LIBRARY_MAJOR_VERSION + "." + FlxG.LIBRARY_MINOR_VERSION;
	}
	
	static public var framerate(get, set):Int;
	
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
		if (Framerate < FlxG.flashFramerate)
		{
			FlxG.log.warn("FlxG.framerate: The game's framerate shouldn't be smaller than the flash framerate, since it can stop your game from updating.");
		}
		
		_game._step = Std.int(Math.abs(1000 / Framerate));
		_game._stepSeconds = (_game._step / 1000);
		if (_game._maxAccumulation < _game._step)
		{
			_game._maxAccumulation = _game._step;
		}
		return Framerate;
	}
		
	public static var flashFramerate(get, set):Int;
		
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
		if (Framerate > FlxG.framerate)
		{
			FlxG.log.warn("FlxG.flashFramerate: The game's framerate shouldn't be smaller than the flash framerate, since it can stop your game from updating.");
		}
		
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
	
	public static var stage(get, never):Stage;
	
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
	
	public static var state(get, never):FlxState;
	
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
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	static public function reset():Void
	{
		PxBitmapFont.clearStorage();
		Atlas.clearAtlasCache();
		TileSheetData.clear();
		
		FlxG.bitmap.clearCache();
		FlxG.resetInput();
		FlxG.sound.destroySounds(true);
		FlxG.paused = false;
		FlxG.timeScale = 1.0;
		FlxG.elapsed = 0;
		FlxRandom.globalSeed = Math.random();
		FlxG.worldBounds = new FlxRect( -10, -10, FlxG.width + 20, FlxG.height + 20);
		FlxG.worldDivisions = 6;
		
		#if !FLX_NO_DEBUG
		var debugPathDisplay:DebugPathDisplay = cast(FlxG.plugins.get(DebugPathDisplay), DebugPathDisplay);
		if (debugPathDisplay != null)
		{
			debugPathDisplay.clear();
		}
		#end
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