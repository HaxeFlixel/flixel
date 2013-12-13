package;

import flixel.FlxG;
import flixel.util.FlxVelocity;

class Player extends PongSprite
{
	public function new()
	{
		super( 16, Std.int( ( FlxG.height - 16 ) / 2 ), 4, 16, Reg.dark );
	}
	
	override public function update():Void
	{
		var xSpeed:Int = ( x < 16 ) ? 2 : 0;
		FlxVelocity.accelerateTowardsMouse( this, 1, xSpeed, 10 );
		
		super.update();
	}
	
	override public function kill():Void
	{
		var emitter:Emitter = Reg.PS.emitterGroup.recycle( Emitter, [ this.x, this.y, 1, Reg.dark ] );
		emitter.width = width;
		emitter.height = height;
		emitter.start( true );
		
		super.kill();
	}
}