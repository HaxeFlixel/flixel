package;

/**
 * @author Masadow
 */
class Bullet extends Entity
{
	public function new(X:Float = -1000, Y:Float = -1000)
	{
		super(X, Y);
		loadRotatedGraphic("images/Bullet.png", 360, -1, true, true);
		radius = 14;
		hitboxRadius = 8;
		width = height = 28;
		offset.y = 0.5 * (28 - 9);
		kill();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		angle = Entity.angleInDegrees(velocity);
		if (!isOnScreen())
		{
			ScreenState.makeExplosion(Particle.BULLET, position.x, position.y, 20, Particle.LOW_SPEED, 0x33ccff, 0x22bbdd);
			kill();
		}
		#if !js
		else
			ScreenState.grid.applyExplosiveForce(position, 0.25 * Math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y), 80);
		#end
	}

	override public function reset(X:Float, Y:Float):Void
	{
		cooldownTimer.cancel();
		alpha = 1;
		acceleration.x = acceleration.y = 0;
		angularVelocity = 0;
		super.reset(X - 0.5 * width, Y - 0.5 * height);
	}
}
