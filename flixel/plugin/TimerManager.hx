package flixel.plugin;

import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;

/**
 * A simple manager for tracking and updating game timer objects.
 */
class TimerManager extends FlxPlugin
{
	var _timers:Array<FlxTimer>;
	
	/**
	 * Instantiates a new timer manager.
	 */
	public function new()
	{
		super();
		
		_timers = new Array<FlxTimer>();
		
		// Don't call draw on this plugin
		visible = false; 
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		clear();
		_timers = null;
		
		super.destroy();
	}
	
	/**
	 * Called by <code>FlxG.plugins.update()</code> before the game state has been updated.
	 * Cycles through timers and calls <code>update()</code> on each one.
	 */
	override public function update():Void
	{
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
	 * Remove a timer from the timer manager.
	 * Usually called automatically by <code>FlxTimer</code>'s <code>stop()</code> function.
	 * 
	 * @param	Timer	The <code>FlxTimer</code> you want to remove from the manager.
	 * @param	ReturnInPool Whether to reset and put Timer into internal _pool.
	 */
	public function remove(Timer:FlxTimer, ReturnInPool:Bool = true):Void
	{
		FlxArrayUtil.fastSplice(_timers, Timer);
		
		if (ReturnInPool)
		{
			FlxTimer.put(Timer);
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
			FlxTimer.put(timer);
		}
	}
	
	override public inline function onStateSwitch():Void
	{
		clear();
	}
}