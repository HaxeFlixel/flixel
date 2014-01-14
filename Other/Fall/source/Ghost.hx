package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxRandom;

class Ghost extends FlxSprite
{
	public function new( X:Int = 0, Y:Int = 0 )
	{
		super( X, Y, "images/ghost.png" );
		init( X, Y );
	}
	
	public function init( X:Int, Y:Int ):Void
	{
		super.reset( X, Y );
		
		alpha = 0;
		velocity.x = FlxRandom.floatRanged( -20, 20 );
		velocity.y = FlxRandom.floatRanged( -32, -24 );
		
		FlxTween.multiVar( this, { alpha: 1 }, FlxRandom.floatRanged( 0.2, 1 ), { complete: fadedIn } );
	}
	
	private function fadedIn( f:FlxTween ):Void
	{
		FlxTween.multiVar( this, { alpha: 0 }, FlxRandom.floatRanged( 0.2, 1 ), { complete: fadedOut } );
	}
	
	private function fadedOut( f:FlxTween ):Void
	{
		kill();
	}
}