package flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.Lib;
import flixel.effects.postprocess.PostProcess;
import flixel.graphics.tile.FlxTilesheet;
import flixel.math.FlxAngle;
import flixel.math.FlxRandom;
import flixel.system.FlxSplash;
import flixel.system.replay.FlxReplay;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Assets;
import openfl.filters.BitmapFilter;

#if FLX_POST_PROCESS
import openfl.display.OpenGLView;
#end

#if !FLX_NO_DEBUG
import flixel.system.debug.FlxDebugger;
#end

#if FLX_SOUND_TRAY
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
@:allow(flixel)
class FlxGame extends Sprite
{
	/**
	 * Framerate to use on focus lost. Default = 10.
	 */
	public var focusLostFramerate:Int = 10;
	
	#if FLX_RECORD
	/**
	 * Flag for whether a replay is currently playing.
	 */
	public var replaying(default, null):Bool = false;
	/**
	 * Flag for whether a new recording is being made.
	 */
	public var recording(default, null):Bool = false;
	#end
	
	#if FLX_SOUND_TRAY
	/**
	 * The sound tray display container (see createSoundTray()).
	 */
	public var soundTray(default, null):FlxSoundTray;
	#end
	
	#if !FLX_NO_DEBUG
	/**
	 * The debugger overlay object.
	 */
	public var debugger(default, null):FlxDebugger;
	#end
	
	/**
	 * Time in milliseconds that has passed (amount of "ticks" passed) since the game has started.
	 */
	public var ticks(default, null):Int = 0;
	/**
	 * Enables or disables the filters set via setFilters()
	 */
	public var filtersEnabled:Bool = true;
	
	/**
	 * A flag for triggering the onGameStart "event".
	 */
	@:allow(flixel.system.FlxSplash)
	private var _gameJustStarted:Bool = false;
	
	/**
	 * Class type of the initial/first game state for the game, usually MenuState or something like that.
	 */
	private var _initialState:Class<FlxState>;
	/**
	 * Current game state.
	 */
	private var _state:FlxState;
	/**
	 * Total number of milliseconds elapsed since game start.
	 */
	private var _total:Int = 0;
	/**
	 * Total number of milliseconds elapsed since last update loop.
	 * Counts down as we step through the game loop.
	 */
	private var _accumulator:Float;
	/**
	 * Milliseconds of time since last step.
	 */
	private var _elapsedMS:Float;
	/**
	 * Milliseconds of time per step of the game loop. e.g. 60 fps = 16ms.
	 */
	private var _stepMS:Float;
	/**
	 * Optimization so we don't have to divide step by 1000 to get its value in seconds every frame.
	 */
	private var _stepSeconds:Float;
	/**
	 * Max allowable accumulation (see _accumulator).
	 * Should always (and automatically) be set to roughly 2x the stage framerate.
	 */
	private var _maxAccumulation:Float;
	
	/**
	 * Whether the game lost focus.
	 */
	private var _lostFocus:Bool = false;
	
	/**
	 * The filters array to be applied to the game.
	 */
	private var _filters:Array<BitmapFilter>;
	
	#if (desktop && lime_legacy)
	/**
	 * Ugly workaround to ensure consistent behaviour between flash and cpp 
	 * (the focus event should not fire when the game starts up!)
	 */ 
	private var _onFocusFiredOnce:Bool = false;
	#end
	
	#if !FLX_NO_FOCUS_LOST_SCREEN 
	/**
	 * The "focus lost" screen (see createFocusScreen()).
	 */
	private var _focusLostScreen:FlxFocusLostScreen;
	#end
	
	/**
	 * Mouse cursor.
	 */
	@:allow(flixel.FlxG)
	@:allow(flixel.system.frontEnds.CameraFrontEnd)
	private var _inputContainer:Sprite;
	
	#if FLX_SOUND_TRAY
	/**
	 * Change this after calling super() in the FlxGame constructor to use a customized sound tray based on FlxSoundTray.
	 */
	private var _customSoundTray:Class<FlxSoundTray> = FlxSoundTray;
	#end
	
