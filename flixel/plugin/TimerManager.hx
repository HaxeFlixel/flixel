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
		
		_timers = [];
		
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
			if (timer.active && !timer.finished && timer.time > 0)
			{
				timer.update();
			}
		}
	}
	
	/**
	 * Add a new timer to the timer manager.
	 * Called when FlxTimer is started.
	 * 
	 * @param	Timer	The FlxTimer you want to add to the manager.
	 */
	@:allow(flixel.util.FlxTimer)
	private function add(Timer:FlxTimer):Void
	{
		_timers.push(Timer);
	}
	
	/**
	 * Remove a timer from the timer manager.
	 * Called automatically by FlxTimer's stop() function.
	 * 
	 * @param	Timer	The FlxTimer you want to remove from the manager.
	 * @param	ReturnInPool Whether to reset and put Timer into internal _pool.
	 */
	@:allow(flixel.util.FlxTimer)
	private function remove(Timer:FlxTimer):Void
	{
		FlxArrayUtil.fastSplice(_timers, Timer);
	}
	
	/**
	 * Removes all the timers from the timer manager.
	 */
	public inline function clear():Void
	{
		FlxArrayUtil.clearArray(_timers);
	}
	
	override public inline function onStateSwitch():Void
	{
		clear();
	}
}