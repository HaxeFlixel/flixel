package flixel;

import flash.display.Stage;
import flash.display.StageDisplayState;
import flixel.system.FlxAssets;
import flixel.system.FlxQuadTree;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.frontEnds.BmpLogFrontEnd;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.ConsoleFrontEnd;
import flixel.system.frontEnds.DebuggerFrontEnd;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.system.frontEnds.LogFrontEnd;
import flixel.system.frontEnds.PluginFrontEnd;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.system.frontEnds.VCRFrontEnd;
import flixel.system.frontEnds.WatchFrontEnd;
import flixel.text.pxText.PxBitmapFont;
import flixel.util.FlxCollision;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.FlxSave;
import flixel.util.FlxStringUtil;
import flixel.FlxBasic;

#if !FLX_NO_TOUCH
import flixel.system.input.touch.FlxTouchManager;
#end
#if !FLX_NO_KEYBOARD
import flixel.system.input.keyboard.FlxKeyboard;
import flixel.system.input.keyboard.FlxKeyShortcuts;
#end
#if !FLX_NO_MOUSE
import flixel.system.input.mouse.FlxMouse;
#end
#if !FLX_NO_GAMEPAD
import flixel.system.input.gamepad.FlxGamepadManager;
#end
#if android
import flixel.system.input.android.FlxAndroidKeys;
#end

interface IDestroyable
{
	public function destroy():Void;
}

/**
 * This is a global helper class full of useful functions for audio,
 * input, basic info, and the camera system among other things.
 * Utilities for maths and color and things can be found in the util package.
 * <code>FlxG</code> is specifically for Flixel-specific properties.
 */
class FlxG 
{
	/**
	 * If you build and maintain your own version of flixel,
	 * you can give it your own name here.
	 */
	static public var LIBRARY_NAME:String = "HaxeFlixel";
	/**
	 * Assign a major version to your library.
	 * Appears before the decimal in the console.
	 */
	static public var LIBRARY_MAJOR_VERSION:String = "3";
	/**
	 * Assign a minor version to your library.
	 * Appears after the decimal in the console.
	 */
	static public var LIBRARY_MINOR_VERSION:String = "0.4-dev";
	
	/**
	 * Internal tracker for game object.
	 */
	static public var game(default, null):FlxGame;
	/**
	 * Handy shared variable for implementing your own pause behavior.
	 */
	static public var paused:Bool = false;
	/**
	 * Whether the game should be paused when focus is lost or not. Use FLX_NO_FOCUS_LOST_SCREEN if you only want to get rid of the default
	 * pause screen. Override onFocus() and onFocusLost() for your own behaviour in your state.
	 */
	static public var autoPause:Bool = true;
	/**
	 * Whether <code>FlxG.resizeGame()</code> should be called whenever the game is resized. False by default.
	 */
	static public var autoResize:Bool = false;
	/**
	 * WARNING: Changing this can lead to issues with physcis and the recording system. Setting this to 
	 * false might lead to smoother animations (even at lower fps) at the cost of physics accuracy.
	 */
	static public var fixedTimestep:Bool = true;
	/**
	 * Represents the amount of time in seconds that passed since last frame.
	 */
	static public var elapsed:Float = 0;
	/**
	 * How fast or slow time should pass in the game; default is 1.0.
	 */
	static public var timeScale:Float = 1;
	/**
	 * The width of the screen in game pixels. Read-only, use <code>resizeGame()</code> to change.
	 */
	static public var width(default, null):Int;
	/**
	 * The height of the screen in game pixels. Read-only, use <code>resizeGame()</code> to change.
	 */
	static public var height(default, null):Int;
	/**
	 * The dimensions of the game world, used by the quad tree for collisions and overlap checks.
	 * Use <code>.set()</code> instead of creating a new object!
	 */
	static public var worldBounds(default, null):FlxRect = new FlxRect();
	/**
	 * How many times the quad tree should divide the world on each axis. Generally, sparse collisions can have fewer divisons,
	 * while denser collision activity usually profits from more. Default value is 6.
	 */
	static public var worldDivisions:Int;
	/**
	 * By default this just refers to the first entry in the <code>FlxG.cameras.list</code> 
	 * array but you can do what you like with it.
	 */
	static public var camera:FlxCamera;
	/**
	 * A <code>FlxSave</code> used internally by flixel to save sound preferences and 
	 * the history of the console window, but no reason you can't use it for your own stuff too!
	 */
	static public var save(default, null):FlxSave = new FlxSave();
	
