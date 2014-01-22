package flixel;

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
import flixel.system.frontEnds.BmpLogFrontEnd;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.ConsoleFrontEnd;
import flixel.system.frontEnds.DebuggerFrontEnd;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.system.frontEnds.LogFrontEnd;
import flixel.system.frontEnds.PluginFrontEnd;
import flixel.system.frontEnds.VCRFrontEnd;
import flixel.system.frontEnds.WatchFrontEnd;
import flixel.system.resolution.BaseResolutionPolicy;
import flixel.system.resolution.StageSizeResolutionPolicy;
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

/**
 * Global helper class for audio, input, the camera system, the debugger and other global properties.
 */
class FlxG 
{
	/**
	 * Whether the game should be paused when focus is lost or not. Use FLX_NO_FOCUS_LOST_SCREEN if you only want to get rid of the default
	 * pause screen. Override onFocus() and onFocusLost() for your own behaviour in your state.
	 */
	static public var autoPause:Bool = true;
	/**
	 * WARNING: Changing this can lead to issues with physics and the recording system. Setting this to 
	 * false might lead to smoother animations (even at lower fps) at the cost of physics accuracy.
	 */
	static public var fixedTimestep:Bool = true;
	/**
	 * How fast or slow time should pass in the game; default is 1.0.
	 */
	static public var timeScale:Float = 1;
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
	 * The HaxeFlixel version, in semantic versioning syntax. Use <code>Std.string()</code>
	 * on it to get a String formatted like this: "HaxeFlixel MAJOR.MINOR.PATCH-PATCH_VERSION".
	 */ 
	static public var VERSION(default, null):FlxVersion = new FlxVersion(3, 1, 0, "dev");
	
	/**
	 * Internal tracker for game object.
	 */
	static public var game(default, null):FlxGame;
	/**
	 * Read-only: retrieves the Flash stage object (required for event listeners)
	 * Will be null if it's not safe/useful yet.
	 */
	public static var stage(get, never):Stage;
	/**
	 * Read-only: access the current game state from anywhere. Consider using <code>addChildBelowMouse()</code>
	 * if you want to add a DisplayObject to the stage instead of directly adding it here!
	 */
	public static var state(get, never):FlxState;
	/**
	 * How many times you want your game to update each second. More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the draw framerate!
	 */
	static public var updateFramerate(get, set):Int;
	/**
	 * How many times you want your game to step each second. More steps usually means greater responsiveness, 
	 * but it can also slowdown your game if the stage can't keep up with the update routine. NOTE: This is NOT the same thing as the Update framerate!
	 */
	public static var drawFramerate(get, set):Int;
	
	/**
	 * Represents the amount of time in seconds that passed since last frame.
	 */
	@:allow(flixel.FlxGame)
	static public var elapsed(default, null):Float = 0;
	
	/**
	 * The width of the screen in game pixels. Read-only, use <code>resizeGame()</code> to change.
	 */
	@:allow(flixel.system.resolution.StageSizeResolutionPolicy) 
	static public var width(default, null):Int;
	/**
	 * The height of the screen in game pixels. Read-only, use <code>resizeGame()</code> to change.
	 */
	@:allow(flixel.system.resolution.StageSizeResolutionPolicy)
	static public var height(default, null):Int;
	/**
	 * The resolution policy the game should use - available policies are <code>FillResolutionPolicy</code>, <code>FixedResolutionPolicy</code>,
	 * <code>RatioResolutionPolicy</code>, <code>RelativeResolutionPolicy</code> and <code>StageResolutionPolicy</code>.
	 */
	static public var resolutionPolicy(default, set):BaseResolutionPolicy;
	/**
	 * Use this to toggle between fullscreen and normal mode. Works in cpp and flash.
	 * You can easily toggle fullscreen with eg: <code>FlxG.fullscreen = !FlxG.fullscreen;</code>
	 */
	@isVar static public var fullscreen(default, set):Bool = false;
	/**
	 * The dimensions of the game world, used by the quad tree for collisions and overlap checks.
	 * Use <code>.set()</code> instead of creating a new object!
	 */
	static public var worldBounds(default, null):FlxRect = new FlxRect();
	
	/**
	 * A <code>FlxSave</code> used internally by flixel to save sound preferences and 
	 * the history of the console window, but no reason you can't use it for your own stuff too!
	 */
	static public var save(default, null):FlxSave = new FlxSave();
	
	#if !FLX_NO_MOUSE
	/**
	 * A <code>FlxMouse</code> object for mouse input. e.g.: check if the left mouse button 
	 * is pressed with <code>if (FlxG.mouse.pressed) { }</code>) </code>in <code>update()</code>.
	 */
	static public var mouse(default, null):FlxMouse;
	#end

	#if !FLX_NO_KEYBOARD
	/**
	 * A <code>FlxKeyboard</code> object for keyboard input e.g.: check if the left arrow key is 
	 * pressed with <code>if (FlxG.keys.pressed.LEFT) { } </code>in <code>update()</code>.
	 */
	static public var keys(default, null):FlxKeyboard;
	#end

