package flixel;

import flash.Lib;
import flash.display.DisplayObject;
import flash.display.Stage;
import flash.display.StageDisplayState;
import flash.net.URLRequest;
import flixel.effects.postprocess.PostProcess;
import flixel.math.FlxMath;
import flixel.math.FlxRandom;
import flixel.math.FlxRect;
import flixel.system.FlxQuadTree;
import flixel.system.FlxVersion;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.frontEnds.BitmapLogFrontEnd;
import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.ConsoleFrontEnd;
import flixel.system.frontEnds.DebuggerFrontEnd;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.system.frontEnds.LogFrontEnd;
import flixel.system.frontEnds.PluginFrontEnd;
import flixel.system.frontEnds.SignalFrontEnd;
import flixel.system.frontEnds.SoundFrontEnd;
import flixel.system.frontEnds.VCRFrontEnd;
import flixel.system.frontEnds.WatchFrontEnd;
import flixel.system.scaleModes.BaseScaleMode;
import flixel.system.scaleModes.RatioScaleMode;
import flixel.util.FlxCollision;
import flixel.util.FlxSave;
#if FLX_TOUCH
import flixel.input.touch.FlxTouchManager;
#end
#if FLX_KEYBOARD
import flixel.input.keyboard.FlxKeyboard;
#end
#if FLX_MOUSE
import flixel.input.mouse.FlxMouse;
#end
#if FLX_GAMEPAD
import flixel.input.gamepad.FlxGamepadManager;
#end
#if android
import flixel.input.android.FlxAndroidKeys;
#end
#if FLX_ACCELEROMETER
import flixel.input.FlxAccelerometer;
#end
#if FLX_POINTER_INPUT
import flixel.input.FlxSwipe;
#end
#if FLX_POST_PROCESS
import openfl.display.OpenGLView;
import flixel.util.FlxDestroyUtil;

using flixel.util.FlxArrayUtil;
#end

#if html5
import flixel.system.frontEnds.HTML5FrontEnd;
#end

/**
 * Global helper class for audio, input, the camera system, the debugger and other global properties.
 */
class FlxG
{
	/**
	 * Whether the game should be paused when focus is lost or not. Use `-D FLX_NO_FOCUS_LOST_SCREEN`
	 * if you only want to get rid of the default pause screen.
	 * Override `onFocus()` and `onFocusLost()` for your own behaviour in your state.
	 */
	public static var autoPause:Bool = true;

	/**
	 * WARNING: Changing this can lead to issues with physics and the recording system. Setting this to
	 * `false` might lead to smoother animations (even at lower fps) at the cost of physics accuracy.
	 */
	public static var fixedTimestep:Bool = true;

	/**
	 * How fast or slow time should pass in the game; default is `1.0`.
	 */
	public static var timeScale:Float = 1;

	/**
	 * How many times the quad tree should divide the world on each axis.
	 * Generally, sparse collisions can have fewer divisons,
	 * while denser collision activity usually profits from more. Default value is `6`.
	 */
	public static var worldDivisions:Int = 6;

	/**
	 * By default this just refers to the first entry in the `FlxG.cameras.list`
	 * array but you can do what you like with it.
	 */
	public static var camera:FlxCamera;

	/**
	 * The HaxeFlixel version, in semantic versioning syntax. Use `Std.string()`
	 * on it to get a `String` formatted like this: `"HaxeFlixel MAJOR.MINOR.PATCH-COMMIT_SHA"`.
	 */
	public static var VERSION(default, null):FlxVersion = new FlxVersion(4, 10, 0);

	/**
	 * Internal tracker for game object.
	 */
	public static var game(default, null):FlxGame;

	/**
	 * The Flash stage object (required for event listeners).
	 * Will be `null` if it's not safe/useful yet.
	 */
	public static var stage(get, never):Stage;

	/**
	 * Access the current game state from anywhere. Consider using `addChildBelowMouse()`
	 * if you want to add a `DisplayObject` to the stage instead of directly adding it here!
	 */
	public static var state(get, never):FlxState;

	/**
	 * How many times you want your game to update each second.
	 * More updates usually means better collisions and smoother motion.
	 * NOTE: This is NOT the same thing as the draw framerate!
	 */
	public static var updateFramerate(default, set):Int;

