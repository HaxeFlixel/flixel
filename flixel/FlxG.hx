package flixel;

import flash.Lib;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.Lib;
import flash.net.URLRequest;
import flixel.FlxBasic;
import flixel.interfaces.IFlxDestroyable;
import flixel.system.FlxAssets;
import flixel.system.FlxQuadTree;
import flixel.system.FlxVersion;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.ConsoleFrontEnd;
import flixel.system.frontEnds.DebuggerFrontEnd;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.system.frontEnds.LogFrontEnd;
import flixel.system.frontEnds.PluginFrontEnd;
import flixel.system.frontEnds.VCRFrontEnd;
import flixel.system.frontEnds.WatchFrontEnd;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.text.pxText.PxBitmapFont;
import flixel.util.FlxCollision;
import flixel.util.FlxMath;
import flixel.util.FlxRandom;
import flixel.util.FlxRect;
import flixel.util.FlxSave;

#if !FLX_NO_TOUCH
import flixel.input.touch.FlxTouchManager;
#end
#if !FLX_NO_KEYBOARD
import flixel.input.keyboard.FlxKeyboard;
#end
#if !FLX_NO_MOUSE
import flixel.input.mouse.FlxMouse;
#end
#if !FLX_NO_GAMEPAD
import flixel.input.gamepad.FlxGamepadManager;
#end
#if !FLX_NO_SOUND_SYSTEM
import flixel.system.frontEnds.SoundFrontEnd;
#end
#if android
import flixel.input.android.FlxAndroidKeys;
#end
#if js
import flixel.system.frontEnds.HTML5FrontEnd;
#end
#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
import flixel.input.FlxSwipe;
#end

/**
 * Global helper class for audio, input, the camera system, the debugger and other global properties.
 */
@:allow(flixel.FlxGame)
class FlxG 
{
	/**
	 * Whether the game should be paused when focus is lost or not. Use FLX_NO_FOCUS_LOST_SCREEN if you only want to get rid of the default
	 * pause screen. Override onFocus() and onFocusLost() for your own behaviour in your state.
	 */
	public static var autoPause:Bool = true;
	/**
	 * WARNING: Changing this can lead to issues with physics and the recording system. Setting this to 
	 * false might lead to smoother animations (even at lower fps) at the cost of physics accuracy.
	 */
	public static var fixedTimestep:Bool = true;
	/**
	 * How fast or slow time should pass in the game; default is 1.0.
	 */
	public static var timeScale:Float = 1;
	/**
	 * How many times the quad tree should divide the world on each axis. Generally, sparse collisions can have fewer divisons,
	 * while denser collision activity usually profits from more. Default value is 6.
	 */
	public static var worldDivisions:Int;
	/**
	 * By default this just refers to the first entry in the FlxG.cameras.list 
	 * array but you can do what you like with it.
	 */
	public static var camera:FlxCamera;
	
	/**
	 * The HaxeFlixel version, in semantic versioning syntax. Use Std.string()
	 * on it to get a String formatted like this: "HaxeFlixel MAJOR.MINOR.PATCH-PATCH_VERSION".
	 */ 
	public static var VERSION(default, null):FlxVersion = new FlxVersion(3, 2, 2, "dev");
	
	/**
	 * Internal tracker for game object.
	 */
	public static var game(default, null):FlxGame;
	/**
	 * Read-only: retrieves the Flash stage object (required for event listeners)
	 * Will be null if it's not safe/useful yet.
	 */
	public static var stage(get, never):Stage;
	/**
	 * Read-only: access the current game state from anywhere. Consider using addChildBelowMouse()
	 * if you want to add a DisplayObject to the stage instead of directly adding it here!
	 */
	public static var state(get, never):FlxState;
	/**
	 * How many times you want your game to update each second. More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the draw framerate!
	 */
	public static var updateFramerate(get, set):Int;
	/**
	 * How many times you want your game to step each second. More steps usually means greater responsiveness, 
	 * but it can also slowdown your game if the stage can't keep up with the update routine. NOTE: This is NOT the same thing as the Update framerate!
	 */
	public static var drawFramerate(default, set):Int;
	
	/**
	 * Represents the amount of time in seconds that passed since last frame.
	 */
	public static var elapsed(default, null):Float = 0;
	
