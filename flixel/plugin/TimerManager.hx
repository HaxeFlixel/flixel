package flixel.plugin;

import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;

/**
 * A simple manager for tracking and updating game timer objects.
 */
class TimerManager extends FlxPlugin
{
	private var _timers:Array<FlxTimer>;
	
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
	 * Called by FlxG.plugins.update() before the game state has been updated.
	 * Cycles through timers and calls update() on each one.
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
	 * Usually called automatically by FlxTimer's constructor.
	 * 
	 * @param	Timer	The FlxTimer you want to add to the manager.
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
	 * Usually called automatically by FlxTimer's stop() function.
	 * 
	 * @param	Timer	The FlxTimer you want to remove from the manager.
	 * @param	ReturnInPool Whether to reset and put Timer into internal _pool.
	 */
	public function remove(Timer:FlxTimer):Void
	{
		FlxArrayUtil.fastSplice(_timers, Timer);
	}
	
	/**
	 * Removes all the timers from the timer manager.
	 */
	public function clear():Void
	{
		while (_timers.length > 0)
		{
			FlxTimer.pool.put(_timers.pop());
		}
	}
	
	override public inline function onStateSwitch():Void
	{
		clear();
	}
}