	#if !FLX_NO_MOUSE
	/**
	 * A reference to a <code>FlxMouse</code> object. Important for input!
	 */
	static public var mouse(default, null):FlxMouse;
	#end

	#if !FLX_NO_KEYBOARD
	/**
	 * A reference to a <code>FlxKeyboard</code> object. Important for input!
	 */
	static public var keyboard(default, null):FlxKeyboard;
	/**
	 * A reference to a <code>FlxKeyAccess</code> object. Handy for quickly 
	 * getting information about keys pressed / just pressed or just released!
	 */
	static public var keys(default, null):FlxKeyShortcuts;
	#end

	#if !FLX_NO_TOUCH
	/**
	 * A reference to a <code>FlxTouchManager</code> object. Useful for devices with multitouch support
	 */
	public static var touches(default, null):FlxTouchManager;
	#end
	
	#if (!FLX_NO_GAMEPAD && (cpp || neko || js))
	/**
	 * A reference to a <code>FlxGamepadManager</code> object.
	 */
	public static var gamepads(default, null):FlxGamepadManager;
	#end
	
	#if android
	/**
	 * A reference to a <code>FlxAndroidKeys</code> object. Useful for tracking Back, Home, etc on Android devices.
	 */
	public static var android(default, null):FlxAndroidKeys;
	#end
	
	/**
	 * From here on: frontEnd classes.
	 */ 
	
	/**
	 * A reference to the <code>InputFrontEnd</code> object. Mostly used internally, 
	 * but you can use it too to reset inputs and create input classes of your own.
	 */
	static public var inputs(default, null):InputFrontEnd = new InputFrontEnd();
	/**
	 * A reference to the <code>ConsoleFrontEnd</code> object. Use it to register functions and objects
	 * or add new commands to the console window.
	 */
	static public var console(default, null):ConsoleFrontEnd = new ConsoleFrontEnd();
	/**
	 * A reference to the <code>LogFrontEnd</code> object. Use it to <code>add</code> messages to the log window. It is recommended 
	 * to use <code>trace()</code> instead of the old <code>FlxG.log()</code>, since traces will be redirected by default.
	 */
	static public var log(default, null):LogFrontEnd = new LogFrontEnd();
	
	#if FLX_BMP_DEBUG
	/**
	 * A reference to the <code>BmpLogFrontEnd</code> object. Use it to <code>add</code> images to the bmplog window. 
	 */	
	static public var bmpLog(default, null):BmpLogFrontEnd = new BmpLogFrontEnd();	
	#end
	
	/**
	 * A reference to the <code>WatchFrontEnd</code> object. Use it to add or remove things to / from the 
	 * watch window.
	 */
	static public var watch(default, null):WatchFrontEnd = new WatchFrontEnd();
	/**
	 * A reference to the <code>DebuggerFrontEnd</code> object. Use it to show / hide / toggle the debguger
	 * change its layout, activate visual debugging or change the key used to toggle it.
	 */
	static public var debugger(default, null):DebuggerFrontEnd = new DebuggerFrontEnd();

	/**
	 * A reference to the <code>VCRFrontEnd</code> object. Contains all the functions needed for recording
	 * and replaying.
	 */
	static public var vcr(default, null):VCRFrontEnd = new VCRFrontEnd();
	
	/**
	 * A reference to the <code>BitmapFrontEnd</code> object. Contains things related to bimtaps,
	 * for example regarding the bitmap cache and the cache itself.
	 */
	static public var bitmap(default, null):BitmapFrontEnd = new BitmapFrontEnd();
	/**
	 * A reference to the <code>CameraFrontEnd</code> object. Contains things related to cameras,
	 * a <code>list</code> of all cameras and the <code>defaultCamera</code> amongst other things.
	 */
	static public var cameras(default, null):CameraFrontEnd = new CameraFrontEnd();
	/**
	 * A reference to the <code>PluginFrontEnd</code> object. Contains a <code>list</code> of all 
	 * plugins and the functions required to <code>add()</code>, <code>remove()</code> them etc.
	 */
	static public var plugins(default, null):PluginFrontEnd = new PluginFrontEnd();
	
	/**
	 * A reference to the <code>SoundFrontEnd</code> object. Contains a <code>list</code> of all 
	 * sounds and other things to manage or <code>play()</code> sounds.
	 */
	static public var sound(default, null):SoundFrontEnd = new SoundFrontEnd();
	
