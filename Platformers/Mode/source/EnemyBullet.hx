package;

import openfl.Assets;
import flixel.FlxG;
import flixel.util.FlxAngle;
import flixel.util.FlxPoint;
import flixel.FlxSprite;

class EnemyBullet extends FlxSprite
{
	public var speed:Float;
	
	public function new()
	{
		super();
		loadGraphic("assets/bot_bullet.png", true);
		animation.add("idle",[0, 1], 50);
		animation.add("poof",[2, 3, 4], 50, false);
		speed = 120;
	}
	
	override public function update():Void
	{
		if(!alive)
		{
			if(animation.finished)
			{
				exists = false;
			}
		}
		else if(touching != 0)
		{
			kill();
		}

        super.update();
	}
	
	override public function kill():Void
	{
		if(!alive)
		{
			return;
		}
		velocity.x = 0;
		velocity.y = 0;
		if(onScreen())
		{
			FlxG.sound.play("Jump");
		}
		alive = false;
		solid = false;
		animation.play("poof");
	}
	
	public function shoot(Location:FlxPoint, Angle:Float):Void
	{
		FlxG.sound.play("Enemy", 0.5);
		
		super.reset(Location.x - width / 2, Location.y - height / 2);
		FlxAngle.rotatePoint(0, speed, 0, 0, Angle, _point);
		velocity.x = _point.x;
		velocity.y = _point.y;
		solid = true;
		animation.play("idle");
	}
}