package org.flixel;

import flash.events.ProgressEvent;
import flash.Lib;
import openfl.Assets;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.media.Sound;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import org.flixel.plugin.pxText.PxBitmapFont;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.TileSheetData;
import org.flixel.system.input.FlxInputs;
import org.flixel.system.layer.TileSheetExt;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxRandom;
import org.flixel.util.FlxTimer;

#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

import org.flixel.plugin.TimerManager;
import org.flixel.system.FlxReplay;

#if !FLX_NO_DEBUG
import org.flixel.system.FlxDebugger;
#end

/**
 * FlxGame is the heart of all flixel games, and contains a bunch of basic game loops and things.
 * It is a long and sloppy file that you shouldn't have to worry about too much!
 * It is basically only used to create your game object in the first place,
 * after that FlxG and FlxState have all the useful stuff you actually need.
 */
class FlxGame extends Sprite
{
	private var junk:String;
	/**
	 * Internal var used to temporarily disable sound hot keys without overriding useSoundHotKeys.
	 */
	public var tempDisableSoundHotKeys:Bool;
	/**
	 * Current game state.
	 */
	public var _state:FlxState;
	/**
	 * Mouse cursor.
	 */
	public var _inputContainer:Sprite;
	/**
	 * Class type of the initial/first game state for the game, usually MenuState or something like that.
	 */
	private var _iState:Class<FlxState>;
	/**
	 * Total number of milliseconds elapsed since game start.
	 */
	private var _total:Int;
	/**
	 * Helper variable to help calculate elapsed time.
	 */
	public static var _mark(default, null):Int;
	/**
	 * Total number of milliseconds elapsed since last update loop.
	 * Counts down as we step through the game loop.
	 */
	private var _accumulator:Int;
	/**
	 * Whether the Flash player lost focus.
	 */
	private var _lostFocus:Bool;
	/**
	 * Milliseconds of time since last step. Supposed to be internal.
	 */
	public var _elapsedMS:Int;
	/**
	 * Milliseconds of time per step of the game loop.  FlashEvent.g. 60 fps = 16ms. Supposed to be internal.
	 */
	public var _step:Int;
	/**
	 * Optimization so we don't have to divide _step by 1000 to get its value in seconds every frame. Supposed to be internal.
	 */
	public var _stepSeconds:Float;
	/**
	 * Framerate of the Flash player (NOT the game loop). Default = 30.
	 */
	public var _flashFramerate:Int;
	/**
	 * Max allowable accumulation (see _accumulator).
	 * Should always (and automatically) be set to roughly 2x the flash player framerate.
	 */
	public var _maxAccumulation:Int;
	/**
	 * If a state change was requested, the new state object is stored here until we switch to it.
	 */
	public var _requestedState:FlxState;
	/**
	 * A flag for keeping track of whether a game reset was requested or not.
	 */
	public var _requestedReset:Bool;
	
	#if !FLX_NO_FOCUS_LOST_SCREEN 
	/**
	 * The "focus lost" screen (see <code>createFocusScreen()</code>).
	 */
	private var _focus:Sprite;
	#end
	
	#if !FLX_NO_SOUND_TRAY
	/**
	 * The sound tray display container (see <code>createSoundTray()</code>).
	 */
	private var _soundTray:Sprite;
	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	private var _soundTrayTimer:Float;
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	private var _updateSoundTray:Bool;
	/**
	 * Helps display the volume bars on the sound tray.
	 */
	private var _soundTrayBars:Array<Bitmap>;
	#end
	
	/**
	 * A FlxSave used for saving the volume and the console's command history.
	 */
	public var _prefsSave:FlxSave;
	
	#if !FLX_NO_DEBUG
	/**
	 * The debugger overlay object.
	 */
	public var _debugger:FlxDebugger;
	/**
	 * A handy boolean that keeps track of whether the debugger exists and is currently visible.
	 */
	public var _debuggerUp:Bool;
	#end
	
	#if !FLX_NO_RECORD
	/**
	 * Container for a game replay object.
	 */
	public var _replay:FlxReplay;
	/**
	 * Flag for whether a playback of a recording was requested.
	 */
	public var _replayRequested:Bool;
	/**
	 * Flag for whether a new recording was requested.
	 */
	public var _recordingRequested:Bool;
	/**
	 * Flag for whether a replay is currently playing.
	 */
	public var _replaying:Bool;
	/**
	 * Flag for whether a new recording is being made.
	 */
	public var _recording:Bool;
	/**
	 * Array that keeps track of keypresses that can cancel a replay.
	 * Handy for skipping cutscenes or getting out of attract modes!
	 */
	public var _replayCancelKeys:Array<String>;
	/**
	 * Helps time out a replay if necessary.
	 */
	public var _replayTimer:Int;
	/**
	 * This function, if set, is triggered when the callback stops playing.
	 */
	public var _replayCallback:Void->Void;
	#end
	
