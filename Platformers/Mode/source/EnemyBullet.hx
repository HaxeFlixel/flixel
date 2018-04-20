package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets;

class EnemyBullet extends FlxSprite
{
	public var speed:Float;
	
	public function new()
	{
		super();
		loadGraphic(AssetPaths.bot_bullet__png, true);
		animation.add("idle", [0, 1], 50);
		animation.add("poof", [2, 3, 4], 50, false);
		speed = 120;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (!alive)
		{
			if (animation.finished)
				exists = false;
		}
		else if (touching != 0)
		{
			kill();
		}

		super.update(elapsed);
	}
	
	override public function kill():Void
	{
		if (!alive)
			return;

		velocity.set();
		if (isOnScreen())
			FlxG.sound.play(FlxAssets.getSound("assets/sounds/jump"));

		alive = false;
		solid = false;
		animation.play("poof");
	}
	
	public function shoot(Location:FlxPoint, Angle:Float):Void
	{
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/enemy"), 0.5);
		
		super.reset(Location.x - width / 2, Location.y - height / 2);
		_point.set(0, -speed);
		_point.rotate(FlxPoint.weak(0, 0), Angle);
		velocity.x = _point.x;
		velocity.y = _point.y;
		solid = true;
		animation.play("idle");
	}
}