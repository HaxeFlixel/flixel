package flixel.plugin.photonstorm;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.Lib;
import flixel.FlxG;
import flixel.util.FlxMisc;

/**
 * A useful timer that can be used to trigger events after certain amounts of time are up.
 * Uses getTimer so is low on resources and avoids using Flash events.
 * Also takes into consideration the Pause state of your game.
 * If your game pauses, when it starts again the timer notices and adjusts the expires time accordingly.
 * 
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxDelay extends Sprite
{
	/**
	 * True if the timer is currently running, otherwise false
	 */
	public var isRunning:Bool;
	/**
	 * If you wish to call a function once the timer completes, set it here
	 */
	public var callbackFunction:Void->Void;
	/**
	 * The duration of the Delay in milliseconds
	 */
	public var duration:Int;
	
	private var _started:Int;
	private var _expires:Int = 0;
	private var _pauseStarted:Int;
	private var _pausedTimerRunning:Bool;
	private var _complete:Bool = false;
	
	/**
	 * Create a new timer which will run for the given amount of ms (1000 = 1 second real time)
	 * 
	 * @param	RunFor	The duration of this timer in ms. Call start() to set it going.
	 */
	public function new(RunFor:Int)
	{
		super();
		
		duration = RunFor;
	}
	
	/**
	 * Starts the timer running
	 */
	public function start():Void
	{
		_started = FlxMisc.getTicks();
		_expires = _started + duration;
		
		isRunning = true;
		_complete = false;
		
		_pauseStarted = 0;
		_pausedTimerRunning = false;
		
		#if flash
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		#else
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
		#end
	}
	
	/**
	 * Has the timer finished?
	 */
	public var hasExpired(get, never):Bool;
	
	private function get_hasExpired():Bool
	{
		return _complete;
	}
	
	/**
	 * Restart the timer using the new duration
	 * 
	 * @param	NewDuration	The duration of this timer in ms.
	 */
	public function reset(NewDuration:Int):Void
	{
		duration = NewDuration;
		
		start();
	}
	
	/**
	 * The amount of seconds that have elapsed since the timer was started
	 */
	public var secondsElapsed(get, never):Int;
	
	private function get_secondsElapsed():Int
	{
		return Std.int((FlxMisc.getTicks() - _started) / 1000);
	}
	
	/**
	 * The amount of seconds that are remaining until the timer completes
	 */
	public var secondsRemaining(get, never):Int;
	
	private function get_secondsRemaining():Int
	{
		return Std.int((_expires - FlxMisc.getTicks()) / 1000);
	}
	
	private function update(E:Event):Void
	{
		//	Has the game been paused?
		if (_pausedTimerRunning == true && FlxG.paused == false)
		{
			_pausedTimerRunning = false;
			
			//	Add the time the game was paused for onto the expires timer
			_expires += (FlxMisc.getTicks() - _pauseStarted);
		}
		else if (FlxG.paused == true && _pausedTimerRunning == false)
		{
			_pauseStarted = FlxMisc.getTicks();
			_pausedTimerRunning = true;
		}
		
		if (isRunning == true && _pausedTimerRunning == false && FlxMisc.getTicks() > _expires)
		{
			stop();
		}
	}
	
	/**
	 * Abors a currently active timer without firing any callbacks (if set)
	 */
	public function abort():Void
	{
		stop(false);
	}
	
	private function stop(RunCallback:Bool = true):Void
	{
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
		
		isRunning = false;
		_complete = true;
		
		if (callbackFunction != null && RunCallback == true)
		{
			callbackFunction();
		}
	}
}