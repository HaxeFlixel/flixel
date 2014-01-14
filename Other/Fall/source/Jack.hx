package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

class Jack extends FlxSprite
{
	public function new( X:Int, Y:Int )
	{
		super( X, Y, "images/jack.png" );
		init( X, Y );
	}
	
	public function init( X:Int, Y:Int )
	{
		super.reset( X, Y );
		
		acceleration.y = 80;
		
		velocity.x = FlxRandom.intRanged( 20, 60 );
		
		if ( x >= 0 )
		{
			velocity.x *= -1;
		}
	}
	
	override public function update():Void
	{
		if ( y > FlxG.height )
		{
			kill();
		}
		
		super.update();
	}
}