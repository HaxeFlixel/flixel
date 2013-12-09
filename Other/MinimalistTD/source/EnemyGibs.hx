package ;

import flixel.util.FlxColor;
import flash.display.BlendMode;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.effects.particles.FlxParticle;

class EnemyGibs extends FlxEmitter
{

	public function new() 
	{
		super();
		
		makeParticles("assets/img/enemy.png", 10);
		var speed:Int = 10;
		setXSpeed( -speed, speed);
		setYSpeed( -speed, speed);
		setAlpha(1, 1, 0, 0);
		
		for (i in 0...10) {
			var p:FlxParticle = members[i];
			p.blend = BlendMode.INVERT;
			p.makeGraphic(2, 2, FlxColor.BLACK);
			add(p);
		}
		
		R.PS.emitterGroup.add(this);
	}
	
	public function init(x:Float, y:Float):Void
	{
		this.x = x;
		this.y = y;
	}
}