	#if !FLX_NO_FOCUS_LOST_SCREEN
	/**
	 * Change this after calling super() in the FlxGame constructor to use a customized screen which will be show when the application lost focus.
	 */
	private var _customFocusLostScreen:Class<FlxFocusLostScreen> = FlxFocusLostScreen;
	#end
	
	/**
	 * Whether the splash screen should be skipped.
	 */
	private var _skipSplash:Bool = false;
	
	#if desktop
	/**
	 * Should we start Fullscreen or not? This is useful if you want to load Fullscreen settings from a FlxSave and set it when the game starts, instead of having it hard-set in your project XML.
	 */
	private var _startFullscreen:Bool = false; 
	#end
	
	/**
	 * If a state change was requested, the new state object is stored here until we switch to it.
	 */
	private var _requestedState:FlxState;
	/**
	 * A flag for keeping track of whether a game reset was requested or not.
	 */
	private var _resetGame:Bool = false;
	
	#if FLX_RECORD
	/**
	 * Container for a game replay object.
	 */
	private var _replay:FlxReplay;
	/**
	 * Flag for whether a playback of a recording was requested.
	 */
	private var _replayRequested:Bool = false;
	/**
	 * Flag for whether a new recording was requested.
	 */
	private var _recordingRequested:Bool = false;
	#end
	
	#if FLX_POST_PROCESS
	/**
	 * Sprite for postprocessing effects
	 */
	private var postProcessLayer:Sprite = new Sprite();
	/**
	 * Post process effects active on the postProcessLayer
	 */
	private var postProcesses:Array<PostProcess> = [];
	#end
	
	/**
	 * Instantiate a new game object.
	 * 
	 * @param	GameSizeX		The width of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	GameSizeY		The height of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
	 * @param	Zoom			The default level of zoom for the game's cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.
	 * @param	UpdateFramerate	How frequently the game should update (default is 60 times per second).
	 * @param	DrawFramerate	Sets the actual display / draw framerate for the game (default is 60 times per second).
	 * @param	SkipSplash		Whether you want to skip the flixel splash screen in FLX_NO_DEBUG or not.
	 * @param	StartFullscreen	Whether to start the game in fullscreen mode (desktop targets only), false by default
	 */
	public function new(GameSizeX:Int = 640, GameSizeY:Int = 480, ?InitialState:Class<FlxState>, Zoom:Float = 1, UpdateFramerate:Int = 60, DrawFramerate:Int = 60, SkipSplash:Bool = false, StartFullscreen:Bool = false)
	{
		super();
		
		#if desktop
		_startFullscreen = StartFullscreen;
		#end
		
		// Super high priority init stuff
		_inputContainer = new Sprite();
		
		// Basic display and update setup stuff
		FlxG.init(this, GameSizeX, GameSizeY, Zoom);
		
		FlxG.updateFramerate = UpdateFramerate;
		FlxG.drawFramerate = DrawFramerate;
		_accumulator = _stepMS;
		_skipSplash = SkipSplash;
		
		#if FLX_RECORD
		_replay = new FlxReplay();
		#end
		
		// Then get ready to create the game object for real
		_initialState = (InitialState == null) ? FlxState : InitialState;
		
		addEventListener(Event.ADDED_TO_STAGE, create);
	}
	
	/**
	 * Sets the filter array to be applied to the game.
	 * 
	 * @param	filters
	 */
	public function setFilters(filters:Array<BitmapFilter>):Void
	{
		_filters = filters;
	}
	