	/**
	 * How many times you want your game to step each second. More steps usually means greater responsiveness,
	 * but it can also slowdown your game if the stage can't keep up with the update routine.
	 * NOTE: This is NOT the same thing as the update framerate!
	 */
	public static var drawFramerate(default, set):Int;

	/**
	 * Whether the game is running on a mobile device.
	 * If on HTML5, it returns `FlxG.html5.onMobile`.
	 * Otherwise, it checks whether the `mobile` haxedef is defined.
	 * @since 4.2.0
	 */
	public static var onMobile(get, never):Bool;

	public static var renderMethod(default, null):FlxRenderMethod;

	public static var renderBlit(default, null):Bool;
	public static var renderTile(default, null):Bool;

	/**
	 * Represents the amount of time in seconds that passed since last frame.
	 */
	@:allow(flixel.FlxGame.updateElapsed)
	public static var elapsed(default, null):Float = 0;

	/**
	 * Useful when the timestep is NOT fixed (i.e. variable),
	 * to prevent jerky movement or erratic behavior at very low fps.
	 * Essentially locks the framerate to a minimum value - any slower and you'll get
	 * slowdown instead of frameskip; default is 1/10th of a second.
	 */
	public static var maxElapsed:Float = 0.1;

	/**
	 * The width of the screen in game pixels. Read-only, use `resizeGame()` to change.
	 */
	@:allow(flixel.system.scaleModes)
	public static var width(default, null):Int;

	/**
	 * The height of the screen in game pixels. Read-only, use `resizeGame()` to change.
	 */
	@:allow(flixel.system.scaleModes)
	public static var height(default, null):Int;

	/**
	 * The scale mode the game should use - available policies are found in `flixel.system.scaleModes`.
	 */
	public static var scaleMode(default, set):BaseScaleMode = new RatioScaleMode();

	/**
	 * Use this to toggle between fullscreen and normal mode. Works on CPP, Neko and Flash.
	 * You can easily toggle fullscreen with e.g.: `FlxG.fullscreen = !FlxG.fullscreen;`
	 */
	public static var fullscreen(get, set):Bool;

	/**
	 * The dimensions of the game world, used by the quad tree for collisions and overlap checks.
	 * Use `.set()` instead of creating a new object!
	 */
	public static var worldBounds(default, null):FlxRect = FlxRect.get();

	/**
	 * A `FlxSave` used internally by flixel to save sound preferences and
	 * the history of the console window, but no reason you can't use it for your own stuff too!
	 */
	public static var save(default, null):FlxSave = new FlxSave();

	/**
	 * A `FlxRandom` object which can be used to generate random numbers.
	 * Also used by Flixel internally.
	 */
	public static var random(default, null):FlxRandom = new FlxRandom();

	#if FLX_MOUSE
	/**
	 * Used for mouse input. e.g.: check if the left mouse button
	 * is pressed with `if (FlxG.mouse.pressed) { })` in `update()`.
	 */
	public static var mouse(default, set):FlxMouse;
	#end

	#if FLX_TOUCH
	/**
	 * Useful for devices with multitouch support.
	 */
	public static var touches(default, null):FlxTouchManager;
	#end

	#if FLX_POINTER_INPUT
	/**
	 * Contains all "swipes" from both mouse and touch input that have just ended.
	 */
	public static var swipes(default, null):Array<FlxSwipe> = [];
	#end

	#if FLX_KEYBOARD
	/**
	 * Used for keyboard input e.g.: check if the left arrow key is
	 * pressed with `if (FlxG.keys.pressed.LEFT) { }` in `update()`.
	 */
	public static var keys(default, null):FlxKeyboard;
	#end

	#if FLX_GAMEPAD
	/**
	 * Allows accessing the available gamepads.
	 */
	public static var gamepads(default, null):FlxGamepadManager;
	#end

	#if android
	/**
	 * Useful for tracking Back, Home buttons etc on Android devices.
	 */
	public static var android(default, null):FlxAndroidKeys;
	#end

	#if FLX_ACCELEROMETER
	/**
	 * Provides access to the accelerometer data of mobile devices as `x`/`y`/`z` values.
	 */
	public static var accelerometer(default, null):FlxAccelerometer;
	#end

