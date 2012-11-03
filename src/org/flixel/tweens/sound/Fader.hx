package org.flixel.tweens.sound;

import org.flixel.FlxG;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * Global volume fader.
 */
class Fader extends FlxTween
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(complete:CompleteCallback = null, type:Int = 0) 
	{
		super(0, type, complete);
	}
	
	/**
	 * Fades FP.volume to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ease:EaseFunction = null):Void
	{
		if (volume < 0) volume = 0;
		_start = FlxG.volume;
		_range = volume - _start;
		_target = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		FlxG.volume = _start + _range * _t;
	}
	
	// Fader information.
	private var _start:Float;
	private var _range:Float;
}