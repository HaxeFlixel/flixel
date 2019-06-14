package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	public function new(X:Float, Y:Float)
	{
		super(X, Y);

		loadGraphic("assets/player.png", true);
		// Walking speed
		maxVelocity.x = 100;
		// Gravity
		acceleration.y = 400;
		// Deceleration (sliding to a stop)
		drag.x = maxVelocity.x * 4;

		// Tweak the bounding box for better feel
		width = 8;
		height = 10;
		offset.x = 3;
		offset.y = 3;

		animation.add("idle", [0], 0, false);
		animation.add("walk", [1, 2, 3, 0], 10, true);
		animation.add("walk_back", [3, 2, 1, 0], 10, true);
		animation.add("flail", [1, 2, 3, 0], 18, true);
		animation.add("jump", [4], 0, false);
	}

	override public function update(elapsed:Float):Void
	{
		// Smooth slidey walking controls
		acceleration.x = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			acceleration.x -= drag.x;
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			acceleration.x += drag.x;
		}

		if (isTouching(FlxObject.FLOOR))
		{
			// Jump controls
			if (FlxG.keys.anyJustPressed([UP, W, SPACE]))
			{
				velocity.y = -acceleration.y * 0.51;
				animation.play("jump");
			}
			// Animations
			else if (velocity.x > 0)
			{
				animation.play("walk");
			}
			else if (velocity.x < 0)
			{
				animation.play("walk_back");
			}
			else
			{
				animation.play("idle");
			}
		}
		else if (velocity.y < 0)
		{
			animation.play("jump");
		}
		else
		{
			animation.play("flail");
		}

		super.update(elapsed);
	}
}
