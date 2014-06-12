package flixel.effects.particles;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;
import flixel.util.helpers.Bounds;
import flixel.util.helpers.Range;
import flixel.util.helpers.RangeBounds;
import flixel.util.helpers.FlxPointRangeBounds;

typedef FlxEmitter = FlxTypedEmitter<FlxParticle>;

/**
 * FlxTypedEmitter is a lightweight particle emitter.
 * It can be used for one-time explosions or for
 * continuous fx like rain and fire.  FlxEmitter
 * is not optimized or anything; all it does is launch
 * FlxParticle objects out at set intervals
 * by setting their positions and velocities accordingly.
 * It is easy to use and relatively efficient,
 * relying on FlxGroup's RECYCLE POWERS.
 */
class FlxTypedEmitter<T:(FlxSprite, IFlxParticle)> extends FlxTypedGroup<T>
{
	/**
	 * Set your own particle class type here. The custom class must extend FlxParticle.
	 * Default is FlxParticle.
	 */
	public var particleClass:Class<T>;
	/**
	 * Determines whether the emitter is currently emitting particles. It is totally safe to directly toggle this.
	 */
	public var emitting:Bool = false;
	/**
	 * How often a particle is emitted (if emitter is started with Explode == false).
	 */
	public var frequency:Float = 0.1;
	/**
	 * Sets particle's blend mode. null by default. Warning: Expensive on flash target.
	 */
	public var blend:BlendMode;
	/**
	 * How much each particle should bounce. 1 = full bounce, 0 = no bounce.
	 */
	public var bounce:Float = 0;
	/**
	 * The width of this emitter. Particles can be randomly generated from anywhere within this box.
	 */
	public var width:Float = 0;
	/**
	 * The height of this emitter.  Particles can be randomly generated from anywhere within this box.
	 */
	public var height:Float = 0;
	/**
	 * The x position of this emitter.
	 */
	public var x:Float = 0;
	/**
	 * The y position of this emitter.
	 */
	public var y:Float = 0;
	/**
	 * Shortcut for setting the acceleration.y property of particles launched from this emitter.
	 */
	public var gravity(get, set):Float;
	/**
	 * Sets the velocity range of particles launched from this emitter.
	 */
	public var velocity(default, null):FlxPointRangeBounds;
	/**
	 * The angular velocity range of particles launched from this emitter.
	 */
	public var angularVelocity(default, null):RangeBounds<Float>;
	/**
	 * The angle range of particles launched from this emitter.
	 */
	public var angle(default, null):RangeBounds<Float>;
	/**
	 * The angle range at which particles will be launched from this emitter.
	 */
	public var launchAngle(default, null):Bounds<Float>;
	/**
	 * The distance range for particles launched from this emitter.
	 */
	public var distance(default, null):Bounds<Float>;
	/**
	 * The life, or duration, range of particles launched from this emitter.
	 */
	public var lifespan(default, null):Bounds<Float>;
	/**
	 * Sets scale range of particles launched from this emitter.
	 */
	public var scale(default, null):FlxPointRangeBounds;
	/**
	 * Sets alpha range of particles launched from this emitter.
	 */
	public var alpha(default, null):RangeBounds<Float>;
	/**
	 * Sets color range of particles launched from this emitter.
	 */
	public var color(default, null):RangeBounds<FlxColor>;
	/**
	 * Sets X and Y drag component of particles launched from this emitter.
	 */
	public var drag(default, null):FlxPointRangeBounds;
	/**
	 * Sets the acceleration range of particles launched from this emitter.
	 */
	public var acceleration(default, null):FlxPointRangeBounds;
	/**
	 * Sets the elasticity, or bounce, range of particles launched from this emitter.
	 */
	public var elasticity(default, null):RangeBounds<Float>;
	/**
	 * Internal helper for deciding how many particles to launch.
	 */
	private var _quantity:Int = 0;
	/**
	 * Internal helper for the style of particle emission (all at once, or one at a time).
	 */
	private var _explode:Bool = true;
	/**
	 * Internal helper for deciding when to launch particles or kill them.
	 */
	private var _timer:Float = 0;
	/**
	 * Internal counter for figuring out how many particles to launch.
	 */
	private var _counter:Int = 0;
	/**
	 * Internal point object, handy for reusing for memory mgmt purposes.
	 */
	private var _point:FlxPoint;
	/**
	 * Internal helper for automatic call the kill() method
	 */
	private var _waitForKill:Bool = false;
	