	#if js
	/**
	 * Has some HTML5-specific things like browser detection, browser dimensions etc...
	 */
	public static var html5(default, null):HTML5FrontEnd = new HTML5FrontEnd();
	#end

	/**
	 * Mostly used internally, but you can use it too to reset inputs and create input classes of your own.
	 */
	public static var inputs(default, null):InputFrontEnd = new InputFrontEnd();

	/**
	 * Used to register functions and objects or add new commands to the console window.
	 */
	public static var console(default, null):ConsoleFrontEnd = new ConsoleFrontEnd();

	/**
	 * Used to add messages to the log window or enable `trace()` redirection.
	 */
	public static var log(default, null):LogFrontEnd = new LogFrontEnd();

	/**
	 * Used to add images to the bitmap log window.
	 */
	public static var bitmapLog(default, null):BitmapLogFrontEnd = new BitmapLogFrontEnd();

	/**
	 * Used to add or remove things to / from the watch window.
	 */
	public static var watch(default, null):WatchFrontEnd = new WatchFrontEnd();

	/**
	 * Used it to show / hide the debugger, change its layout,
	 * activate debug drawing or change the key used to toggle it.
	 */
	public static var debugger(default, null):DebuggerFrontEnd = new DebuggerFrontEnd();

	/**
	 * Contains all the functions needed for recording and replaying.
	 */
	public static var vcr(default, null):VCRFrontEnd;

	/**
	 * Contains things related to bitmaps, for example regarding the `BitmapData` cache and the cache itself.
	 */
	public static var bitmap(default, null):BitmapFrontEnd = new BitmapFrontEnd();

	/**
	 * Contains things related to cameras, a list of all cameras and several effects like `flash()` or `fade()`.
	 */
	public static var cameras(default, null):CameraFrontEnd = new CameraFrontEnd();

	/**
	 * Contains a list of all plugins and the functions required to `add()`, `remove()` them etc.
	 */
	public static var plugins(default, null):PluginFrontEnd;

	public static var initialWidth(default, null):Int = 0;
	public static var initialHeight(default, null):Int = 0;
	public static var initialZoom(default, null):Float = 0;

	#if FLX_SOUND_SYSTEM
	/**
	 * Contains a list of all sounds and other things to manage or `play()` sounds.
	 */
	public static var sound(default, null):SoundFrontEnd;
	#end

	/**
	 * Contains system-wide signals like `gameResized` or `preStateSwitch`.
	 */
	public static var signals(default, null):SignalFrontEnd = new SignalFrontEnd();

	/**
	 * Resizes the game within the window by reapplying the current scale mode.
	 */
	public static inline function resizeGame(Width:Int, Height:Int):Void
	{
		scaleMode.onMeasure(Width, Height);
	}

	/**
	 * Resizes the window. Only works on desktop targets (Neko, Windows, Linux, Mac).
	 */
	public static function resizeWindow(Width:Int, Height:Int):Void
	{
		#if desktop
		#if openfl_legacy
		stage.resize(Width, Height);
		#else
		#if air
		var window = flash.desktop.NativeApplication.nativeApplication.activeWindow;
		window.width = Width;
		window.height = Height;
		#else
		Lib.application.window.resize(Width, Height);
		#end
		#end
		#end
	}

	/**
	 * Like hitting the reset button a game console, this will re-launch the game as if it just started.
	 */
	public static inline function resetGame():Void
	{
		game._resetGame = true;
	}

	/**
	 * Attempts to switch from the current game state to `nextState`.
	 * The state switch is successful if `switchTo()` of the current `state` returns `true`.
	 */
	public static inline function switchState(nextState:FlxState):Void
	{
		if (state.switchTo(nextState))
			game._requestedState = nextState;
	}

	/**
	 * Request a reset of the current game state.
	 * Calls `switchState()` with a new instance of the current `state`.
	 */
	public static inline function resetState():Void
	{
		switchState(Type.createInstance(Type.getClass(state), []));
	}

