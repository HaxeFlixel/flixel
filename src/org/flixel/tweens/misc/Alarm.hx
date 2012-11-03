﻿package org.flixel.tweens.misc;

import org.flixel.tweens.FlxTween;

/**
 * A simple alarm, useful for timed events, etc.
 */
class Alarm extends FlxTween
{
	/**
	 * Constructor.
	 * @param	duration	Duration of the alarm.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(duration:Float, complete:CompleteCallback = null, type:Int = 0)
	{
		super(duration, type, complete, null);
	}

	/**
	 * Sets the alarm.
	 * @param	duration	Duration of the alarm.
	 */
	public function reset(duration:Float):Void
	{
		_target = duration;
		start();
	}

	/**
	 * How much time has passed since reset.
	 */
	public var elapsed(getElapsed, never):Float;
	private function getElapsed():Float { return _time; }

	/**
	 * Current alarm duration.
	 */
	public var duration(getDuration, never):Float;
	private function getDuration():Float { return _target; }

	/**
	 * Time remaining on the alarm.
	 */
	public var remaining(getRemaining, never):Float;
	private function getRemaining():Float { return _target - _time; }
}