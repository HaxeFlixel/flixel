package org.flixel.plugin;

import org.flixel.FlxBasic;
import org.flixel.FlxTimer;
import org.flixel.FlxU;

/**
 * A simple manager for tracking and updating game timer objects.
 */
class TimerManager extends FlxBasic
{
	private var _timers:Array<FlxTimer>;
	
	/**
	 * Instantiates a new timer manager.
	 */
	public function new()
	{
		super();
		
		_timers = new Array<FlxTimer>();
		visible = false; //don't call draw on this plugin
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
	 * Called by <code>FlxG.updatePlugins()</code> before the game state has been updated.
	 * Cycles through timers and calls <code>update()</code> on each one.
	 */
	override public function update():Void
	{
		var i:Int = _timers.length - 1;
		var timer:FlxTimer;
		while(i >= 0)
		{
			timer = _timers[i--];
			if ((timer != null) && !timer.paused && !timer.finished && (timer.time > 0))
			{
				timer.update();
			}
		}
	}
	
	/**
	 * Add a new timer to the timer manager.
	 * Usually called automatically by <code>FlxTimer</code>'s constructor.
	 * @param	Timer	The <code>FlxTimer</code> you want to add to the manager.
	 */
	public function add(Timer:FlxTimer):Void
	{
		_timers.push(Timer);
	}
	
	/**
	 * Remove a timer from the timer manager.
	 * Usually called automatically by <code>FlxTimer</code>'s <code>stop()</code> function.
	 * @param	Timer	The <code>FlxTimer</code> you want to remove from the manager.
	 */
	public function remove(Timer:FlxTimer):Void
	{
		//var index:Int = _timers.indexOf(Timer);
		var index:Int = FlxU.ArrayIndexOf(_timers, Timer);
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
		var i:Int = _timers.length - 1;
		var timer:FlxTimer;
		while(i >= 0)
		{
			timer = _timers[i--];
			if (timer != null)
			{
				timer.destroy();
			}
		}
		_timers = [];
	}
}