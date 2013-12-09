package;

import flixel.effects.FlxFlicker;
import flixel.util.FlxPath;
import openfl.Assets;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.effects.particles.FlxParticle;
import flixel.effects.particles.FlxTypedEmitter;

class Enemy extends FlxSprite 
{
	public var moneyGain:Bool = true;
	public var maxHealth:Float;
	
	public function new(X:Int, Y:Int) 
	{
		super(X, Y, Assets.getBitmapData("images/enemy.png"));
		if (Reg.GS != null) {
			health = Math.floor(Reg.GS.wave / 3) + 1;
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
		FlxG.sound.play(Assets.getSound("enemykill"));
		
		var emitter:FlxTypedEmitter<FlxParticle> = new FlxTypedEmitter<FlxParticle>(x, y);
		emitter.makeParticles(Assets.getBitmapData("images/enemy.png"), 10);
		var speed:Int = 10;
		emitter.setXSpeed( -speed, speed);
		emitter.setYSpeed( -speed, speed);
		
		for (i in 0...10) {
			var p:FlxParticle = cast(emitter.members[i]);
			p.blend = BlendMode.INVERT;
			p.makeGraphic(2, 2, 0xff000000);
			emitter.add(p);
		}
		Reg.GS.emitterGroup.add(emitter);
		emitter.start(true);
		
		Reg.GS.enemiesToKill --;
		if (Reg.GS.enemiesToKill <= 0) Reg.GS.killedWave();
		Reg.GS.enemyGroup.remove(this, true);
		if (moneyGain) {
			var money:Int = 1;
			if (Reg.GS.wave < 5) money = 2;
			
			Reg.GS.money += money;
			Reg.GS.moneyText.size = 16;
		}
		
		super.kill();
	}
	
	public function flicker( Duration:Float ):Void
	{
		FlxFlicker.flicker( this, Duration );
	}
	
	public function followPath( Path:FlxPath, one:Int, two:Int, three:Bool ):Void
	{
		
	}
}