	/**
	 * Call this function to see if one `FlxObject` overlaps another within `FlxG.worldBounds`.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a `FlxGroup` (or even bundling groups together!).
	 *
	 * NOTE: does NOT take objects' `scrollFactor` into account, all overlaps are checked in world space.
	 *
	 * NOTE: this takes the entire area of `FlxTilemap`s into account (including "empty" tiles).
	 * Use `FlxTilemap#overlaps()` if you don't want that.
	 *
	 * @param   ObjectOrGroup1    The first object or group you want to check.
	 * @param   ObjectOrGroup2    The second object or group you want to check. If it is the same as the first,
	 *                            Flixel knows to just do a comparison within that group.
	 * @param   NotifyCallback    A function with two `FlxObject` parameters -
	 *                            e.g. `onOverlap(object1:FlxObject, object2:FlxObject)` -
	 *                            that is called if those two objects overlap.
	 * @param   ProcessCallback   A function with two `FlxObject` parameters -
	 *                            e.g. `onOverlap(object1:FlxObject, object2:FlxObject)` -
	 *                            that is called if those two objects overlap.
	 *                            If a `ProcessCallback` is provided, then `NotifyCallback`
	 *                            will only be called if `ProcessCallback` returns true for those objects!
	 * @return  Whether any overlaps were detected.
	 */
	public static function overlap(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void,
			?ProcessCallback:Dynamic->Dynamic->Bool):Bool
	{
		if (ObjectOrGroup1 == null)
			ObjectOrGroup1 = state;
		if (ObjectOrGroup2 == ObjectOrGroup1)
			ObjectOrGroup2 = null;

		FlxQuadTree.divisions = worldDivisions;
		var quadTree = FlxQuadTree.recycle(worldBounds.x, worldBounds.y, worldBounds.width, worldBounds.height);
		quadTree.load(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
		var result:Bool = quadTree.execute();
		quadTree.destroy();
		return result;
	}

	/**
	 * A pixel perfect collision check between two `FlxSprite` objects.
	 * It will do a bounds check first, and if that passes it will run a
	 * pixel perfect match on the intersecting area. Works with rotated and animated sprites.
	 * May be slow, so use it sparingly.
	 *
	 * @param   Sprite1          The first `FlxSprite` to test against.
	 * @param   Sprite2          The second `FlxSprite` to test again, sprite order is irrelevant.
	 * @param   AlphaTolerance   The tolerance value above which alpha pixels are included.
	 *                           Default to `255` (must be fully opaque for collision).
	 * @param   Camera           If the collision is taking place in a camera other than
	 *                          `FlxG.camera` (the default/current) then pass it here.
	 * @return  Whether the sprites collide
	 */
	public static inline function pixelPerfectOverlap(Sprite1:FlxSprite, Sprite2:FlxSprite, AlphaTolerance:Int = 255, ?Camera:FlxCamera):Bool
	{
		return FlxCollision.pixelPerfectCheck(Sprite1, Sprite2, AlphaTolerance, Camera);
	}

	/**
	 * Call this function to see if one `FlxObject` collides with another within `FlxG.worldBounds`.
	 * Can be called with one object and one group, or two groups, or two objects,
	 * whatever floats your boat! For maximum performance try bundling a lot of objects
	 * together using a FlxGroup (or even bundling groups together!).
	 *
	 * This function just calls `FlxG.overlap` and presets the `ProcessCallback` parameter to `FlxObject.separate`.
	 * To create your own collision logic, write your own `ProcessCallback` and use `FlxG.overlap` to set it up.
	 * NOTE: does NOT take objects' `scrollFactor` into account, all overlaps are checked in world space.
	 *
	 * @param   ObjectOrGroup1   The first object or group you want to check.
	 * @param   ObjectOrGroup2   The second object or group you want to check. If it is the same as the first,
	 *                           Flixel knows to just do a comparison within that group.
	 * @param   NotifyCallback   A function with two `FlxObject` parameters -
	 *                           e.g. `onOverlap(object1:FlxObject, object2:FlxObject)` -
	 *                           that is called if those two objects overlap.
	 * @return  Whether any objects were successfully collided/separated.
	 */
	public static inline function collide(?ObjectOrGroup1:FlxBasic, ?ObjectOrGroup2:FlxBasic, ?NotifyCallback:Dynamic->Dynamic->Void):Bool
	{
		return overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, FlxObject.separate);
	}

