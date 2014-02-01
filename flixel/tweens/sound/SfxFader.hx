﻿package flixel.tweens.sound;

#if !FLX_NO_SOUND_SYSTEM
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Sound effect fader.
 */
class SfxFader extends FlxTween
{
	/**
	 * @param	sfx			The Sfx object to alter.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(sfx:FlxSound, ?complete:CompleteCallback, type:Int = 0)
	{
		super(0, type, finishCallback);
		_complete = complete;
		_sfx = sfx;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_sfx = null;
		_crossSfx = null;
		_complete = null;
	}

	/**
	 * Fades the Sfx to the target volume.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ?ease:EaseFunction):SfxFader
	{
		if (volume < 0) 
		{
			volume = 0;
		}
		_start = _sfx.volume;
		_range = volume - _start;
		this.duration = duration;
		_ease = ease;
		start();
		return this;
	}

	/**
	 * Fades out the Sfx, while also playing and fading in a replacement Sfx.
	 * @param	play		The Sfx to play and fade in.
	 * @param	duration	Duration of the crossfade.
	 * @param	volume		The volume to fade in the new Sfx to.
	 * @param	ease		Optional easer function.
	 */
	public function crossFade(play:FlxSound, duration:Float, volume:Float = 1, ?ease:EaseFunction):SfxFader
	{
		_crossSfx = play;
		_crossRange = volume;
		_start = _sfx.volume;
		_range = -_start;
		this.duration = duration;
		_ease = ease;
		_crossSfx.play(true);
		start();
		return this;
	}

	override public function update():Void
	{
		super.update();
		if (_sfx != null) 
		{
			_sfx.volume = _start + _range * _t;
		}
		if (_crossSfx != null) 
		{
			_crossSfx.volume = _crossRange * _t;
		}
	}

	override public function finish():Void 
	{ 
		finishCallback(this);
	}
	
	function finishCallback(tween:FlxTween):Void
	{
		if (_crossSfx != null)
		{
			if (_sfx != null) 
			{
				_sfx.stop();
			}
			_sfx = _crossSfx;
			_crossSfx = null;
		}
		if (_complete != null) 
		{
			_complete(this);
		}
	}

	/**
	 * The current Sfx this object is effecting.
	 */
	public var sfx(get_sfx, null):FlxSound;
	function get_sfx():FlxSound { return _sfx; }

	// Fader information.
	var _sfx:FlxSound;
	var _start:Float;
	var _range:Float;
	var _crossSfx:FlxSound;
	var _crossRange:Float;
	var _complete:CompleteCallback;
}
#end