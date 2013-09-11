package flixel;

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.Lib;
import flixel.system.FlxSplash;
import flixel.system.layer.TileSheetExt;
import flixel.system.replay.FlxReplay;
import flixel.text.pxText.PxBitmapFont;
import flixel.util.FlxRandom;

#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

#if !FLX_NO_DEBUG
import flixel.system.debug.FlxDebugger;
#end

#if !FLX_NO_SOUND_TRAY
import flixel.system.ui.FlxSoundTray;
#end

#if !FLX_NO_FOCUS_LOST_SCREEN
import flixel.system.ui.FlxFocusLostScreen;
#end

/**
 * FlxGame is the heart of all flixel games, and contains a bunch of basic game loops and things.
 * It is a long and sloppy file that you shouldn't have to worry about too much!
 * It is basically only used to create your game object in the first place,
 * after that FlxG and FlxState have all the useful stuff you actually need.
 */
class FlxGame extends Sprite
{
	/**
	 * Time in milliseconds that has passed (amount of "ticks" passed) since the game has started.
	 */
	public var ticks(default, null):Int = 0;
	/**
	 * Current game state.
	 */
	public var state:FlxState = null;
	/**
	 * Mouse cursor.
	 */
	public var inputContainer:Sprite;
	/**
	 * Milliseconds of time since last step. Supposed to be internal.
	 */
	public var elapsedMS:Int;
	/**
	 * Milliseconds of time per step of the game loop. FlashEvent.g. 60 fps = 16ms. Supposed to be internal.
	 */
	public var stepMS:Int;
	/**
	 * Optimization so we don't have to divide step by 1000 to get its value in seconds every frame. Supposed to be internal.
	 */
	public var stepSeconds:Float;
	/**
	 * Framerate of the Flash player (NOT the game loop). Default = 60.
	 */
	public var flashFramerate:Int;
	/**
	 * Max allowable accumulation (see _accumulator).
	 * Should always (and automatically) be set to roughly 2x the flash player framerate.
	 */
	public var maxAccumulation:Int;
	/**
	 * If a state change was requested, the new state object is stored here until we switch to it.
	 */
	public var requestedState:FlxState = null;
	/**
	 * A flag for keeping track of whether a game reset was requested or not.
	 */
	public var requestedReset:Bool = true;
	
	#if !FLX_NO_DEBUG
	/**
	 * The debugger overlay object.
	 */
	public var debugger(default, null):FlxDebugger;
	#end
	
	#if FLX_RECORD
	/**
	 * Container for a game replay object.
	 */
	public var replay:FlxReplay;
	/**
	 * Flag for whether a playback of a recording was requested.
	 */
	public var replayRequested:Bool = false;
	/**
	 * Flag for whether a new recording was requested.
	 */
	public var recordingRequested:Bool = false;
	/**
	 * Flag for whether a replay is currently playing.
	 */
	public var replaying:Bool = false;
	/**
	 * Flag for whether a new recording is being made.
	 */
	public var recording:Bool = false;
	#end
	
	#if !FLX_NO_SOUND_TRAY
	/**
	 * The sound tray display container (see <code>createSoundTray()</code>).
	 */
	public var soundTray(default, null):FlxSoundTray;
	#end
	
	/**
	 * Class type of the initial/first game state for the game, usually MenuState or something like that.
	 */
	private var _iState:Class<FlxState>;
	/**
	 * Total number of milliseconds elapsed since game start.
	 */
	private var _total:Int = 0;
	/**
	 * Total number of milliseconds elapsed since last update loop.
	 * Counts down as we step through the game loop.
	 */
	private var _accumulator:Int;
	/**
	 * Whether the Flash player lost focus.
	 */
	private var _lostFocus:Bool = false;
	
	#if !FLX_NO_FOCUS_LOST_SCREEN 
	/**
	 * The "focus lost" screen (see <code>createFocusScreen()</code>).
	 */
	private var _focusLostScreen:FlxFocusLostScreen;
	#end
	
	#if !FLX_NO_SOUND_TRAY
	/**
	 * Change this afterr calling super() in the FlxGame constructor to use a customized sound tray based on FlxSoundTray.
	 */
	private var _customSoundTray:Class<FlxSoundTray> = FlxSoundTray;
	#end
	
	#if !FLX_NO_FOCUS_LOST_SCREEN
	/**
	 * Change this afterr calling super() in the FlxGame constructor to use a customized sound tray based on FlxFocusLostScreen.
	 */
	private var _customFocusLostScreen:Class<FlxFocusLostScreen> = FlxFocusLostScreen;
	#end
	