	/**
	 * The width of the screen in game pixels. Read-only, use resizeGame() to change.
	 */
	@:allow(flixel.system.scaleModes.StageSizeScaleMode) 
	public static var width(default, null):Int;
	/**
	 * The height of the screen in game pixels. Read-only, use resizeGame() to change.
	 */
	@:allow(flixel.system.scaleModes.StageSizeScaleMode)
	public static var height(default, null):Int;
	/**
	 * The scale mode the game should use - available policies are FillScaleMode, FixedScaleMode,
	 * RatioScaleMode, RelativeScaleMode and StageSizeScaleMode.
	 */
	public static var scaleMode(default, set):BaseScaleMode;
	/**
	 * Use this to toggle between fullscreen and normal mode. Works in cpp and flash.
	 * You can easily toggle fullscreen with eg: FlxG.fullscreen = !FlxG.fullscreen;
	 */
	public static var fullscreen(default, set):Bool = false;
	/**
	 * The dimensions of the game world, used by the quad tree for collisions and overlap checks.
	 * Use .set() instead of creating a new object!
	 */
	public static var worldBounds(default, null):FlxRect = new FlxRect();
	
	/**
	 * A FlxSave used internally by flixel to save sound preferences and 
	 * the history of the console window, but no reason you can't use it for your own stuff too!
	 */
	public static var save(default, null):FlxSave = new FlxSave();
	
	#if !FLX_NO_MOUSE
	/**
	 * A FlxMouse object for mouse input. e.g.: check if the left mouse button 
	 * is pressed with if (FlxG.mouse.pressed) { }) in update().
	 */
	public static var mouse(default, null):FlxMouse;
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * A reference to a FlxTouchManager object. 
	 * Useful for devices with multitouch support.
	 */
	public static var touches(default, null):FlxTouchManager;
	#end
	
	#if (!FLX_NO_MOUSE || !FLX_NO_TOUCH)
	/**
	 * Contains all "swipes" from both mouse and touch input that have just ended.
	 */
	public static var swipes(default, null):Array<FlxSwipe> = [];
	#end

	#if !FLX_NO_KEYBOARD
	/**
	 * A FlxKeyboard object for keyboard input e.g.: check if the left arrow key is 
	 * pressed with if (FlxG.keys.pressed.LEFT) { } in update().
	 */
	public static var keys(default, null):FlxKeyboard;
	#end
	
	#if !FLX_NO_GAMEPAD
	/**
	 * A reference to a FlxGamepadManager object.
	 */
	public static var gamepads(default, null):FlxGamepadManager;
	#end
	
	#if android
	/**
	 * A reference to a FlxAndroidKeys object. Useful for tracking Back, Home, etc on Android devices.
	 */
	public static var android(default, null):FlxAndroidKeys;
	#end
	
	#if js
	/**
	 * A reference to the HTML5FrontEnd object. Has some HTML5-specific things like
	 * browser detection, browser dimensions etc...
	 */
	public static var html5(default, null):HTML5FrontEnd = new HTML5FrontEnd();
	#end
	
	/**
	 * A reference to the InputFrontEnd object. Mostly used internally, 
	 * but you can use it too to reset inputs and create input classes of your own.
	 */
	public static var inputs(default, null):InputFrontEnd = new InputFrontEnd();
	/**
	 * A reference to the ConsoleFrontEnd object. Use it to register functions and objects
	 * or add new commands to the console window.
	 */
	public static var console(default, null):ConsoleFrontEnd = new ConsoleFrontEnd();
	/**
	 * A reference to the LogFrontEnd object. Use it to add messages to the log window. It is recommended 
	 * to use trace() instead of the old FlxG.log(), since traces will be redirected by default.
	 */
	public static var log(default, null):LogFrontEnd = new LogFrontEnd();
	
	/**
	 * A reference to the WatchFrontEnd object. Use it to add or remove things to / from the 
	 * watch window.
	 */
	public static var watch(default, null):WatchFrontEnd = new WatchFrontEnd();
	/**
	 * A reference to the DebuggerFrontEnd object. Use it to show / hide / toggle the debguger
	 * change its layout, activate visual debugging or change the key used to toggle it.
	 */
	public static var debugger(default, null):DebuggerFrontEnd = new DebuggerFrontEnd();

	/**
	 * A reference to the VCRFrontEnd object. Contains all the functions needed for recording
	 * and replaying.
	 */
	public static var vcr(default, null):VCRFrontEnd = new VCRFrontEnd();
	
	/**
	 * A reference to the BitmapFrontEnd object. Contains things related to bimtaps,
	 * for example regarding the bitmap cache and the cache itself.
	 */
	public static var bitmap(default, null):BitmapFrontEnd = new BitmapFrontEnd();
	/**
	 * A reference to the CameraFrontEnd object. Contains things related to cameras,
	 * a list of all cameras and several effects like flash() or fade().
	 */
	public static var cameras(default, null):CameraFrontEnd = new CameraFrontEnd();
	/**
	 * A reference to the PluginFrontEnd object. Contains a list of all 
	 * plugins and the functions required to add(), remove() them etc.
	 */
	public static var plugins(default, null):PluginFrontEnd = new PluginFrontEnd();
	
