package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxAngle;
import flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Zaphod
 */
class PlayerShip extends FlxSprite
{
	private var _thrust:Float = 0;
	
	public function new() 
	{
		super(Math.floor(FlxG.width / 2 - 8), Math.floor(FlxG.height / 2 - 8));
		
		#if flash
		loadRotatedGraphic("assets/ship.png", 32, -1, false, true);
		#else
		loadGraphic("assets/ship.png");
		#end
		
		width *= 0.75;
		height *= 0.75;
		centerOffsets();
	}
	
	override public function update():Void 
	{
		angularVelocity = 0;
		
		if (FlxG.keys.anyPressed(["A", "LEFT"]))
		{
			angularVelocity -= 240;
		}
		
		if (FlxG.keys.anyPressed(["D", "RIGHT"]))
		{
			angularVelocity += 240;
		}
		
		acceleration.set();
		
		if (FlxG.keys.anyPressed(["W", "UP"]))
		{
			FlxAngle.rotatePoint(90, 0, 0, 0, angle, acceleration);
		}
		
		if (FlxG.keys.justPressed.SPACE)
		{
			var bullet:FlxSprite = PlayState.bullets.recycle();
			bullet.reset(x + (width - bullet.width) / 2, y + (height - bullet.height) / 2);
			bullet.angle = angle;
			FlxAngle.rotatePoint(150, 0, 0, 0, bullet.angle, bullet.velocity);
			bullet.velocity.x *= 2;
			bullet.velocity.y *= 2;
		}
		
		FlxSpriteUtil.screenWrap(this);
		
		super.update();
	}
}