package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;
import flixel.util.FlxVelocity;


/**
 * ...
 * @author Zaphod
 */
class Ship extends FlxSprite
{

	public function new(Velocity:Float, Angle:Float) 
	{
		super(Math.random() * FlxG.width, Math.random() * FlxG.height, "assets/ship.png");
		angle = Angle;
		velocity = FlxVelocity.velocityFromAngle(Math.floor(Angle + 270), Math.floor(Velocity));
	}
	
	override public function update():Void 
	{
		if (velocity.y > 0)
		{
			if (y > FlxG.height)
				y = - height;
		}
		else
		{
			if (y < -height)
				y = FlxG.height + height;
		}
		
		if (velocity.x > 0)
		{
			if (x > FlxG.width)
				x = - width;
		}
		else
		{
			if (x < -width)
				x = FlxG.width + width;
		}
		
		super.update();
	}
	
}