	/**
	 * Called by <code>FlxGame</code> to set up <code>FlxG</code> during <code>FlxGame</code>'s constructor.
	 */
	@:allow(flixel.FlxGame) // Access to this function is only needed in FlxGame::new()
	static private function init(Game:FlxGame, Width:Int, Height:Int, Zoom:Float):Void
	{	
		// TODO: check this later on real device
		//FlxAssets.cacheSounds();
		
		game = Game;
		width = Std.int(Math.abs(Width));
		height = Std.int(Math.abs(Height));
		FlxCamera.defaultZoom = Zoom;
		
		// Instantiate inputs
		#if !FLX_NO_KEYBOARD
			keyboard = cast(inputs.add(new FlxKeyboard()), FlxKeyboard);
			keys = new FlxKeyShortcuts();
		#end
		
		#if !FLX_NO_MOUSE
			mouse = cast(inputs.add(new FlxMouse(game.inputContainer)), FlxMouse);
		#end
		
		#if !FLX_NO_TOUCH
			touches = cast(inputs.add(new FlxTouchManager()), FlxTouchManager);
		#end
		
		#if (!FLX_NO_GAMEPAD && (cpp||neko||js))
			gamepads = cast(inputs.add(new FlxGamepadManager()), FlxGamepadManager);
		#end
		
		#if android
			android = cast(inputs.add(new FlxAndroidKeys()), FlxAndroidKeys);
		#end
		
		save.bind("flixel");
		sound.loadSavedPrefs();
		
		FlxAssets.init();
	}
	
	/**
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	@:allow(flixel.FlxGame.resetGame) // Access to this function is only needed in FlxGame::resetGame()
	static private function reset():Void
	{
		PxBitmapFont.clearStorage();
		FlxRandom.globalSeed = Math.random();
		
		bitmap.clearCache();
		inputs.reset();
		sound.destroySounds(true);
		paused = false;
		timeScale = 1.0;
		elapsed = 0;
		worldBounds.set( -10, -10, width + 20, height + 20);
		worldDivisions = 6;
	}
	
	/**
	 * The library name, which is "HaxeFlixel v.(major version).(minor version)"
	 */
	static public var libraryName(get, never):String;
	
	inline static private function get_libraryName():String
	{
		return LIBRARY_NAME + " v" + LIBRARY_MAJOR_VERSION + "." + LIBRARY_MINOR_VERSION;
	}
	
	/**
	 * How many times you want your game to update each second. More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the Flash Player framerate!
	 */
	static public var framerate(get, set):Int;
	
	inline static private function get_framerate():Int
	{
		return Std.int(1000 / game.stepMS);
	}
		
	static private function set_framerate(Framerate:Int):Int
	{
		if (Framerate < flashFramerate)
		{
			log.warn("FlxG.framerate: The game's framerate shouldn't be smaller than the flash framerate, since it can stop your game from updating.");
		}
		
		game.stepMS = Std.int(Math.abs(1000 / Framerate));
		game.stepSeconds = (game.stepMS / 1000);
		
		if (game.maxAccumulation < game.stepMS)
		{
			game.maxAccumulation = game.stepMS;
		}
		
		return Framerate;
	}
		
	/**
	 * How many times you want your game to update each second. More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the Flash Player framerate!
	 */
	public static var flashFramerate(get, set):Int;
		
	static private function get_flashFramerate():Int
	{
		if (game.stage != null)
		{
			return Std.int(game.stage.frameRate);
		}
		
		return 0;
	}
		
	static private function set_flashFramerate(Framerate:Int):Int
	{
		if (Framerate > framerate)
		{
			log.warn("FlxG.flashFramerate: The game's framerate shouldn't be smaller than the flash framerate, since it can stop your game from updating.");
		}
		
		game.flashFramerate = Std.int(Math.abs(Framerate));
		
		if (game.stage != null)
		{
			game.stage.frameRate = game.flashFramerate;
		}
		
		game.maxAccumulation = Std.int(2000 / game.flashFramerate) - 1;
		
		if (game.maxAccumulation < game.stepMS)
		{
			game.maxAccumulation = game.stepMS;
		}
		
		return Framerate;
	}
	
	/**
	 * Like hitting the reset button a game console, this will re-launch the game as if it just started.
	 */
	inline static public function resetGame():Void
	{
		game.requestedReset = true;
	}
	
	/**
	 * Handy helper functions that takes care of all the things to resize the game. 
	 * Use <code>FlxG.autoResize</code> to call this function automtically when the window is resized!
	 */
	inline static public function resizeGame(Width:Int, Height:Int):Void
	{
		camera.setSize(Math.ceil(Width / camera.zoom), Math.ceil(Height / camera.zoom));
		width = Width;
		height = Height;
	}
	
