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
		
		addAnimation("idle", [0], 0, false);
		addAnimation("walk", [1, 2, 3, 0], 10, true);
		addAnimation("walk_back", [3, 2, 1, 0], 10, true);
		addAnimation("flail", [1, 2, 3, 0], 18, true);
		addAnimation("jump", [4], 0, false);
	}
	
	override public function update():Void
	{
		// Smooth slidey walking controls
		acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			acceleration.x -= drag.x;
		}
		if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			acceleration.x += drag.x;
		}
		
		if (isTouching(FlxObject.FLOOR))
		{
			// Jump controls
			if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.W || FlxG.keys.justPressed.UP)
			{
				velocity.y = -acceleration.y*0.51;
				play("jump");
			}
			// Animations
			else if (velocity.x > 0)
			{
				play("walk");
			}
			else if (velocity.x < 0)
			{
				play("walk_back");
			}
			else
			{
				play("idle");
			}
		}
		else if (velocity.y < 0)
		{
			play("jump");
		}
		else
		{
			play("flail");
		}
		
        super.update();
	}
}