	/**
	 * Regular `DisplayObject`s are normally displayed over the Flixel cursor and the Flixel debugger if simply
	 * added to `stage`. This function simplifies things by adding a `DisplayObject` directly below mouse level.
	 *
	 * @param   Child           The `DisplayObject` to add
	 * @param   IndexModifier   Amount to add to the index - makes sure the index stays within bounds.
	 * @return  The added `DisplayObject`
	 */
	public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T
	{
		var index = game.getChildIndex(game._inputContainer);
		var max = game.numChildren;

		index = FlxMath.maxAdd(index, IndexModifier, max);
		game.addChildAt(Child, index);
		return Child;
	}

	/**
	 * Removes a child from the Flixel display list, if it is part of it.
	 *
	 * @param   Child   The `DisplayObject` to add
	 * @return  The removed `DisplayObject`
	 */
	public static inline function removeChild<T:DisplayObject>(Child:T):T
	{
		if (game.contains(Child))
			game.removeChild(Child);
		return Child;
	}

	public static function addPostProcess(postProcess:PostProcess):PostProcess
	{
		#if FLX_POST_PROCESS
		if (OpenGLView.isSupported)
		{
			var postProcesses = game.postProcesses;

			// chaining
			var length = postProcesses.length;
			if (length > 0)
			{
				postProcesses[length - 1].to = postProcess;
			}

			game.postProcessLayer.addChild(postProcess);
			postProcesses.push(postProcess);
		}
		else
		{
			FlxG.log.error("Shaders are not supported on this platform.");
		}
		#end

		return postProcess;
	}

	public static function removePostProcess(postProcess:PostProcess):Void
	{
		#if FLX_POST_PROCESS
		var postProcesses = game.postProcesses;
		if (postProcesses.remove(postProcess))
		{
			chainPostProcesses();
			postProcess.to = null;

			FlxDestroyUtil.removeChild(game.postProcessLayer, postProcess);
		}
		#end
	}

	#if FLX_POST_PROCESS
	static function chainPostProcesses():Void
	{
		var postProcesses = game.postProcesses;

		if (postProcesses.length > 0)
		{
			for (i in 0...postProcesses.length - 1)
			{
				postProcesses[i].to = postProcesses[i + 1];
			}
			postProcesses.last().to = null;
		}
	}
	#end

