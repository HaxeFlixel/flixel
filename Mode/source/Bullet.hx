package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

class Bullet extends FlxSprite
{
	private var _speed:Float;
	
	public function new()
	{
		super();
		
		loadGraphic("assets/bullet.png", true);
		width = 6;
		height = 6;
		offset.set(1, 1);
		
		addAnimation("up", [0]);
		addAnimation("down", [1]);
		addAnimation("left", [2]);
		addAnimation("right", [3]);
		addAnimation("poof", [4, 5, 6, 7], 50, false);
		
		_speed = 360;
	}
	
	override public function update():Void
	{
		if (!alive)
		{
			if (finished)
			{
				exists = false;
			}
		}
		else if (touching != 0)
		{
			kill();
		}

        super.update();
	}
	
	override public function kill():Void
	{
		if (!alive)
		{
			return;
		}
		
		velocity.set(0, 0);
		
		if (onScreen())
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
		
		switch (Aim)
		{
			case FlxObject.UP:
				play("up");
				velocity.y = - _speed;
			case FlxObject.DOWN:
				play("down");
				velocity.y = _speed;
			case FlxObject.LEFT:
				play("left");
				velocity.x = - _speed;
			case FlxObject.RIGHT:
				play("right");
				velocity.x = _speed;
		}
	}
}