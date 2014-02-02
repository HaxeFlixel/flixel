package flixel.effects.particles;

/**
 * FlxEmitter is a lightweight particle emitter.
 * It can be used for one-time explosions or for
 * continuous fx like rain and fire.  FlxEmitter
 * is not optimized or anything; all it does is launch
 * FlxParticle objects out at set intervals
 * by setting their positions and velocities accordingly.
 * It is easy to use and relatively efficient,
 * relying on FlxGroup's RECYCLE POWERS.
 */
class FlxEmitter extends FlxTypedEmitter<FlxParticle>
{
	/**
	 * Creates a new FlxEmitter object at a specific position.
	 * Does NOT automatically generate or attach particles!
	 * 
	 * @param	X		The X position of the emitter.
	 * @param	Y		The Y position of the emitter.
	 * @param	Size	Optional, specifies a maximum capacity for this emitter.
	 */
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0)
	{
		super(X, Y, Size);
	}
}