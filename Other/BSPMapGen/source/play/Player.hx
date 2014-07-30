package play;

import flixel.FlxG;
import flixel.FlxSprite;

class Player extends FlxSprite
{
	private static inline var SPEED:Int = 100;
	
	public function new(x:Float, y:Float) 
	{
		super(x, y, "assets/images/player.png");
		pixelPerfectRender = false;
		
		// let's decrease the hitbox size so it's less 
		// frustrating to move through the narrow hallways
		setSize(12, 12);
		centerOffsets();
	}
	
	override public function update():Void
	{
		super.update();
		
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			velocity.x = -SPEED;
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			velocity.x = SPEED;
		}
		else
		{
			velocity.x = 0;
		}

		if (FlxG.keys.anyPressed([W, UP]))
		{
			velocity.y = -SPEED;
		}
		else if (FlxG.keys.anyPressed([S, DOWN]))
		{
			velocity.y = SPEED;
		}
		else
		{
			velocity.y = 0;
		}
	}
}