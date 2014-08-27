package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	private var _isReadyToJump:Bool = true;
	private var _jumpPower:Int = 200;

	// This is the player object class.  Most of the comments I would put in here
	// would be near duplicates of the Enemy class, so if you're confused at all
	// I'd recommend checking that out for some ideas!
	public function new(X:Int, Y:Int)
	{
		super(X,Y);
		loadGraphic("assets/spaceman.png", true, 8);
		
		//bounding box tweaks
		width = 6;
		height = 7;
		offset.x = 1;
		offset.y = 1;
		
		//basic player physics
		var runSpeed:Int = 80;
		drag.x = runSpeed * 8;
		acceleration.y = 420;
		maxVelocity.x = runSpeed;
		maxVelocity.y = _jumpPower;
		
		//animations
		animation.add("idle", [0]);
		animation.add("run", [1, 2, 3, 0], 12);
		animation.add("jump", [4]);
	}
	
	override public function update(elapsed:Float):Void
	{
		// MOVEMENT
		acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			flipX = true;
			acceleration.x -= drag.x;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			flipX = false;
			acceleration.x += drag.x;
		}
		
		if ((FlxG.keys.anyJustPressed([UP, W, SPACE]) && _isReadyToJump) && velocity.y == 0)
		{
			velocity.y = -_jumpPower;
		}
		
		// ANIMATION
		if (velocity.y != 0)
		{
			animation.play("jump");
		}
		else if (velocity.x == 0)
		{
			animation.play("idle");
		}
		else
		{
			animation.play("run");
		}
		
        super.update(elapsed);
	}
}