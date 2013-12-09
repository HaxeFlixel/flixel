package;

import org.flixel.FlxEmitter;
import org.flixel.FlxParticle;
import org.flixel.FlxPoint;
import org.flixel.FlxSprite;
import org.flixel.FlxG;
import nme.display.BlendMode;

class Enemy extends FlxSprite 
{
	public var moneyGain:Bool = true;
	public var maxHealth:Float;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y, "assets/img/enemy.png");
		if (R.GS != null) {
			health = Math.floor(R.GS.wave / 3) + 1;
		}
		maxHealth = health;
	}
	
	override public function update():Void
	{
		alpha = health / maxHealth; 
		
		super.update();
	}
	
	override public function hurt(Damage:Float):Void
	{
		super.hurt(Damage);
	}
	
	override public function kill():Void
	{
		FlxG.play("assets/sfx/EnemyKill.mp3");
		
		var emitter:FlxTypedEmitter<FlxParticle> = new FlxTypedEmitter(x, y);
		emitter.makeParticles("assets/img/enemy.png", 10);
		var speed:Int = 10;
		emitter.setXSpeed( -speed, speed);
		emitter.setYSpeed( -speed, speed);
		
		for (i in 0...10) {
			var p:FlxParticle = emitter.members[i];
			p.blend = BlendMode.INVERT;
			p.makeGraphic(2, 2, FlxG.BLACK);
			emitter.add(p);
		}
		R.GS.emitterGroup.add(emitter);
		emitter.start(true);
		
		R.GS.enemiesToKill --;
		if (R.GS.enemiesToKill <= 0) R.GS.killedWave();
		R.GS.enemyGroup.remove(this, true);
		if (moneyGain) {
			var money:Int = 1;
			if (R.GS.wave < 5) money = 2;
			
			R.GS.money += money;
			R.GS.moneyText.size = 16;
		}
		
		super.kill();
	}
}