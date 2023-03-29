package flixel.util;

import flixel.FlxG;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * A simple timer class. Calls the given function after the specified amount of time passed.
 * `FlxTimers` are automatically updated and managed by the `globalManager`. They are deterministic
 * by default, unless [`FlxG.fixedTimestep`](https://api.haxeflixel.com/flixel/FlxG.html#fixedTimestep)
 * is set to `false`.
 * 
 * Note: Timer duration is affected when [`FlxG.timeScale`](https://api.haxeflixel.com/flixel/FlxG.html#timeScale)
 * is changed.
 * 
 * Example: To create a timer that executes a function in 3 seconds:
 * ```haxe
 * new FlxTimer().start(3.0, ()->{ FlxG.log.add("The FlxTimer has finished"); })
 * ```
 * @see [FlxG.fixedTimestep](https://api.haxeflixel.com/flixel/FlxG.html#fixedTimestep)
 * @see [FlxG.timeScale](https://api.haxeflixel.com/flixel/FlxG.html#timeScale)
 */
class FlxTimer implements IFlxDestroyable
{
	/**
	 * The global timer manager that handles global timers.
	 * @since 4.2.0
	 */
	public static var globalManager:FlxTimerManager;

	/**
	 * The manager to which this timer belongs.
	 * @since 4.2.0
	 */
	public var manager:FlxTimerManager;

	/**
	 * How much time the timer was set for.
	 */
	public var time:Float = 0;

	/**
	 * How many loops the timer was set for. `0` means "looping forever".
	 */
	public var loops:Int = 0;

	/**
	 * Whether the timer is active. Can be changed manually to pause/resume the timer.
	 */
	public var active:Bool = false;

	/**
	 * Whether the timer is finished.
	 */
	public var finished:Bool = false;

	/**
	 * Function that is called whenever the timer completes one loop.
	 * Callback should take the form `onComplete(timer:FlxTimer):Void`.
	 */
	public var onComplete:FlxTimer->Void;

	/**
	 * How much time is left on the timer. Read-only.
	 */
	public var timeLeft(get, never):Float;

	/**
	 * The amount of milliseconds that have elapsed since the timer was started. Read-only.
	 */
	public var elapsedTime(get, never):Float;

	/**
	 * How many loops are left on the timer. Read-only.
	 */
	public var loopsLeft(get, never):Int;

	/**
	 * How many loops have elapsed since the timer was started. Read-only.
	 */
	public var elapsedLoops(get, never):Int;

	/**
	 * How far along the timer is, on a scale of `0.0` to `1.0`. Read-only.
	 */
	public var progress(get, never):Float;

	/**
	 * Internal tracker for the actual timer counting up.
	 */
	var _timeCounter:Float = 0;

	/**
	 * Internal tracker for the loops counting up.
	 */
	var _loopsCounter:Int = 0;

	var _inManager:Bool = false;

	/**
	 * Creates a new timer.
	 */
	public function new(?manager:FlxTimerManager)
	{
		this.manager = manager != null ? manager : globalManager;
	}

	/**
	 * Cleans up memory.
	 */
	public function destroy():Void
	{
		onComplete = null;
	}

	/**
	 * Starts the timer and adds the timer to the timer manager.
	 *
	 * @param time How many seconds it takes for the timer to go off.
	 * If `0`, then timer will fire `onComplete` callback only once at the first call of `update()` (which means that `Loops` argument will be ignored).
	 * @param onComplete Optional callback that is triggered whenever the time runs out, once for each loop.
	 * Callback should take the form `onComplete(timer:FlxTimer):Void`.
	 * @param loops How many times the timer should go off. `0` means "looping forever".
	 * @return A reference to itself (handy for chaining or whatever).
	 */
	public function start(time:Float = 1, ?onComplete:FlxTimer->Void, loops:Int = 1):FlxTimer
	{
		if (manager != null && !_inManager)
		{
			manager.add(this);
			_inManager = true;
		}

		active = true;
		finished = false;
		this.time = Math.abs(time);

		if (loops < 0)
			loops *= -1;

		this.loops = loops;
		this.onComplete = onComplete;
		_timeCounter = 0;
		_loopsCounter = 0;

		return this;
	}

	/**
	 * Restarts the timer using the new duration.
	 * @param newTime The duration of this timer in seconds.
	 */
	public function reset(newTime:Float = -1):FlxTimer
	{
		if (newTime < 0)
			newTime = time;

		start(newTime, onComplete, loops);
		return this;
	}

	/**
	 * Stops the timer and removes it from the timer manager.
	 */
	public function cancel():Void
	{
		finished = true;
		active = false;

		if (manager != null && _inManager)
		{
			manager.remove(this);
			_inManager = false;
		}
	}

	/**
	 * Called by the timer manager plugin to update the timer.
	 * If time runs out, the loop counter is advanced, the timer is reset, and the callback is called if it exists.
	 * If the timer runs out of loops, then the timer calls `cancel()`.
	 * However, callbacks are called AFTER `cancel()` is called.
	 */
	public function update(elapsed:Float):Void
	{
		_timeCounter += elapsed;

		while ((_timeCounter >= time) && active && !finished)
		{
			_timeCounter -= time;
			_loopsCounter++;

			if (loops > 0 && (_loopsCounter >= loops))
			{
				finished = true;
			}
		}
	}

	@:allow(flixel.util.FlxTimerManager)
	function onLoopFinished():Void
	{
		if (finished)
			cancel();

		if (onComplete != null)
			onComplete(this);
	}

	inline function get_timeLeft():Float
	{
		return time - _timeCounter;
	}

	inline function get_elapsedTime():Float
	{
		return _timeCounter;
	}

	inline function get_loopsLeft():Int
	{
		return loops - _loopsCounter;
	}

	inline function get_elapsedLoops():Int
	{
		return _loopsCounter;
	}

	inline function get_progress():Float
	{
		return (time > 0) ? (_timeCounter / time) : 0;
	}
}

/**
 * A simple manager for tracking and updating game timer objects.
 * Normally accessed via the static `FlxTimer.manager` rather than being created separately.
 */
class FlxTimerManager extends FlxBasic
{
	var _timers:Array<FlxTimer> = [];

	/**
	 * Instantiates a new timer manager.
	 */
	public function new()
	{
		super();

		// Don't call draw on this plugin
		visible = false;

		FlxG.signals.preStateSwitch.add(clear);
	}

	/**
	 * Cleans up memory.
	 */
	override public function destroy():Void
	{
		clear();
		_timers = null;
		FlxG.signals.preStateSwitch.remove(clear);
		super.destroy();
	}

	/**
	 * Called by `FlxG.plugins.update()` before the game state has been updated.
	 * Cycles through timers and calls `update()` on each one.
	 * 
	 * @param elapsed The amount of time in seconds that have passed since the last frame.
	 */
	override public function update(elapsed:Float):Void
	{
		var loopedTimers:Array<FlxTimer> = null;

		for (timer in _timers)
		{
			if (timer.active && !timer.finished && timer.time >= 0)
			{
				var timerLoops:Int = timer.elapsedLoops;
				timer.update(elapsed);

				if (timerLoops != timer.elapsedLoops)
				{
					if (loopedTimers == null)
						loopedTimers = [];

					loopedTimers.push(timer);
				}
			}
		}

		if (loopedTimers != null)
		{
			while (loopedTimers.length > 0)
			{
				loopedTimers.shift().onLoopFinished();
			}
		}
	}

	/**
	 * Adds a new timer to the timer manager.
	 * Called when `FlxTimer` is started.
	 *
	 * @param timer The `FlxTimer` to add to the manager.
	 */
	@:allow(flixel.util.FlxTimer)
	function add(timer:FlxTimer):Void
	{
		_timers.push(timer);
	}

	/**
	 * Removes a timer from the timer manager.
	 * Called automatically by `FlxTimer#cancel()`.
	 *
	 * @param timer The `FlxTimer` to remove from the manager.
	 */
	@:allow(flixel.util.FlxTimer)
	function remove(timer:FlxTimer):Void
	{
		FlxArrayUtil.fastSplice(_timers, timer);
	}

	/**
	 * Immediately updates all `active`, non-infinite timers to their end points, repeatedly,
	 * until all their loops are finished, resulting in `onComplete` callbacks being run.
	 * @since 4.2.0
	 */
	public function completeAll():Void
	{
		var timersToFinish:Array<FlxTimer> = [];
		for (timer in _timers)
			if (timer.loops > 0 && timer.active)
				timersToFinish.push(timer);

		for (timer in timersToFinish)
		{
			while (!timer.finished)
			{
				timer.update(timer.timeLeft);
				timer.onLoopFinished();
			}
		}
	}

	/**
	 * Removes all the timers from the timer manager.
	 */
	public inline function clear():Void
	{
		FlxArrayUtil.clearArray(_timers);
	}

	/**
	 * Applies a function to all timers.
	 *
	 * @param func A function that modifies one timer at a time.
	 * @since 4.2.0
	 */
	public function forEach(func:FlxTimer->Void)
	{
		for (timer in _timers)
			func(timer);
	}
}
