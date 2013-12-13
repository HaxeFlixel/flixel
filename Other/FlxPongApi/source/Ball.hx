package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxAngle;
import flixel.util.FlxCollision;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.util.FlxVelocity;

class Ball extends PongSprite
{
	public function new()
	{
		super( Std.int( FlxG.width / 2 ), Std.int( FlxG.height / 2 ), 4, 4, Reg.dark );
		velocity = new FlxPoint( -128, -128 );
		minVelocity = new FlxPoint( 32, 32 );
		maxVelocity = new FlxPoint( 256, 256 );
		drag = new FlxPoint( 0, 0 );
		elasticity = 1.0;
	}
	
	override public function update():Void
	{
		//if ( y < 0 || y > FlxG.height - height ) {
		//	velocity.y = -velocity.y;
		//	FlxG.sound.play( "plip" );
		//	y = ( y < 0 ) ? 0 : FlxG.height - height;
		//}
		
		FlxG.collide( this, Reg.PS.collidables, ballBounce );
		
		super.update();
	}
	
	private function ballBounce( BallObject:FlxObject, CollidedWith:FlxObject ):Void
	{
		//this.velocity.x = FlxVelocity
		FlxG.sound.play( "plip" );
	}
}