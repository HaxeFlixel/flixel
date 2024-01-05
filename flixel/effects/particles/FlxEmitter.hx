package flixel.effects.particles;

import openfl.display.BlendMode;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle.IFlxParticle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDirectionFlags;
import flixel.util.helpers.FlxBounds;
import flixel.util.helpers.FlxPointRangeBounds;
import flixel.util.helpers.FlxRangeBounds;

typedef FlxEmitter = FlxTypedEmitter<FlxParticle>;

/**
 * FlxTypedEmitter is a lightweight particle emitter.
 * It can be used for one-time explosions or for continuous fx like rain and fire.
 * `FlxEmitter` is not optimized or anything; all it does is launch `FlxParticle` objects out
 * at set intervals by setting their positions and velocities accordingly.
 * It is easy to use and relatively efficient, relying on `FlxGroup`'s RECYCLE POWERS.
 */
class FlxTypedEmitter<T:FlxSprite & IFlxParticle> extends FlxTypedGroup<T>
{
	/**
	 * Set your own particle class type here. The custom class must extend `FlxParticle`. Default is `FlxParticle`.
	 */
	public var particleClass:Class<T> = cast FlxParticle;
	/**
	 * Determines whether the emitter is currently emitting particles. It is totally safe to directly toggle this.
	 */
	public var emitting:Bool = false;
	/**
	 * How often a particle is emitted (if emitter is started with `Explode == false`).
	 */
	public var frequency:Float = 0.1;
	/**
	 * Sets particle's blend mode. `null` by default. Warning: Expensive on Flash.
	 */
	public var blend:BlendMode;
	/**
	 * The x position of this emitter.
	 */
	public var x:Float = 0;
	/**
	 * The y position of this emitter.
	 */
	public var y:Float = 0;
	/**
	 * The width of this emitter. Particles can be randomly generated from anywhere within this box.
	 */
	public var width:Float = 0;
	/**
	 * The height of this emitter. Particles can be randomly generated from anywhere within this box.
	 */
	public var height:Float = 0;
	/**
	 * How particles should be launched. If `CIRCLE`, particles will use `launchAngle` and `speed`.
	 * Otherwise, particles will just use `velocity.x` and `velocity.y`.
	 */
	public var launchMode:FlxEmitterMode = FlxEmitterMode.CIRCLE;
	/**
	 * Keep the scale ratio of the particle. Uses the `x` values of `scale`.
	 */
	public var keepScaleRatio:Bool = false;
	/**
	 * Sets the velocity range of particles launched from this emitter. Only used with `FlxEmitterMode.SQUARE`.
	 */
	public var velocity(default, null):FlxPointRangeBounds = new FlxPointRangeBounds(-100, -100, 100, 100);
	/**
	 * Set the speed range of particles launched from this emitter. Only used with `FlxEmitterMode.CIRCLE`.
	 */
	public var speed(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(0, 100);
	/**
	 * Set the angular acceleration range of particles launched from this emitter.
	 */
	public var angularAcceleration(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(0, 0);
	/**
	 * Set the angular drag range of particles launched from this emitter.
	 */
	public var angularDrag(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(0, 0);
	/**
	 * The angular velocity range of particles launched from this emitter.
	 */
	public var angularVelocity(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(0, 0);
	/**
	 * The angle range of particles launched from this emitter.
	 * `angle.end` is ignored unless `ignoreAngularVelocity` is set to `true`.
	 */
	public var angle(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(0);
	/**
	 * Set this if you want to specify the beginning and ending value of angle,
	 * instead of using `angularVelocity` (or `angularAcceleration`).
	 */
	public var ignoreAngularVelocity:Bool = false;
	/**
	 * The angle range at which particles will be launched from this emitter.
	 * Ignored unless `launchMode` is set to `FlxEmitterMode.CIRCLE`.
	 */
	public var launchAngle(default, null):FlxBounds<Float> = new FlxBounds<Float>(-180, 180);
	/**
	 * The life, or duration, range of particles launched from this emitter.
	 */
	public var lifespan(default, null):FlxBounds<Float> = new FlxBounds<Float>(3);
	/**
	 * Sets `scale` range of particles launched from this emitter.
	 */
	public var scale(default, null):FlxPointRangeBounds = new FlxPointRangeBounds(1, 1);
	/**
	 * Sets `alpha` range of particles launched from this emitter.
	 */
	public var alpha(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(1);
	/**
	 * Sets `color` range of particles launched from this emitter.
	 */
	public var color(default, null):FlxRangeBounds<FlxColor> = new FlxRangeBounds(FlxColor.WHITE, FlxColor.WHITE);
	/**
	 * Sets X and Y drag component of particles launched from this emitter.
	 */
	public var drag(default, null):FlxPointRangeBounds = new FlxPointRangeBounds(0, 0);
	/**
	 * Sets the `acceleration` range of particles launched from this emitter.
	 * Set acceleration y-values to give particles gravity.
	 */
	public var acceleration(default, null):FlxPointRangeBounds = new FlxPointRangeBounds(0, 0);
	/**
	 * Sets the `elasticity`, or bounce, range of particles launched from this emitter.
	 */
	public var elasticity(default, null):FlxRangeBounds<Float> = new FlxRangeBounds<Float>(0);
	/**
	 * Sets the `immovable` flag for particles launched from this emitter.
	 */
	public var immovable:Bool = false;
	/**
	 * Sets the `autoUpdateHitbox` flag for particles launched from this emitter.
	 * If true, the particles' hitbox will be updated to match scale.
	 */
	public var autoUpdateHitbox:Bool = false;
	/**
	 * Sets the `allowCollisions` value for particles launched from this emitter.
	 * Set to `NONE` by default. Don't forget to call `FlxG.collide()` in your update loop!
	 */
	public var allowCollisions:FlxDirectionFlags = NONE;
	/**
	 * Shorthand for toggling `allowCollisions` between `ANY` (if `true`) and `NONE` (if `false`).
	 * Don't forget to call `FlxG.collide()` in your update loop!
	 */
	public var solid(get, set):Bool;

	/**
	 * Internal helper for deciding how many particles to launch.
	 */
	var _quantity:Int = 0;

	/**
	 * Internal helper for the style of particle emission (all at once, or one at a time).
	 */
	var _explode:Bool = true;

	/**
	 * Internal helper for deciding when to launch particles or kill them.
	 */
	var _timer:Float = 0;

	/**
	 * Internal counter for figuring out how many particles to launch.
	 */
	var _counter:Int = 0;

	/**
	 * Internal point object, handy for reusing for memory management purposes.
	 */
	var _point:FlxPoint = FlxPoint.get();

	/**
	 * Internal helper for automatically calling the `kill()` method
	 */
	var _waitForKill:Bool = false;

	/**
	 * Creates a new `FlxTypedEmitter` object at a specific position.
	 * Does NOT automatically generate or attach particles!
	 *
	 * @param   X      The X position of the emitter.
	 * @param   Y      The Y position of the emitter.
	 * @param   Size   Optional, specifies a maximum capacity for this emitter.
	 */
	public function new(X:Float = 0, Y:Float = 0, Size:Int = 0)
	{
		super(Size);

		setPosition(X, Y);
		exists = false;
	}

	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		velocity = FlxDestroyUtil.destroy(velocity);
		scale = FlxDestroyUtil.destroy(scale);
		drag = FlxDestroyUtil.destroy(drag);
		acceleration = FlxDestroyUtil.destroy(acceleration);
		_point = FlxDestroyUtil.put(_point);

		blend = null;
		angularAcceleration = null;
		angularDrag = null;
		angularVelocity = null;
		angle = null;
		speed = null;
		launchAngle = null;
		lifespan = null;
		alpha = null;
		color = null;
		elasticity = null;

		super.destroy();
	}

	/**
	 * This function generates a new array of particle sprites to attach to the emitter.
	 *
	 * @param   Graphics         If you opted to not pre-configure an array of `FlxParticle` objects,
	 *                           you can simply pass in a particle image or sprite sheet.
	 * @param   Quantity         The number of particles to generate when using the "create from image" option.
	 * @param   BakedRotations   How many frames of baked rotation to use (boosts performance).
	 *                           Set to zero to not use baked rotations.
	 * @param   Multiple         Whether the image in the `Graphics` param is a single particle or a bunch of particles
	 *                           (if it's a bunch, they need to be square!).
	 * @param   AutoBuffer       Whether to automatically increase the image size to accommodate rotated corners.
	 *                           Default is `false`. Will create frames that are 150% larger on each axis than the
	 *                           original frame or graphic.
	 * @return  This `FlxEmitter` instance (nice for chaining stuff together).
	 */
	public function loadParticles(Graphics:FlxGraphicAsset, Quantity:Int = 50, bakedRotationAngles:Int = 16, Multiple:Bool = false,
			AutoBuffer:Bool = false):FlxTypedEmitter<T>
	{
		maxSize = Quantity;
		var totalFrames:Int = 1;

		if (Multiple)
		{
			var sprite = new FlxSprite();
			sprite.loadGraphic(Graphics, true);
			totalFrames = sprite.numFrames;
			sprite.destroy();
		}

		for (i in 0...Quantity)
			add(loadParticle(Graphics, Quantity, bakedRotationAngles, Multiple, AutoBuffer, totalFrames));

		return this;
	}

	function loadParticle(Graphics:FlxGraphicAsset, Quantity:Int, bakedRotationAngles:Int, Multiple:Bool = false, AutoBuffer:Bool = false, totalFrames:Int):T
	{
		var particle:T = Type.createInstance(particleClass, []);
		var frame = Multiple ? FlxG.random.int(0, totalFrames - 1) : -1;

		if (FlxG.renderBlit && bakedRotationAngles > 0)
			particle.loadRotatedGraphic(Graphics, bakedRotationAngles, frame, false, AutoBuffer);
		else
			particle.loadGraphic(Graphics, Multiple);

		if (Multiple)
			particle.animation.frameIndex = frame;

		return particle;
	}

	/**
	 * Similar to `FlxSprite#makeGraphic()`, this function allows you to quickly make single-color particles.
	 *
	 * @param   Width      The width of the generated particles. Default is `2` pixels.
	 * @param   Height     The height of the generated particles. Default is `2` pixels.
	 * @param   Color      The color of the generated particles. Default is white.
	 * @param   Quantity   How many particles to generate. Default is `50`.
	 * @return  This `FlxEmitter` instance (nice for chaining stuff together).
	 */
	public function makeParticles(Width:Int = 2, Height:Int = 2, Color:FlxColor = FlxColor.WHITE, Quantity:Int = 50):FlxTypedEmitter<T>
	{
		maxSize = Quantity;

		for (i in 0...Quantity)
		{
			var particle:T = Type.createInstance(particleClass, []);
			particle.makeGraphic(Width, Height, Color);
			add(particle);
		}

		return this;
	}

	/**
	 * Called automatically by the game loop, decides when to launch particles and when to "die".
	 */
	override public function update(elapsed:Float):Void
	{
		if (emitting)
		{
			if (_explode)
				explode();
			else
				emitContinuously(elapsed);
		}
		else if (_waitForKill)
		{
			_timer += elapsed;

			if ((lifespan.max > 0) && (_timer > lifespan.max))
			{
				kill();
				return;
			}
		}

		super.update(elapsed);
	}

	function explode():Void
	{
		var amount:Int = _quantity;
		if (amount <= 0 || amount > length)
			amount = length;

		for (i in 0...amount)
			emitParticle();

		onFinished();
	}

	function emitContinuously(elapsed:Float):Void
	{
		// Spawn one particle per frame
		if (frequency <= 0)
		{
			emitParticleContinuously();
		}
		else
		{
			_timer += elapsed;

			while (_timer > frequency)
			{
				_timer -= frequency;
				emitParticleContinuously();
			}
		}
	}

	function emitParticleContinuously():Void
	{
		emitParticle();
		_counter++;

		if (_quantity > 0 && _counter >= _quantity)
			onFinished();
	}

	function onFinished():Void
	{
		emitting = false;
		_waitForKill = true;
		_quantity = 0;
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
	 * @param   Explode     Whether the particles should all burst out at once.
	 * @param   Frequency   Ignored if `Explode` is set to `true`. `Frequency` is how often to emit a particle.
	 *                      `0` = never emit, `0.1` = 1 particle every 0.1 seconds, `5` = 1 particle every 5 seconds.
	 * @param   Quantity    How many particles to launch. `0` = "all of the particles".
	 * @return  This `FlxEmitter` instance (nice for chaining stuff together).
	 */
	public function start(Explode:Bool = true, Frequency:Float = 0.1, Quantity:Int = 0):FlxTypedEmitter<T>
	{
		exists = true;
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
	public function emitParticle():T
	{
		var particle:T = cast recycle(cast particleClass);

		particle.reset(0, 0); // Position is set later, after size has been calculated

		particle.blend = blend;
		particle.immovable = immovable;
		particle.solid = solid;
		particle.allowCollisions = allowCollisions;
		particle.autoUpdateHitbox = autoUpdateHitbox;

		// Particle lifespan settings
		if (lifespan.active)
		{
			particle.lifespan = FlxG.random.float(lifespan.min, lifespan.max);
		}

		if (velocity.active)
		{
			// Particle velocity/launch angle settings
			particle.velocityRange.active = particle.lifespan > 0 && !particle.velocityRange.start.equals(particle.velocityRange.end);

			if (launchMode == FlxEmitterMode.CIRCLE)
			{
				var particleAngle:Float = 0;
				if (launchAngle.active)
					particleAngle = FlxG.random.float(launchAngle.min, launchAngle.max);

				// Calculate launch velocity
				_point = FlxVelocity.velocityFromAngle(particleAngle, FlxG.random.float(speed.start.min, speed.start.max));
				particle.velocity.x = _point.x;
				particle.velocity.y = _point.y;
				particle.velocityRange.start.set(_point.x, _point.y);

				// Calculate final velocity
				_point = FlxVelocity.velocityFromAngle(particleAngle, FlxG.random.float(speed.end.min, speed.end.max));
				particle.velocityRange.end.set(_point.x, _point.y);
			}
			else
			{
				particle.velocityRange.start.x = FlxG.random.float(velocity.start.min.x, velocity.start.max.x);
				particle.velocityRange.start.y = FlxG.random.float(velocity.start.min.y, velocity.start.max.y);
				particle.velocityRange.end.x = FlxG.random.float(velocity.end.min.x, velocity.end.max.x);
				particle.velocityRange.end.y = FlxG.random.float(velocity.end.min.y, velocity.end.max.y);
				particle.velocity.x = particle.velocityRange.start.x;
				particle.velocity.y = particle.velocityRange.start.y;
			}
		}
		else
			particle.velocityRange.active = false;

		// Particle angular velocity settings
		particle.angularVelocityRange.active = particle.lifespan > 0 && angularVelocity.start != angularVelocity.end;

		if (!ignoreAngularVelocity)
		{
			if (angularAcceleration.active)
				particle.angularAcceleration = FlxG.random.float(angularAcceleration.start.min, angularAcceleration.start.max);

			if (angularVelocity.active)
			{
				particle.angularVelocityRange.start = FlxG.random.float(angularVelocity.start.min, angularVelocity.start.max);
				particle.angularVelocityRange.end = FlxG.random.float(angularVelocity.end.min, angularVelocity.end.max);
				particle.angularVelocity = particle.angularVelocityRange.start;
			}

			if (angularDrag.active)
				particle.angularDrag = FlxG.random.float(angularDrag.start.min, angularDrag.start.max);
		}
		else if (angularVelocity.active)
		{
			particle.angularVelocity = (FlxG.random.float(angle.end.min,
				angle.end.max) - FlxG.random.float(angle.start.min, angle.start.max)) / FlxG.random.float(lifespan.min, lifespan.max);
			particle.angularVelocityRange.active = false;
		}

		// Particle angle settings
		if (angle.active)
			particle.angle = FlxG.random.float(angle.start.min, angle.start.max);

		// Particle scale settings
		if (scale.active)
		{
			particle.scaleRange.start.x = FlxG.random.float(scale.start.min.x, scale.start.max.x);
			particle.scaleRange.start.y = keepScaleRatio ? particle.scaleRange.start.x : FlxG.random.float(scale.start.min.y, scale.start.max.y);
			particle.scaleRange.end.x = FlxG.random.float(scale.end.min.x, scale.end.max.x);
			particle.scaleRange.end.y = keepScaleRatio ? particle.scaleRange.end.x : FlxG.random.float(scale.end.min.y, scale.end.max.y);
			particle.scaleRange.active = particle.lifespan > 0 && !particle.scaleRange.start.equals(particle.scaleRange.end);
			particle.scale.x = particle.scaleRange.start.x;
			particle.scale.y = particle.scaleRange.start.y;
			if (particle.autoUpdateHitbox)
				particle.updateHitbox();
		}
		else
			particle.scaleRange.active = false;

		// Particle alpha settings
		if (alpha.active)
		{
			particle.alphaRange.start = FlxG.random.float(alpha.start.min, alpha.start.max);
			particle.alphaRange.end = FlxG.random.float(alpha.end.min, alpha.end.max);
			particle.alphaRange.active = particle.lifespan > 0 && particle.alphaRange.start != particle.alphaRange.end;
			particle.alpha = particle.alphaRange.start;
		}
		else
			particle.alphaRange.active = false;

		// Particle color settings
		if (color.active)
		{
			particle.colorRange.start = FlxG.random.color(color.start.min, color.start.max);
			particle.colorRange.end = FlxG.random.color(color.end.min, color.end.max);
			particle.colorRange.active = particle.lifespan > 0 && particle.colorRange.start != particle.colorRange.end;
			particle.color = particle.colorRange.start;
		}
		else
			particle.colorRange.active = false;

		// Particle drag settings
		if (drag.active)
		{
			particle.dragRange.start.x = FlxG.random.float(drag.start.min.x, drag.start.max.x);
			particle.dragRange.start.y = FlxG.random.float(drag.start.min.y, drag.start.max.y);
			particle.dragRange.end.x = FlxG.random.float(drag.end.min.x, drag.end.max.x);
			particle.dragRange.end.y = FlxG.random.float(drag.end.min.y, drag.end.max.y);
			particle.dragRange.active = particle.lifespan > 0 && !particle.dragRange.start.equals(particle.dragRange.end);
			particle.drag.x = particle.dragRange.start.x;
			particle.drag.y = particle.dragRange.start.y;
		}
		else
			particle.dragRange.active = false;

		// Particle acceleration settings
		if (acceleration.active)
		{
			particle.accelerationRange.start.x = FlxG.random.float(acceleration.start.min.x, acceleration.start.max.x);
			particle.accelerationRange.start.y = FlxG.random.float(acceleration.start.min.y, acceleration.start.max.y);
			particle.accelerationRange.end.x = FlxG.random.float(acceleration.end.min.x, acceleration.end.max.x);
			particle.accelerationRange.end.y = FlxG.random.float(acceleration.end.min.y, acceleration.end.max.y);
			particle.accelerationRange.active = particle.lifespan > 0
				&& !particle.accelerationRange.start.equals(particle.accelerationRange.end);
			particle.acceleration.x = particle.accelerationRange.start.x;
			particle.acceleration.y = particle.accelerationRange.start.y;
		}
		else
			particle.accelerationRange.active = false;

		// Particle elasticity settings
		if (elasticity.active)
		{
			particle.elasticityRange.start = FlxG.random.float(elasticity.start.min, elasticity.start.max);
			particle.elasticityRange.end = FlxG.random.float(elasticity.end.min, elasticity.end.max);
			particle.elasticityRange.active = particle.lifespan > 0 && particle.elasticityRange.start != particle.elasticityRange.end;
			particle.elasticity = particle.elasticityRange.start;
		}
		else
			particle.elasticityRange.active = false;

		// Set position
		particle.x = FlxG.random.float(x, x + width) - particle.width / 2;
		particle.y = FlxG.random.float(y, y + height) - particle.height / 2;

		// Restart animation
		if (particle.animation.curAnim != null)
			particle.animation.curAnim.restart();

		particle.onEmit();

		return particle;
	}

	/**
	 * Change the emitter's midpoint to match the midpoint of a `FlxObject`.
	 *
	 * @param   Object   The `FlxObject` that you want to sync up with.
	 */
	public function focusOn(Object:FlxObject):Void
	{
		Object.getMidpoint(_point);

		x = _point.x - (Std.int(width) >> 1);
		y = _point.y - (Std.int(height) >> 1);
	}

	/**
	 * Helper function to set the coordinates of this object.
	 */
	public inline function setPosition(X:Float = 0, Y:Float = 0):Void
	{
		x = X;
		y = Y;
	}

	public inline function setSize(Width:Float, Height:Float):Void
	{
		width = Width;
		height = Height;
	}

	inline function get_solid():Bool
	{
		return allowCollisions.has(ANY);
	}

	function set_solid(Solid:Bool):Bool
	{
		if (Solid)
		{
			allowCollisions = ANY;
		}
		else
		{
			allowCollisions = NONE;
		}
		return Solid;
	}
}
enum FlxEmitterMode
{
	SQUARE;
	CIRCLE;
}
