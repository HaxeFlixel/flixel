package flixel.tweens.sound;

#if !FLX_NO_SOUND_SYSTEM
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxPool;

/**
 * Sound effect fader.
 */
class SfxFader extends FlxTween
{
	/**
	 * A pool that contains SfxFaders for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<SfxFader>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool():FlxPool<SfxFader>
	{
		if (_pool == null)
		{
			_pool = new FlxPool<SfxFader>(SfxFader);
		}
		return _pool;
	}
	
	/**
	 * The current Sfx this object is effecting.
	 */
	public var sfx(default, null):FlxSound;

	// Fader information.
	private var _start:Float;
	private var _range:Float;
	private var _crossSfx:FlxSound;
	private var _crossRange:Float;
	
	/**
	 * Clean up references and pool this object for recycling.
	 */
	override public function destroy():Void 
	{
		super.destroy();
		sfx = null;
		_crossSfx = null;
	}

	/**
	 * Fades the Sfx to the target volume.
	 * 
	 * @param	sound		The FlxSound
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(sound:FlxSound, volume:Float, duration:Float, ?ease:EaseFunction):SfxFader
	{
		if (volume < 0) 
			volume = 0;
		
		this.sfx = sound;
		_start = sfx.volume;
		_range = volume - _start;
		this.duration = duration;
		startDelay = loopDelay = 0;
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
		startDelay = loopDelay = 0;
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

	override inline public function finish():Void 
	{ 
		finishCallback(this);
	}
	
	override inline public function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
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
		if (complete != null) 
		{
			complete(this);
		}
	}
}
#end