package ;

import flash.display.BlendMode;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxTypedEmitter.Bounds;
import flixel.util.FlxRandom;

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
		
		setXSpeed( -SPEED, SPEED);
		setYSpeed( -SPEED, SPEED);
		
		#if !(cpp || neko || js)
		blend = BlendMode.INVERT;
		#end
		
		for (i in 0...SIZE)
		{
			var p:FlxParticle = new FlxParticle();
			
			#if !(cpp || neko || js)
			p.makeGraphic(2, 2, FlxColor.BLACK);
			#else
			if (FlxRandom.chanceRoll())
			{
				p.makeGraphic(2, 2, FlxColor.BLACK);
			}
			else
			{
				p.makeGraphic(2, 2, FlxColor.WHITE);
			}
			#end
			add(p);
		}
		
		Reg.PS.emitterGroup.add(this);
	}
	
	/**
	 * Explode this emitter at a given X and Y. Called by Enemy.explode() when health reaches zero or the enemy reaches the goal.
	 * 
	 * @param	X	The X position for this emitter.
	 * @param	Y	The Y position for this emitter.
	 */ 
	public function explode(X:Float, Y:Float):Void
	{
		x = X;
		y = Y;
		start(true, 1, 0, SIZE, 1);
	}
}