	/**
	 * Instantiate a new game object.
	 * @param	GameSizeX		The width of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	GameSizeY		The height of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
	 * @param	Zoom			The default level of zoom for the game's cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.
	 * @param	GameFramerate	How frequently the game should update (default is 60 times per second).
	 * @param	FlashFramerate	Sets the actual display framerate for Flash player (default is 30 times per second).
	 * @param	UseSystemCursor	Whether to use the default OS mouse pointer, or to use custom flixel ones.
	 */
	public function new(GameSizeX:Int, GameSizeY:Int, InitialState:Class<FlxState>, Zoom:Float = 1, GameFramerate:Int = 60, FlashFramerate:Int = 30)
	{
		super();
		
		//super high priority init stuff (focus, mouse, etc)
		_lostFocus = false;
		#if !FLX_NO_FOCUS_LOST_SCREEN 
		_focus = new Sprite();
		_focus.visible = false;
		#end
		
		#if !FLX_NO_SOUND_TRAY 
		_soundTray = new Sprite();
		#end
		
		_inputContainer = new Sprite();
		
		//basic display and update setup stuff
		FlxG.init(this, GameSizeX, GameSizeY, Zoom);
		FlxG.framerate = GameFramerate;
		FlxG.flashFramerate = FlashFramerate;
		_accumulator = _step;
		_total = 0;
		_mark = 0;
		_state = null;
		tempDisableSoundHotKeys = false;
		_prefsSave = new FlxSave();
		_prefsSave.bind("flixel");
		
		#if !FLX_NO_DEBUG
		FlxG.debug = true;
		_debuggerUp = false;
		#end
		
		#if !FLX_NO_RECORD
		//replay data
		_replay = new FlxReplay();
		_replayRequested = false;
		_recordingRequested = false;
		_replaying = false;
		_recording = false;
		#end
		
		//then get ready to create the game object for real
		_iState = InitialState;
		_requestedState = null;
		_requestedReset = true;
		
		addEventListener(Event.ADDED_TO_STAGE, create);
	}
	
