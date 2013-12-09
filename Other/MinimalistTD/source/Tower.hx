package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxVelocity;
import flixel.util.FlxMath;
import flixel.util.FlxPoint;
import flixel.group.FlxGroup;
import flixel.group.FlxTypedGroup;

class Tower extends FlxSprite 
{
	private static var HELPER_POINT:FlxPoint = new FlxPoint();
	private static var HELPER_POINT_2:FlxPoint = new FlxPoint();
	
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
		super(X, Y, "images/tower.png");
		
		indicator = new FlxSprite(getMidpoint().x - 1, getMidpoint().y - 1);
		indicator.makeGraphic(2, 2);
		Reg.PS.towerIndicators.add(indicator);
	}
	
	override public function update():Void
	{	
		if (getNearestEnemy() == null) {
			indicator.visible = false;
		} else {
			indicator.visible = true;
			indicator.alpha = shootCounter / (shootInvertall * FlxG.framerate);
			
			shootCounter += Std.int(FlxG.timeScale);
			
			if (shootCounter > (shootInvertall * FlxG.framerate) * fireRate) {
				shoot();
			}
		}
		
		super.update();
	}
	
	private function shoot():Void
	{
		var target:Enemy = getNearestEnemy();
		if (target == null) return;
		
		var bullet:Bullet = Reg.PS.bulletGroup.recycle(Bullet);
		getMidpoint(HELPER_POINT);
		bullet.init(HELPER_POINT.x, HELPER_POINT.y, target, damage);
		
		#if !js
		FlxG.sound.play("shoot");
		#end
		
		shootCounter = 0;
	}
	
	private function getNearestEnemy():Enemy
	{
		var firstEnemy:Enemy = null;
		var enemies:FlxTypedGroup<Enemy> = Reg.PS.enemyGroup;
		var l:Int = enemies.members.length;
		
		for (i in 0...l) 
		{
			var enemy:Enemy = enemies.members[i];
			if (enemy != null && enemy.alive)
			{
				HELPER_POINT.set(x, y);
				HELPER_POINT_2.set(enemy.x, enemy.y);
				var distance:Float = FlxMath.getDistance(HELPER_POINT, HELPER_POINT_2);
				
				if (distance <= range && enemy.alive) {
					firstEnemy = enemy;
					break;
				}
			}
		}
		
		return firstEnemy;
	}
	
	// Upgrades
	
	public function upgradeRange():Void
	{
		range += 10;
		range_LEVEL++;
		range_PRIZE = Std.int(range_PRIZE * 1.5);
	}
	
	public function upgradeDamage():Void
	{
		damage++;
		damage_LEVEL++;
		damage_PRIZE = Std.int(damage_PRIZE * 1.5);
	}
	
	public function upgradeFirerate():Void
	{
		fireRate *= 0.9;
		firerate_LEVEL++;
		firerate_PRIZE = Std.int(firerate_PRIZE * 1.5);
	}
}