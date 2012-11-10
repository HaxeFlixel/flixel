package;

import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxU;

/**
 * ...
 * @author Zaphod
 */
class PlayerShip extends WrapSprite
{
	
	private var _thrust:Float;
	
	public function new() 
	{
		super(Math.floor(FlxG.width / 2 - 8), Math.floor(FlxG.height / 2 - 8));
		#if flash
		loadRotatedGraphic("assets/ship.png", 32, -1, false, true);
		#else
		loadGraphic("assets/ship.png");
		#end
		alterBoundingBox();
		_thrust = 0;
	}
	
	override public function update():Void 
	{
		wrap();
		angularVelocity = 0;
		
		if (FlxG.keys.LEFT)
		{
			angularVelocity -= 240;
		}
		if(FlxG.keys.RIGHT)
		{
			angularVelocity += 240;
		}
		
		acceleration.x = 0;
		acceleration.y = 0;
		if (FlxG.keys.UP)
		{
			FlxU.rotatePoint(90,0,0,0,angle,acceleration);
		}

		if(FlxG.keys.justPressed("SPACE"))
		{
			var bullet:FlxSprite = cast(cast(FlxG.state, PlayState).bullets.recycle(), FlxSprite);
			bullet.reset(x + (width - bullet.width)/2, y + (height - bullet.height)/2);
			bullet.angle = angle;
			FlxU.rotatePoint(150,0,0,0,bullet.angle,bullet.velocity);
			bullet.velocity.x += velocity.x;
			bullet.velocity.y += velocity.y;
		}

	}
	
}