	/**
	 * Used to instantiate the guts of the flixel game object once we have a valid reference to the root.
	 */
	private function create(_):Void
	{
		if (stage == null)
		{
			return;
		}
		removeEventListener(Event.ADDED_TO_STAGE, create);
		
		_total = getTimer();
		
		#if desktop
		FlxG.fullscreen = _startFullscreen;
		#end
		
		// Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = FlxG.drawFramerate;
		
		addChild(_inputContainer);
		
		#if FLX_POST_PROCESS
		if (OpenGLView.isSupported)
			addChild(postProcessLayer);
		#end
		
		// Creating the debugger overlay
		#if !FLX_NO_DEBUG
		debugger = new FlxDebugger(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		addChild(debugger);
		#end
		
		// No need for overlays on mobile.
		#if !mobile
		// Volume display tab
		#if FLX_SOUND_TRAY
		soundTray = Type.createInstance(_customSoundTray, []);
		addChild(soundTray);
		#end
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		_focusLostScreen = Type.createInstance(_customFocusLostScreen, []);
		addChild(_focusLostScreen);
		#end
		#end
		
		// Focus gained/lost monitoring
		#if desktop
		stage.addEventListener(FocusEvent.FOCUS_OUT, onFocusLost);
		stage.addEventListener(FocusEvent.FOCUS_IN, onFocus);
		#else
		stage.addEventListener(Event.DEACTIVATE, onFocusLost);
		stage.addEventListener(Event.ACTIVATE, onFocus);
		#end
		
		// Instantiate the initial state
		resetGame();
		switchState();
		
		if (FlxG.updateFramerate < FlxG.drawFramerate)
		{
			FlxG.log.warn("FlxG.updateFramerate: The update framerate shouldn't be smaller than the draw framerate, since it can slow down your game.");
		}
		
		// Finally, set up an event for the actual game loop stuff.
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
		
		// We need to listen for resize event which means new context
		// it means that we need to recreate bitmapdatas of dumped tilesheets
		stage.addEventListener(Event.RESIZE, onResize);
		
		// make sure the cursor etc are properly scaled from the start
		resizeGame(FlxG.stage.stageWidth, FlxG.stage.stageHeight);
		
		Assets.addEventListener(Event.CHANGE, FlxG.bitmap.onAssetsReload);
	}
	
	private function onFocus(_):Void
	{
		#if flash
		if (!_lostFocus) 
		{
			return; // Don't run this function twice (bug in standalone flash player)
		}
		#end
		
		#if (desktop && lime_legacy)
		// make sure the on focus event doesn't fire on startup 
		if (!_onFocusFiredOnce)
		{
			_onFocusFiredOnce = true;
			return;
		}
		#end
		
		#if mobile
		// just check if device orientation has been changed
		onResize(_);
		#end
		
		_lostFocus = false;
		FlxG.signals.focusGained.dispatch();
		_state.onFocus();
		
		if (!FlxG.autoPause) 
		{
			return;
		}
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		if (_focusLostScreen != null)
		{
			_focusLostScreen.visible = false;
		}
		#end 
		
		#if !FLX_NO_DEBUG
		debugger.stats.onFocus();
		#end
		
		stage.frameRate = FlxG.drawFramerate;
		#if !FLX_NO_SOUND_SYSTEM
		FlxG.sound.onFocus();
		#end
		FlxG.inputs.onFocus();
	}
	
	private function onFocusLost(_):Void
	{
		#if flash
		if (_lostFocus) 
		{
			return; // Don't run this function twice (bug in standalone flash player)
		}
		#end
		
		_lostFocus = true;
		FlxG.signals.focusLost.dispatch();
		_state.onFocusLost();
		
		if (!FlxG.autoPause) 
		{
			return;
		}
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		if (_focusLostScreen != null)
		{
			_focusLostScreen.visible = true;
		}
		#end 
		
		#if !FLX_NO_DEBUG
		debugger.stats.onFocusLost();
		#end
		
		stage.frameRate = focusLostFramerate;
		#if !FLX_NO_SOUND_SYSTEM
		FlxG.sound.onFocusLost();
		#end
		FlxG.inputs.onFocusLost();
	}
	
	@:allow(flixel.FlxG)
	private function onResize(_):Void 
	{
		var width:Int = FlxG.stage.stageWidth;
		var height:Int = FlxG.stage.stageHeight;
		
		#if !flash
		if (FlxG.renderTile)
		{
			FlxG.bitmap.onContext();
		}
		#end
		
		resizeGame(width, height);
	}
	
	private function resizeGame(width:Int, height:Int):Void
	{
		FlxG.resizeGame(width, height);
		
		_state.onResize(width, height);
		FlxG.signals.gameResized.dispatch(width, height);
		
		FlxG.cameras.resize();
		
		#if !FLX_NO_DEBUG
		debugger.onResize(width, height);
		#end
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		if (_focusLostScreen != null)
		{
			_focusLostScreen.draw();
		}
		#end
		
		#if FLX_SOUND_TRAY
		if (soundTray != null)
		{
			soundTray.screenCenter();
		}
		#end
		
		#if FLX_POST_PROCESS
		for (postProcess in postProcesses)
		{
			postProcess.rebuild();
		}
		#end
	}
	
	/**
	 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.
	 */
	private function onEnterFrame(_):Void
	{
		ticks = getTimer();
		_elapsedMS = ticks - _total;
		_total = ticks;
		
		#if FLX_SOUND_TRAY
		if (soundTray != null && soundTray.active)
		{
			soundTray.update(_elapsedMS);
		}
		#end
		
		if (!_lostFocus || !FlxG.autoPause)
		{
			if (FlxG.vcr.paused)
			{
				if (FlxG.vcr.stepRequested)
				{
					FlxG.vcr.stepRequested = false;
				}
				else if (_state == _requestedState) // don't pause a state switch request
				{
					return;
				}
			}
			
			if (FlxG.fixedTimestep)
			{
				_accumulator += _elapsedMS;
				_accumulator = (_accumulator > _maxAccumulation) ? _maxAccumulation : _accumulator;
				
				while (_accumulator >= _stepMS)
				{
					step();
					_accumulator -= _stepMS; 
				}
			}
			else
			{
				step();
			}
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount = 0;
			#end
			
			draw();
			
			#if !FLX_NO_DEBUG
			debugger.stats.visibleObjects(FlxBasic.visibleCount);
			debugger.update();
			#end
		}
	}
	
	/**
	 * Internal method to create a new instance of iState and reset the game.
	 * This gets called when the game is created, as well as when a new state is requested.
	 */
	private inline function resetGame():Void
	{
		FlxG.signals.preGameReset.dispatch();
		
		#if !FLX_NO_DEBUG
		_skipSplash = true;
		#end
		
		if (_skipSplash || FlxSplash.nextState != null) // already played
		{
			_requestedState = cast (Type.createInstance(_initialState, []));
			if (FlxSplash.nextState == null)
			{
				_gameJustStarted = true;
			}
		}
		else
		{
			FlxSplash.nextState = _initialState;
			_requestedState = new FlxSplash();
			_skipSplash = true; // only play it once
		}
		
		#if !FLX_NO_DEBUG
		if (Std.is(_requestedState, FlxSubState))
		{
			throw "You can't set FlxSubState class instance as the state for you game";
		}
		#end
		
		FlxG.reset();
		
		FlxG.signals.postGameReset.dispatch();
	}

	/**
	 * If there is a state change requested during the update loop,
	 * this function handles actual destroying the old state and related processes,
	 * and calls creates on the new state and plugs it into the game object.
	 */
	private function switchState():Void
	{ 
		// Basic reset stuff
		FlxG.bitmap.clearCache();
		FlxG.cameras.reset();
		FlxG.inputs.onStateSwitch();
		#if !FLX_NO_SOUND_SYSTEM
		FlxG.sound.destroy();
		#end
		
		FlxG.signals.stateSwitched.dispatch();
		
		#if FLX_RECORD
		FlxRandom.updateStateSeed();
		#end
		
		// Destroy the old state (if there is an old state)
		if (_state != null)
		{
			_state.destroy();
		}
		
		// Finally assign and create the new state
		_state = _requestedState;
		
		FlxG.signals.preStateCreate.dispatch(_state);
		
		_state.create();
		
		if (_gameJustStarted)
		{
			gameStart();
		}
		
		#if !FLX_NO_DEBUG
		debugger.console.registerObject("state", _state);
		#end
	}
	
	private function gameStart():Void
	{
		FlxG.signals.gameStarted.dispatch();
		_gameJustStarted = false;
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
		if (_resetGame)
		{
			resetGame();
			_resetGame = false;
		}
		
		#if FLX_RECORD
		// Handle replay-related requests
		if (_recordingRequested)
		{
			_recordingRequested = false;
			_replay.create(FlxRandom.getRecordingSeed());
			recording = true;
			
			#if !FLX_NO_DEBUG
			debugger.vcr.recording();
			FlxG.log.notice("Starting new flixel gameplay record.");
			#end
		}
		else if (_replayRequested)
		{
			_replayRequested = false;
			_replay.rewind();
			FlxG.random.initialSeed = _replay.seed;
			
			#if !FLX_NO_DEBUG
			debugger.vcr.playingReplay();
			#end
			
			replaying = true;
		}
		#end
		
		#if !FLX_NO_DEBUG
		// Finally actually step through the game physics
		FlxBasic.activeCount = 0;
		#end
		
		update();
		
		#if !FLX_NO_DEBUG
		debugger.stats.activeObjects(FlxBasic.activeCount);
		#end
	}
	
	/**
	 * This function is called by step() and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	private function update():Void
	{
		if (!_state.active || !_state.exists)
		{
			return;
		}
		
		if (_state != _requestedState)
		{
			switchState();
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			ticks = getTimer(); // Lib.getTimer() is expensive, only do it if necessary
		}
		#end
		
		FlxG.signals.preUpdate.dispatch();
		
		if (FlxG.fixedTimestep)
		{
			FlxG.elapsed = FlxG.timeScale * _stepSeconds; // fixed timestep
		}
		else
		{
			FlxG.elapsed = FlxG.timeScale * (_elapsedMS / 1000); // variable timestep
			
			var max = FlxG.maxElapsed * FlxG.timeScale;
			if (FlxG.elapsed > max) 
				FlxG.elapsed = max;
		}
		
		updateInput();
		
		#if FLX_POST_PROCESS
		if (postProcesses[0] != null)
		{
			postProcesses[0].update(FlxG.elapsed);
		}
		#end
		
		#if !FLX_NO_SOUND_SYSTEM
		FlxG.sound.update(FlxG.elapsed);
		#end
		FlxG.plugins.update(FlxG.elapsed);
		
		_state.tryUpdate(FlxG.elapsed);
		
		FlxG.cameras.update(FlxG.elapsed);
		FlxG.signals.postUpdate.dispatch();
		
		#if !FLX_NO_DEBUG
		debugger.stats.flixelUpdate(getTimer() - ticks);
		#end
		
		#if FLX_POINTER_INPUT
		for (swipe in FlxG.swipes)
		{
			swipe = null;
		}
		FlxArrayUtil.clearArray(FlxG.swipes);
		#end
		
		filters = filtersEnabled ? _filters : null;
	}
	
	private function updateInput():Void
	{
		#if FLX_RECORD
		if (replaying)
		{
			_replay.playNextFrame();
			
			if (FlxG.vcr.timeout > 0)
			{
				FlxG.vcr.timeout -= _stepMS;
				
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
			
			if (replaying && _replay.finished)
			{
				FlxG.vcr.stopReplay();
				
				if (FlxG.vcr.replayCallback != null)
				{
					FlxG.vcr.replayCallback();
					FlxG.vcr.replayCallback = null;
				}
			}
			
			#if !FLX_NO_DEBUG
			debugger.vcr.updateRuntime(_stepMS);
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
			_replay.recordFrame();
			
			#if !FLX_NO_DEBUG
			debugger.vcr.updateRuntime(_stepMS);
			#end
		}
		#end
	}
	
	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	private function draw():Void
	{
		if (!_state.visible || !_state.exists)
		{
			return;
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			// getTimer() is expensive, only do it if necessary
			ticks = getTimer(); 
		}
		#end
		
		FlxG.signals.preDraw.dispatch();
		
		if (FlxG.renderTile)
		{
			FlxTilesheet._DRAWCALLS = 0;
		}
		
		#if FLX_POST_PROCESS
		if (postProcesses[0] != null)
		{
			postProcesses[0].capture();
		}
		#end
		
		FlxG.cameras.lock();
		
		FlxG.plugins.draw();
		
		_state.draw();
		
		if (FlxG.renderTile)
		{
			FlxG.cameras.render();
			
			#if !FLX_NO_DEBUG
			debugger.stats.drawCalls(FlxTilesheet._DRAWCALLS);
			#end
		}
	
		FlxG.cameras.unlock();
		
		FlxG.signals.postDraw.dispatch();
		
		#if !FLX_NO_DEBUG
		debugger.stats.flixelDraw(getTimer() - ticks);
		#end
	}
	
	private dynamic function getTimer():Int
	{
		return Lib.getTimer();
	}
}
