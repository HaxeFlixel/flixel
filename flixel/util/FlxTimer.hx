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
	/**
	 * The TimerManager instance.
	 */
	public static var manager:TimerManager;
	/**
	 * A pool that contains FlxTimers for recycling.
	 */
	@:allow(flixel.plugin.TimerManager)
	private static var _pool = new FlxPool<FlxTimer>(FlxTimer);
	
	/**
	 * Returns a recycled timer and starts it.
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off. 0 means "looping forever".
 	 */
	public static function start(Time:Float = 1, ?Callback:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = _pool.get();
		timer.run(Time, Callback, Loops);
		return timer;
	}
	
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
	public var userData:Dynamic;
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
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		complete = null;
		userData = null;
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
			_pool.put(this);
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
	
	private function new() {}
	
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