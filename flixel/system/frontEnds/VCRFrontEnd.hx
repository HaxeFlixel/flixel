package flixel.system.frontEnds;

import flash.events.Event;
import flixel.FlxG;
import flixel.FlxState;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.ui.Mouse;
import flash.utils.ByteArray;
import flash.net.FileReference;
import flash.net.FileFilter;

class VCRFrontEnd
{
	/**
	 * Just needed to create an instance.
	 */
	public function new() { }

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		#if (flash && FLX_RECORD)
		_file = null;
		#end
	}

	#if FLX_RECORD
	/**
	 * This function, if set, is triggered when the callback stops playing.
	 */
	public var replayCallback:Void->Void = null;
	/**
	 * The key codes used to toggle the debugger (via <code>flash.ui.Keyboard</code>). 
	 * "0" means "any key". Handy for skipping cutscenes or getting out of attract modes!
	 */
	public var cancelKeys:Array<String> = null;
	/**
	 * Helps time out a replay if necessary.
	 */
	public var timeout:Int = 0;

	#if flash
	static private var FILE_TYPES:Array<FileFilter> = [new FileFilter("Flixel Game Recording", "*.fgr")];

	static private inline var DEFAULT_FILE_NAME:String = "replay.fgr";

	private var _file:FileReference = null;
	#end

	#end

	/**
	 * Whether the debugger has been paused.
	 */
	public var paused:Bool = false;
	/**
	 * Whether a "1 frame step forward" was requested.
	 */
	public var stepRequested:Bool = false;

	/**
	* Pause the main game loop
	**/
	public function pause():Void
	{
		if(!paused)
		{
			#if !FLX_NO_MOUSE
			if (!FlxG.mouse.useSystemCursor)
				Mouse.show();
			#end

			paused = true;

			#if !FLX_NO_DEBUG
			FlxG.game.debugger.vcr.onPause();
			#end
		}
	}

	/**
	* Resume the main game loop from FlxG.vcr.pause();
	**/
	public function resume():Void
	{
		if(paused)
		{
			#if !FLX_NO_MOUSE
			if (!FlxG.mouse.useSystemCursor)
				Mouse.hide();
			#end

			paused = false;

			#if !FLX_NO_DEBUG
			FlxG.game.debugger.vcr.onResume();
			#end
		}
	}

	#if FLX_RECORD

	/**
	 * Called when the user presses the Rewind-looking button.
	 * If Alt is pressed, the entire game is reset.
	 * If Alt is NOT pressed, only the current state is reset.
	 * The GUI is updated accordingly.
	 * @param	StandardMode	Whether to reset the current game (== true), or just the current state.  Just resetting the current state can be very handy for debugging.
	 */
	public function restartReplay(StandardMode:Bool = false):Void
	{
		FlxG.vcr.reloadReplay(StandardMode);
		// TODO: Fix this. I don't know where is the problem
	}

	/**
	 * Load replay data from a string and play it back.
	 * 
	 * @param	Data		The replay that you want to load.
	 * @param	State		Optional parameter: if you recorded a state-specific demo or cutscene, pass a new instance of that state here.
	 * @param	CancelKeys	Optional parameter: an array of string names of keys (see FlxKeyboard) that can be pressed to cancel the playback, e.g. ["ESCAPE","ENTER"].  Also accepts 2 custom key names: "ANY" and "MOUSE" (fairly self-explanatory I hope!).
	 * @param	Timeout		Optional parameter: set a time limit for the replay. CancelKeys will override this if pressed.
	 * @param	Callback	Optional parameter: if set, called when the replay finishes. Running to the end, CancelKeys, and Timeout will all trigger Callback(), but only once, and CancelKeys and Timeout will NOT call FlxG.stopReplay() if Callback is set!
	 */
	public function loadReplay(Data:String, ?State:FlxState, ?CancelKeys:Array<String>, ?Timeout:Float = 0, ?Callback:Void->Void):Void
	{
		FlxG.game.replay.load(Data);
		
		if (State == null)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.switchState(State);
		}
		
		cancelKeys = CancelKeys;
		timeout = Std.int(Timeout * 1000);
		replayCallback = Callback;
		FlxG.game.replayRequested = true;

		#if !FLX_NO_KEYBOARD
		FlxG.keyboard.enabled = false;
		#end

		#if !FLX_NO_DEBUG
		FlxG.game.debugger.vcr.runtime = 0;
		FlxG.game.debugger.vcr.playingReplay();
		#end
	}

	/**
	 * Resets the game or state and replay requested flag.
	 * 
	 * @param	StandardMode	If true, reload entire game, else just reload current game state.
	 */
	public function reloadReplay(StandardMode:Bool = true):Void
	{
		if (StandardMode)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.resetState();
		}
		
		if (FlxG.game.replay.frameCount > 0)
		{
			FlxG.game.replayRequested = true;
		}
	}
	
	/**
	 * Stops the current replay.
	 */
	inline public function stopReplay():Void
	{
		FlxG.game.replaying = false;
		FlxG.inputs.reset();
		
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.vcr.stoppedReplay();
		#end
		
		#if !FLX_NO_KEYBOARD
		FlxG.keyboard.enabled = true;
		#end
	}
		
	/**
	 * Resets the game or state and requests a new recording.
	 * 
	 * @param	StandardMode	If true, reset the entire game, else just reset the current state.
	 */
	public function startRecording(StandardMode:Bool = true):Void
	{
		if (StandardMode)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.resetState();
		}

		FlxG.game.recordingRequested = true;
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.vcr.recording();
		#end
	}
	
	/**
	 * Stop recording the current replay and return the replay data.
	 * 
	 * @return	The replay data in simple ASCII format (see <code>FlxReplay.save()</code>).
	 */
	inline public function stopRecording():String
	{
		FlxG.game.recording = false;

		#if !FLX_NO_DEBUG
		FlxG.game.debugger.vcr.stoppedRecording();
		#end

		var data:String = FlxG.game.replay.save();

		FlxG.game.debugger.vcr.stoppedReplay();
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
		return data;
	}

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
			FlxG.log.error("Empty flixel gameplay record.");
			return;
		}

		FlxG.vcr.loadReplay(fileContents);
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
		FlxG.log.error("Unable to open flixel gameplay record.");
		#end
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
		FlxG.log.notice("Successfully saved flixel gameplay record.");
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
		FlxG.log.error("Problem saving flixel gameplay record.");
		#end
	}
	#end
}