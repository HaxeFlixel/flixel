package flixel.effects.particles;

/**
 * Extended FlxEmitter that emits particles in a circle (instead of a square).
 * It also provides a new function setMotion to control particle behavior even more.
 * This was inspired by the way Chevy Ray Johnston implemented his particle emitter in Flashpunk.
 * @author Dirk Bunk
 */
class FlxEmitterExt extends FlxTypedEmitterExt<FlxParticle>
{
	/**
	 * Creates a new FlxEmitterExt object at a specific position.
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