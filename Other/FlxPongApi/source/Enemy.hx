package;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.util.FlxVelocity;

class Enemy extends PongSprite
{
	public function new()
	{
		super( FlxG.width, 0, Reg.level, Reg.level * 4, Reg.dark );
		reset(0,0);
	}
	
	override public function update():Void
	{
		FlxVelocity.accelerateTowardsObject( this, Reg.PS.ball, Reg.level, 0, Reg.level * 2 );
		
		super.update();
	}
	
	override public function reset( X:Float, Y:Float ):Void
	{
		makeGraphic( Reg.level, Reg.level * 4, Reg.dark );
		super.reset( FlxG.width, Std.int( ( FlxG.height - height ) / 2 ) );
		FlxTween.linearMotion( this, this.x, this.y, this.x - 20, this.y, 1 );
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