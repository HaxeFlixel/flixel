package;

import flixel.effects.particles.FlxParticle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;

class Enemy extends FlxSprite 
{
	public var moneyGain:Bool = true;
	public var maxHealth:Float = 0.0;
	
	override public function new( X:Int, Y:Int ) 
	{
		super( X, Y, "images/enemy.png" );
		
		health = maxHealth = 1;
	}
	
	public function init( X:Int, Y:Int )
	{
		reset( X, Y );
		
		if ( Reg.PS != null ) {
			health = Math.floor( Reg.PS.wave / 3 ) + 1;
		}
		
		maxHealth = health;
	}
	
	override public function update():Void
	{
		alpha = health / maxHealth; 
		
		super.update();
	}
	
	override public function kill():Void
	{
		#if !js
		FlxG.sound.play("enemykill");
		#end
		
		var emitter:EnemyGibs = Reg.PS.emitterGroup.recycle(EnemyGibs);
		emitter.init(x, y);
		emitter.start(true, 2);
		
		Reg.PS.enemiesToKill--;
		
		if ( Reg.PS.enemiesToKill <= 0 ) Reg.PS.killedWave();
		
		if ( moneyGain ) {
			var money:Int = 1;
			if ( Reg.PS.wave < 5 ) money = 2;
			Reg.PS.money += money;
			Reg.PS.moneyText.size = 16;
		}
		
		super.kill();
	}
	
	public function followPath( Path:Array<FlxPoint> ):Void
	{
		x = Path[0].x;
		y = Path[0].y;
		FlxPath.start( this, Path, 50, 0, true );
	}
}