	#if (cpp && FLX_THREADING)
	// push 'true' into this array to trigger an update. push 'false' to terminate update thread.
	private var _stateSwitchRequested:Bool;
	private var _threadSync:cpp.vm.Deque<Bool>;
	
	private function threadedUpdate():Void 
	{
		while (_threadSync.pop(true))
		{
			update();
		}
	}
	#end
	
	private var _skipSplash:Bool = false;
	
	/**
	 * Instantiate a new game object.
	 * @param	GameSizeX		The width of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	GameSizeY		The height of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
	 * @param	Zoom			The default level of zoom for the game's cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.
	 * @param	GameFramerate	How frequently the game should update (default is 60 times per second).
	 * @param	FlashFramerate	Sets the actual display framerate for Flash player (default is 60 times per second).
	 * @param	SkipSplash		Whether you want to skip the flixel splash screen in FLX_NO_DEBUG or not.
	 */
	public function new(GameSizeX:Int, GameSizeY:Int, InitialState:Class<FlxState>, Zoom:Float = 1, GameFramerate:Int = 60, FlashFramerate:Int = 60, SkipSplash:Bool = false)
	{
		super();
		
		// Super high priority init stuff
		inputContainer = new Sprite();
		
		// Basic display and update setup stuff
		FlxG.init(this, GameSizeX, GameSizeY, Zoom);
		
		FlxG.framerate = GameFramerate;
		FlxG.flashFramerate = FlashFramerate;
		_accumulator = stepMS;
		_skipSplash = SkipSplash;
		
		#if FLX_RECORD
		replay = new FlxReplay();
		#end
		
		// Then get ready to create the game object for real
		_iState = InitialState;
		
		addEventListener(Event.ADDED_TO_STAGE, create);
	}
	
