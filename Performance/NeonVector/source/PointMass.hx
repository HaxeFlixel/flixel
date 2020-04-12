package;

import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;

/**
 * @author Masadow
 */
class PointMass
{
	public var position:FlxPoint;
	public var velocity:FlxPoint;
	public var acceleration:FlxPoint;
	public var inverseMass:Float;
	public var damping:Float;

	public function new(X:Float, Y:Float, InverseMass:Float)
	{
		position = FlxPoint.get(X, Y);
		velocity = FlxPoint.get();
		acceleration = FlxPoint.get();
		damping = 0.98;
		inverseMass = InverseMass;
	}

	public function applyForce(ForceX:Float, ForceY:Float):Void
	{
		acceleration.x += ForceX * inverseMass;
		acceleration.y += ForceY * inverseMass;
	}

	public function increaseDamping(Factor:Float):Void
	{
		damping *= Factor;
	}

	public function update(elapsed:Float):Void
	{
		velocity.x += acceleration.x;
		velocity.y += acceleration.y;
		position.x += velocity.x * elapsed;
		position.y += velocity.y * elapsed;
		acceleration.x = 0;
		acceleration.y = 0;
		if ((velocity.x * velocity.x + velocity.y * velocity.y) < (0.001 * 0.001))
		{
			velocity.x = 0;
			velocity.y = 0;
		}
		velocity.x *= damping;
		velocity.y *= damping;
		damping = 0.98;
	}

	/**
	 * Internal function for updating the position and speed of this object.
	 * Useful for cases when you need to update this but are buried down in too many supers.
	 * Does a slightly fancier-than-normal integration to help with higher fidelity framerate-independenct motion.
	 */
	function updateMotion(elapsed:Float):Void
	{
		var delta:Float;
		var velocityDelta:Float;

		velocityDelta = (FlxVelocity.computeVelocity(velocity.x, acceleration.x, Math.abs(damping * velocity.x), 0, elapsed) - velocity.x) / 2;
		velocity.x += velocityDelta;
		delta = velocity.x * elapsed;
		velocity.x += velocityDelta;
		position.x += delta;

		velocityDelta = (FlxVelocity.computeVelocity(velocity.y, acceleration.y, Math.abs(damping * velocity.y), 0, elapsed) - velocity.y) / 2;
		velocity.y += velocityDelta;
		delta = velocity.y * elapsed;
		velocity.y += velocityDelta;
		position.y += delta;
	}
}
