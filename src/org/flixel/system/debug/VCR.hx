package org.flixel.system.debug;

import nme.Assets;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Sprite;
import nme.events.Event;
import nme.events.IOErrorEvent;
import nme.events.MouseEvent;
#if !FLX_NO_MOUSE
import nme.ui.Mouse;
#end

import org.flixel.FlxAssets;
#if flash
import flash.net.FileFilter;
import flash.net.FileReference;
#end
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.utils.ByteArray;

import org.flixel.FlxG;
import org.flixel.FlxU;
import org.flixel.system.FlxReplay;
import org.flixel.system.replay.FrameRecord;
import org.flixel.system.replay.MouseRecord;

/**
 * This class contains the record, stop, play, and step 1 frame buttons seen on the top edge of the debugger overlay.
 */
class VCR extends Sprite
{
	#if flash
	static private inline var FILE_TYPES:Array<FileFilter> = [new FileFilter("Flixel Game Recording", "*.fgr")];
	#end
	static private inline var DEFAULT_FILE_NAME:String = "replay.fgr";
	
	/**
	 * Whether the debugger has been paused. 
	 */
	public var paused:Bool;
	/**
	 * Whether a "1 frame step forward" was requested.
	 */
	public var stepRequested:Bool;
	
	private var _open:Bitmap;
	private var _recordOff:Bitmap;
	private var _recordOn:Bitmap;
	private var _stop:Bitmap;
	private var _flixel:Bitmap;
	private var _restart:Bitmap;
	private var _pause:Bitmap;
	private var _play:Bitmap;
	private var _step:Bitmap;
	
	private var _overOpen:Bool;
	private var _overRecord:Bool;
	private var _overRestart:Bool;
	private var _overPause:Bool;
	private var _overStep:Bool;
	
	private var _pressingOpen:Bool;
	private var _pressingRecord:Bool;
	private var _pressingRestart:Bool;
	private var _pressingPause:Bool;
	private var _pressingStep:Bool;
	
	#if flash
	private var _file:FileReference;
	#end
	
	private var _runtimeDisplay:TextField;
	
