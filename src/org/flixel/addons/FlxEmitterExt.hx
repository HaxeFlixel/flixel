package org.flixel.addons;

import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxParticle;

class FlxEmitterExt extends FlxTypedEmitterExt<FlxParticle>
{
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0)
	{
		super(X, Y, Size);
	}
}

/**
 * Extended FlxEmitter that emits particles in a circle (instead of a square).
 * It also provides a new function setMotion to control particle behavior even more.
 * This was inspired by the way Chevy Ray Johnston implemented his particle emitter in Flashpunk.
 * @author Dirk Bunk
 * @link https://github.com/krix/ParticleTest
 */
class FlxTypedEmitterExt<T:FlxParticle> extends FlxTypedEmitter<T:FlxParticle>
{		
	/**
	 * 	Launch Direction.
	 */
	public var angle:Float;
	
	/**
	 * 	Distance to travel.
	 */
	public var distance:Float;
	
	/**
	 * 	Random amount to add to the particle's direction.
	 */
	public var angleRange:Float;
	
	/**
	 * 	Random amount to add to the particle's distance.
	 */
	public var distanceRange:Float;
	
	/**
	 * 	Random amount to add to the particle's duration.
	 */
	public var lifespanRange:Float;
	
	/**
	 * Creates a new <code>FlxEmitterExt</code> object at a specific position.
	 * Does NOT automatically generate or attach particles!
	 * 
	 * @param	X		The X position of the emitter.
	 * @param	Y		The Y position of the emitter.
	 * @param	Size	Optional, specifies a maximum capacity for this emitter.
	 */
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0) 
	{
		super(X, Y, Size);
		//set defaults
		setMotion(0, 0, 0.5, 360, 100, 1.5);
	}
	
	/**
	 * Defines the motion range for this emitter.
	 * @param	angle			Launch Direction.
	 * @param	distance		Distance to travel.
	 * @param	lifespan		Particle duration.
	 * @param	angleRange		Random amount to add to the particle's direction.
	 * @param	distanceRange	Random amount to add to the particle's distance.
	 * @param	lifespanRange	Random amount to add to the particle's duration.
	 */
	public function setMotion(angle:Float, distance:Float, lifespan:Float, angleRange:Float = 0, distanceRange:Float = 0, lifespanRange:Float = 0):Void
	{
		this.angle = angle * FlxG.RAD;
		this.distance = distance;
		this.lifespan = lifespan;
		this.angleRange = angleRange * FlxG.RAD;
		this.distanceRange = distanceRange;
		this.lifespanRange = lifespanRange;
	}
	
	/**
	 * Defines the motion range for a specific particle.
	 * @param   particle		The Particle to set the motion for
	 * @param	angle			Launch Direction.
	 * @param	distance		Distance to travel.
	 * @param	lifespan		Particle duration.
	 * @param	angleRange		Random amount to add to the particle's direction.
	 * @param	distanceRange	Random amount to add to the particle's distance.
	 * @param	lifespanRange	Random amount to add to the particle's duration.
	 */
	private function setParticleMotion(particle:FlxParticle, angle:Float, distance:Float, lifespan:Float, angleRange:Float = 0, distanceRange:Float = 0, lifespanRange:Float = 0):Void
	{			
		//set particle direction and speed
		var a:Float = angle + FlxG.random() * angleRange;
		var d:Float = distance + FlxG.random() * distanceRange;
			
		particle.velocity.x = Math.cos(a) * d;
		particle.velocity.y = Math.sin(a) * d;
		particle.lifespan = lifespan + FlxG.random() * lifespanRange;
	}
	
	/**
	 * Call this function to start emitting particles.
	 * 
	 * @param	Explode		Whether the particles should all burst out at once.
	 * @param	Lifespan	Unused parameter due to class override. Use setMotion to set things like a particle's lifespan.
	 * @param	Frequency	Ignored if Explode is set to true. Frequency is how often to emit a particle. 0 = never emit, 0.1 = 1 particle every 0.1 seconds, 5 = 1 particle every 5 seconds.
	 * @param	Quantity	How many particles to launch. 0 = "all of the particles".
	 */
	override public function start(Explode:Bool = true, Lifespan:Float = 0, Frequency:Float = 0.1, Quantity:Int = 0):Void
	{
		super.start(Explode, Lifespan, Frequency, Quantity);

		//Immediately execute the explosion code part from the update function, to prevent other explosions to override this one.
		//This fixes the problem, that you can not add two particle explosions in the same frame.
		if (Explode)
		{
			on = false;
			var i:Int = 0;
			var l:Int = _quantity;
			if ((l <= 0) || (l > members.length))
			{
				l = members.length;
			}
			while (i < l)
			{
				emitParticle();
				i++;
			}
			_quantity = 0;
			_waitForKill = true;
		}
	}
	
	/**
	 * This function can be used both internally and externally to emit the next particle.
	 */
	override public function emitParticle():Void
	{
		//recycle a particle to emit
		var particle:FlxParticle = recycle(FlxParticle);
		particle.elasticity = bounce;
		particle.reset(x - (Std.int(particle.width) >> 1) + FlxG.random() * width, y - (Std.int(particle.height) >> 1) + FlxG.random() * height);
		particle.visible = true;
		
		//set particle motion
		setParticleMotion(particle, angle, distance, lifespan, angleRange, distanceRange, lifespanRange);

		//add gravity
		particle.acceleration.y = gravity;
		
		//set particle rotation
		if(minRotation != maxRotation) { particle.angularVelocity = minRotation + FlxG.random() * (maxRotation - minRotation); }
		else {particle.angularVelocity = minRotation; }
		if (particle.angularVelocity != 0) { particle.angle = FlxG.random() * 360 - 180; }
		
		//set particle drag
		particle.drag.x = particleDrag.x;
		particle.drag.y = particleDrag.y;
		
		//emit particle
		particle.onEmit();
	}
	
}