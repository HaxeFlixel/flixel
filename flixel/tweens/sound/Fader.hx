﻿package flixel.tweens.sound;

#if !FLX_NO_SOUND_SYSTEM
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

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
	 * Fades FlxG.volume to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ease:EaseFunction = null):Void
	{
		if (volume < 0) volume = 0;
		_start = FlxG.sound.volume;
		_range = volume - _start;
		this.duration = duration;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		FlxG.sound.volume = _start + _range * _t;
	}
	
	// Fader information.
	var _start:Float;
	var _range:Float;
}
#end