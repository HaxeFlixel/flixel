package;

import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.group.FlxTypedGroup;

class Tower extends FlxSprite 
{
	public var range:Int = 40;
	public var fireRate:Float = 1;
	public var damage:Int = 1;
	
	public var range_LEVEL:Int = 1;
	public var firerate_LEVEL:Int = 1;
	public var damage_LEVEL:Int = 1;
	
	public var range_PRIZE:Int = 10;
	public var firerate_PRIZE:Int = 10;
	public var damage_PRIZE:Int =  10;
	
	private var shootInvertall:Int = 2;
	private var shootCounter:Int = 0;
	
	private var indicator:FlxSprite;
	public var index:Int;
	
	public function new(X:Float, Y:Float) 
	{
		super(X, Y, Assets.getBitmapData("images/tower.png"));
		
		indicator = new FlxSprite(getMidpoint().x - 1, getMidpoint().y - 1);
		indicator.makeGraphic(2, 2);
		Reg.GS.towerIndicators.add(indicator);
	}
	
	override public function update():Void
	{	
		if (getNearestEnemy() == null) {
			indicator.visible = false;
		}
		else {
			indicator.visible = true;
			indicator.alpha = shootCounter / (shootInvertall * FlxG.framerate);
			
			shootCounter += cast(FlxG.timeScale);
			if (shootCounter > (shootInvertall * FlxG.framerate) * fireRate) 
				shoot();
		}
		
		super.update();
	}
	
	private function shoot():Void
	{
		var target:Enemy = getNearestEnemy();
		if (target == null) return;
		
		var bullet:Bullet = new Bullet(getMidpoint().x, getMidpoint().y, target, damage);
		Reg.GS.bulletGroup.add(bullet);
		
		FlxG.sound.play(Assets.getSound("shoot"));
		shootCounter = 0;
	}
	
	private function getNearestEnemy():Enemy
	{
		var firstEnemy:Enemy = null;
		var enemies:FlxTypedGroup<Enemy> = Reg.GS.enemyGroup;
		
		for (i in 0...enemies.members.length) 
		{
			var enemy:Enemy = cast(enemies.members[i]);
			var distance:Float = FlxMath.getDistance(new FlxPoint(x, y), new FlxPoint(enemy.x, enemy.y));
			
			if (distance <= range && enemy.alive) {
				firstEnemy = enemy;
				break;
			}
		}
		
		return firstEnemy;
	}
	
	// Upgrades
	
	public function upgradeRange():Void
	{
		range += 10;
		range_LEVEL ++;
		range_PRIZE = cast(range_PRIZE * 1.5);
	}
	
	public function upgradeDamage():Void
	{
		damage ++;
		damage_LEVEL ++;
		damage_PRIZE = cast(damage_PRIZE * 1.5);
	}
	
	public function upgradeFirerate():Void
	{
		fireRate *= 0.9;
		firerate_LEVEL ++;
		firerate_PRIZE = cast(firerate_PRIZE * 1.5);
	}
}