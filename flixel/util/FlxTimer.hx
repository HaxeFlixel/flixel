package flixel.util;

import flixel.FlxG;
import flixel.plugin.TimerManager;
import flixel.interfaces.IFlxDestroyable;
import flixel.system.frontEnds.PluginFrontEnd;

/**
 * A simple timer class, leveraging the new plugins system.
 * Can be used with callbacks or by polling the finished flag.
 * Not intended to be added to a game state or group; the timer manager
 * is responsible for actually calling update(), not the user.
 */
class FlxTimer implements IFlxDestroyable
{
	public static var manager:TimerManager;
	
	/**
	 * How much time the timer was set for.
	 */
	public var time:Float = 0;
	/**
	 * How many loops the timer was set for. 0 means "looping forever".
	 */
	public var loops:Int = 0;
	/**
	 * Pauses or checks the pause state of the timer.
	 */
	public var active:Bool = true;
	/**
	 * Check to see if the timer is finished.
	 */
	public var finished:Bool = false;
	/**
	 * Function that gets called when timer completes.
	 * Callback should be formed "onTimer(Timer:FlxTimer);"
	 */
	public var complete:FlxTimer->Void;
	/**
	 * Read-only: check how much time is left on the timer.
	 */
	public var timeLeft(get, never):Float;
	/**
	 * Read-only: The amount of milliseconds that have elapsed since the timer was started
	 */
	public var elapsedTime(get, never):Float;
	/**
	 * Read-only: check how many loops are left on the timer.
	 */
	public var loopsLeft(get, never):Int;
	/**
	 * Read-only: how many loops that have elapsed since the timer was started.
	 */
	public var elapsedLoops(get, never):Int;
	/**
	 * Read-only: how far along the timer is, on a scale of 0.0 to 1.0.
	 */
	public var progress(get, never):Float;
	
	/**
	 * Internal tracker for the actual timer counting up.
	 */
	private var _timeCounter:Float = 0;
	/**
	 * Internal tracker for the loops counting up.
	 */
	private var _loopsCounter:Int = 0;
	
	private var _inManager:Bool = false;
	
	/**
	 * Creates a new timer (and calls start() right away if Time != null).
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off. 0 means "looping forever".
	 */
	public function new(?Time:Null<Float>, ?Callback:FlxTimer->Void, Loops:Int = 1)
	{
		if (Time != null)
		{
			start(Time, Callback, Loops);
		}
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		complete = null;
	}
	
	/**
	 * Starts the timer and adds the timer to the timer manager.
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off. 0 means "looping forever".
	 * @return	A reference to itself (handy for chaining or whatever).
	 */
	public function start(Time:Float = 1, ?Callback:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		if (manager != null && !_inManager)
		{
			manager.add(this);
			_inManager = true;
		}
		
		active = true;
		finished = false;
		time = Math.abs(Time);
		
		if (Loops < 0) 
		{
			Loops *= -1;
		}
		
		loops = Loops;
		complete = Callback;
		_timeCounter = 0;
		_loopsCounter = 0;
		return this;
	}
	
	/**
	 * Restart the timer using the new duration
	 * @param	NewDuration	The duration of this timer in ms.
	 */
	public function reset(NewTime:Float = -1):FlxTimer
	{
		if (NewTime < 0)
		{
			NewTime = time;
		}
		start(NewTime, complete, loops);
		return this;
	}
	
	/**
	 * Stops the timer and removes it from the timer manager.
	 */
	public function cancel():Void
	{
		finished = true;
		if (manager != null && _inManager)
		{
			manager.remove(this);
			_inManager = false;
		}
	}
	
	/**
	 * Called by the timer manager plugin to update the timer.
	 * If time runs out, the loop counter is advanced, the timer reset, and the callback called if it exists.
	 * If the timer runs out of loops, then the timer calls cancel().
	 * However, callbacks are called AFTER cancel() is called.
	 */
	public function update():Void
	{
		_timeCounter += FlxG.elapsed;
		
		while ((_timeCounter >= time) && active && !finished)
		{
			_timeCounter -= time;
			_loopsCounter++;
			
			if (complete != null)
			{
				complete(this);
			}
			
			if (loops > 0 && (_loopsCounter >= loops))
			{
				cancel();
			}
		}
	}
	
	private inline function get_timeLeft():Float
	{
		return time - _timeCounter;
	}
	
	private inline function get_elapsedTime():Float
	{
		return _timeCounter;
	}
	
	private inline function get_loopsLeft():Int
	{
		return loops - _loopsCounter;
	}
	
	private inline function get_elapsedLoops():Int
	{
		return _loopsCounter;
	}
	
	private inline function get_progress():Float
	{
		return (time > 0) ? (_timeCounter / time) : 0;
	}
}