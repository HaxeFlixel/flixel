package;

import openfl.Assets;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxPoint;
import flixel.FlxSprite;

class Bullet extends FlxSprite
{
	
	public var speed:Float;
	
	public function new()
	{
		super();
		loadGraphic("assets/bullet.png", true);
		width = 6;
		height = 6;
		offset.x = 1;
		offset.y = 1;
		
		addAnimation("up",[0]);
		addAnimation("down",[1]);
		addAnimation("left",[2]);
		addAnimation("right",[3]);
		addAnimation("poof",[4, 5, 6, 7], 50, false);
		
		speed = 360;
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
		play("poof");
	}
	
	public function shoot(Location:FlxPoint, Aim:Int):Void
	{
		FlxG.sound.play("Shoot");
		
		super.reset(Location.x - width / 2, Location.y - height / 2);
		solid = true;
		switch(Aim)
		{
			case FlxObject.UP:
				play("up");
				velocity.y = -speed;
			case FlxObject.DOWN:
				play("down");
				velocity.y = speed;
			case FlxObject.LEFT:
				play("left");
				velocity.x = -speed;
			case FlxObject.RIGHT:
				play("right");
				velocity.x = speed;
		}
	}
}