	#if !FLX_NO_TOUCH
	/**
	 * A reference to a <code>FlxTouchManager</code> object. 
	 * Useful for devices with multitouch support.
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
	
	#if !FLX_NO_SOUND_SYSTEM
	/**
	 * A reference to the <code>SoundFrontEnd</code> object. Contains a <code>list</code> of all 
	 * sounds and other things to manage or <code>play()</code> sounds.
	 */
	static public var sound(default, null):SoundFrontEnd = new SoundFrontEnd();
	#end
	
	static private var _resolutionPolicy:BaseResolutionPolicy = new StageSizeResolutionPolicy();
	
	/**
	 * Handy helper functions that takes care of all the things to resize the game.
	 */
	inline static public function resizeGame(Width:Int, Height:Int):Void
	{
		_resolutionPolicy.onMeasure(Width, Height);
	}
	
	/**
	 * Like hitting the reset button a game console, this will re-launch the game as if it just started.
	 */
	inline static public function resetGame():Void
	{
		game.resetState = true;
	}
	
	/**
	 * Switch from the current game state to the one specified here.
	 */
	inline static public function switchState(State:FlxState):Void
	{
		game.requestedState = State; 
	}
	
	/**
	 * Request a reset of the current game state.
	 */
	inline static public function resetState():Void
	{
		switchState(Type.createInstance(Type.getClass(state), []));
		
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
	static public function safeDestroy<T:IFlxDestroyable>(Object:Null<IFlxDestroyable>):T
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
	static public function addChildBelowMouse(Child:DisplayObject, IndexModifier:Int = 0):DisplayObject
	{
		var index = game.getChildIndex(game.inputContainer);
		var max = game.numChildren;
		
		index = FlxMath.maxAdd(index, IndexModifier, max);
		return game.addChildAt(Child, index);
	}
	
	/**
	 * Removes a child from the flixel display list.
	 * 
	 * @param 	Child	The DisplayObject to add
	 * @return	The removed DisplayObject
	 */
	inline static public function removeChild(Child:DisplayObject):DisplayObject
	{
		return game.removeChild(Child);
	}
	
	/**
	 * Opens a web page, by default a new tab or window.
	 * 
	 * @param	URL		The address of the web page.
	 * @param	Target	<code>"_blank", "_self", "_parent"</code> or <code>"_top"</code>
	 */
	inline static public function openURL(URL:String, Target:String = "_blank"):Void
	{
		Lib.getURL(new URLRequest(URL), Target);
	}
	
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
		
		resizeGame(width, height);
		
		// Instantiate inputs
		#if !FLX_NO_KEYBOARD
		keys = inputs.add(new FlxKeyboard());
		#end
		
		#if !FLX_NO_MOUSE
		mouse = inputs.add(new FlxMouse(game.inputContainer));
		#end
		
		#if !FLX_NO_TOUCH
		touches = inputs.add(new FlxTouchManager());
		#end
		
		#if (!FLX_NO_GAMEPAD && (cpp||neko||js))
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
	@:allow(flixel.FlxGame.resetGame) // Access to this function is only needed in FlxGame::resetGame()
	static private function reset():Void
	{
		PxBitmapFont.clearStorage();
		FlxRandom.resetGlobalSeed();
		
		bitmap.clearCache();
		inputs.reset();
		#if !FLX_NO_SOUND_SYSTEM
		sound.destroySounds(true);
		#end
		timeScale = 1.0;
		elapsed = 0;
		worldBounds.set( -10, -10, width + 20, height + 20);
		worldDivisions = 6;
	}
	
	static private function set_resolutionPolicy(Policy:BaseResolutionPolicy):BaseResolutionPolicy
	{
		_resolutionPolicy = Policy;
		resizeGame(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		return Policy;
	}
	
	inline static private function get_updateFramerate():Int
	{
		return Std.int(1000 / game.stepMS);
	}
	
	static private function set_updateFramerate(Framerate:Int):Int
	{
		if (Framerate < drawFramerate)
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
	
	static private function get_drawFramerate():Int
	{
		if (game.stage != null)
		{
			return Std.int(game.stage.frameRate);
		}
		
		return 0;
	}
	
	static private function set_drawFramerate(Framerate:Int):Int
	{
		if (Framerate > updateFramerate)
		{
			log.warn("FlxG.drawFramerate: The update framerate shouldn't be smaller than the draw framerate, since it can stop your game from updating.");
		}
		
		game.drawFramerate = Std.int(Math.abs(Framerate));
		
		if (game.stage != null)
		{
			game.stage.frameRate = game.drawFramerate;
		}
		
		game.maxAccumulation = Std.int(2000 / game.drawFramerate) - 1;
		
		if (game.maxAccumulation < game.stepMS)
		{
			game.maxAccumulation = game.stepMS;
		}
		
		return Framerate;
	}
	
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
	
	inline static private function get_stage():Stage
	{
		return game.stage;
	}
	
	inline static private function get_state():FlxState
	{
		return game.state;
	}
}