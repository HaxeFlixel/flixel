package;

import flixel.FlxG;
import flixel.system.FlxCollisionType;
import flixel.util.FlxVelocity;

class Player extends PongSprite
{
	private var _emitter:Emitter;
	
	public function new()
	{
		super( 16, Std.int( ( FlxG.height - 16 ) / 2 ), 4, 16, Reg.dark );
		
		moves = false;
		immovable = true;
	}
	
	public function init():Void
	{
		_emitter = Reg.PS.emitterGroup.add( new Emitter( Std.int( x ), Std.int( y ), 1 ) );
		_emitter.width = width;
		_emitter.height = height;
	}
	
	override public function update():Void
	{
		var xSpeed:Int = ( x < 16 ) ? 2 : 0;
		FlxVelocity.accelerateTowardsMouse( this, 1, xSpeed, 10 );
		
		super.update();
	}
	
	override public function kill():Void
	{
		_emitter.start( true );
		FlxG.sound.play( "kaboom" );
		
		super.kill();
	}
}