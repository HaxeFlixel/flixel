package flixel.system.frontEnds;

import flixel.FlxG;

class VCRFrontEnd
{
	/**
	 * Just needed to create an instance.
	 */
	public function new() { }
	
	#if (FLX_RECORD && !FLX_VARIABLE_TIMESTEP)
	/**
	 * Load replay data from a string and play it back.
	 * 
	 * @param	Data		The replay that you want to load.
	 * @param	State		Optional parameter: if you recorded a state-specific demo or cutscene, pass a new instance of that state here.
	 * @param	CancelKeys	Optional parameter: an array of string names of keys (see FlxKeyboard) that can be pressed to cancel the playback, e.g. ["ESCAPE","ENTER"].  Also accepts 2 custom key names: "ANY" and "MOUSE" (fairly self-explanatory I hope!).
	 * @param	Timeout		Optional parameter: set a time limit for the replay.  CancelKeys will override this if pressed.
	 * @param	Callback	Optional parameter: if set, called when the replay finishes.  Running to the end, CancelKeys, and Timeout will all trigger Callback(), but only once, and CancelKeys and Timeout will NOT call FlxG.stopReplay() if Callback is set!
	 */
	public function loadReplay(Data:String, State:FlxState = null, CancelKeys:Array<String> = null, Timeout:Float = 0, Callback:Void->Void = null):Void
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
		FlxG.game.replayCancelKeys = CancelKeys;
		FlxG.game.replayTimer = Std.int(Timeout * 1000);
		FlxG.game.replayCallback = Callback;
		FlxG.game.replayRequested = true;
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
	public function stopReplay():Void
	{
		FlxG.game.replaying = false;
		
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger != null)
		{
			FlxG.game.debugger.vcr.stopped();
		}
		#end
		
		FlxG.resetInput();
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
	}
	
	/**
	 * Stop recording the current replay and return the replay data.
	 * 
	 * @return	The replay data in simple ASCII format (see <code>FlxReplay.save()</code>).
	 */
	public function stopRecording():String
	{
		FlxG.game.recording = false;
		
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger != null)
		{
			FlxG.game.debugger.vcr.stopped();
		}
		#end
		
		return FlxG.game.replay.save();
	}
	#end
}