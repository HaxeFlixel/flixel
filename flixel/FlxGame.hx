package flixel;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.plugin.TimerManager;
import flixel.system.FlxAssets;
import flixel.system.FlxReplay;
import flixel.system.input.FlxInputs;
import flixel.system.layer.Atlas;
import flixel.system.layer.TileSheetData;
import flixel.system.layer.TileSheetExt;
import flixel.text.pxText.PxBitmapFont;
import flixel.util.FlxColor;
import flixel.util.FlxRandom;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import openfl.Assets;

#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

#if !FLX_NO_DEBUG
import flixel.system.FlxDebugger;
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
	 * Helper variable to help calculate elapsed time.
	 */
	static public var mark(default, null):Int = 0;
	
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
	/**
	 * A FlxSave used for saving the volume and the console's command history.
	 */
	public var prefsSave:FlxSave;
	
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
	/**
	 * Array that keeps track of keypresses that can cancel a replay.
	 * Handy for skipping cutscenes or getting out of attract modes!
	 */
	public var replayCancelKeys:Array<String>;
	/**
	 * Helps time out a replay if necessary.
	 */
	public var replayTimer:Int;
	/**
	 * This function, if set, is triggered when the callback stops playing.
	 */
	public var replayCallback:Void->Void;
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
	
	/**
	 * Instantiate a new game object.
	 * @param	GameSizeX		The width of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	GameSizeY		The height of your game in game pixels, not necessarily final display pixels (see Zoom).
	 * @param	InitialState	The class name of the state you want to create and switch to first (e.g. MenuState).
	 * @param	Zoom			The default level of zoom for the game's cameras (e.g. 2 = all pixels are now drawn at 2x).  Default = 1.
	 * @param	GameFramerate	How frequently the game should update (default is 60 times per second).
	 * @param	FlashFramerate	Sets the actual display framerate for Flash player (default is 60 times per second).
	 */
	public function new(GameSizeX:Int, GameSizeY:Int, InitialState:Class<FlxState>, Zoom:Float = 1, GameFramerate:Int = 60, FlashFramerate:Int = 60)
	{
		super();
		
		// Super high priority init stuff (focus, mouse, etc)
		#if !FLX_NO_FOCUS_LOST_SCREEN 
		_focus = new Sprite();
		_focus.visible = false;
		#end
		
		#if !FLX_NO_SOUND_TRAY 
		_soundTray = new Sprite();
		#end
		
		inputContainer = new Sprite();
		
		//basic display and update setup stuff
		FlxG.init(this, GameSizeX, GameSizeY, Zoom);
		
		if (GameFramerate < FlashFramerate)
		{
			GameFramerate = FlashFramerate;
		}
		
		FlxG.framerate = GameFramerate;
		FlxG.flashFramerate = FlashFramerate;
		_accumulator = stepMS;
		prefsSave = new FlxSave();
		prefsSave.bind("flixel");
		
		#if FLX_RECORD
		// Replay data
		replay = new FlxReplay();
		#end
		
		// Then get ready to create the game object for real
		_iState = InitialState;
		
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
			FlxG.sound.play(FlxAssets.sndBeep);
		}
		_soundTrayTimer = 1;
		_soundTray.y = 0;
		_soundTray.visible = true;
		_updateSoundTray = true;
		var globalVolume:Int = Math.round(FlxG.sound.volume * 10);
		if (FlxG.sound.muted)
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
			state.onFocus();
			return;
		}
		
		_lostFocus = false;
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		_focus.visible = false;
		#end 
		
		stage.frameRate = flashFramerate;
		FlxG.sound.resumeSounds();
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
			state.onFocusLost();
			return;
		}
		
		_lostFocus = true;
		
		#if !FLX_NO_FOCUS_LOST_SCREEN
		_focus.visible = true;
		#end 
		
		stage.frameRate = 10;
		FlxG.sound.pauseSounds();
		FlxInputs.onFocusLost();
	}
	
	/**
	 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.
	 * @param	FlashEvent	Flash event.
	 */
	private function onEnterFrame(FlashEvent:Event = null):Void
	{			
		mark = Lib.getTimer();
		elapsedMS = mark - _total;
		_total = mark;
		
		#if !FLX_NO_SOUND_TRAY
		if (_updateSoundTray)
			updateSoundTray(elapsedMS);
		#end
		
		if(!_lostFocus)
		{
			#if !FLX_NO_DEBUG
			if((debugger != null) && debugger.vcr.paused)
			{
				if(debugger.vcr.stepRequested)
				{
					debugger.vcr.stepRequested = false;
					step();
				}
			}
			else
			{
			#end
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
			#if !FLX_NO_DEBUG
			}
			#end
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT = 0;
			#end
			
			draw();
			
			#if !FLX_NO_DEBUG
			if (FlxG.debugger.visible)
			{
				debugger.perf.flash(elapsedMS);
				debugger.perf.visibleObjects(FlxBasic._VISIBLECOUNT);
				debugger.perf.update();
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
		requestNewState(Type.createInstance(_iState, []));
		
		#if !FLX_NO_DEBUG
		if (Std.is(requestedState, FlxSubState))
		{
			throw "You can't set FlxSubState class instance as the state for you game";
		}
		#end
		
		#if FLX_RECORD
		replayTimer = 0;
		replayCancelKeys = null;
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
		Atlas.clearAtlasCache();
		TileSheetData.clear();
		
		FlxG.bitmap.clearCache();
		FlxG.cameras.reset();
		FlxG.resetInput();
		FlxG.sound.destroySounds();
		
		#if !FLX_NO_DEBUG
		// Clear the debugger overlay's Watch window
		if (debugger != null)
		{
			debugger.watch.removeAll();
		}
		#end
		
		// Clear any timers left in the timer manager
		var timerManager:TimerManager = FlxTimer.manager;
		if (timerManager != null)
		{
			timerManager.clear();
		}
		
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
		if(requestedReset)
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
			debugger.vcr.playing();
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
			debugger.perf.activeObjects(FlxBasic._ACTIVECOUNT);
		}
		#end
	}
	
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
				prefsSave.data.mute = FlxG.sound.muted;
				prefsSave.data.volume = FlxG.sound.volume; 
				prefsSave.flush(); 
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
		if (state != requestedState)
		{
			switchState();
		}
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			// getTimer() is expensive, only do it if necessary
			mark = Lib.getTimer(); 
		}
		#end
		
		FlxG.elapsed = FlxG.timeScale * stepSeconds;
		
		updateInput();
		
		FlxG.sound.updateSounds();
		FlxG.plugins.update();
		
		updateState();
		
		if (FlxG.tweener.active && FlxG.tweener.hasTween) 
		{
			FlxG.tweener.updateTweens();
		}
		
		FlxG.cameras.update();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			debugger.perf.flixelUpdate(Lib.getTimer() - mark);
		}
		#end
	}
	
	private function updateState():Void
	{
		state.tryUpdate();
	}
	
	private function updateInput():Void
	{
		#if FLX_RECORD
		if (replaying)
		{
			replay.playNextFrame();
			
			if (replayTimer > 0)
			{
				replayTimer -= stepMS;
				
				if (replayTimer <= 0)
				{
					if(replayCallback != null)
					{
						replayCallback();
						replayCallback = null;
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
				
				if (replayCallback != null)
				{
					replayCallback();
					replayCallback = null;
				}
			}
			
			#if !FLX_NO_DEBUG
			debugger.vcr.updateRuntime(stepMS);
			#end
		}
		else
		{
		#end
		
		FlxInputs.updateInputs();
		
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
		
		#if !FLX_NO_MOUSE
		// TODO: Test why is this needed can it be put in FlxMouse
		FlxG.mouse.wheel = 0;
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
			mark = Lib.getTimer(); 
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
			debugger.perf.drawCalls(TileSheetExt._DRAWCALLS);
		}
		#end
		#end
		
		FlxG.plugins.draw();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visualDebug)
		{
			FlxG.debugger.drawDebugPlugins();
		}
		#end
		
		FlxG.cameras.unlock();
		
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.visible)
		{
			debugger.perf.flixelDraw(Lib.getTimer() - mark);
		}
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
		
		// Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = flashFramerate;
		
		addChild(inputContainer);
		
		FlxInputs.init();
		
		FlxG.autoPause = true;
		
		// Creating the debugger overlay
		#if !FLX_NO_DEBUG
		debugger = new FlxDebugger(FlxG.width * FlxCamera.defaultZoom, FlxG.height * FlxCamera.defaultZoom);
		addChild(debugger);
		#end
		
		// Let mobile devs opt out of unnecessary overlays.
		#if !mobile	
			// Volume display tab
			#if !FLX_NO_SOUND_TRAY
			createSoundTray();
			#end
				
			loadSoundPrefs();
				
			// Focus gained/lost monitoring
			stage.addEventListener(Event.DEACTIVATE, onFocusLost);
			stage.addEventListener(Event.ACTIVATE, onFocus);
				
			#if !FLX_NO_FOCUS_LOST_SCREEN
			createFocusScreen();
			#end
			
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
		
		// Finally, set up an event for the actual game loop stuff.
		stage.addEventListener(Event.ENTER_FRAME, onEnterFrame);
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
		var dtf:TextFormat = new TextFormat(FlxAssets.defaultFont, 8, 0xffffff);
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
		if (prefsSave.data.volume != null)
			FlxG.sound.volume = prefsSave.data.volume;
		else 
			FlxG.sound.volume = 0.5; 
		
		if (prefsSave.data.mute != null)
			FlxG.sound.muted = prefsSave.data.mute;
		else 
			FlxG.sound.muted = false; 
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
}