	/**
	 * Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
	 * 
	 * @param	FlashEvent	Just a Flash system event, not too important for our purposes.
	 */
	private function create(FlashEvent:Event):Void
	{
		if (stage == null)
		{
			return;
		}
		removeEventListener(Event.ADDED_TO_STAGE, create);
		
		_total = Lib.getTimer();

		// Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = flashFramerate;
		
		addChild(inputContainer);
		
		// Creating the debugger overlay
		#if !FLX_NO_DEBUG
		debugger = new FlxDebugger(FlxG.width * FlxCamera.defaultZoom, FlxG.height * FlxCamera.defaultZoom);
		addChild(debugger);
		#end
		
	// Let mobile devs opt out of unnecessary overlays.
	#if !mobile	
		// Volume display tab
		#if !FLX_NO_SOUND_TRAY
		soundTray = Type.createInstance(_customSoundTray, []);
		addChild(soundTray);
		#end
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		_focusLostScreen = Type.createInstance(_customFocusLostScreen, []);
		addChild(_focusLostScreen);
		#end
	#end
		
		// Focus gained/lost monitoring
		#if flash
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		#else
		stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		stage.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		#end
		
		// Instantiate the initial state
		if (requestedReset)
		{
			resetGame();
			switchState();
			requestedReset = false;
		}
		
		#if (cpp && FLX_THREADING)
		_threadSync = new cpp.vm.Deque();
		cpp.vm.Thread.create(threadedUpdate);
		#end
		
		if (FlxG.framerate < FlxG.flashFramerate)
		{
			FlxG.log.warn("FlxG.flashFramerate: The game's framerate shouldn't be smaller than the flash framerate, since it can stop your game from updating.");
		}
		
		// Finally, set up an event for the actual game loop stuff.
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		// We need to listen for resize event which means new context
		// it means that we need to recreate bitmapdatas of dumped tilesheets
		stage.addEventListener(Event.RESIZE, onResize);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash event.
	 */
	private function onFocus(?FlashEvent:Event):Void
	{
		if (!FlxG.autoPause) 
		{
			state.onFocus();
			return;
		}
		
		_lostFocus = false;
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		if (_focusLostScreen != null)
		{
			_focusLostScreen.visible = false;
		}
		#end 
		
		stage.frameRate = flashFramerate;
		FlxG.sound.resumeSounds();
		FlxG.inputs.onFocus();
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash event.
	 */
	private function onFocusLost(?FlashEvent:Event):Void
	{
		if (!FlxG.autoPause) 
		{
			state.onFocusLost();
			return;
		}
		
		_lostFocus = true;
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		if (_focusLostScreen != null)
		{
			_focusLostScreen.visible = true;
		}
		#end 
		
		stage.frameRate = 10;
		FlxG.sound.pauseSounds();
		FlxG.inputs.onFocusLost();
	}
	
	private function onResize(E:Event):Void 
	{
		var width:Int = Lib.current.stage.stageWidth;
		var height:Int = Lib.current.stage.stageHeight;
		
		#if (desktop || mobile)
		FlxG.bitmap.onContext();
		#end
		
		state.onResize(width, height);
		FlxG.plugins.onResize(width, height);
		#if !FLX_NO_DEBUG
		debugger.onResize(width, height);
		#end
		
		if (FlxG.autoResize)
		{
			FlxG.resizeGame(width, height);
		}
	}
	
	/**
	 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.
	 * @param	FlashEvent	Flash event.
	 */
	private function onEnterFrame(?FlashEvent:Event):Void
	{
		ticks = Lib.getTimer();
		elapsedMS = ticks - _total;
		_total = ticks;
		
		#if !FLX_NO_SOUND_TRAY
		if (soundTray != null && soundTray.active)
		{
			soundTray.update(elapsedMS);
		}
		#end
		
		if (!_lostFocus)
		{
			if(FlxG.vcr.paused)
			{
				if (FlxG.vcr.stepRequested)
				{
					FlxG.vcr.stepRequested = false;
				}
				else
				{
					return;
				}
			}
			
			if (FlxG.fixedTimestep)
			{
				_accumulator += elapsedMS;
				if (_accumulator > maxAccumulation)
				{
					_accumulator = maxAccumulation;
				}
				// TODO: You may uncomment following lines
				while (_accumulator > stepMS)
				//while(_accumulator >= stepMS)
				{
					step();
					_accumulator = _accumulator - stepMS; 
				}
			}
			else
			{
				step();
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT = 0;
			#end
			
			draw();
			
			#if !FLX_NO_DEBUG
			if (FlxG.debugger.visible)
			{
				debugger.stats.flash(elapsedMS);
				debugger.stats.visibleObjects(FlxBasic._VISIBLECOUNT);
				debugger.stats.update();
				debugger.watch.update();
			}
			#end	
		}
	}
	
	/**
	 * Internal method to create a new instance of iState and reset the game.
	 * This gets called when the game is created, as well as when a new state is requested.
	 */
	private inline function resetGame():Void
	{
		#if !FLX_NO_DEBUG
		requestNewState(Type.createInstance(_iState, []));
		#else
		if (_skipSplash)
		{
			requestNewState(Type.createInstance(_iState, []));
		}
		else
		{
			requestNewState(new FlxSplash(_iState));
		}
		#end
		
		#if !FLX_NO_DEBUG
		if (Std.is(requestedState, FlxSubState))
		{
			throw "You can't set FlxSubState class instance as the state for you game";
		}
		#end
		
		FlxG.reset();
	}
	
	/**
	 * Notify the game that we're about to switch states. 
	 * INTERNAL, do not use this, call FlxG.switchState instead.
	 */
	public inline function requestNewState(newState:FlxState):Void
	{
		requestedState = newState;
		
		#if (cpp && FLX_THREADING)
		_stateSwitchRequested = true;
		#end
	} 

	/**
	 * If there is a state change requested during the update loop,
	 * this function handles actual destroying the old state and related processes,
	 * and calls creates on the new state and plugs it into the game object.
	 */
	private function switchState():Void
	{ 
		// Basic reset stuff
		PxBitmapFont.clearStorage();
		FlxG.bitmap.clearCache();
		FlxG.cameras.reset();
		FlxG.inputs.reset();
		FlxG.sound.destroySounds();
		FlxG.plugins.onStateSwitch();
		
		#if !FLX_NO_DEBUG
		// Clear the debugger overlay's Watch window
		if (debugger != null)
		{
			debugger.watch.removeAll();
		}
		#end
		
		#if !FLX_NO_MOUSE
		var mouseVisibility:Bool = FlxG.mouse.visible || ((state != null) ? state.useMouse : false);
		#end
		// Destroy the old state (if there is an old state)
		if (state != null)
		{
			state.destroy();
		}
		
		// Finally assign and create the new state
		state = requestedState;
		
		#if !FLX_NO_MOUSE
		state.useMouse = mouseVisibility;
		#end
		
		state.create();
		
		#if (cpp && FLX_THREADING) 
		_stateSwitchRequested = false; 
		#end
	}
	
	/**
	 * This is the main game update logic section.
	 * The onEnterFrame() handler is in charge of calling this
	 * the appropriate number of times each frame.
	 * This block handles state changes, replays, all that good stuff.
	 */
	private function step():Void
	{
		// Handle game reset request
		if (requestedReset)
		{
			resetGame();
			requestedReset = false;
		}
		
		#if FLX_RECORD
		// Handle replay-related requests
		if (recordingRequested)
		{
			recordingRequested = false;
			replay.create(FlxRandom.globalSeed);
			recording = true;
			
			#if !FLX_NO_DEBUG
			debugger.vcr.recording();
			FlxG.log.notice("Starting new flixel gameplay record.");
			#end
		}
		else if (replayRequested)
		{
			replayRequested = false;
			replay.rewind();
			FlxRandom.globalSeed = replay.seed;
			
			#if !FLX_NO_DEBUG
			debugger.vcr.playingReplay();
			#end
			
			replaying = true;
		}
		#end
		
		#if !FLX_NO_DEBUG
		// Finally actually step through the game physics
		FlxBasic._ACTIVECOUNT = 0;
		#end
		
		#if (cpp && FLX_THREADING)
		_threadSync.push(true);
		#else
		update();
		#end
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			debugger.stats.activeObjects(FlxBasic._ACTIVECOUNT);
		}
		#end
	}
	
	/**
	 * This function is called by step() and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	private function update():Void
	{
		if (state != requestedState)
		{
			switchState();
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			ticks = Lib.getTimer(); // getTimer() is expensive, only do it if necessary
		}
		#end
		
		if (FlxG.fixedTimestep)
		{
			FlxG.elapsed = FlxG.timeScale * stepSeconds; // fixed timestep
		}
		else
		{
			FlxG.elapsed = FlxG.timeScale * (elapsedMS / 1000); // variable timestep
		}
		
		updateInput();
		
		FlxG.sound.updateSounds();
		FlxG.plugins.update();
		
		state.tryUpdate(); // Update the current state
		
		FlxG.cameras.update();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			debugger.stats.flixelUpdate(Lib.getTimer() - ticks);
		}
		#end
	}
	
	private function updateInput():Void
	{
		#if FLX_RECORD
		if (replaying)
		{
			replay.playNextFrame();
			
			if (FlxG.vcr.timeout > 0)
			{
				FlxG.vcr.timeout -= stepMS;
				
				if (FlxG.vcr.timeout <= 0)
				{
					if (FlxG.vcr.replayCallback != null)
					{
						FlxG.vcr.replayCallback();
						FlxG.vcr.replayCallback = null;
					}
					else
					{
						FlxG.vcr.stopReplay();
					}
				}
			}
			
			if (replaying && replay.finished)
			{
				FlxG.vcr.stopReplay();
				
				if (FlxG.vcr.replayCallback != null)
				{
					FlxG.vcr.replayCallback();
					FlxG.vcr.replayCallback = null;
				}
			}
			
			#if !FLX_NO_DEBUG
			debugger.vcr.updateRuntime(stepMS);
			#end
		}
		else
		{
		#end
		
		FlxG.inputs.update();
		
		#if FLX_RECORD
		}
		if (recording)
		{
			replay.recordFrame();
			
			#if !FLX_NO_DEBUG
			debugger.vcr.updateRuntime(stepMS);
			#end
		}
		#end
	}
	
	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	private function draw():Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			// getTimer() is expensive, only do it if necessary
			ticks = Lib.getTimer(); 
		}
		#end

		#if !flash
		TileSheetExt._DRAWCALLS = 0;
		#end
		
		FlxG.cameras.lock();
		
		#if (cpp && FLX_THREADING)
		// Only draw the state if a new state hasn't been requested
		if (!_stateSwitchRequested)
		#end 
		
		FlxG.plugins.draw();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visualDebug)
		{
			FlxG.plugins.drawDebug();
		}
		#end
		
		state.draw();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visualDebug)
		{
			state.drawDebug();
		}
		#end
		
		#if !flash
		FlxG.cameras.render();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			debugger.stats.drawCalls(TileSheetExt._DRAWCALLS);
		}
		#end
		#end
		
		FlxG.cameras.unlock();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			debugger.stats.flixelDraw(Lib.getTimer() - ticks);
		}
		#end
	}
}
