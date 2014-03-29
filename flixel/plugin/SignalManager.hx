package flixel.plugin;

import flixel.FlxG;
import flixel.util.FlxSignal;
import flixel.util.FlxArrayUtil;

/**
 * Manages the lifetime of FlxSignal objects.
 * 
 * @author Sam Batista (https://github.com/gamedevsam)
 */
class SignalManager extends FlxPlugin
{
	private var _signals:Array<FlxSignal>;
	
	/**
	 * Instantiates a new signal manager.
	 */
	public function new()
	{
		super();
		
		_signals = new Array<FlxSignal>();
		
		visible = false; // don't draw this plugin
		active = false; // don't update this plugin
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		clear();
		_signals = null;
		super.destroy();
	}
	
	/**
	 * Add a signal from the manager.
	 * Usually called automatically by FlxTimer's constructor.
	 * 
	 * @param	Timer	The FlxTimer you want to add to the manager.
	 */
	public function add(Signal:FlxSignal):Void
	{
		_signals.push(Signal);
	}
	
	/**
	 * Remove a signal from the manager.
	 * Called when FlxSignal is destroyed (and when the state changes).
	 * 
	 * @param	Signal	The FlxSignal you want to remove from the manager.
	 * @param	ReturnInPool Whether to reset and put Timer into internal _pool.
	 */
	public function remove(Signal:FlxSignal):Void
	{
		FlxArrayUtil.fastSplice(_signals, Signal);
	}
	
	/**
	 * Removes all the signals from the signal manager.
	 */
	public function clear():Void
	{
		while (_signals.length > 0)
		{
			remove(_signals[0]);
		}
	}
	
	/**
	 * Recycle non-permanent signals
	 */
	override public function onStateSwitch():Void
	{
		var i = _signals.length;
		while (i-- > 0)
		{
			if (!_signals[i].persist)
				_signals[i].put();
		}
	}
}