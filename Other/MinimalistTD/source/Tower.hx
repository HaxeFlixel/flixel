package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxVelocity;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup;

class Tower extends FlxSprite
{
	public var range:Int = 40;
	public var fireRate:Float = 1;
	public var damage:Int = 1;
	
	public var range_LEVEL:Int = 1;
	public var firerate_LEVEL:Int = 1;
	public var damage_LEVEL:Int = 1;
	
	public var range_PRIZE:Int = BASE_PRIZE;
	public var firerate_PRIZE:Int = BASE_PRIZE;
	public var damage_PRIZE:Int =  BASE_PRIZE;
	
	private var _shootInvertall:Int = 2;
	private var _shootCounter:Int = 0;
	private var _initialCost:Int = 0;
	private var _indicator:FlxSprite;
	
	private static inline var COST_INCREASE:Float = 1.5;
	private static inline var BASE_PRIZE:Int = 10;
	
	/**
	 * Create a new tower at X and Y with default range, fire rate, and damage; create this tower's indicator.
	 */
	public function new(X:Float, Y:Float, Cost:Int)
	{
		super(X, Y, "images/tower.png");
		
		_indicator = new FlxSprite(getMidpoint().x - 1, getMidpoint().y - 1);
		_indicator.makeGraphic(2, 2);
		Reg.PS.towerIndicators.add(_indicator);
		
		_initialCost = Cost;
	}
	
	/**
	 * The tower's update function just checks if there's an enemy nearby; if so, the indicator "charges"
	 * by slowly increasing its alpha; once the shootCounter has reached the required level, a bullet is
	 * shot.
	 */
	override public function update():Void
	{	
		if (getNearestEnemy() == null)
		{
			_indicator.visible = false;
		}
		else
		{
			_indicator.visible = true;
			_indicator.alpha = _shootCounter / (_shootInvertall * FlxG.updateFramerate);
			
			_shootCounter += Std.int(FlxG.timeScale);
			
			if (_shootCounter > (_shootInvertall * FlxG.updateFramerate) * fireRate)
			{
				shoot();
			}
		}
		
		super.update();
	}
	
	/**
	 * Used to determine value of a tower when selling it. Equivalent to half its next upgrade costs plus half its base cost.
	 */
	public var value(get, null):Int;
	
	private function get_value():Int
	{
		var val:Float = _initialCost;
		
		val += range_PRIZE - BASE_PRIZE;
		val += firerate_PRIZE - BASE_PRIZE;
		val += damage_PRIZE - BASE_PRIZE;
		val = Math.round(val / 2);
		
		return Std.int(val);
	}
	
	/**
	 * Shoots a bullet! Called when shootCounter reaches the required limit.
	 */
	private function shoot():Void
	{
		var target:Enemy = getNearestEnemy();
		
		if (target == null)
		{
			return;
		}
		
		var bullet:Bullet = Reg.PS.bulletGroup.recycle(Bullet);
		var midpoint = getMidpoint();
		bullet.init(midpoint.x, midpoint.y, target, damage);
		midpoint.put();
		
		FlxG.sound.play("shoot");
		
		_shootCounter = 0;
	}
	
	/**
	 * Goes through the entire enemy group and returns the first non-null enemy within range of this tower.
	 * 
	 * @return	The first enemy that is not null, in range, and alive. Returns null if none found.
	 */
	private function getNearestEnemy():Enemy
	{
		var firstEnemy:Enemy = null;
		var enemies:FlxTypedGroup<Enemy> = Reg.PS.enemyGroup;
		
		for (enemy in enemies)
		{
			if (enemy != null && enemy.alive)
			{
				var distance:Float = FlxMath.getDistance(toPoint(), enemy.toPoint());
				
				if (distance <= range)
				{
					firstEnemy = enemy;
					break;
				}
			}
		}
		
		return firstEnemy;
	}
	
	/**
	 * Upgrading range increases the radius within which it will consider enemies valid targets by 10.
	 * Also updates the range_LEVEL and range_PRIZE (1.5 x LEVEL) values for display and player money impact.
	 */
	public function upgradeRange():Void
	{
		range += 10;
		range_LEVEL++;
		range_PRIZE = Std.int(range_PRIZE * COST_INCREASE);
	}
	
	/**
	 * Upgrading damage increases the damage value passed to bullets, and later enemies, by 1.
	 * Also updates the damage_LEVEL and damage_PRIZE (1.5 x LEVEL) values for display and player money impact.
	 */
	public function upgradeDamage():Void
	{
		damage++;
		damage_LEVEL++;
		damage_PRIZE = Std.int(damage_PRIZE * COST_INCREASE);
	}
	
	/**
	 * Upgrading fire rate decreases time between shots by 10%.
	 * Also updates the firerate_LEVEL and firerate_PRIZE (1.5 x LEVEL) values for display and player money impact.
	 */
	public function upgradeFirerate():Void
	{
		fireRate *= 0.9;
		firerate_LEVEL++;
		firerate_PRIZE = Std.int(firerate_PRIZE * COST_INCREASE);
	}
}
