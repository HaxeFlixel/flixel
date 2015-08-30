package;

import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.FlxG;

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
			PixelSize = FlxG.random.int(1, 4);
		}
		
		for (i in 0...100)
		{
			var fp = new FlxParticle();
			var color:Int = (Color == 0) ? Reg.randomColor() : Color;
			fp.makeGraphic(PixelSize, PixelSize, color);
			add(fp);
		}
	}
}