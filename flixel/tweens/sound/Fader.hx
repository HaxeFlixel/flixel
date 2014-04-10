package flixel.tweens.sound;

#if !FLX_NO_SOUND_SYSTEM
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxPool;

/**
 * Global volume fader.
 */
class Fader extends FlxTween
{
	/**
	 * A pool that contains Faders for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<Fader>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool():FlxPool<Fader>
	{
		if (_pool == null)
		{
			_pool = new FlxPool<Fader>(Fader);
		}
		return _pool;
	}
	
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * Fades FlxG.volume to the target volume.
	 * 
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	ease		Optional easer function.
	 */
	public function fadeTo(volume:Float, duration:Float, ?ease:EaseFunction):Void
	{
		if (volume < 0) volume = 0;
		_start = FlxG.sound.volume;
		_range = volume - _start;
		this.duration = duration;
		this.ease = ease;
		start();
	}
	
	override public function update():Void
	{
		super.update();
		FlxG.sound.volume = _start + _range * scale;
	}
	
	override inline public function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}
}
#end