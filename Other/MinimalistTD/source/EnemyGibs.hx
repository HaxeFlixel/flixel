package ;

import flash.display.BlendMode;
import flixel.effects.particles.FlxTypedEmitter.Bounds;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

class EnemyGibs extends FlxEmitter
{
	inline static private var SPEED:Int = 10;
	inline static private var SIZE:Int = 10;
	
	public function new()
	{
		super( 0, 0, SIZE );
		
		setXSpeed( -SPEED, SPEED );
		setYSpeed( -SPEED, SPEED );
		blend = BlendMode.INVERT;
		life = new Bounds( 1.0, 1.0 );
		
		for ( i in 0...SIZE ) {
			var p:FlxParticle = new FlxParticle();
			p.makeGraphic( 2, 2, FlxColor.BLACK );
			add( p );
		}
		
		Reg.PS.emitterGroup.add( this );
	}
	
	public function init(x:Float, y:Float):Void
	{
		this.x = x;
		this.y = y;
	}
	
	public function explode():Void
	{
		super.start( true, 1, 0, SIZE, 1 );
	}
}