	/**
	 * Use this to toggle between fullscreen and normal mode. Works in cpp and flash.
	 * You can easily toggle fullscreen with eg: <code>FlxG.fullscreen = !FlxG.fullscreen;</code>
	 */
	@isVar static public var fullscreen(default, set):Bool = false;
	 
	static private function set_fullscreen(Value:Bool):Bool
	{

		if (Value)
		{
			stage.displayState = StageDisplayState.FULL_SCREEN;
			#if flash
			camera.x = (stage.fullScreenWidth - width * camera.zoom) / 2;
			camera.y = (stage.fullScreenHeight - height * camera.zoom) / 2;
			#end
		}
		else
		{
			stage.displayState = StageDisplayState.NORMAL;
		}

		return fullscreen = Value;
	}
	
	/**
	 * Read-only: retrieves the Flash stage object (required for event listeners)
	 * Will be null if it's not safe/useful yet.
	 */
	public static var stage(get, never):Stage;
	
	inline static private function get_stage():Stage
	{
		return game.stage;
	}
	
	/**
	 * Read-only: access the current game state from anywhere.
	 */
	public static var state(get, never):FlxState;
	
	inline static private function get_state():FlxState
	{
		return game.state;
	}
	
	/**
	 * Switch from the current game state to the one specified here.
	 */
	inline static public function switchState(State:FlxState):Void
	{
		game.requestNewState(State); 
	}
	
	/**
	 * Request a reset of the current game state.
	 */
	inline static public function resetState():Void
	{
		game.requestNewState(Type.createInstance(Type.resolveClass(FlxStringUtil.getClassName(game.state, false)), []));
		
		#if !FLX_NO_DEBUG
		if (Std.is(game.requestedState, FlxSubState))
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
	 * NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.
	 * @param	ProcessCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.  If a ProcessCallback is provided, then NotifyCallback will only be called if ProcessCallback returns true for those objects!
	 * @return	Whether any overlaps were detected.
	 */
	static public function overlap(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void, ?ProcessCallback:Dynamic->Dynamic->Bool):Bool
	{
		if (ObjectOrGroup1 == null)
		{
			ObjectOrGroup1 = state;
		}
		if (ObjectOrGroup2 == ObjectOrGroup1)
		{
			ObjectOrGroup2 = null;
		}
		FlxQuadTree.divisions = worldDivisions;
		var quadTree:FlxQuadTree = FlxQuadTree.recycle(worldBounds.x, worldBounds.y, worldBounds.width, worldBounds.height);
		quadTree.load(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
		var result:Bool = quadTree.execute();
		quadTree.destroy();
		return result;
	}
	
	/**
	 * A Pixel Perfect Collision check between two FlxSprites.
	 * It will do a bounds check first, and if that passes it will run a pixel perfect match on the intersecting area.
	 * Works with rotated and animated sprites.
	 * It's extremly slow on cpp targets, so I don't recommend you to use it on them.
	 * Not working on neko target and awfully slows app down
	 * 
	 * @param	Sprite1			The first FlxSprite to test against
	 * @param	Sprite2			The second FlxSprite to test again, sprite order is irrelevant
	 * @param	AlphaTolerance	The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
	 * @param	Camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * @return	Boolean True if the sprites collide, false if not
	 */
	inline static public function pixelPerfectOverlap(Sprite1:FlxSprite, Sprite2:FlxSprite, AlphaTolerance:Int = 255, ?Camera:FlxCamera):Bool
	{
		return FlxCollision.pixelPerfectCheck(Sprite1, Sprite2, AlphaTolerance, Camera);
	}
	
	/**
	 * Call this function to see if one <code>FlxObject</code> collides with another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a <code>FlxGroup</code> (or even bundling groups together!).
	 * This function just calls FlxG.overlap and presets the ProcessCallback parameter to FlxObject.separate.
	 * To create your own collision logic, write your own ProcessCallback and use FlxG.overlap to set it up.
	 * NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two <code>FlxObject</code> parameters - e.g. <code>myOverlapFunction(Object1:FlxObject,Object2:FlxObject)</code> - that is called if those two objects overlap.
	 * @return	Whether any objects were successfully collided/separated.
	 */
	inline static public function collide(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void):Bool
	{
		return overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, FlxObject.separate);
	}
	
	/**
	 * Checks if an object is not null before calling destroy(), always returns null.
	 * 
	 * @param	Object	An FlxBasic object that will be destroyed if it's not null.
	 * @return	Null
	 */
	public static function safeDestroy<T:IDestroyable>(Object:Null<IDestroyable>):T
	{
		if (Object != null)
		{
			Object.destroy(); 
		}
		return null;
	}
}
