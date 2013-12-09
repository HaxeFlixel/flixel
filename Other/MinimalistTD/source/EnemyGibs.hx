package ;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;

class EnemyGibs extends FlxEmitter
{
	public function new()
	{
		super();
		
		makeParticles("images/enemy.png", 10);
		var speed:Int = 10;
		setXSpeed( -speed, speed);
		setYSpeed( -speed, speed);
		setAlpha(1, 1, 0, 0);
		
		for (i in 0...10) {
			var p:FlxParticle = cast( members[i], FlxParticle );
			p.blend = BlendMode.INVERT;
			p.makeGraphic(2, 2, FlxColor.BLACK);
			add(p);
		}
		
		Reg.PS.emitterGroup.add(this);
	}
	
	public function init(x:Float, y:Float):Void
	{
		this.x = x;
		this.y = y;
	}
}