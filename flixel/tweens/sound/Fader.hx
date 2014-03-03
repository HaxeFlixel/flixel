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
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * A pool that contains QuadPaths for recycling.
	 */
	@:isVar public static var pool(get, null):FlxPool<Fader>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	public static function get_pool():FlxPool<Fader>
	{
		if (pool == null)
		{
			pool = new FlxPool<Fader>(Fader);
		}
		return pool;
	}
	
	/**
	 * Clean up references and pool this object for recycling.
	 */
	override public function destroy()
	{
		super.destroy();
		pool.put(this);
	}
	
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
}
#end