package flixel.util;

class FlxChance
{
	/**
	 * The first part of the ratio determining chance, e.g. in 1:1000 the numerator is 1.
	 */
	public var numerator:Int = 1;
	/**
	 * The second part of the ratio determining chance, e.g. in 1:1000 the denominator is 1000.
	 */
	public var denominatorBase:Int = 1;
	/**
	 * The currently applied denominator, as it has been affected by things such as decrement.
	 */
	public var denominatorCurrent:Int = 1;
	/**
	 * A multiplier that increases (or decreases) the chance. For example, if you wanted to double the drop chance, set buff to 2.
	 */
	public var buff:Float = 1.0;
	/**
	 * Functions identical to buff, but meant to indicate an area effect modification to chance, such as a certain dungeon, level, range from an enemy, etc.
	 */
	public var areaEffect:Float = 1.0;
	/**
	 * How much to decrease the denominator by each time the chance is calculated. For example, if the chance was 1:1000 and the decrement was 100, then the chance would increase to 1:900 after one chance check.
	 */
	public var decrement:Int = 0;
	/**
	 * Set this to true for blocking to be activated after a successful check.
	 */
	public var enableBlocking:Bool = false;
	/**
	 * After a successful chance check, this will prevent the player from having a successful chance for a given number of checks. For example, if set to 10, the next 10 checks after a chance check returned true would have a 100% chance of being false.
	 */
	public var blockTimes:Int = 0;
	/**
	 * After a successful chance check, this will prevent the player from having a successful chance for a given period of time. For example, if set to 10, any checks in the next 10 seconds will have a 100% chance of being false.
	 */
	public var blockTimer:Float = 0;
	/**
	 * Used internally for tracking the blocking status.
	 */
	public var blocking:Bool = false;
	
	/**
	 * Storage for a number of variables which can modify loot drop, critical hit, or any other chance.
	 * Used by FlxRandom.chanceCheck().
	 */
	public function new( Numerator:Int, Denominator:Int, Buff:Float = 1.0, AreaEffect:Float = 1.0, Decrement:Int = 0, EnableBlocking:Bool = false, BlockTimes:Int = 0, BlockTimer:Float = 0 )
	{
		numerator = Numerator;
		denominatorBase = Denominator;
		denominatorCurrent = Denominator;
		buff = Buff;
		areaEffect = AreaEffect;
		decrement = Decrement;
		blockTimes = BlockTimes;
		blockTimer = BlockTimer;
	}
	
	/**
	 * The current chance of a chanceCheck on this object being successful, on a scale from 0 to 1.
	 */
	public var currentChance(get, null):Float;
	
	private function get_currentChance():Float
	{
		var chance:Float = 0.0;
		
		if ( !blocking )
		{
			chance = ( numerator / denominatorCurrent ) * buff * areaEffect;
		}
		
		return chance;
	}
}