	private var _runtime:Int;
	
	
	/**
	 * Creates the "VCR" control panel for debugger pausing, stepping, and recording.
	 */
	public function new()
	{
		super();
		
		var spacing:Int = 7;
		
		_open = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgOpen));
		addChild(_open);
		
		_recordOff = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgRecordOff));
		_recordOff.x = _open.x + _open.width + spacing;
		addChild(_recordOff);
		
		_recordOn = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgRecordOn));
		_recordOn.x = _recordOff.x;
		_recordOn.visible = false;
		addChild(_recordOn);
		
		#if FLX_NO_RECORD
		_open.visible = false;
		_recordOff.visible = false;
		_recordOn.visible = false;
		#end
		
		_stop = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgStop));
		_stop.x = _recordOff.x;
		_stop.visible = false;
		addChild(_stop);
		
		_flixel = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgFlixel));
		_flixel.x = _recordOff.x + _recordOff.width + spacing;
		addChild(_flixel);
		
		_restart = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgRestart));
		_restart.x = _flixel.x + _flixel.width + spacing;
		addChild(_restart);
		
		_pause = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgPause));
		_pause.x = _restart.x + _restart.width + spacing;
		addChild(_pause);
		
		_play = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgPlay));
		_play.x = _pause.x;
		_play.visible = false;
		addChild(_play);
		
		_step = new Bitmap(FlxAssets.getBitmapData(FlxAssets.imgStep));
		_step.x = _pause.x + _pause.width + spacing;
		addChild(_step);
		
		_runtimeDisplay = new TextField();
		_runtimeDisplay.width = width;
		_runtimeDisplay.x = width;
		_runtimeDisplay.y = -2;
		_runtimeDisplay.multiline = false;
		_runtimeDisplay.wordWrap = false;
		_runtimeDisplay.selectable = false;
		var dtf:TextFormat = new TextFormat(Assets.getFont(FlxAssets.debuggerFont).fontName, 12, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		//_runtimeDisplay.defaultTextFormat = new TextFormat("Courier", 12, 0xffffff, null, null, null, null, null, "center");
		_runtimeDisplay.defaultTextFormat = dtf;
		_runtimeDisplay.visible = false;
		addChild(_runtimeDisplay);
		_runtime = 0;
		
		stepRequested = false;
		#if flash
		_file = null;
		#end
		
		unpress();
		checkOver();
		updateGUI();
		
		addEventListener(Event.ENTER_FRAME, init);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		#if flash
		_file = null;
		#end
		
		removeChild(_open);
		_open = null;
		removeChild(_recordOff);
		_recordOff = null;
		removeChild(_recordOn);
		_recordOn = null;
		removeChild(_stop);
		_stop = null;
		removeChild(_flixel);
		_flixel = null;
		removeChild(_restart);
		_restart = null;
		removeChild(_pause);
		_pause = null;
		removeChild(_play);
		_play = null;
		removeChild(_step);
		_step = null;
		
		parent.removeEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		parent.removeEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		parent.removeEventListener(MouseEvent.MOUSE_UP,onMouseUp);
	}
	
	/**
	 * Usually called by FlxGame when a requested recording has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function recording():Void
	{
		_stop.visible = false;
		_recordOff.visible = false;
		_recordOn.visible = true;
	}
	
	/**
	 * Usually called by FlxGame when a replay has been stopped.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function stopped():Void
	{
		_stop.visible = false;
		_recordOn.visible = false;
		_recordOff.visible = true;
	}
	
	/**
	 * Usually called by FlxGame when a requested replay has begun.
	 * Just updates the VCR GUI so the buttons are in the right state.
	 */
	public function playing():Void
	{
		_recordOff.visible = false;
		_recordOn.visible = false;
		_stop.visible = true;
	}
	
	/**
	 * Just updates the VCR GUI so the runtime displays roughly the right thing.
	 */
	public function updateRuntime(Time:Int):Void
	{
		_runtime += Time;
		_runtimeDisplay.text = FlxU.formatTime(Std.int(_runtime / 1000), true);
		if (!_runtimeDisplay.visible)
		{
			_runtimeDisplay.visible = true;
		}
	}
	
	#if !FLX_NO_RECORD
	//*** ACTUAL BUTTON BEHAVIORS ***//
	
	/**
	 * Called when the "open file" button is pressed.
	 * Opens the file dialog and registers event handlers for the file dialog.
	 */
	public function onOpen():Void
	{
		#if flash
		_file = new FileReference();
		_file.addEventListener(Event.SELECT, onOpenSelect);
		_file.addEventListener(Event.CANCEL, onOpenCancel);
		_file.browse(FILE_TYPES);
		#end
	}
	
	/**
	 * Called when a file is picked from the file dialog.
	 * Attempts to load the file and registers file loading event handlers.
	 * @param	E	Flash event.
	 */
	private function onOpenSelect(E:Event = null):Void
	{
		#if flash
		_file.removeEventListener(Event.SELECT, onOpenSelect);
		_file.removeEventListener(Event.CANCEL, onOpenCancel);
		
		_file.addEventListener(Event.COMPLETE, onOpenComplete);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onOpenError);
		_file.load();
		#end
	}
	
	/**
	 * Called when a file is opened successfully.
	 * If there's stuff inside, then the contents are loaded into a new replay.
	 * @param	E	Flash Event.
	 */
	private function onOpenComplete(E:Event = null):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onOpenComplete);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);
		
		//Turn the file into a giant string
		var fileContents:String = null;
		var data:ByteArray = _file.data;
		if (data != null)
		{
			fileContents = data.readUTFBytes(data.bytesAvailable);
		}
		_file = null;
		if((fileContents == null) || (fileContents.length <= 0))
		{
			FlxG.log("ERROR: Empty flixel gameplay record.");
			return;
		}
		
		FlxG.loadReplay(fileContents);
		#end
	}
	
	/**
	 * Called if the open file dialog is canceled.
	 * @param	E	Flash Event.
	 */
	private function onOpenCancel(E:Event = null):Void
	{
		#if flash
		_file.removeEventListener(Event.SELECT, onOpenSelect);
		_file.removeEventListener(Event.CANCEL, onOpenCancel);
		_file = null;
		#end
	}
	
	/**
	 * Called if there is a file open error.
	 * @param	E	Flash Event.
	 */
	private function onOpenError(E:Event=null):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onOpenComplete);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);
		_file = null;
		FlxG.log("ERROR: Unable to open flixel gameplay record.");
		#end
	}
	
	/**
	 * Called when the user presses the white record button.
	 * If Alt is pressed, the current state is reset, and a new recording is requested.
	 * If Alt is NOT pressed, the game is reset, and a new recording is requested.
	 * @param	StandardMode	Whether to reset the whole game, or just this <code>FlxState</code>.  StandardMode == false is useful for recording demos or attract modes.
	 */
	public function onRecord(StandardMode:Bool = false):Void
	{
		if (_play.visible)
		{
			onPlay();
		}
		FlxG.recordReplay(StandardMode);
	}
	
	/**
	 * Called when the user presses the red record button.
	 * Stops the current recording, opens the save file dialog, and registers event handlers.
	 */
	public function stopRecording():Void
	{
		#if !FLX_NO_RECORD
		var data:String = FlxG.stopRecording();
		#end
	
		if((data != null) && (data.length > 0))
		{
			#if flash
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL,onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data, DEFAULT_FILE_NAME);
			#end
		}
	}
	
	/**
	 * Called when the file is saved successfully.
	 * @param	E	Flash Event.
	 */
	private function onSaveComplete(E:Event = null):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL,onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log("FLIXEL: successfully saved flixel gameplay record.");
		#end
	}
	
	/**
	 * Called when the save file dialog is cancelled.
	 * @param	E	Flash Event.
	 */
	private function onSaveCancel(E:Event = null):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL,onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		#end
	}
	
	/**
	 * Called if there is an error while saving the gameplay recording.
	 * @param	E	Flash Event.
	 */
	private function onSaveError(E:Event = null):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL,onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log("ERROR: problem saving flixel gameplay record.");
		#end
	}
	
	/**
	 * Called when the user presses the stop button.
	 * Stops the current replay.
	 */
	public function onStop():Void
	{
		FlxG.stopReplay();
	}
	#end
	
	/**
	 * Called when the user presses the Rewind-looking button.
	 * If Alt is pressed, the entire game is reset.
	 * If Alt is NOT pressed, only the current state is reset.
	 * The GUI is updated accordingly.
	 * @param	StandardMode	Whether to reset the current game (== true), or just the current state.  Just resetting the current state can be very handy for debugging.
	 */
	public function onRestart(StandardMode:Bool = false):Void
	{
		FlxG.reloadReplay(StandardMode);
		// TODO: Fix this. I don't know where is the problem
		/*
		if(FlxG.reloadReplay(StandardMode))
		{
			_recordOff.visible = false;
			_recordOn.visible = false;
			_stop.visible = true;
		}
		*/
	}
	
	/**
	 * Called when the user presses the Pause button.
	 * This is different from user-defined pause behavior, or focus lost behavior.
	 * Does NOT pause music playback!!
	 */
	public function onPause():Void
	{
		#if !FLX_NO_MOUSE
		if (!FlxG.mouse.useSystemCursor)
			Mouse.show();
		#end
		
		paused = true;
		_pause.visible = false;
		_play.visible = true;
	}
	
	/**
	 * Called when the user presses the Play button.
	 * This is different from user-defined unpause behavior, or focus gained behavior.
	 */
	public function onPlay():Void
	{
		#if !FLX_NO_MOUSE
		if (!FlxG.mouse.useSystemCursor)
			Mouse.hide();
		#end
	
		paused = false;
		_play.visible = false;
		_pause.visible = true;
	}
	
	/**
	 * Called when the user presses the fast-forward-looking button.
	 * Requests a 1-frame step forward in the game loop.
	 */
	public function onStep():Void
	{
		if (!paused)
		{
			onPause();
		}
		stepRequested = true;
	}
	
	//***EVENT HANDLERS***//
	
	/**
	 * Just sets up basic mouse listeners, a la FlxWindow.
	 * @param	E	Flash event.
	 */
	private function init(E:Event = null):Void
	{
		#if flash
		if (root == null)
		#else
		if (stage == null)
		#end
		{
			return;
		}
		removeEventListener(Event.ENTER_FRAME, init);

		parent.addEventListener(MouseEvent.MOUSE_MOVE,onMouseMove);
		parent.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
		parent.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
	}
	
	/**
	 * If the mouse moves, check to see if any buttons should be highlighted.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseMove(E:MouseEvent = null):Void
	{
		if (!checkOver())
		{
			unpress();
		}
		updateGUI();
	}
	
	/**
	 * If the mouse is pressed down, check to see if the user started pressing down a specific button.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseDown(E:MouseEvent = null):Void
	{
		unpress();
		if (_overOpen)
		{
			_pressingOpen = true;
		}
		if (_overRecord)
		{
			_pressingRecord = true;
		}
		if (_overRestart)
		{
			_pressingRestart = true;
		}
		if (_overPause)
		{
			_pressingPause = true;
		}
		if (_overStep)
		{
			_pressingStep = true;
		}
	}
	
	/**
	 * If the mouse is released, check to see if it was released over a button that was pressed.
	 * If it was, take the appropriate action based on button state and visibility.
	 * @param	E	Flash mouse event.
	 */
	private function onMouseUp(E:MouseEvent = null):Void
	{
		#if !FLX_NO_RECORD
		if (_overOpen && _pressingOpen)
		{
			onOpen();
		}
		else if(_overRecord && _pressingRecord)
		{
			if (_stop.visible)
			{
				onStop();
			}
			else if (_recordOn.visible)
			{
				stopRecording();
			}
			else
			{
				onRecord(!E.altKey);
			}
		}
		else 
		#end
		if (_overRestart && _pressingRestart)
		{
			onRestart(!E.altKey);
		}
		else if(_overPause && _pressingPause)
		{
			if (_play.visible)
			{
				onPlay();
			}
			else
			{
				onPause();
			}
		}
		else if (_overStep && _pressingStep)
		{
			onStep();
		}
		
		unpress();
		checkOver();
		updateGUI();
	}
	
	//***MISC GUI MGMT STUFF***//
	
	/**
	 * This function checks to see what button the mouse is currently over.
	 * Has some special behavior based on whether a recording is happening or not.
	 * @return	Whether the mouse was over any buttons or not.
	 */
	private function checkOver():Bool
	{
		_overOpen = _overRecord = _overRestart = _overPause = _overStep = false;
		if ((mouseX < 0) || (mouseX > width) || (mouseY < 0) || (mouseY > 15))
		{
			return false;
		}
		if ((mouseX >= _recordOff.x) && (mouseX <= _recordOff.x + _recordOff.width))
		{
			_overRecord = true;
		}
		if(!_recordOn.visible && !_overRecord)
		{
			if ((mouseX >= _open.x) && (mouseX <= _open.x + _open.width))
			{
				_overOpen = true;
			}
			else if ((mouseX >= _restart.x) && (mouseX <= _restart.x + _restart.width))
			{
				_overRestart = true;
			}
			else if ((mouseX >= _pause.x) && (mouseX <= _pause.x + _pause.width))
			{
				_overPause = true;
			}
			else if ((mouseX >= _step.x) && (mouseX <= _step.x + _step.width))
			{
				_overStep = true;
			}
		}
		return true;
	}
	
	/**
	 * Sets all the pressed state variables for the buttons to false.
	 */
	private function unpress():Void
	{
		_pressingOpen = false;
		_pressingRecord = false;
		_pressingRestart = false;
		_pressingPause = false;
		_pressingStep = false;
	}
	
	/**
	 * Figures out what buttons to highlight based on the _overWhatever and _pressingWhatever variables.
	 */
	private function updateGUI():Void
	{
		if(_recordOn.visible)
		{
			_open.alpha = _restart.alpha = _pause.alpha = _step.alpha = 0.35;
			_recordOn.alpha = 1.0;
			return;
		}
		
		if (_overOpen && (_open.alpha != 1.0))
		{
			_open.alpha = 1.0;
		}
		else if (!_overOpen && (_open.alpha != 0.8))
		{
			_open.alpha = 0.8;
		}
		
		if (_overRecord && (_recordOff.alpha != 1.0))
		{
			_recordOff.alpha = _recordOn.alpha = _stop.alpha = 1.0;
		}
		else if (!_overRecord && (_recordOff.alpha != 0.8))
		{
			_recordOff.alpha = _recordOn.alpha = _stop.alpha = 0.8;
		}
		
		if (_overRestart && (_restart.alpha != 1.0))
		{
			_restart.alpha = 1.0;
		}
		else if (!_overRestart && (_restart.alpha != 0.8))
		{
			_restart.alpha = 0.8;
		}
		
		if (_overPause && (_pause.alpha != 1.0))
		{
			_pause.alpha = _play.alpha = 1.0;
		}
		else if (!_overPause && (_pause.alpha != 0.8))
		{
			_pause.alpha = _play.alpha = 0.8;
		}
		
		if (_overStep && (_step.alpha != 1.0))
		{
			_step.alpha = 1.0;
		}
		else if (!_overStep && (_step.alpha != 0.8))
		{
			_step.alpha = 0.8;
		}
	}
}