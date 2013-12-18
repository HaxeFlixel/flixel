package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;

class Enemy extends FlxSprite 
{
	public var moneyGain:Bool = true;
	public var maxHealth:Float = 1.0;
	
	/**
	 * Create a new enemy. Used in the menu and playstate.
	 * 
	 * @param	X	The X position for the enemy.
	 * @param	Y	The Y position for the enemy.
	 */
	override public function new( X:Int, Y:Int ) 
	{
		super( X, Y, Reg.enemyImage );
		
		health = maxHealth;
	}
	
	/**
	 * Reset this enemy at X,Y and reset their health. Used for object pooling in the PlayState.
	 * 
	 * @param	X	The X position for the enemy.
	 * @param	Y	The Y position for the enemy.
	 */
	public function init( X:Int, Y:Int )
	{
		reset( X, Y );
		
		if ( Reg.PS != null ) {
			health = Math.floor( Reg.PS.wave / 3 ) + 1;
		}
		
		maxHealth = health;
	}
	
	/**
	 * The alpha of the enmy is dependent on health.
	 */
	override public function update():Void
	{
		alpha = health / maxHealth; 
		
		super.update();
	}
	
	/**
	 * Inflict horrible pain on this adorable square. How could you?!
	 * 
	 * @param	Damage	The damage to deal to this enemy.
	 */
	override public function hurt( Damage:Float ):Void
	{
		health -= Damage;
		
		if ( health <= 0 ) {
			explode( true );
		}
	}
	
	/**
	 * Called on this enemy's death. Recycles and emits particles, updates the number of enemies left,
	 * finishes the wave if it was the last enemy, and awards money as appropriate.
	 * 
	 * @param	GainMoney	Whether or not this enemy should give the player money. True if killed by a tower, false if killed by colliding with the goal.
	 */
	public function explode( GainMoney:Bool ):Void
	{
		#if !js
		FlxG.sound.play("enemykill");
		#end
		
		var emitter:EnemyGibs = Reg.PS.emitterGroup.recycle( EnemyGibs );
		emitter.explode( x, y );
		
		Reg.PS.enemiesToKill--;
		
		if ( Reg.PS.enemiesToKill <= 0 ) {
			Reg.PS.killedWave();
		}
		
		if ( GainMoney ) {
			var money:Int = ( Reg.PS.wave < 5 ) ? 2 : 1;
			
			Reg.PS.money += money;
		}
		
		super.kill();
	}
	
	/**
	 * Start this enemy on a path, as represented by an array of FlxPoints. Updates position to the first node
	 * and then uses FlxPath.start() to set this enemy on the path. Speed is determined by wave number, unless
	 * in the menu, in which case it's arbitrary.
	 * 
	 * @param	Path	The path to follow.
	 */
	public function followPath( Path:Array<FlxPoint> ):Void
	{
		x = Path[0].x;
		y = Path[0].y;
		
		if ( Reg.PS != null ) {
			FlxPath.start( this, Path, 20 + Reg.PS.wave, 0, true );
		} else {
			FlxPath.start( this, Path, 50, 0, true );
		}
	}
}