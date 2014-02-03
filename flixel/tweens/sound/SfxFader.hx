package flixel.tweens.sound;

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
	 * The current Sfx this object is effecting.
	 */
	public var sfx(default, null):FlxSound;

	// Fader information.
	private var _start:Float;
	private var _range:Float;
	private var _crossSfx:FlxSound;
	private var _crossRange:Float;
	private var _complete:CompleteCallback;
	
	/**
	 * @param	sfx			The Sfx object to alter.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(sfx:FlxSound, ?complete:CompleteCallback, type:Int = 0)
	{
		super(0, type, finishCallback);
		_complete = complete;
		this.sfx = sfx;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		sfx = null;
		_crossSfx = null;
		_complete = null;
	}

	/**
	 * Fades the Sfx to the target volume.
	 * 
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
		_start = sfx.volume;
		_range = volume - _start;
		this.duration = duration;
		_ease = ease;
		start();
		return this;
	}

	/**
	 * Fades out the Sfx, while also playing and fading in a replacement Sfx.
	 * 
	 * @param	play		The Sfx to play and fade in.
	 * @param	duration	Duration of the crossfade.
	 * @param	volume		The volume to fade in the new Sfx to.
	 * @param	ease		Optional easer function.
	 */
	public function crossFade(play:FlxSound, duration:Float, volume:Float = 1, ?ease:EaseFunction):SfxFader
	{
		_crossSfx = play;
		_crossRange = volume;
		_start = sfx.volume;
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
		if (sfx != null) 
		{
			sfx.volume = _start + _range * scale;
		}
		if (_crossSfx != null) 
		{
			_crossSfx.volume = _crossRange * scale;
		}
	}

	override public function finish():Void 
	{ 
		finishCallback(this);
	}
	
	private function finishCallback(tween:FlxTween):Void
	{
		if (_crossSfx != null)
		{
			if (sfx != null) 
			{
				sfx.stop();
			}
			sfx = _crossSfx;
			_crossSfx = null;
		}
		if (_complete != null) 
		{
			_complete(this);
		}
	}
}
#end