	#if !FLX_NO_SOUND_SYSTEM
	/**
	 * A reference to the SoundFrontEnd object. Contains a list of all 
	 * sounds and other things to manage or play() sounds.
	 */
	public static var sound(default, null):SoundFrontEnd = new SoundFrontEnd();
	#end
	
	private static var _scaleMode:BaseScaleMode = new RatioScaleMode();
	
	/**
	 * Handy helper functions that takes care of all the things to resize the game.
	 */
	public static inline function resizeGame(Width:Int, Height:Int):Void
	{
		_scaleMode.onMeasure(Width, Height);
	}
	
	/**
	 * Like hitting the reset button a game console, this will re-launch the game as if it just started.
	 */
	public static inline function resetGame():Void
	{
		game._resetGame = true;
	}
	
	/**
	 * Switch from the current game state to the one specified here.
	 */
	public static inline function switchState(State:FlxState):Void
	{
		game._requestedState = State; 
	}
	
	/**
	 * Request a reset of the current game state.
	 */
	public static inline function resetState():Void
	{
		switchState(Type.createInstance(Type.getClass(state), []));
	}

	/**
	 * Call this function to see if one FlxObject overlaps another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 * NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two FlxObject parameters - e.g. myOverlapFunction(Object1:FlxObject,Object2:FlxObject) - that is called if those two objects overlap.
	 * @param	ProcessCallback	A function with two FlxObject parameters - e.g. myOverlapFunction(Object1:FlxObject,Object2:FlxObject) - that is called if those two objects overlap.  If a ProcessCallback is provided, then NotifyCallback will only be called if ProcessCallback returns true for those objects!
	 * @return	Whether any overlaps were detected.
	 */
	public static function overlap(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void, ?ProcessCallback:Dynamic->Dynamic->Bool):Bool
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
	 * A Pixel Perfect Collision check between two FlxSprites. It will do a bounds check first, and if that passes it will run a 
	 * pixel perfect match on the intersecting area. Works with rotated and animated sprites. May be slow, so use it sparingly.
	 * 
	 * @param	Sprite1			The first FlxSprite to test against
	 * @param	Sprite2			The second FlxSprite to test again, sprite order is irrelevant
	 * @param	AlphaTolerance	The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
	 * @param	Camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * @return	Whether the sprites collide
	 */
	public static inline function pixelPerfectOverlap(Sprite1:FlxSprite, Sprite2:FlxSprite, AlphaTolerance:Int = 255, ?Camera:FlxCamera):Bool
	{
		return FlxCollision.pixelPerfectCheck(Sprite1, Sprite2, AlphaTolerance, Camera);
	}
	
