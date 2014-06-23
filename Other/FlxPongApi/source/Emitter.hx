package;

import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.math.FlxRandom;

/**
 * A painfully simple emitter class.
 */
class Emitter extends FlxEmitter
{
	public function new(X:Float, Y:Float, PixelSize:Int = 1, Color:Int = 0)
	{
		super(X, Y, 100);
		
		if (PixelSize == 0)
		{
			PixelSize = FlxRandom.int(1, 4);
		}
		
		for (i in 0...100)
		{
			var fp:FlxParticle = new FlxParticle();
			var color:Int = (Color == 0) ? Reg.randomColor() : Color;
			fp.makeGraphic(PixelSize, PixelSize, color);
			add(fp);
		}
	}
}