	/**
	 * Creates a new FlxTypedEmitter object at a specific position.
	 * Does NOT automatically generate or attach particles!
	 * 
	 * @param	X		The X position of the emitter.
	 * @param	Y		The Y position of the emitter.
	 * @param	Size	Optional, specifies a maximum capacity for this emitter.
	 */
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0)
	{
		super(Size);
		
		x = X;
		y = Y;
		
		velocity = new FlxPointRangeBounds( -100, 100);
		angularVelocity = new RangeBounds<Float>( -360, 360);
		angle = new RangeBounds<Float>(0);
		launchAngle = null; // this is ignored unless set
		distance = new Bounds<Float>(0);
		lifespan = new Bounds<Float>(3);
		scale = new FlxPointRangeBounds(1, 1);
		alpha = new RangeBounds<Float>(1);
		color = new RangeBounds<FlxColor>(FlxColor.WHITE);
		drag = new FlxPointRangeBounds(0, 0);
		acceleration = new FlxPointRangeBounds(0, 0);
		elasticity = new RangeBounds<Float>(0);
		
		particleClass = cast FlxParticle;
		
		exists = false;
		_point = FlxPoint.get();
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		blend = null;
		velocity = null;
		angularVelocity = null;
		angle = null;
		launchAngle = null;
		distance = null;
		lifespan = null;
		scale = null;
		alpha = null;
		color = null;
		drag = null;
		acceleration = null;
		elasticity = null;
		
		_point = FlxDestroyUtil.put(_point);
		_point = null;
		
		super.destroy();
	}
	
	/**
	 * This function generates a new array of particle sprites to attach to the emitter.
	 * 
	 * @param	Graphics		If you opted to not pre-configure an array of FlxParticle objects, you can simply pass in a particle image or sprite sheet.
	 * @param	Quantity		The number of particles to generate when using the "create from image" option.
	 * @param	BakedRotations	How many frames of baked rotation to use (boosts performance).  Set to zero to not use baked rotations.
	 * @param	Multiple		Whether the image in the Graphics param is a single particle or a bunch of particles (if it's a bunch, they need to be square!).
	 * @param	Collide			Whether the particles should be flagged as not 'dead' (non-colliding particles are higher performance).  0 means no collisions, 0-1 controls scale of particle's bounding box.
	 * @param	AutoBuffer		Whether to automatically increase the image size to accomodate rotated corners.  Default is false.  Will create frames that are 150% larger on each axis than the original frame or graphic.
	 * @return	This FlxEmitter instance (nice for chaining stuff together).
	 */
	public function makeParticles(Graphics:FlxGraphicAsset, Quantity:Int = 50, bakedRotationAngles:Int = 16, Multiple:Bool = false, Collide:Float = 0.8, AutoBuffer:Bool = false):FlxTypedEmitter<T>
	{
		maxSize = Quantity;
		var totalFrames:Int = 1;
		
		if (Multiple)
		{ 
			var sprite = new FlxSprite();
			sprite.loadGraphic(Graphics, true);
			totalFrames = sprite.frames;
			sprite.destroy();
		}
		
		var randomFrame:Int;
		var particle:T;
		var pClass:Class<T> = particleClass;
		var i:Int = 0;
		
		while (i < Quantity)
		{
			particle = Type.createInstance(pClass, []);
			
			if (Multiple)
			{
				randomFrame = FlxRandom.int(0, totalFrames - 1);
				
				if (bakedRotationAngles > 0)
				{
					#if FLX_RENDER_BLIT
					particle.loadRotatedGraphic(Graphics, bakedRotationAngles, randomFrame, false, AutoBuffer);
					#else
					particle.loadGraphic(Graphics, true);
					#end
				}
				else
				{
					particle.loadGraphic(Graphics, true);
				}
				particle.animation.frameIndex = randomFrame;
			}
			else
			{
				if (bakedRotationAngles > 0)
				{
					#if FLX_RENDER_BLIT
					particle.loadRotatedGraphic(Graphics, bakedRotationAngles, -1, false, AutoBuffer);
					#else
					particle.loadGraphic(Graphics);
					#end
				}
				else
				{
					particle.loadGraphic(Graphics);
				}
			}
			if (Collide > 0)
			{
				particle.width *= Collide;
				particle.height *= Collide;
				particle.centerOffsets();
			}
			else
			{
				particle.allowCollisions = FlxObject.NONE;
			}
			
			particle.exists = false;
			add(particle);
			i++;
		}
		
		return this;
	}
	
	/**
	 * Called automatically by the game loop, decides when to launch particles and when to "die".
	 */
	override public function update():Void
	{
		if (emitting)
		{
			if (_explode)
			{
				emitting = false;
				_waitForKill = true;
				
				var i:Int = 0;
				var l:Int = _quantity;
				
				if ((l <= 0) || (l > length))
				{
					l = length;
				}
				
				while (i < l)
				{
					emitParticle();
					i++;
				}
				
				_quantity = 0;
			}
			else
			{
				// Spawn a particle per frame
				if (frequency <= 0)
				{
					emitParticle();
					
					if ((_quantity > 0) && (++_counter >= _quantity))
					{
						emitting = false;
						_waitForKill = true;
						_quantity = 0;
					}
				}
				else
				{
					_timer += FlxG.elapsed;
					
					while (_timer > frequency)
					{
						_timer -= frequency;
						emitParticle();
						
						if ((_quantity > 0) && (++_counter >= _quantity))
						{
							emitting = false;
							_waitForKill = true;
							_quantity = 0;
						}
					}
				}
			}
		}
		else if (_waitForKill)
		{
			_timer += FlxG.elapsed;
			
			if ((lifespan.max > 0) && (_timer > lifespan.max))
			{
				kill();
				return;
			}
		}
		
		super.update();
	}
	
	/**
	 * Call this function to turn off all the particles and the emitter.
	 */
	override public function kill():Void
	{
		emitting = false;
		_waitForKill = false;
		
		super.kill();
	}
	
	/**
	 * Call this function to start emitting particles.
	 * 
	 * @param	Explode			Whether the particles should all burst out at once.
	 * @param	Frequency		Ignored if Explode is set to true. Frequency is how often to emit a particle. 0 = never emit, 0.1 = 1 particle every 0.1 seconds, 5 = 1 particle every 5 seconds.
	 * @param	Quantity		Ignored if Explode is set to true. How many particles to launch. 0 = "all of the particles".
	 * @return	This FlxEmitter instance (nice for chaining stuff together).
	 */
	public function start(Explode:Bool = true, Frequency:Float = 0.1, Quantity:Int = 0, LifespanRange:Float = 0):FlxTypedEmitter<T>
	{
		revive();
		visible = true;
		emitting = true;
		
		_explode = Explode;
		frequency = Frequency;
		_quantity += Quantity;
		
		_counter = 0;
		_timer = 0;
		
		_waitForKill = false;
		
		return this;
	}
	
	/**
	 * This function can be used both internally and externally to emit the next particle.
	 */
	public function emitParticle():Void
	{
		var particle:T = cast recycle(cast particleClass);
		
		particle.reset(x - (Std.int(particle.width) >> 1) + FlxRandom.float() * width, y - (Std.int(particle.height) >> 1) + FlxRandom.float() * height);
		particle.visible = true;
		
		// Particle velocity/launch angle settings
		
		if (launchAngle != null)
		{
			//FlxVelocity.
		}
		else
		{
			particle.velocity.x = FlxRandom.float(velocity.start.min.x, velocity.start.max.x);
			particle.velocity.y = FlxRandom.float(velocity.start.min.y, velocity.start.max.y);
		}
		
		// Particle angular velocity settings
		
		particle.useAngularVelocity = angularVelocity.start == angularVelocity.end;
		particle.angularVelocity = FlxRandom.float(angularVelocity.start.min, angularVelocity.start.max);
		particle.endAngularVelocity = FlxRandom.float(angularVelocity.end.min, angularVelocity.end.max);
		
		// Particle angle settings
		
		particle.angle = FlxRandom.float(angle.start.min, angle.start.max);
		
		// Particle lifespan settings
		
		particle.lifespan = FlxRandom.float(lifespan.min, lifespan.max);
		
		// Particle alpha settings
		
		particle.useFading = alpha.start == alpha.end;
		particle.alpha = FlxRandom.float(alpha.start.min, alpha.start.max);
		particle.endAlpha = FlxRandom.float(alpha.end.min, alpha.end.max);
		
		// Particle color settings
		
		particle.useColoring = color.start == color.end;
		particle.color = FlxRandom.color(color.start.min, color.start.max);
		particle.endColor = FlxRandom.color(color.end.min, color.end.max);
		
		
		
		
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
			particleEndScale = endScale.min + FlxRandom.int(0, Std.int(endScale.max - endScale.min));
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
		
		if (xVelocity.min != xVelocity.max)
		{
			particle.velocity.x = xVelocity.min + FlxRandom.float() * (xVelocity.max - xVelocity.min);
		}
		else
		{
			particle.velocity.x = xVelocity.min;
		}
		if (yVelocity.min != yVelocity.max)
		{
			particle.velocity.y = yVelocity.min + FlxRandom.float() * (yVelocity.max - yVelocity.min);
		}
		else
		{
			particle.velocity.y = yVelocity.min;
		}
		particle.acceleration.set(acceleration.x, acceleration.y);
		
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
			particle.angle = FlxRandom.float( -180, 180);
		}
		
		particle.drag.set(particleDrag.x, particleDrag.y);
		particle.onEmit();
	}
	
	/**
	 * Change the emitter's midpoint to match the midpoint of a FlxObject.
	 * 
	 * @param	Object		The FlxObject that you want to sync up with.
	 */
	public function focusOn(Object:FlxObject):Void
	{
		Object.getMidpoint(_point);
		
		x = _point.x - (Std.int(width) >> 1);
		y = _point.y - (Std.int(height) >> 1);
	}
	
	private inline function get_gravity():Float
	{
		return acceleration.y;
	}
	
	private inline function set_gravity(Value:Float):Float
	{
		return acceleration.y = Value;
	}
}