	/**
	 * Opens a web page, by default a new tab or window. If the URL does not
	 * already start with `"http://"` or `"https://"`, it gets added automatically.
	 *
	 * @param   URL      The address of the web page.
	 * @param   Target   `"_blank"`, `"_self"`, `"_parent"` or `"_top"`
	 */
	public static inline function openURL(URL:String, Target:String = "_blank"):Void
	{
		var prefix:String = "";
		// if the URL does not already start with "http://" or "https://", add it.
		if (!~/^https?:\/\//.match(URL))
			prefix = "http://";
		Lib.getURL(new URLRequest(prefix + URL), Target);
	}

	/**
	 * Called by `FlxGame` to set up `FlxG` during `FlxGame`'s constructor.
	 */
	@:allow(flixel.FlxGame.new)
	static function init(Game:FlxGame, Width:Int, Height:Int, Zoom:Float):Void
	{
		game = Game;
		width = Std.int(Math.abs(Width));
		height = Std.int(Math.abs(Height));

		initRenderMethod();

		FlxG.initialWidth = width;
		FlxG.initialHeight = height;
		FlxG.initialZoom = FlxCamera.defaultZoom = Zoom;

		resizeGame(Lib.current.stage.stageWidth, Lib.current.stage.stageHeight);

		// Instantiate inputs
		#if FLX_KEYBOARD
		keys = inputs.add(new FlxKeyboard());
		#end

		#if FLX_MOUSE
		mouse = inputs.add(new FlxMouse(game._inputContainer));
		#end

		#if FLX_TOUCH
		touches = inputs.add(new FlxTouchManager());
		#end

		#if FLX_GAMEPAD
		gamepads = inputs.add(new FlxGamepadManager());
		#end

		#if android
		android = inputs.add(new FlxAndroidKeys());
		#end

		#if FLX_ACCELEROMETER
		accelerometer = new FlxAccelerometer();
		#end
		save.bind("flixel");

		plugins = new PluginFrontEnd();
		vcr = new VCRFrontEnd();

		#if FLX_SOUND_SYSTEM
		sound = new SoundFrontEnd();
		#end
	}

	static function initRenderMethod():Void
	{
		renderMethod = BLITTING;

		#if (!lime_legacy && !flash)
		#if (lime >= "7.0.0")
		renderMethod = switch (stage.window.context.type)
		{
			case OPENGL, OPENGLES, WEBGL: DRAW_TILES;
			default: BLITTING;
		}
		#else
		if (!Lib.application.config.windows[0].hardware)
		{
			renderMethod = BLITTING;
		}
		else
		{
			renderMethod = switch (stage.window.renderer.type)
			{
				case OPENGL, CONSOLE: DRAW_TILES;
				case CANVAS, FLASH, CAIRO: BLITTING;
				default: BLITTING;
			}
		}
		#end
		#else
		#if web
		renderMethod = BLITTING;
		#else
		renderMethod = DRAW_TILES;
		#end
		#end

		#if air
		renderMethod = BLITTING;
		#end

		renderBlit = renderMethod == BLITTING;
		renderTile = renderMethod == DRAW_TILES;

		FlxObject.defaultPixelPerfectPosition = renderBlit;
	}

	/**
	 * Called whenever the game is reset, doesn't have to do quite as much work as the basic initialization stuff.
	 */
	@:allow(flixel.FlxGame)
	static function reset():Void
	{
		random.resetInitialSeed();

		bitmap.reset();
		inputs.reset();
		#if FLX_SOUND_SYSTEM
		sound.destroy(true);
		#end
		autoPause = true;
		fixedTimestep = true;
		timeScale = 1.0;
		elapsed = 0;
		maxElapsed = 0.1;
		worldBounds.set(-10, -10, width + 20, height + 20);
		worldDivisions = 6;
	}

	static function set_scaleMode(ScaleMode:BaseScaleMode):BaseScaleMode
	{
		scaleMode = ScaleMode;
		game.onResize(null);
		return ScaleMode;
	}

	#if FLX_MOUSE
	static function set_mouse(NewMouse:FlxMouse):FlxMouse
	{
		if (mouse == null) // if no mouse, just add it
		{
			mouse = inputs.add(NewMouse); // safe to do b/c it won't add repeats!
			return mouse;
		}
		var oldMouse:FlxMouse = mouse;
		var result:FlxMouse = inputs.replace(oldMouse, NewMouse); // replace existing mouse
		if (result != null)
		{
			mouse = result;
			oldMouse.destroy();
			return NewMouse;
		}
		return oldMouse;
	}
	#end

	static function set_updateFramerate(Framerate:Int):Int
	{
		if (Framerate < drawFramerate)
			log.warn("FlxG.framerate: the game's framerate shouldn't be smaller than the flash framerate," + " since it can stop your game from updating.");

		updateFramerate = Framerate;

		game._stepMS = Math.abs(1000 / Framerate);
		game._stepSeconds = game._stepMS / 1000;

		if (game._maxAccumulation < game._stepMS)
			game._maxAccumulation = game._stepMS;

		return Framerate;
	}

	static function set_drawFramerate(Framerate:Int):Int
	{
		if (Framerate > updateFramerate)
			log.warn("FlxG.drawFramerate: the update framerate shouldn't be smaller than the draw framerate," + " since it can stop your game from updating.");

		drawFramerate = Std.int(Math.abs(Framerate));

		if (game.stage != null)
			game.stage.frameRate = drawFramerate;

		game._maxAccumulation = 2000 / drawFramerate - 1;

		if (game._maxAccumulation < game._stepMS)
			game._maxAccumulation = game._stepMS;

		return Framerate;
	}

	static function get_fullscreen():Bool
	{
		return stage.displayState == StageDisplayState.FULL_SCREEN || stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE;
	}

	static function set_fullscreen(Value:Bool):Bool
	{
		stage.displayState = Value ? StageDisplayState.FULL_SCREEN : StageDisplayState.NORMAL;
		return Value;
	}

	static inline function get_stage():Stage
	{
		return Lib.current.stage;
	}

	static inline function get_state():FlxState
	{
		return game._state;
	}

	static inline function get_onMobile():Bool
	{
		return #if js
			html5.onMobile
		#elseif mobile
			true
		#else
			false
		#end;
	}
}

enum FlxRenderMethod
{
	DRAW_TILES;
	BLITTING;
}