	/**
	 * Call this function to see if one FlxObject collides with another.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 * This function just calls FlxG.overlap and presets the ProcessCallback parameter to FlxObject.separate.
	 * To create your own collision logic, write your own ProcessCallback and use FlxG.overlap to set it up.
	 * NOTE: does NOT take objects' scrollfactor into account, all overlaps are checked in world space.
	 * 
	 * @param	ObjectOrGroup1	The first object or group you want to check.
	 * @param	ObjectOrGroup2	The second object or group you want to check.  If it is the same as the first, flixel knows to just do a comparison within that group.
	 * @param	NotifyCallback	A function with two FlxObject parameters - e.g. myOverlapFunction(Object1:FlxObject,Object2:FlxObject) - that is called if those two objects overlap.
	 * @return	Whether any objects were successfully collided/separated.
	 */
	public static inline function collide(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void):Bool
	{
		return overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, FlxObject.separate);
	}
	
	/**
	 * Checks if an object is not null before calling destroy(), always returns null.
	 * 
	 * @param	Object	An FlxBasic object that will be destroyed if it's not null.
	 * @return	Null
	 */
	public static function safeDestroy<T:IFlxDestroyable>(Object:Null<IFlxDestroyable>):T
	{
		if (Object != null)
		{
			Object.destroy(); 
		}
		return null;
	}
	
	/**
	 * Regular DisplayObjects are normally displayed over the flixel cursor and the flixel debugger if simply 
	 * added to stage. This function simplifies things by adding a DisplayObject directly below mouse level.
	 * 
	 * @param 	Child			The DisplayObject to add
	 * @param 	IndexModifier	Amount to add to the index - makes sure the index stays within bounds!
	 * @return	The added DisplayObject
	 */
	@:generic public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T
	{
		var index = game.getChildIndex(game._inputContainer);
		var max = game.numChildren;
		
		index = FlxMath.maxAdd(index, IndexModifier, max);
		game.addChildAt(Child, index);
		return Child;
	}
	
	/**
	 * Removes a child from the flixel display list, if it is part of it.
	 * 
	 * @param 	Child	The DisplayObject to add
	 * @return	The removed DisplayObject
	 */
	@:generic public static inline function removeChild<T:DisplayObject>(Child:T):T
	{
		if (game.contains(Child))
		{
			game.removeChild(Child);
		}
		return Child;
	}
	
	/**
	 * Opens a web page, by default a new tab or window.
	 * 
	 * @param	URL		The address of the web page.
	 * @param	Target	"_blank", "_self", "_parent" or "_top"
	 */
	public static inline function openURL(URL:String, Target:String = "_blank"):Void
	{
		Lib.getURL(new URLRequest(URL), Target);
	}
	
	/**
	 * Called by FlxGame to set up FlxG during FlxGame's constructor.
	 */
	private static function init(Game:FlxGame, Width:Int, Height:Int, Zoom:Float):Void
	{	
		// TODO: check this later on real device
		//FlxAssets.cacheSounds();
		
		game = Game;
		width = Std.int(Math.abs(Width));
		height = Std.int(Math.abs(Height));
		FlxCamera.defaultZoom = Zoom;
		
		resizeGame(stage.stageWidth, stage.stageHeight);
		
		// Instantiate inputs
		#if !FLX_NO_KEYBOARD
		keys = inputs.add(new FlxKeyboard());
		#end
		
		#if !FLX_NO_MOUSE
		mouse = inputs.add(new FlxMouse(game._inputContainer));
		#end
		
		#if !FLX_NO_TOUCH
		touches = inputs.add(new FlxTouchManager());
		#end
		
		#if !FLX_NO_GAMEPAD
		gamepads = inputs.add(new FlxGamepadManager());
		#end
		
		#if android
		android = inputs.add(new FlxAndroidKeys());
		#end
		
		save.bind("flixel");
		
		#if !FLX_NO_SOUND_SYSTEM
		sound.loadSavedPrefs();
		#end
		
		FlxAssets.init();
	}
	
	/**
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	private static function reset():Void
	{
		PxBitmapFont.clearStorage();
		FlxRandom.resetGlobalSeed();
		
		bitmap.clearCache();
		inputs.reset();
		#if !FLX_NO_SOUND_SYSTEM
		sound.destroy(true);
		#end
		timeScale = 1.0;
		elapsed = 0;
		worldBounds.set( -10, -10, width + 20, height + 20);
		worldDivisions = 6;
	}
	
	private static function set_scaleMode(ScaleMode:BaseScaleMode):BaseScaleMode
	{
		_scaleMode = ScaleMode;
		game.onResize();
		return ScaleMode;
	}
	
	private static inline function get_updateFramerate():Int
	{
		return Std.int(1000 / game._stepMS);
	}
	
	private static function set_updateFramerate(Framerate:Int):Int
	{
		if (Framerate < drawFramerate)
		{
			log.warn("FlxG.framerate: The game's framerate shouldn't be smaller than the flash framerate, since it can stop your game from updating.");
		}
		
		game._stepMS = Std.int(Math.abs(1000 / Framerate));
		game._stepSeconds = (game._stepMS / 1000);
		
		if (game._maxAccumulation < game._stepMS)
		{
			game._maxAccumulation = game._stepMS;
		}
		
		return Framerate;
	}
	
	private static function set_drawFramerate(Framerate:Int):Int
	{
		if (Framerate > updateFramerate)
		{
			log.warn("FlxG.drawFramerate: The update framerate shouldn't be smaller than the draw framerate, since it can stop your game from updating.");
		}
		
		drawFramerate = Std.int(Math.abs(Framerate));
		
		if (game.stage != null)
		{
			game.stage.frameRate = drawFramerate;
		}
		
		game._maxAccumulation = Std.int(2000 / drawFramerate) - 1;
		
		if (game._maxAccumulation < game._stepMS)
		{
			game._maxAccumulation = game._stepMS;
		}
		
		return Framerate;
	}
	
	private static function set_fullscreen(Value:Bool):Bool
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
	
	private static inline function get_stage():Stage
	{
		return Lib.current.stage;
	}
	
	private static inline function get_state():FlxState
	{
		return game._state;
	}
}
