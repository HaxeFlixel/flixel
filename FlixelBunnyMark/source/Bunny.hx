package ;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Zaphod
 */

class Bunny extends FlxSprite
{
	
	public function new(gravity:Float = 0) 
	{
		super();
		#if flash
		loadRotatedGraphic("assets/wabbit_alpha.png", 16, -1, false, true);
		#else
		loadGraphic("assets/wabbit_alpha.png");
		#end
		velocity.x = 50 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
		velocity.y = 50 * ((Math.random() * 5) - 2.5) * (Math.random() < 0.5 ? 1 : -1);
		acceleration.y = gravity;
		scale.x = scale.y = 0.3 + Math.random();
		angle = 15 - Math.random() * 30;
		angularVelocity = 30 * (Math.random() * 5) * (Math.random() < 0.5 ? 1 : -1);
	}
	
	override public function update():Void 
	{
		super.update();
		
		alpha = 0.3 + 0.7 * y / BunnyMarkState.maxY;
		
		if (x > BunnyMarkState.maxX)
		{
			velocity.x *= -1;
			x = BunnyMarkState.maxX;
		}
		else if (x < BunnyMarkState.minX)
		{
			velocity.x *= -1;
			x = BunnyMarkState.minX;
		}
		if (y > BunnyMarkState.maxY)
		{
			velocity.y *= -0.8;
			y = BunnyMarkState.maxY;
			if (Math.random() > 0.5) velocity.y -= 3 + Math.random() * 4;
		}
		else if (y < BunnyMarkState.minY)
		{
			velocity.y *= -0.8;
			y = BunnyMarkState.minY;
		}
	}
	
}