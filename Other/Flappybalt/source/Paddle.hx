package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class Paddle extends FlxSprite
{
	public var targetY:Int = 0;
	
	inline static public var SPEED:Int = 480;
	
	public function new( X:Float = 0, Facing:Int = 0 )
	{
		super( X, FlxG.height );
		loadGraphic( "assets/paddle.png", false, true );
		facing = Facing;
	}
	
	public function randomize():Void
	{
		targetY = Reg.PS.randomPaddleY();
		
		if( targetY < y )
			velocity.y = -SPEED;
		else
			velocity.y = SPEED;
	}
	
	override public function update():Void
	{
		if( ((velocity.y < 0) && (y <= targetY + SPEED*FlxG.elapsed)) ||
			((velocity.y > 0) && (y >= targetY - SPEED*FlxG.elapsed)) )
		{
			velocity.y = 0;
			y = targetY;
		}
		
		super.update();
	}
}