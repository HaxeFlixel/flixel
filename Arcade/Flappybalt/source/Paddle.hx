package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxDirection;

class Paddle extends FlxSprite
{
	public var targetY:Int = 0;

	inline static public var SPEED:Int = 480;

	public function new(X:Float = 0, Facing:FlxDirection)
	{
		super(X, FlxG.height);
		loadGraphic("assets/paddle.png", false);

		if (Facing == LEFT)
		{
			flipX = true;
		}
	}

	public function randomize():Void
	{
		targetY = Reg.PS.randomPaddleY();

		if (targetY < y)
			velocity.y = -SPEED;
		else
			velocity.y = SPEED;
	}

	override public function update(elapsed:Float):Void
	{
		if (((velocity.y < 0) && (y <= targetY + SPEED * elapsed)) || ((velocity.y > 0) && (y >= targetY - SPEED * elapsed)))
		{
			velocity.y = 0;
			y = targetY;
		}

		super.update(elapsed);
	}
}
