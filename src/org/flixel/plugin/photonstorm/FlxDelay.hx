/**
 * FlxDelay
 * -- Part of the Flixel Power Tools set
 * 
 * v1.4 Modified abort so it no longer runs the stop callback (thanks to Cambrian-Man)
 * v1.3 Added secondsElapsed and secondsRemaining and some more documentation
 * v1.2 Added callback support
 * v1.1 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.4 - July 31st 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import nme.display.Sprite;
import nme.events.Event;
import nme.events.EventDispatcher;
import org.flixel.FlxG;
import org.flixel.FlxU;

/**
 * A useful timer that can be used to trigger events after certain amounts of time are up.<br />
 * Uses getTimer so is low on resources and avoids using Flash events.<br />
 * Also takes into consideration the Pause state of your game.<br />
 * If your game pauses, when it starts again the timer notices and adjusts the expires time accordingly.
 */

class FlxDelay extends Sprite
{
	/**
	 * true if the timer is currently running, otherwise false
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
	
	private var started:Int;
	private var expires:Int;
	private var pauseStarted:Int;
	private var pausedTimerRunning:Bool;
	private var complete:Bool;
	
	/**
	 * Create a new timer which will run for the given amount of ms (1000 = 1 second real time)
	 * 
	 * @param	runFor	The duration of this timer in ms. Call start() to set it going.
	 */
	public function new(runFor:Int)
	{
		super();
		
		expires = 0;
		duration = runFor;
		complete = false;
	}
	
	/**
	 * Starts the timer running
	 */
	public function start():Void
	{
		started = FlxU.getTicks();
		expires = started + duration;
		
		isRunning = true;
		complete = false;
		
		pauseStarted = 0;
		pausedTimerRunning = false;
		
		#if flash
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update, false, 0, true);
		#else
		Lib.current.stage.addEventListener(Event.ENTER_FRAME, update);
		#end
	}
	
	public var hasExpired(get_hasExpired, null):Bool;
	
	/**
	 * Has the timer finished?
	 */
	private function get_hasExpired():Bool
	{
		return complete;
	}
	
	/**
	 * Restart the timer using the new duration
	 * 
	 * @param	newDuration	The duration of this timer in ms.
	 */
	public function reset(newDuration:Int):Void
	{
		duration = newDuration;
		
		start();
	}
	
	public var secondsElapsed(get_secondsElapsed, null):Int;
	
	/**
	 * The amount of seconds that have elapsed since the timer was started
	 */
	private function get_secondsElapsed():Int
	{
		return Std.int((FlxU.getTicks() - started) / 1000);
	}
	
	public var secondsRemaining(get_secondsRemaining, null):Int;
	
	/**
	 * The amount of seconds that are remaining until the timer completes
	 */
	private function get_secondsRemaining():Int
	{
		return Std.int((expires - FlxU.getTicks()) / 1000);
	}
	
	private function update(event:Event):Void
	{
		//	Has the game been paused?
		if (pausedTimerRunning == true && FlxG.paused == false)
		{
			pausedTimerRunning = false;
			
			//	Add the time the game was paused for onto the expires timer
			expires += (FlxU.getTicks() - pauseStarted);
		}
		else if (FlxG.paused == true && pausedTimerRunning == false)
		{
			pauseStarted = FlxU.getTicks();
			pausedTimerRunning = true;
		}
		
		if (isRunning == true && pausedTimerRunning == false && FlxU.getTicks()) > expires)
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
	
	private function stop(runCallback:Bool = true):Void
	{
		Lib.current.stage.removeEventListener(Event.ENTER_FRAME, update);
		
		isRunning = false;
		complete = true;
		
		if (callbackFunction != null && runCallback == true)
		{
			callbackFunction();
		}
		
	}
	
}