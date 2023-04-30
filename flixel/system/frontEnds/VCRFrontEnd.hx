package flixel.system.frontEnds;

import flash.ui.Mouse;
import flixel.FlxG;
#if FLX_RECORD
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.utils.ByteArray;
import flixel.FlxState;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxRandom;
#if flash
import flash.net.FileReference;
import flash.net.FileFilter;
#end
#end

/**
 * Accessed via `FlxG.vcr`.
 */
class VCRFrontEnd
{
	#if FLX_RECORD
	#if flash
	static var FILE_TYPES:Array<FileFilter> = [new FileFilter("Flixel Game Recording", "*.fgr")];

	static inline var DEFAULT_FILE_NAME:String = "replay.fgr";
	#end

	/**
	 * This function, if set, is triggered when the callback stops playing.
	 */
	public var replayCallback:Void->Void;

	/**
	 * The keys used to toggle the debugger. "MOUSE" to cancel with the mouse.
	 * Handy for skipping cutscenes or getting out of attract modes!
	 */
	public var cancelKeys:Array<FlxKey>;

	/**
	 * Helps time out a replay if necessary.
	 */
	public var timeout:Float = 0;

	#if flash
	var _file:FileReference;
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
		if (!paused)
		{
			#if FLX_MOUSE
			if (!FlxG.mouse.useSystemCursor)
				Mouse.show();
			#end

			paused = true;

			#if FLX_DEBUG
			FlxG.game.debugger.vcr.onPause();
			#end
		}
	}

	/**
	 * Resume the main game loop from FlxG.vcr.pause();
	**/
	public function resume():Void
	{
		if (paused)
		{
			#if FLX_MOUSE
			if (!FlxG.mouse.useSystemCursor)
				Mouse.hide();
			#end

			paused = false;

			#if FLX_DEBUG
			FlxG.game.debugger.vcr.onResume();
			#end
		}
	}

	#if FLX_RECORD
	/**
	 * Called when the user presses the Rewind-looking button. If Alt is pressed, the entire game is reset.
	 * If Alt is NOT pressed, only the current state is reset. The GUI is updated accordingly.
	 *
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
	public function loadReplay(Data:String, ?State:FlxState, ?CancelKeys:Array<FlxKey>, ?Timeout:Float = 0, ?Callback:Void->Void):Void
	{
		FlxG.game._replay.load(Data);

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
		FlxG.game._replayRequested = true;

		#if FLX_KEYBOARD
		FlxG.keys.enabled = false;
		#end

		#if FLX_MOUSE
		FlxG.mouse.enabled = false;
		#end

		#if FLX_DEBUG
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

		if (FlxG.game._replay.frameCount > 0)
		{
			FlxG.game._replayRequested = true;
		}
	}

	/**
	 * Stops the current replay.
	 */
	public inline function stopReplay():Void
	{
		FlxG.game.replaying = false;
		FlxG.inputs.reset();

		#if FLX_DEBUG
		FlxG.game.debugger.vcr.stoppedReplay();
		#end

		#if FLX_KEYBOARD
		FlxG.keys.enabled = true;
		#end

		#if FLX_MOUSE
		FlxG.mouse.enabled = true;
		#end
	}

	public function cancelReplay():Void
	{
		if (replayCallback != null)
		{
			replayCallback();
			replayCallback = null;
		}
		else
		{
			stopReplay();
		}
	}

	/**
	 * Resets the game or state and requests a new recording.
	 *
	 * @param	StandardMode	If true, reset the entire game, else just reset the current state.
	 */
	public function startRecording(StandardMode:Bool = true):Void
	{
		FlxRandom.updateRecordingSeed(StandardMode);

		if (StandardMode)
		{
			FlxG.resetGame();
		}
		else
		{
			FlxG.resetState();
		}

		FlxG.game._recordingRequested = true;
		#if FLX_DEBUG
		FlxG.game.debugger.vcr.recording();
		#end
	}

	/**
	 * Stop recording the current replay and return the replay data.
	 *
	 * @param	OpenSaveDialog	If true, and targeting flash, open an OS-native save dialog for the user to choose where to save the data, and save it there.
	 *
	 * @return	The replay data in simple ASCII format (see FlxReplay.save()).
	 */
	public inline function stopRecording(OpenSaveDialog:Bool = true):String
	{
		FlxG.game.recording = false;

		#if FLX_DEBUG
		FlxG.game.debugger.vcr.stoppedRecording();
		FlxG.game.debugger.vcr.stoppedReplay();
		#end

		var data:String = FlxG.game._replay.save();

		if (OpenSaveDialog && (data != null) && (data.length > 0))
		{
			#if flash
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
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
	 * Clean up memory.
	 */
	function destroy():Void
	{
		#if FLX_RECORD
		cancelKeys = null;
		#if flash
		_file = null;
		#end
		#end
	}

	/**
	 * Called when a file is picked from the file dialog.
	 * Attempts to load the file and registers file loading event handlers.
	 */
	function onOpenSelect(_):Void
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
	 */
	function onOpenComplete(_):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onOpenComplete);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onOpenError);

		// Turn the file into a giant string
		var fileContents:String = null;
		var data:ByteArray = _file.data;
		if (data != null)
		{
			fileContents = data.readUTFBytes(data.bytesAvailable);
		}
		_file = null;
		if ((fileContents == null) || (fileContents.length <= 0))
		{
			FlxG.log.error("Empty flixel gameplay record.");
			return;
		}

		FlxG.vcr.loadReplay(fileContents);
		#end
	}

	/**
	 * Called if the open file dialog is canceled.
	 */
	function onOpenCancel(_):Void
	{
		#if flash
		_file.removeEventListener(Event.SELECT, onOpenSelect);
		_file.removeEventListener(Event.CANCEL, onOpenCancel);
		_file = null;
		#end
	}

	/**
	 * Called if there is a file open error.
	 */
	function onOpenError(_):Void
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
	 */
	function onSaveComplete(_):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved flixel gameplay record.");
		#end
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		#end
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		#if flash
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving flixel gameplay record.");
		#end
	}
	#end

	@:allow(flixel.FlxG)
	function new() {}
}
