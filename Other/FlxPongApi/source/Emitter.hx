package;

import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxRandom;

/**
 * A painfully simple emitter class.
 */
class Emitter extends FlxEmitter
{
	public function new(X:Int, Y:Int, PixelSize:Int = 1, Color:Int = 0)
	{
		super(X, Y, 100);
		setRotation(0, 0);
		
		if (PixelSize == 0) {
			PixelSize = FlxRandom.intRanged(1, 4);
		}
		
		for (i in 0...100) {
			var fp:FlxParticle = new FlxParticle();
			var col:Int = 0;
			if (Color == 0) {
				col = Reg.randomColor();
			} else {
				col = Color;
			}
			fp.makeGraphic(PixelSize, PixelSize, col);
			add(fp);
		}
	}
}