	#if !FLX_NO_SOUND_TRAY 
	/**
	 * Makes the little volume tray slide out.
	 * @param	Silent	Whether or not it should beep.
	 */
	public function showSoundTray(Silent:Bool = false):Void
	{
		if (!Silent)
		{
			FlxG.play(FlxAssets.sndBeep);
		}
		_soundTrayTimer = 1;
		_soundTray.y = 0;
		_soundTray.visible = true;
		_updateSoundTray = true;
		var globalVolume:Int = Math.round(FlxG.volume * 10);
		if (FlxG.mute)
		{
			globalVolume = 0;
		}
		for (i in 0...(_soundTrayBars.length))
		{
			if (i < globalVolume) _soundTrayBars[i].alpha = 1;
			else _soundTrayBars[i].alpha = 0.5;
		}
	}
	#end

	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash event.
	 */
	private function onFocus(FlashEvent:Event = null):Void
	{
		if (!FlxG.autoPause) 
		{
			_state.onFocus();
			return;
		}
		
		_lostFocus = false;
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		_focus.visible = false;
		#end 
		
		stage.frameRate = _flashFramerate;
		FlxG.resumeSounds();
		FlxInputs.onFocus();
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash event.
	 */
	private function onFocusLost(FlashEvent:Event = null):Void
	{
		if (!FlxG.autoPause) 
		{
			_state.onFocusLost();
			return;
		}
		
		_lostFocus = true;
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		_focus.visible = true;
		#end 
		
		stage.frameRate = 10;
		FlxG.pauseSounds();
		FlxInputs.onFocusLost();
	}
	
	/**
	 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.
	 * @param	FlashEvent	Flash event.
	 */
	private function onEnterFrame(FlashEvent:Event = null):Void
	{			
		_mark = Lib.getTimer();
		_elapsedMS = _mark - _total;
		_total = _mark;
		
		#if !FLX_NO_SOUND_TRAY
		if (_updateSoundTray)
			updateSoundTray(_elapsedMS);
		#end
		
		if(!_lostFocus)
		{
			#if !FLX_NO_DEBUG
			if((_debugger != null) && _debugger.vcr.paused)
			{
				if(_debugger.vcr.stepRequested)
				{
					_debugger.vcr.stepRequested = false;
					step();
				}
			}
			else
			{
			#end
				_accumulator += _elapsedMS;
				if (_accumulator > _maxAccumulation)
				{
					_accumulator = _maxAccumulation;
				}
				// TODO: You may uncomment following lines
				//while (_accumulator > _step)
				while(_accumulator >= _step)
				{
					step();
					_accumulator = _accumulator - _step; 
				}
			#if !FLX_NO_DEBUG
			}
			#end
			
			FlxBasic._VISIBLECOUNT = 0;
			draw();
			
			#if !FLX_NO_DEBUG
			if(_debuggerUp)
			{
				_debugger.perf.flash(_elapsedMS);
				_debugger.perf.visibleObjects(FlxBasic._VISIBLECOUNT);
				_debugger.perf.update();
				_debugger.watch.update();
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
		requestNewState(Type.createInstance(_iState, []));
		
		#if !FLX_NO_DEBUG
		if (Std.is(_requestedState, FlxSubState))
		{
			throw "You can't set FlxSubState class instance as the state for you game";
		}
		#end
		
		#if !FLX_NO_RECORD
		_replayTimer = 0;
		_replayCancelKeys = null;
		#end
		
		FlxG.reset();
	}
	
	/**
	 * Notify the game that we're about to switch states. 
	 * INTERNAL, do not use this, call FlxG.switchState instead.
	 */
	public inline function requestNewState(newState:FlxState):Void
	{
		_requestedState = newState;
		#if(cpp && thread)
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
		//Basic reset stuff
		PxBitmapFont.clearStorage();
		Atlas.clearAtlasCache();
		TileSheetData.clear();
		
		FlxG.clearBitmapCache();
		FlxG.resetCameras();
		FlxG.resetInput();
		FlxG.destroySounds();
		
		#if !FLX_NO_DEBUG
		//Clear the debugger overlay's Watch window
		if (_debugger != null)
		{
			_debugger.watch.removeAll();
		}
		#end
		
		//Clear any timers left in the timer manager
		var timerManager:TimerManager = FlxTimer.manager;
		if (timerManager != null)
		{
			timerManager.clear();
		}
		
		#if !FLX_NO_MOUSE
		var mouseVisibility:Bool = FlxG.mouse.visible || ((_state != null) ? _state.useMouse : false);
		#end
		//Destroy the old state (if there is an old state)
		if (_state != null)
		{
			_state.destroy();
		}
		
		//Finally assign and create the new state
		_state = _requestedState;
		#if !FLX_NO_MOUSE
		_state.useMouse = mouseVisibility;
		#end
		_state.create();
		
		#if (cpp && thread) 
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
		//handle game reset request
		if(_requestedReset)
		{
			resetGame();
			_requestedReset = false;
		}
		
		#if !FLX_NO_RECORD
		//handle replay-related requests
		if (_recordingRequested)
		{
			_recordingRequested = false;
			_replay.create(FlxRandom.globalSeed);
			_recording = true;
			
			#if !FLX_NO_DEBUG
			_debugger.vcr.recording();
			FlxG.notice("Starting new flixel gameplay record.");
			#end
		}
		else if (_replayRequested)
		{
			_replayRequested = false;
			_replay.rewind();
			FlxRandom.globalSeed = _replay.seed;
			#if !FLX_NO_DEBUG
			_debugger.vcr.playing();
			#end
			_replaying = true;
		}
		#end
		
		//finally actually step through the game physics
		FlxBasic._ACTIVECOUNT = 0;
		
		#if (cpp && thread)
		_threadSync.push(true);
		#else
		update();
		#end
		
		#if !FLX_NO_DEBUG
		if (_debuggerUp)
		{
			_debugger.perf.activeObjects(FlxBasic._ACTIVECOUNT);
		}
		#end
	}
	
	#if (cpp && thread)
	// push 'true' into this array to trigger an update. push 'false' to terminate update thread.
	public var _stateSwitchRequested:Bool;
	public var _threadSync:cpp.vm.Deque<Bool>;
	
	private function threadedUpdate():Void 
	{
		while (_threadSync.pop(true))
			update();
	}
	#end
	
	#if !FLX_NO_SOUND_TRAY
	/**
	 * This function just updates the soundtray object.
	 */
	private function updateSoundTray(MS:Float):Void
	{
		//animate stupid sound tray thing
		if (_soundTrayTimer > 0)
		{
			_soundTrayTimer -= MS/1000;
		}
		else if (_soundTray.y > -_soundTray.height)
		{
			_soundTray.y -= (MS / 1000) * FlxG.height * 2;
			if (_soundTray.y <= -_soundTray.height)
			{
				_soundTray.visible = false;
				_updateSoundTray = false;
				
				//Save sound preferences
				_prefsSave.data.mute = FlxG.mute;
				_prefsSave.data.volume = FlxG.volume; 
				_prefsSave.flush(); 
			}
		}
	}
	#end
	
	/**
	 * This function is called by step() and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	private function update():Void
	{
		if (_state != _requestedState)
			switchState();
		
		#if !FLX_NO_DEBUG
		if (_debuggerUp)
			_mark = Lib.getTimer(); // getTimer is expensive, only do it if necessary
		#end
		
		FlxG.elapsed = FlxG.timeScale * _stepSeconds;
		FlxG.updateSounds();
		FlxG.updatePlugins();
		
		updateInput();
		updateState();
		
		if (FlxG.tweener.active && FlxG.tweener.hasTween) 
		{
			FlxG.tweener.updateTweens();
		}
		
		FlxG.updateCameras();
		
		#if !FLX_NO_DEBUG
		if (_debuggerUp)
			_debugger.perf.flixelUpdate(Lib.getTimer() - _mark);
		#end
	}
	
	private function updateState():Void
	{
		_state.tryUpdate();
	}
	
	private function updateInput():Void
	{
		#if !FLX_NO_RECORD
		if(_replaying)
		{
			_replay.playNextFrame();
			if(_replayTimer > 0)
			{
				_replayTimer -= _step;
				if(_replayTimer <= 0)
				{
					if(_replayCallback != null)
					{
						_replayCallback();
						_replayCallback = null;
					}
					else
					{
						FlxG.stopReplay();
					}
				}
			}
			if(_replaying && _replay.finished)
			{
				FlxG.stopReplay();
				if(_replayCallback != null)
				{
					_replayCallback();
					_replayCallback = null;
				}
			}
			#if !FLX_NO_DEBUG
				_debugger.vcr.updateRuntime(_step);
			#end
		}
		else
		{
		#end
		
		FlxInputs.updateInputs();
		
		#if !FLX_NO_RECORD
		}
		if(_recording)
		{
			_replay.recordFrame();
			#if !FLX_NO_DEBUG
			_debugger.vcr.updateRuntime(_step);
			#end
		}
		#end
		
		#if !FLX_NO_MOUSE
		//todo test why is this needed can it be put in FlxMouse
		FlxG.mouse.wheel = 0;
		#end
	}
	
	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	private function draw():Void
	{
		#if !FLX_NO_DEBUG
		if (_debuggerUp)
			_mark = Lib.getTimer(); // getTimer is expensive, only do it if necessary
		#end

		#if !flash
		TileSheetExt._DRAWCALLS = 0;
		#end
		
		FlxG.lockCameras();
		
		#if (cpp && thread)
		// Only draw the state if a new state hasn't been requested
		if (!_stateSwitchRequested)
		#end 
		_state.draw();
		
		#if !FLX_NO_DEBUG
		if (FlxG.visualDebug)
		{
			_state.drawDebug();
		}
		#end
		
		#if !flash
		FlxG.renderCameras();
		
		#if !FLX_NO_DEBUG
		if (_debuggerUp)
		{
			_debugger.perf.drawCalls(TileSheetExt._DRAWCALLS);
		}
		#end
		#end
		
		FlxG.drawPlugins();
		#if !FLX_NO_DEBUG
		if (FlxG.visualDebug)
		{
			FlxG.drawDebugPlugins();
		}
		#end
		FlxG.unlockCameras();
		#if !FLX_NO_DEBUG
		if (_debuggerUp)
			_debugger.perf.flixelDraw(Lib.getTimer() - _mark);
		#end
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
		//Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = _flashFramerate;
		
		addChild(_inputContainer);
		
		#if !FLX_NO_KEYBOARD
		//Assign default values to the keys used by core flixel
		FlxG.keyDebugger = [192, 220];
		FlxG.keyVolumeUp = [107, 187];
		FlxG.keyVolumeDown = [109, 189];
		FlxG.keyMute = [48, 96]; 
		#end
		
		FlxInputs.init();
		
		FlxG.autoPause = true;
		
		//Let mobile devs opt out of unnecessary overlays.
		if(!FlxG.mobile)
		{
			#if !FLX_NO_DEBUG
			//Debugger overlay
			if(FlxG.debug)
			{
				_debugger = new FlxDebugger(FlxG.width * FlxCamera.defaultZoom, FlxG.height * FlxCamera.defaultZoom);
				#if flash
				addChild(_debugger);
				#else
				Lib.current.stage.addChild(_debugger);
				#end
			}
			#end
			
			//Volume display tab
			#if !FLX_NO_SOUND_TRAY
			createSoundTray();
			#end
			
			loadSoundPrefs();
			
			//Focus gained/lost monitoring
			stage.addEventListener(Event.DEACTIVATE, onFocusLost);
			stage.addEventListener(Event.ACTIVATE, onFocus);
			// TODO: add event listeners for Event.ACTIVATE/DEACTIVATE 
			#if !FLX_NO_FOCUS_LOST_SCREEN
			createFocusScreen();
			#end
		}
		
		// Instantiate the initial state
		if (_requestedReset)
		{
			resetGame();
			switchState();
			_requestedReset = false;
		}
		
		#if (cpp && thread)
		_threadSync = new cpp.vm.Deque();
		cpp.vm.Thread.create(threadedUpdate);
		#end
		
		//Finally, set up an event for the actual game loop stuff.
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	#if !FLX_NO_SOUND_TRAY
	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	private function createSoundTray():Void
	{
		_soundTray.visible = false;
		_soundTray.scaleX = 2;
		_soundTray.scaleY = 2;
		var tmp:Bitmap = new Bitmap(new BitmapData(80, 30, true, 0x7F000000));
		_soundTray.x = (FlxG.width / 2) * FlxCamera.defaultZoom - (tmp.width / 2) * _soundTray.scaleX;
		_soundTray.addChild(tmp);
		
		var text:TextField = new TextField();
		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;
		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		
		#end
		var dtf:TextFormat = new TextFormat(Assets.getFont(FlxAssets.defaultFont).fontName, 8, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		_soundTray.addChild(text);
		text.text = "VOLUME";
		text.y = 16;
		
		var bx:Int = 10;
		var by:Int = 14;
		_soundTrayBars = new Array();
		var i:Int = 0;
		while(i < 10)
		{
			tmp = new Bitmap(new BitmapData(4, ++i, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			_soundTray.addChild(tmp);
			_soundTrayBars.push(tmp);
			bx += 6;
			by--;
		}
		
		_soundTray.y = -_soundTray.height;
		_soundTray.visible = false;
		addChild(_soundTray);
	}
	#end
	
	/**
	 * Loads sound preferences if they exist.
	 */
	private function loadSoundPrefs():Void
	{
		if (_prefsSave.data.volume != null)
			FlxG.volume = _prefsSave.data.volume;
		else 
			FlxG.volume = 0.5; 
		
		if (_prefsSave.data.mute != null)
			FlxG.mute = _prefsSave.data.mute;
		else 
			FlxG.mute = false; 
	}
	
	#if !FLX_NO_FOCUS_LOST_SCREEN
	/**
	 * Sets up the darkened overlay with the big white "play" button that appears when a flixel game loses focus.
	 */
	public function createFocusScreen():Void
	{
		var gfx:Graphics = _focus.graphics;
		var screenWidth:Int = Std.int(FlxG.width * FlxCamera.defaultZoom);
		var screenHeight:Int = Std.int(FlxG.height * FlxCamera.defaultZoom);
		
		//draw transparent black backdrop
		gfx.moveTo(0, 0);
		gfx.beginFill(0, 0.5);
		gfx.lineTo(screenWidth, 0);
		gfx.lineTo(screenWidth, screenHeight);
		gfx.lineTo(0, screenHeight);
		gfx.lineTo(0, 0);
		gfx.endFill();
		
		//draw white arrow
		var halfWidth:Int = Std.int(screenWidth / 2);
		var halfHeight:Int = Std.int(screenHeight / 2);
		var helper:Int = Std.int(Math.min(halfWidth, halfHeight) / 3);
		gfx.moveTo(halfWidth - helper, halfHeight - helper);
		gfx.beginFill(0xffffff, 0.65);
		gfx.lineTo(halfWidth + helper, halfHeight);
		gfx.lineTo(halfWidth - helper, halfHeight + helper);
		gfx.lineTo(halfWidth - helper, halfHeight - helper);
		gfx.endFill();
		
		var logo:Sprite = new Sprite();
		FlxAssets.drawLogo(logo.graphics);
		logo.scaleX = helper / 1000;
		if (logo.scaleX < 0.2)
		{
			logo.scaleX = 0.2;
		}
		logo.scaleY = logo.scaleX;
		logo.x = logo.y = 5;
		logo.alpha = 0.35;
		_focus.addChild(logo);
		
		addChild(_focus);
	}
	#end

	#if !FLX_NO_DEBUG
	public var debugger(get_debugger, null):FlxDebugger;
	public function get_debugger():FlxDebugger
	{
		return _debugger;
	}
	#end
}