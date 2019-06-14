package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;

/**
 * ...
 * @author David Bell
 */
class Bullet extends FlxSprite
{
	public function new()
	{
		super();

		loadGraphic("assets/art/bullet.png", false);
		// We don't want the bullets to exist anywhere before we call them.
		exists = false;
	}

	override public function update(elapsed:Float):Void
	{
		// Finished refers to animation, only included here in case I add animation later
		if (!alive && animation.finished)
		{
			// Stop paying attention when the bullet dies.
			exists = false;
		}

		if (getScreenPosition().x < -64 || getScreenPosition().x > FlxG.width + 64)
		{
			// If the bullet makes it 64 pixels off the side of the screen, kill it
			kill();
		}
		else if (touching != 0)
		{
			// We want the bullet to go away when it hits something, not just stop.
			kill();
		}
		else
		{
			super.update(elapsed);
		}
	}

	/**
	 * We need some sort of function other classes can call that will let us actually fire the bullet.
	 */
	public function shoot(X:Int, Y:Int, VelocityX:Int, VelocityY:Int):Void
	{
		// reset() makes the sprite exist again, at the new location you tell it.
		super.reset(X, Y);

		solid = true;
		velocity.x = VelocityX;
		velocity.y = VelocityY;
	}

	public function angleshoot(X:Int, Y:Int, Speed:Int, Target:FlxPoint):Void
	{
		super.reset(X, Y);

		solid = true;
		var rangle:Float = Math.atan2(Target.y - (y + (height / 2)), Target.x - (x + (width / 2))); // This gives angle in radians
		velocity.x = Math.cos(rangle) * Speed;
		velocity.y = Math.sin(rangle) * Speed;
	}
}
