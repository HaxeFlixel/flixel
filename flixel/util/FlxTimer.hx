package flixel.util;

import flixel.FlxG;
import flixel.plugin.TimerManager;
import flixel.interfaces.IFlxDestroyable;

/**
 * A simple timer class, leveraging the new plugins system.
 * Can be used with callbacks or by polling the finished flag.
 * Not intended to be added to a game state or group; the timer manager
 * is responsible for actually calling update(), not the user.
 */
class FlxTimer implements IFlxDestroyable
{
	/**
	 * The TimerManager instance.
	 */
	public static var manager:TimerManager;
	/**
	 * A pool that contains FlxTimers for recycling.
	 */
	public static var pool = new FlxPool<FlxTimer>(FlxTimer);
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
	public var paused:Bool = false;
	/**
	 * Check to see if the timer is finished.
	 */
	public var finished:Bool = false;
	/**
	 * Useful to store values you want to access within your callback function, ex:
	 * FlxTimer.start(1, function(t) { trace(t.userData); } ).userData = "Hello World!";
	 */
	public var userData:Dynamic = null;
	/**
	 * Function that gets called when timer completes.
	 * Callback should be formed "onTimer(Timer:FlxTimer);"
	 */
	public var complete:FlxTimer->Void = null;
	/**
	 * Internal tracker for the actual timer counting up.
	 */
	private var _timeCounter:Float = 0;
	/**
	 * Internal tracker for the loops counting up.
	 */
	private var _loopsCounter:Int = 0;
	
	/**
	 * Internal constructor.
	 * This is private, use recycle() or start() to get timers instead.
	 */
	private function new() { }
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		complete = null;
		userData = null;
	}
	
	/**
	 * Returns a recycled timer and starts it.
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off. 0 means "looping forever".
 	 */
	public static function start(Time:Float = 1, ?Callback:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = pool.get();
		timer.run(Time, Callback, Loops);
		return timer;
	}
	
	/**
	 * Starts the timer and adds the timer to the timer manager.
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off. 0 means "looping forever".
	 * @return	A reference to itself (handy for chaining or whatever).
	 */
	public function run(Time:Float = 1, ?Callback:FlxTimer->Void, Loops:Int = 1):Void
	{
		if (manager != null)
		{
			manager.add(this);
		}
		
		paused = false;
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
		run(NewTime, complete, loops);
		return this;
	}
	
	/**
	 * Stops the timer and removes it from the timer manager.
	 */
	public function abort():Void
	{
		finished = true;
		if (manager != null)
		{
			manager.remove(this);
			pool.put(this);
		}
	}
	
	/**
	 * Called by the timer manager plugin to update the timer.
	 * If time runs out, the loop counter is advanced, the timer reset, and the callback called if it exists.
	 * If the timer runs out of loops, then the timer calls stop().
	 * However, callbacks are called AFTER stop() is called.
	 */
	public function update():Void
	{
		_timeCounter += FlxG.elapsed;
		
		while ((_timeCounter >= time) && !paused && !finished)
		{
			_timeCounter -= time;
			_loopsCounter++;
			
			if (complete != null)
			{
				complete(this);
			}
			
			if (loops > 0 && (_loopsCounter >= loops))
			{
				abort();
			}
		}
	}
	
	/**
	 * Read-only: check how much time is left on the timer.
	 */
	public var timeLeft(get, never):Float;
	
	private inline function get_timeLeft():Float
	{
		return time - _timeCounter;
	}
	
	/**
	 * Read-only: The amount of milliseconds that have elapsed since the timer was started
	 */
	public var elapsedTime(get, never):Float;
	
	private inline function get_elapsedTime():Float
	{
		return _timeCounter;
	}
	
	/**
	 * Read-only: check how many loops are left on the timer.
	 */
	public var loopsLeft(get, never):Int;
	
	private inline function get_loopsLeft():Int
	{
		return loops - _loopsCounter;
	}
	
	/**
	 * Read-only: how many loops that have elapsed since the timer was started.
	 */
	public var elapsedLoops(get, never):Int;
	
	private inline function get_elapsedLoops():Int
	{
		return _loopsCounter;
	}
	
	/**
	 * Read-only: how far along the timer is, on a scale of 0.0 to 1.0.
	 */
	public var progress(get_progress, never):Float;
	
	private inline function get_progress():Float
	{
		if (time > 0)
		{
			return _timeCounter / time;
		}
		else
		{
			return 0;
		}
	}
}