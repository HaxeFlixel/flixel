package org.flixel.tweens.sound;

import org.flixel.FlxG;
import org.flixel.FlxSound;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * Sound effect fader.
 */
class SfxFader extends FlxTween
{
	/**
	 * Constructor.
	 * @param	sfx			The Sfx object to alter.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(sfx:FlxSound, complete:CompleteCallback = null, type:Int = 0)
	{
		super(0, type, finish);
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
	public function fadeTo(volume:Float, duration:Float, ease:EaseFunction = null):Void
	{
		if (volume < 0) 
		{
			volume = 0;
		}
		_start = _sfx.volume;
		_range = volume - _start;
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Fades out the Sfx, while also playing and fading in a replacement Sfx.
	 * @param	play		The Sfx to play and fade in.
	 * @param	duration	Duration of the crossfade.
	 * @param	volume		The volume to fade in the new Sfx to.
	 * @param	ease		Optional easer function.
	 */
	public function crossFade(play:FlxSound, duration:Float, volume:Float = 1, ease:EaseFunction = null):Void
	{
		_crossSfx = play;
		_crossRange = volume;
		_start = _sfx.volume;
		_range = -_start;
		_target = duration;
		_ease = ease;
		_crossSfx.play(true);
		start();
	}

	/** @private Updates the Tween. */
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

	/** @private When the tween completes. */
	override private function finish():Void
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
			_complete();
		}
	}

	/**
	 * The current Sfx this object is effecting.
	 */
	public var sfx(get_sfx, null):FlxSound;
	private function get_sfx():FlxSound { return _sfx; }

	// Fader information.
	private var _sfx:FlxSound;
	private var _start:Float;
	private var _range:Float;
	private var _crossSfx:FlxSound;
	private var _crossRange:Float;
	private var _complete:CompleteCallback;
}