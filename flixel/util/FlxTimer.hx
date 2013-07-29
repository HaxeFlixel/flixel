package flixel.util;

import flixel.FlxG;
import flixel.plugin.TimerManager;

/**
 * A simple timer class, leveraging the new plugins system.
 * Can be used with callbacks or by polling the <code>finished</code> flag.
 * Not intended to be added to a game state or group; the timer manager
 * is responsible for actually calling update(), not the user.
 */
class FlxTimer
{
	/**
	 * How much time the timer was set for.
	 */
	public var time:Float = 0;
	/**
	 * How many loops the timer was set for.
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
	 * Internal tracker for the time's-up callback function.
	 * Callback should be formed "onTimer(Timer:FlxTimer);"
	 */
	private var _callback:FlxTimer->Void = null;
	/**
	 * Internal tracker for the actual timer counting up.
	 */
	private var _timeCounter:Float = 0;
	/**
	 * Internal tracker for the loops counting up.
	 */
	private var _loopsCounter:Int = 0;
	
	/**
	 * Instantiate a new timer.
	 */
	private function new() {  }
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_callback = null;
	}
	
	/**
	 * Called by the timer manager plugin to update the timer.
	 * If time runs out, the loop counter is advanced, the timer reset, and the callback called if it exists.
	 * If the timer runs out of loops, then the timer calls <code>stop()</code>.
	 * However, callbacks are called AFTER <code>stop()</code> is called.
	 */
	public function update():Void
	{
		_timeCounter += FlxG.elapsed;
		
		while ((_timeCounter >= time) && !paused && !finished)
		{
			_timeCounter -= time;
			_loopsCounter++;
			
			var callback:FlxTimer->Void = _callback;
			
			if ((loops > 0) && (_loopsCounter >= loops))
			{
				stop();
			}
			
			if (callback != null)
			{
				callback(this);
			}
		}
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
		return start(NewTime, _callback, loops);
	}
	
	/**
	 * Starts or resumes the timer.  If this timer was paused,
	 * then all the parameters are ignored, and the timer is resumed.
	 * Adds the timer to the timer manager.
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off.  Default is 1, or "just count down once."
	 * @return	A reference to itself (handy for chaining or whatever).
	 */
	public function start(Time:Float = 1, ?Callback:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timerManager:TimerManager = manager;
		
		if (timerManager != null)
		{
			timerManager.add(this);
		}
		
		if (paused)
		{
			paused = false;
			return this;
		}
		
		paused = false;
		finished = false;
		time = Math.abs(Time);
		
		if (Loops < 1) 
		{
			Loops = 1;
		}
		
		loops = Loops;
		_callback = Callback;
		_timeCounter = 0;
		_loopsCounter = 0;
		
		return this;
	}
	
	/**
	 * Stops the timer and removes it from the timer manager.
	 */
	public function stop():Void
	{
		finished = true;
		var timerManager:TimerManager = manager;
		
		if (timerManager != null)
		{
			timerManager.remove(this);
		}
	}
	
	/**
	 * Read-only: check how much time is left on the timer.
	 */
	public var timeLeft(get, never):Float;
	
	inline private function get_timeLeft():Float
	{
		return time - _timeCounter;
	}
	
	/**
	 * Read-only: The amount of milliseconds that have elapsed since the timer was started
	 */
	public var elapsedTime(get, never):Float;
	
	inline private function get_elapsedTime():Float
	{
		return _timeCounter;
	}
	
	/**
	 * Read-only: check how many loops are left on the timer.
	 */
	public var loopsLeft(get, never):Int;
	
	inline private function get_loopsLeft():Int
	{
		return loops - _loopsCounter;
	}
	
	/**
	 * Read-only: how many loops that have elapsed since the timer was started.
	 */
	public var elapsedLoops(get, never):Int;
	
	inline private function get_elapsedLoops():Int
	{
		return _loopsCounter;
	}
	
	/**
	 * Read-only: how far along the timer is, on a scale of 0.0 to 1.0.
	 */
	public var progress(get_progress, never):Float;
	
	inline private function get_progress():Float
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
	
	/**
	 * Read-only: The <code>TimerManager</code> instance.
	 */
	static public var manager(get, never):TimerManager;
	
	inline static private function get_manager():TimerManager
	{
		return cast(FlxG.plugins.get(TimerManager), TimerManager);
	}
	
	/**
	 * Returns a recycled timer and starts it if a Time different from -1 is passed.
	 * 
	 * @param	Time		How many seconds it takes for the timer to go off. This timer will start automatically if pass positive value for this argument.
	 * @param	Callback	Optional, triggered whenever the time runs out, once for each loop. Callback should be formed "onTimer(Timer:FlxTimer);"
	 * @param	Loops		How many times the timer should go off.  Default is 1, or "just count down once."
 	 */
	static public function get(Time:Float = -1, ?Callback:FlxTimer->Void, Loops:Int = 1):FlxTimer
	{
		var timer:FlxTimer = FlxTimer.manager.get();
		if (timer == null)
		{
			timer = new FlxTimer();
		}
		
		if (Time > 0)
		{
			timer.start(Time, Callback, Loops);
		}
		
		return timer;
	}
}