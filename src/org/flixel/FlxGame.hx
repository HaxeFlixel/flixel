package org.flixel;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.KeyboardEvent;
import nme.events.MouseEvent;
import nme.media.Sound;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.Lib;
import nme.ui.Mouse;

#if (cpp || neko)
import org.flixel.tileSheetManager.TileSheetManager;
#end

#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end

import org.flixel.plugin.TimerManager;
import org.flixel.system.FlxDebugger;
import org.flixel.system.FlxReplay;

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
	 * Sets 0, -, and + to control the global volume sound volume.
	 * @default true
	 */
	public var useSoundHotKeys:Bool;
	/**
	 * Tells flixel to use the default system mouse cursor instead of custom Flixel mouse cursors.
	 * @default false
	 */
	public var useSystemCursor:Bool;
	/**
	 * Initialize and allow the flixel debugger overlay even in release mode.
	 * Also useful if you don't use FlxPreloader!
	 * @default false
	 */
	public var forceDebugger:Bool;

	/**
	 * Current game state.
	 */
	public var _state:FlxState;
	/**
	 * Mouse cursor.
	 */
	public var _mouse:Sprite;
	
	/**
	 * Class type of the initial/first game state for the game, usually MenuState or something like that.
	 */
	private var _iState:Class<FlxState>;
	/**
	 * Whether the game object's basic initialization has finished yet.
	 */
	private var _created:Bool;
	
	/**
	 * Total number of milliseconds elapsed since game start.
	 */
	private var _total:Int;
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
	 * Milliseconds of time per step of the game loop.  FlashEvent.g. 60 fps = 16ms. Supposed to be internal
	 */
	public var _step:Int;
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

	/**
	 * The "focus lost" screen (see <code>createFocusScreen()</code>).
	 */
	private var _focus:Sprite;
	/**
	 * The sound tray display container (see <code>createSoundTray()</code>).
	 */
	private var _soundTray:Sprite;
	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	private var _soundTrayTimer:Float;
	/**
	 * Helps display the volume bars on the sound tray.
	 */
	private var _soundTrayBars:Array<Bitmap>;
	/**
	 * The debugger overlay object.
	 */
	public var _debugger:FlxDebugger;
	/**
	 * A handy boolean that keeps track of whether the debugger exists and is currently visible.
	 */
	public var _debuggerUp:Bool;
	
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
	
	/**
	 * This sprite is needed in c++ version of games.
	 */
	public static var clickableArea:Sprite;

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
	public function new(GameSizeX:Int, GameSizeY:Int, InitialState:Class<FlxState>, ?Zoom:Float = 1, GameFramerate:Int = 60, ?FlashFramerate:Int = 30, ?UseSystemCursor:Bool = false)
	{
		super();
		
		//super high priority init stuff (focus, mouse, etc)
		_lostFocus = false;
		_focus = new Sprite();
		_focus.visible = false;
		_soundTray = new Sprite();
		_mouse = new Sprite();
		
		//basic display and update setup stuff
		FlxG.init(this, GameSizeX, GameSizeY, Zoom);
		FlxG.framerate = GameFramerate;
		FlxG.flashFramerate = FlashFramerate;
		_accumulator = _step;
		_total = 0;
		_state = null;
		useSoundHotKeys = true;
		useSystemCursor = UseSystemCursor;
		if (!useSystemCursor)
		{
			Mouse.hide();
		}
		forceDebugger = false;
		_debuggerUp = false;
		
		//replay data
		_replay = new FlxReplay();
		_replayRequested = false;
		_recordingRequested = false;
		_replaying = false;
		_recording = false;
		
		//then get ready to create the game object for real
		_iState = InitialState;
		_requestedState = null;
		_requestedReset = true;
		_created = false;
		addEventListener(Event.ENTER_FRAME, create);
	}
	
	/**
	 * Makes the little volume tray slide out.
	 * @param	Silent	Whether or not it should beep.
	 */
	private function showSoundTray(?Silent:Bool = false):Void
	{
		if (!Silent)
		{
			FlxG.play(FlxAssets.sndBeep);
		}
		_soundTrayTimer = 1;
		_soundTray.y = 0;
		_soundTray.visible = true;
		var globalVolume:Int = Math.round(FlxG.volume * 10);
		if (FlxG.mute)
		{
			globalVolume = 0;
		}
		for (i in 0...(_soundTrayBars.length))
		{
			if (i < Std.int(globalVolume)) _soundTrayBars[i].alpha = 1;
			else _soundTrayBars[i].alpha = 0.5;
		}
	}

	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash keyboard event.
	 */
	private function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		if (_debuggerUp && _debugger.watch.editing)
		{
			return;
		}
		if(!FlxG.mobile)
		{
			if((_debugger != null) && ((FlashEvent.keyCode == 192) || (FlashEvent.keyCode == 220)))
			{
				_debugger.visible = !_debugger.visible;
				_debuggerUp = _debugger.visible;
				if (_debugger.visible)
				{
					Mouse.show();
				}
				else if (!useSystemCursor)
				{
					Mouse.hide();
				}
				//_console.toggle();
				return;
			}
			if(useSoundHotKeys)
			{
				var c:Int = FlashEvent.keyCode;
				var code:String = String.fromCharCode(FlashEvent.charCode);
				if (c == 48 || c == 96)
				{
					FlxG.mute = !FlxG.mute;
					if (FlxG.volumeHandler != null)
					{
						FlxG.volumeHandler(FlxG.mute?0:FlxG.volume);
					}
					showSoundTray();
					return;
				}
				else if (c == 109 || c == 189)
				{
					FlxG.mute = false;
					FlxG.volume = FlxG.volume - 0.1;
					showSoundTray();
					return;
				}
				else if (c == 107 || c == 187)
				{
					FlxG.mute = false;
					FlxG.volume = FlxG.volume + 0.1;
					showSoundTray();
					return;
				}
				else
				{
					//default:
				}
			}
		}
		if (_replaying)
		{
			return;
		}
		FlxG.keys.handleKeyUp(FlashEvent);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash keyboard event.
	 */
	private function onKeyDown(FlashEvent:KeyboardEvent):Void
	{
		if (_debuggerUp && _debugger.watch.editing)
		{
			return;
		}
		if(_replaying && (_replayCancelKeys != null) && (_debugger == null) && (FlashEvent.keyCode != 192) && (FlashEvent.keyCode != 220))
		{
			var cancel:Bool = false;
			var replayCancelKey:String;
			var i:Int = 0;
			var l:Int = _replayCancelKeys.length;
			while(i < l)
			{
				replayCancelKey = _replayCancelKeys[i++];
				if((replayCancelKey == "ANY") || (FlxG.keys.getKeyCode(replayCancelKey) == Std.int(FlashEvent.keyCode)))
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
					break;
				}
			}
			return;
		}
		FlxG.keys.handleKeyDown(FlashEvent);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash mouse event.
	 */
	private function onMouseDown(FlashEvent:MouseEvent):Void
	{
		if(_debuggerUp)
		{
			if (_debugger.hasMouse)
			{
				return;
			}
			if (_debugger.watch.editing)
			{
				_debugger.watch.submit();
			}
		}
		if(_replaying && (_replayCancelKeys != null))
		{
			var replayCancelKey:String;
			var i:Int = 0;
			var l:Int = _replayCancelKeys.length;
			while(i < l)
			{
				replayCancelKey = _replayCancelKeys[i++];
				if((replayCancelKey == "MOUSE") || (replayCancelKey == "ANY"))
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
					break;
				}
			}
			return;
		}
		FlxG.mouse.handleMouseDown(FlashEvent);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash mouse event.
	 */
	private function onMouseUp(FlashEvent:MouseEvent):Void
	{
		if ((_debuggerUp && _debugger.hasMouse) || _replaying)
		{
			return;
		}
		FlxG.mouse.handleMouseUp(FlashEvent);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash mouse event.
	 */
	private function onMouseWheel(FlashEvent:MouseEvent):Void
	{
		if ((_debuggerUp && _debugger.hasMouse) || _replaying)
		{
			return;
		}
		FlxG.mouse.handleMouseWheel(FlashEvent);
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash event.
	 */
	private function onFocus(?FlashEvent:Event = null):Void
	{
		if (!_debuggerUp && !useSystemCursor)
		{
			Mouse.hide();
		}
		FlxG.resetInput();
		_lostFocus = _focus.visible = false;
		stage.frameRate = _flashFramerate;
		FlxG.resumeSounds();
	}
	
	/**
	 * Internal event handler for input and focus.
	 * @param	FlashEvent	Flash event.
	 */
	private function onFocusLost(?FlashEvent:Event = null):Void
	{
		if((x != 0) || (y != 0))
		{
			x = 0;
			y = 0;
		}
		Mouse.show();
		_lostFocus = _focus.visible = true;
		stage.frameRate = 10;
		FlxG.pauseSounds();
	}
	
	/**
	 * Handles the onEnterFrame call and figures out how many updates and draw calls to do.
	 * @param	FlashEvent	Flash event.
	 */
	private function onEnterFrame(?FlashEvent:Event = null):Void
	{			
		var mark:Int = Lib.getTimer();
		var elapsedMS:Int = mark - _total;
		_total = mark;
		updateSoundTray(elapsedMS);
		if(!_lostFocus)
		{
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
				_accumulator += elapsedMS;
				if (_accumulator > _maxAccumulation)
				{
					_accumulator = _maxAccumulation;
				}
				// TODO: You may uncomment following lines
				//while(_accumulator >= Std.int(_step))
				while(_accumulator > Std.int(_step))
				{
					step();
					_accumulator = _accumulator - _step; 
				}
			}
			
			FlxBasic._VISIBLECOUNT = 0;
			draw();
			
			if(_debuggerUp)
			{
				_debugger.perf.flash(elapsedMS);
				_debugger.perf.visibleObjects(FlxBasic._VISIBLECOUNT);
				_debugger.perf.update();
				_debugger.watch.update();
			}
		}
	}

	/**
	 * If there is a state change requested during the update loop,
	 * this function handles actual destroying the old state and related processes,
	 * and calls creates on the new state and plugs it into the game object.
	 */
	private function switchState():Void
	{ 
		//Basic reset stuff
		#if (cpp || neko)
		TileSheetManager.clear();
		#end
		FlxG.clearBitmapCache();
		FlxG.resetCameras();
		FlxG.resetInput();
		FlxG.destroySounds();
		
		//Clear the debugger overlay's Watch window
		if (_debugger != null)
		{
			_debugger.watch.removeAll();
		}
		
		//Clear any timers left in the timer manager
		var timerManager:TimerManager = FlxTimer.manager;
		if (timerManager != null)
		{
			timerManager.clear();
		}
		
		//Destroy the old state (if there is an old state)
		if (_state != null)
		{
			_state.destroy();
		}
		
		//Finally assign and create the new state
		_state = _requestedState;
		_state.create();
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
			_requestedReset = false;
			//_requestedState = new _iState();
			_requestedState = Type.createInstance(_iState, []);
			_replayTimer = 0;
			_replayCancelKeys = null;
			FlxG.reset();
		}
		//handle replay-related requests
		if (_recordingRequested)
		{
			_recordingRequested = false;
			_replay.create(FlxG.globalSeed);
			_recording = true;
			if(_debugger != null)
			{
				_debugger.vcr.recording();
				FlxG.log("FLIXEL: starting new flixel gameplay record.");
			}
		}
		else if (_replayRequested)
		{
			_replayRequested = false;
			_replay.rewind();
			FlxG.globalSeed = _replay.seed;
			if (_debugger != null)
			{
				_debugger.vcr.playing();
			}
			_replaying = true;
		}
		
		//handle state switching requests
		if (_state != _requestedState)
		{
			switchState();
		}
		
		//finally actually step through the game physics
		FlxBasic._ACTIVECOUNT = 0;
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
			if (_debugger != null)
			{
				_debugger.vcr.updateRuntime(_step);
			}
		}
		else
		{
			FlxG.updateInput();
		}
		if(_recording)
		{
			_replay.recordFrame();
			if (_debugger != null)
			{
				_debugger.vcr.updateRuntime(_step);
			}
		}
		update();
		FlxG.mouse.wheel = 0;
		if (_debuggerUp)
		{
			_debugger.perf.activeObjects(FlxBasic._ACTIVECOUNT);
		}
	}

	/**
	 * This function just updates the soundtray object.
	 */
	private function updateSoundTray(MS:Float):Void
	{
		//animate stupid sound tray thing
		
		if(_soundTray != null)
		{
			if (_soundTrayTimer > 0)
			{
				_soundTrayTimer -= MS/1000;
			}
			else if(_soundTray.y > -_soundTray.height)
			{
				_soundTray.y -= (MS/1000)*FlxG.height*2;
				if(_soundTray.y <= -_soundTray.height)
				{
					_soundTray.visible = false;
					
					//Save sound preferences
					var soundPrefs:FlxSave = new FlxSave();
					if(soundPrefs.bind("flixel"))
					{
						if (soundPrefs.data.sound == null)
						{
							soundPrefs.data.sound = {};
						}
						soundPrefs.data.sound.mute = FlxG.mute;
						soundPrefs.data.sound.volume = FlxG.volume;
						soundPrefs.close();
					}
				}
			}
		}
	}
	
	/**
	 * This function is called by step() and updates the actual game state.
	 * May be called multiple times per "frame" or draw call.
	 */
	private function update():Void
	{			
		var mark:Int = Lib.getTimer();
		
		FlxG.elapsed = FlxG.timeScale * (_step / 1000);
		FlxG.updateSounds();
		FlxG.updatePlugins();
		_state.update();
		FlxG.updateCameras();
		
		if (_debuggerUp)
		{
			_debugger.perf.flixelUpdate(Lib.getTimer() - mark);
		}
	}
	
	/**
	 * Goes through the game state and draws all the game objects and special effects.
	 */
	private function draw():Void
	{
		var mark:Int = Lib.getTimer();
		
		#if (cpp || neko)
		TileSheetManager.clearAllDrawData();
		#end
		
		FlxG.lockCameras();
		_state.draw();
		
		#if (cpp || neko)
		TileSheetManager.renderAll();
		#end
		
		FlxG.drawPlugins();
		FlxG.unlockCameras();
		if (_debuggerUp)
		{
			_debugger.perf.flixelDraw(Lib.getTimer() - mark);
		}
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
		removeEventListener(Event.ENTER_FRAME, create);
		_total = Lib.getTimer();
		//Set up the view window and double buffering
		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
		stage.frameRate = _flashFramerate;
		
		//Add basic input event listeners and mouse container
		#if flash
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		Lib.current.stage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		#else
		clickableArea = new Sprite();
		clickableArea.graphics.beginFill(0xff0000);
		clickableArea.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
		clickableArea.graphics.endFill();
		Lib.current.stage.addChild(clickableArea);
		clickableArea.alpha = 0;
		clickableArea.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		clickableArea.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		clickableArea.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
		#end
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		addChild(_mouse);
		
		//Let mobile devs opt out of unnecessary overlays.
		if(!FlxG.mobile)
		{
			//Debugger overlay
			if(FlxG.debug || forceDebugger)
			{
				_debugger = new FlxDebugger(FlxG.width * FlxCamera.defaultZoom, FlxG.height * FlxCamera.defaultZoom);
				#if flash
				addChild(_debugger);
				#else
				Lib.current.stage.addChild(_debugger);
				#end
			}
			
			//Volume display tab
			createSoundTray();
			
			//Focus gained/lost monitoring
			stage.addEventListener(Event.DEACTIVATE, onFocusLost);
			stage.addEventListener(Event.ACTIVATE, onFocus);
			createFocusScreen();
		}
		
		//Finally, set up an event for the actual game loop stuff.
		addEventListener(Event.ENTER_FRAME, onEnterFrame);
	}
	
	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	private function createSoundTray():Void
	{
		_soundTray.visible = false;
		_soundTray.scaleX = 2;
		_soundTray.scaleY = 2;
		#if !neko
		var tmp:Bitmap = new Bitmap(new BitmapData(80, 30, true, 0x7F000000));
		#else
		var tmp:Bitmap = new Bitmap(new BitmapData(80, 30, true, {rgb: 0x000000, a: 0x7F}));
		#end
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
		var dtf:TextFormat = new TextFormat(FlxAssets.nokiaFont, 8, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf; //new TextFormat("system",8,0xffffff,null,null,null,null,null,"center");
		_soundTray.addChild(text);
		text.text = "VOLUME";
		text.y = 16;
		
		var bx:Int = 10;
		var by:Int = 14;
		_soundTrayBars = new Array();
		var i:Int = 0;
		while(i < 10)
		{
			#if !neko
			tmp = new Bitmap(new BitmapData(4,++i, false, 0xffffff));
			#else
			tmp = new Bitmap(new BitmapData(4,++i, false, {rgb: 0xffffff, a: 0xff}));
			#end
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
		
		//load saved sound preferences for this game if they exist
		var soundPrefs:FlxSave = new FlxSave();
		if(soundPrefs.bind("flixel") && (soundPrefs.data.sound != null))
		{
			if (soundPrefs.data.sound.volume != null)
			{
				FlxG.volume = soundPrefs.data.sound.volume;
			}
			if (soundPrefs.data.sound.mute != null)
			{
				FlxG.mute = soundPrefs.data.sound.mute;
			}
			soundPrefs.destroy();
		}
	}
	
	/**
	 * Sets up the darkened overlay with the big white "play" button that appears when a flixel game loses focus.
	 */
	private function createFocusScreen():Void
	{
		var gfx:Graphics = _focus.graphics;
		var screenWidth:Int = Math.floor(FlxG.width * FlxCamera.defaultZoom);
		var screenHeight:Int = Math.floor(FlxG.height * FlxCamera.defaultZoom);
		
		//draw transparent black backdrop
		gfx.moveTo(0, 0);
		gfx.beginFill(0, 0.5);
		gfx.lineTo(screenWidth, 0);
		gfx.lineTo(screenWidth, screenHeight);
		gfx.lineTo(0, screenHeight);
		gfx.lineTo(0, 0);
		gfx.endFill();
		
		//draw white arrow
		var halfWidth:Int = Math.floor(screenWidth / 2);
		var halfHeight:Int = Math.floor(screenHeight / 2);
		var helper:Int = Math.floor(FlxU.min(halfWidth, halfHeight) / 3);
		gfx.moveTo(halfWidth - helper, halfHeight - helper);
		gfx.beginFill(0xffffff,0.65);
		gfx.lineTo(halfWidth + helper, halfHeight);
		gfx.lineTo(halfWidth - helper, halfHeight + helper);
		gfx.lineTo(halfWidth - helper, halfHeight - helper);
		gfx.endFill();
		
		var logo:Bitmap = new Bitmap(Assets.getBitmapData(FlxAssets.imgLogo));
		logo.scaleX = Math.floor(helper/10);
		if (logo.scaleX < 1)
		{
			logo.scaleX = 1;
		}
		logo.scaleY = logo.scaleX;
		logo.x -= logo.scaleX;
		logo.alpha = 0.35;
		_focus.addChild(logo);
		
		addChild(_focus);
	}
	
	public var debugger(getDebugger, null):FlxDebugger;
	
	public function getDebugger():FlxDebugger
	{
		return _debugger;
	}
	
}