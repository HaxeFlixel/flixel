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
		loadGraphic("assets/spaceman.png", true, true, 8);
		
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
		addAnimation("idle", [0]);
		addAnimation("run", [1, 2, 3, 0], 12);
		addAnimation("jump", [4]);
	}
	
	override public function update():Void
	{
		// MOVEMENT
		acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			facing = FlxObject.LEFT;
			acceleration.x -= drag.x;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			facing = FlxObject.RIGHT;
			acceleration.x += drag.x;
		}
		
		var jumpKeyPressed:Bool = (FlxG.keys.justPressed.W || FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.UP);
		
		if ((jumpKeyPressed && _isReadyToJump) && velocity.y == 0)
		{
			velocity.y = -_jumpPower;
		}
		
		// ANIMATION
		if (velocity.y != 0)
		{
			play("jump");
		}
		else if (velocity.x == 0)
		{
			play("idle");
		}
		else
		{
			play("run");
		}
		
        super.update();
	}
}