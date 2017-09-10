package;

import flash.display.BlendMode;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
#if flash
import flixel.FlxG;
#end

class EnemyGibs extends FlxEmitter
{
	private static inline var SPEED:Int = 10;
	private static inline var SIZE:Int = 10;
	
	/**
	 * Creates a FlxEmitter with pre-defined particle size, speed, color, inversion, and so forth.
	 */
	public function new()
	{
		super(0, 0, SIZE);
		
		velocity.set(-SPEED, -SPEED, SPEED, SPEED);
		lifespan.set(1, 1);
		
		#if flash
		blend = BlendMode.INVERT;
		#end
		
		for (i in 0...SIZE)
		{
			var p = new FlxParticle();
			
			var color = FlxColor.BLACK;
			#if flash
			if (FlxG.random.bool())
				color = FlxColor.WHITE;
			#end

			p.makeGraphic(2, 2, FlxColor.BLACK);
			add(p);
		}
		
		Reg.PS.emitters.add(this);
	}
	
	/**
	 * Explode this emitter at a given X and Y.
	 */
	public function startAtPosition(X:Float, Y:Float):Void
	{
		x = X;
		y = Y;
		start(true, 0, SIZE);
	}
}