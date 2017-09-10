package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPath;
import flixel.math.FlxPoint;

class Enemy extends FlxSprite 
{
	public var moneyGain:Bool = true;
	public var maxHealth:Float = 1.0;
	
	/**
	 * Create a new enemy. Used in the menu and playstate.
	 */
	override public function new(X:Float, Y:Float) 
	{
		super(X, Y, Reg.enemyImage);
		health = maxHealth;
	}
	
	/**
	 * Reset this enemy at X,Y and reset their health. Used for object pooling in the PlayState.
	 */
	public function init(X:Float, Y:Float)
	{
		reset(X, Y);
		
		if (Reg.PS != null)
			health = Math.floor(Reg.PS.wave / 3) + 1;
		
		maxHealth = health;
	}
	
	/**
	 * The alpha of the enemy is dependent on health.
	 */
	override public function update(elapsed:Float):Void
	{
		alpha = health / maxHealth; 
		super.update(elapsed);
	}
	
	/**
	 * Inflict horrible pain on this adorable square. How could you?!
	 * 
	 * @param	Damage	The damage to deal to this enemy.
	 */
	override public function hurt(Damage:Float):Void
	{
		health -= Damage;
		
		if (health <= 0)
			explode(true);
	}
	
	/**
	 * Called on this enemy's death. Recycles and emits particles, updates the number of enemies left,
	 * finishes the wave if it was the last enemy, and awards money as appropriate.
	 * 
	 * @param	GainMoney	Whether or not this enemy should give the player money. True if killed by a tower, false if killed by colliding with the goal.
	 */
	public function explode(GainMoney:Bool):Void
	{
		FlxG.sound.play("enemykill");
		
		var emitter = Reg.PS.emitterGroup.recycle(EnemyGibs.new);
		emitter.startAtPosition(x, y);
		
		Reg.PS.enemiesToKill--;
		
		if (Reg.PS.enemiesToKill <= 0)
			Reg.PS.killedWave();
		
		if (GainMoney)
		{
			var money:Int = (Reg.PS.wave < 5) ? 2 : 1;
			Reg.PS.money += money;
		}
		
		super.kill();
	}
	
	/**
	 * Start this enemy on a path, as represented by an array of FlxPoints. Updates position to the first node
	 * and then uses FlxPath.start() to set this enemy on the path. Speed is determined by wave number, unless
	 * in the menu, in which case it's arbitrary.
	 */
	public function followPath(Path:Array<FlxPoint>, Speed:Int, ?OnComplete:FlxPath->Void):Void
	{
		if (Path == null)
			throw("No valid path was passed to the enemy! Does the tilemap provide a valid path from start to finish?");
		
		x = Path[0].x;
		y = Path[0].y;
		
		path = new FlxPath().start(Path, Speed, 0, true);
		path.onComplete = OnComplete;
	}
}