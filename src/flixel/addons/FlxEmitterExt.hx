package flixel.addons;

import flixel.FlxEmitter;
import flixel.FlxParticle;
import flixel.util.FlxRandom;

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
 */
class FlxTypedEmitterExt<T:FlxParticle> extends FlxTypedEmitter<FlxParticle> 
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
	 * Creates a new <code>FlxEmitterExt</code> object at a specific position.
	 * Does NOT automatically generate or attach particles!
	 * 
	 * @param	X		The X position of the emitter.
	 * @param	Y		The Y position of the emitter.
	 * @param	Size	Optional, specifies a maximum capacity for this emitter.
	 */
	public function new(X:Float = 0, Y:Float = 0, Size:Float = 0) 
	{
		super(X, Y, Std.int(Size));
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
		this.angle = angle * 0.017453293;
		this.distance = distance;
		this.life.min = lifespan;
		this.life.max = lifespan + lifespanRange;
		this.angleRange = angleRange * 0.017453293;
		this.distanceRange = distanceRange;
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
	private function setParticleMotion(particle:FlxParticle, angle:Float, distance:Float, angleRange:Float = 0, distanceRange:Float = 0):Void
	{			
		//set particle direction and speed
		var a:Float = angle + FlxRandom.float() * angleRange;
		var d:Float = distance + FlxRandom.float() * distanceRange;
		
		particle.velocity.x = Math.cos(a) * d;
		particle.velocity.y = Math.sin(a) * d;
	}
	
	/**
	 * Call this function to start emitting particles.
	 * 
	 * @param	Explode		Whether the particles should all burst out at once.
	 * @param	Lifespan	Unused parameter due to class override. Use setMotion to set things like a particle's lifespan.
	 * @param	Frequency	Ignored if Explode is set to true. Frequency is how often to emit a particle. 0 = never emit, 0.1 = 1 particle every 0.1 seconds, 5 = 1 particle every 5 seconds.
	 * @param	Quantity	How many particles to launch. 0 = "all of the particles".
	 * @param	LifespanRange	Max amount to add to the particle's lifespan. Leave it to default (zero), if you want to make particle "live" forever (plus you should set Lifespan parameter to zero too).
	 */
	override public function start(Explode:Bool = true, Lifespan:Float = 0, Frequency:Float = 0.1, Quantity:Int = 0, LifespanRange:Float = 0):Void
	{
		super.start(Explode, Lifespan, Frequency, Quantity, LifespanRange);

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
		}
	}
	
	/**
	 * This function can be used both internally and externally to emit the next particle.
	 */
	override public function emitParticle():Void
	{
		var particle:FlxParticle = recycle(cast _particleClass);
		particle.elasticity = bounce;
		
		particle.reset(x - (Std.int(particle.width) >> 1) + FlxRandom.float() * width, y - (Std.int(particle.height) >> 1) + FlxRandom.float() * height);
		particle.visible = true;
		
		if (life.min != life.max)
		{
			particle.lifespan = particle.maxLifespan = life.min + FlxRandom.float() * (life.max - life.min);
		}
		else
		{
			particle.lifespan = particle.maxLifespan = life.min;
		}
		
		if (startAlpha.min != startAlpha.max)
		{
			particle.startAlpha = startAlpha.min + FlxRandom.float() * (startAlpha.max - startAlpha.min);
		}
		else
		{
			particle.startAlpha = startAlpha.min;
		}
		particle.alpha = particle.startAlpha;
		
		var particleEndAlpha:Float = endAlpha.min;
		if (endAlpha.min != endAlpha.max)
		{
			particleEndAlpha = endAlpha.min + FlxRandom.float() * (endAlpha.max - endAlpha.min);
		}
		
		if (particleEndAlpha != particle.startAlpha)
		{
			particle.useFading = true;
			particle.rangeAlpha = particleEndAlpha - particle.startAlpha;
		}
		else
		{
			particle.useFading = false;
			particle.rangeAlpha = 0;
		}
		// particle color settings
		var startRedComp:Float = particle.startRed = startRed.min;
		var startGreenComp:Float = particle.startGreen = startGreen.min;
		var startBlueComp:Float = particle.startBlue = startBlue.min;
		
		var endRedComp:Float = endRed.min;
		var endGreenComp:Float = endGreen.min;
		var endBlueComp:Float = endBlue.min;
		
		if (startRed.min != startRed.max)
		{
			particle.startRed = startRedComp = startRed.min + FlxRandom.float() * (startRed.max - startRed.min);
		}
		if (startGreen.min != startGreen.max)
		{
			particle.startGreen = startGreenComp = startGreen.min + FlxRandom.float() * (startGreen.max - startGreen.min);
		}
		if (startBlue.min != startBlue.max)
		{
			particle.startBlue = startBlueComp = startBlue.min + FlxRandom.float() * (startBlue.max - startBlue.min);
		}
		
		if (endRed.min != endRed.max)
		{
			endRedComp = endRed.min + FlxRandom.float() * (endRed.max - endRed.min);
		}
		
		if (endGreen.min != endGreen.max)
		{
			endGreenComp = endGreen.min + FlxRandom.float() * (endGreen.max - endGreen.min);
		}
		
		if (endBlue.min != endBlue.max)
		{
			endBlueComp = endBlue.min + FlxRandom.float() * (endBlue.max - endBlue.min);
		}
		
		particle.rangeRed = endRedComp - startRedComp;
		particle.rangeGreen = endGreenComp - startGreenComp;
		particle.rangeBlue = endBlueComp - startBlueComp;
		
		particle.useColoring = false;
		if (particle.rangeRed != 0 || particle.rangeGreen != 0 || particle.rangeBlue != 0)
		{
			particle.useColoring = true;
		}
		// end of particle color settings
		if (startScale.min != startScale.max)
		{
			particle.startScale = startScale.min + FlxRandom.float() * (startScale.max - startScale.min);
		}
		else
		{
			particle.startScale = startScale.min;
		}
		particle.scale.x = particle.scale.y = particle.startScale;
		
		var particleEndScale:Float = endScale.min;
		if (endScale.min != endScale.max)
		{
			particleEndScale = endScale.min + Std.int(FlxRandom.float() * (endScale.max - endScale.min));
		}
		
		if (particleEndScale != particle.startScale)
		{
			particle.useScaling = true;
			particle.rangeScale = particleEndScale - particle.startScale;
		}
		else
		{
			particle.useScaling = false;
			particle.rangeScale = 0;
		}
		
		particle.blend = blend;
		
		//set particle motion
		setParticleMotion(particle, angle, distance, angleRange, distanceRange);
		particle.acceleration.make(acceleration.x, acceleration.y);
		
		if (rotation.min != rotation.max)
		{
			particle.angularVelocity = rotation.min + FlxRandom.float() * (rotation.max - rotation.min);
		}
		else
		{
			particle.angularVelocity = rotation.min;
		}
		if (particle.angularVelocity != 0)
		{
			particle.angle = FlxRandom.float() * 360 - 180;
		}
		
		particle.drag.make(particleDrag.x, particleDrag.y);
		particle.onEmit();
	}
}