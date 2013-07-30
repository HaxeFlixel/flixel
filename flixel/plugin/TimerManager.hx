package flixel.plugin;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;
import flixel.util.FlxPool;

/**
 * A simple manager for tracking and updating game timer objects.
 */
class TimerManager extends FlxBasic
{
	private var _timers:Array<FlxTimer>;
	private var _pool:FlxPool<FlxTimer>;
	
	/**
	 * Instantiates a new timer manager.
	 */
	public function new()
	{
		super();
		
		_timers = new Array<FlxTimer>();
		_pool = new FlxPool<FlxTimer>();
		
		// Don't call draw on this plugin
		visible = false; 
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		// pooled objects are already destroyed, look at remove function
		_pool = null;
		
		while (_timers.length > 0)
		{
			_timers.pop().destroy();
		}
		_timers = null;
		
		super.destroy();
	}
	
	/**
	 * Called by <code>FlxG.plugins.update()</code> before the game state has been updated.
	 * Cycles through timers and calls <code>update()</code> on each one.
	 */
	override public function update():Void
	{
		if (FlxG.paused) 
		{
			return;
		}
		
		for (timer in _timers)
		{
			if (!timer.paused && !timer.finished && timer.time > 0)
			{
				timer.update();
			}
		}
	}
	
	/**
	 * Add a new timer to the timer manager.
	 * Usually called automatically by <code>FlxTimer</code>'s constructor.
	 * 
	 * @param	Timer	The <code>FlxTimer</code> you want to add to the manager.
	 */
	public function add(Timer:FlxTimer):Void
	{
		if (FlxArrayUtil.indexOf(_timers, Timer) < 0) 
		{
			_timers.push(Timer);
		}
	}
	
	/**
	 * Gets new or recycled FlxTimer object.
	 * It is recommended to use this method instead of creating new FlxTimer objects all the time.
	 */
	inline public function get():FlxTimer
	{
		return _pool.get();
	}
	
	/**
	 * Remove a timer from the timer manager.
	 * Usually called automatically by <code>FlxTimer</code>'s <code>stop()</code> function.
	 * 
	 * @param	Timer	The <code>FlxTimer</code> you want to remove from the manager.
	 * @param	ReturnInPool Whether to reset and put Timer into internal _pool.
	 */
	public function remove(Timer:FlxTimer, ReturnInPool:Bool = true):Void
	{
		if (ReturnInPool)
		{
			Timer.destroy();
			_pool.put(Timer);
		}
		
		var index:Int = FlxArrayUtil.indexOf(_timers, Timer);
		if (index >= 0)
		{
			// Fast array removal (only do on arrays where order doesn't matter)
			_timers[index] = _timers[_timers.length - 1];
			_timers.pop();
		}
	}
	
	/**
	 * Removes all the timers from the timer manager.
	 */
	public function clear():Void
	{
		while (_timers.length > 0)
		{
			var timer:FlxTimer = _timers.pop();
			timer.destroy();
			_pool.put(timer);
		}
	}
}