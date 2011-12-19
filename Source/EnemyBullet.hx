package;

import nme.Assets;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxU;

class EnemyBullet extends FlxSprite
{
	public var speed:Float;
	
	public function new()
	{
		super();
		loadGraphic(FlxAssets.imgBotBullet, true);
		addAnimation("idle",[0, 1], 50);
		addAnimation("poof",[2, 3, 4], 50, false);
		speed = 120;
	}
	
	override public function update():Void
	{
		if(!alive)
		{
			if(finished)
			{
				exists = false;
			}
		}
		else if(touching != 0)
		{
			kill();
		}
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
			FlxG.play(Assets.getSound("assets/jump.wav"));
		}
		alive = false;
		solid = false;
		play("poof");
	}
	
	public function shoot(Location:FlxPoint, Angle:Float):Void
	{
		FlxG.play(Assets.getSound("assets/enemy.wav"), 0.5);
		super.reset(Location.x - width / 2, Location.y - height / 2);
		FlxU.rotatePoint(0, speed, 0, 0, Angle, _point);
		velocity.x = _point.x;
		velocity.y = _point.y;
		solid = true;
		play("idle");
	}
}