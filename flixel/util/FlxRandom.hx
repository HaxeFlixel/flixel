package flixel.util;

/**
 * A class containing a set of functions for randomnly 
 * generating numbers or other random things.
 */
class FlxRandom
{
	/**
	 * The global random number generator seed (for deterministic behavior in recordings and saves).
	 */
	static public var globalSeed:Float;
	/**
	 * Internal helper for <code>FlxRandom.int()</code>
	 */
	static private var intHelper:Int = 0;
	/**
	 * Maximum value returned by <code>FlxRandom.intRanged</code> and <code>FlxRandom.floatRanged</code> by default.
	 */
	static public inline var MAX_RANGE:Int = 0xffffff;
	
	/**
	 * Generates a small random number between 0 and 65535 very quickly
	 * 
	 * Generates a small random number between 0 and 65535 using an extremely fast cyclical generator, 
	 * with an even spread of numbers. After the 65536th call to this function the value resets.
	 * 
	 * @return A pseudo random value between 0 and 65536 inclusive.
	 */
	static public function int():Int
	{
		var result:Int = Std.int(intHelper);
		
		result++;
		result *= 75;
		result %= 65537;
		result--;
		
		intHelper++;
		
		if (intHelper == 65536)
		{
			intHelper = 0;
		}
		
		return result;
	}
	
	/**
	 * Generate a random integer
	 * 
	 * If called without the optional min, max arguments rand() returns a peudo-random integer between 0 and MAX_RANGE.
	 * If you want a random number between 5 and 15, for example, (inclusive) use rand(5, 15)
	 * Parameter order is insignificant, the return will always be between the lowest and highest value.
	 * 
	 * @param 	min 		The lowest value to return (default: 0)
	 * @param 	max 		The highest value to return (default: MAX_RANGE)
	 * @param 	excludes 	An Array of integers that will NOT be returned (default: null)
	 * @return A pseudo-random value between min (or 0) and max (or MAX_RANGE, inclusive)
	 */
	static public function intRanged(?min:Float, ?max:Float, ?excludes:Array<Float> = null):Int
	{
		if (min == null)
		{
			min = 0;
		}
		
		if (max == null)
		{
			max = MAX_RANGE;
		}
		
		if (min == max)
		{
			return Math.floor(min);
		}
		
		if (excludes != null)
		{
			//	Sort the exclusion array
			//excludes.sort(Array.NUMERIC);
			excludes.sort(FlxMath.numericComparison);
			
			var result:Int;
			
			do {
				if (min < max)
				{
					result = Math.floor(min + (Math.random() * (max + 1 - min)));
				}
				else
				{
					result = Math.floor(max + (Math.random() * (min + 1 - max)));
				}
			}
			while (FlxArray.indexOf(excludes, result) >= 0);
			
			return result;
		}
		else
		{
			//	Reverse check
			if (min < max)
			{
				return Math.floor(min + (Math.random() * (max + 1 - min)));
			}
			else
			{
				return Math.floor(max + (Math.random() * (min + 1 - max)));
			}
		}
	}
	
	/**
	 * Generates a random number.  Deterministic, meaning safe
	 * to use if you want to record replays in random environments.
	 * @return	A <code>Number</code> between 0 and 1.
	 */
	inline static public function float():Float
	{
		globalSeed = srand(globalSeed);
		if (globalSeed <= 0) globalSeed += 1;
		return globalSeed;
	}
	
	/**
	 * Generate a random float (number)
	 * 
	 * If called without the optional min, max arguments rand() returns a peudo-random float between 0 and MAX_RANGE().
	 * If you want a random number between 5 and 15, for example, (inclusive) use rand(5, 15)
	 * Parameter order is insignificant, the return will always be between the lowest and highest value.
	 * 
	 * @param 	min 	The lowest value to return (default: 0)
	 * @param 	max 	The highest value to return (default: MAX_RANGE)
	 * @return A pseudo random value between min (or 0) and max (or MAX_RANGE, inclusive)
	 */
	static public function floatRanged(?min:Float, ?max:Float):Float
	{
		if (min == null)
		{
			min = 0;
		}
		
		if (max == null)
		{
			max = MAX_RANGE;
		}
		
		if (min == max)
		{
			return min;
		}
		else if (min < max)
		{
			return min + (Math.random() * (max - min + 1));
		}
		else
		{
			return max + (Math.random() * (min - max + 1));
		}
	}
	
	/**
	 * Generates a random number based on the seed provided.
	 * @param	Seed	A number between 0 and 1, used to generate a predictable random number (very optional).
	 * @return	A <code>Number</code> between 0 and 1.
	 */
	inline static public function srand(Seed:Float):Float
	{
		return ((69621 * Std.int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
	}
	
	/**
	 * Generate a random boolean result based on the chance value
	 * 
	 * Returns true or false based on the chance value (default 50%). For example if you wanted a player to have a 30% chance
	 * of getting a bonus, call chanceRoll(30) - true means the chance passed, false means it failed.
	 * 
	 * @param 	chance 	The chance of receiving the value. Should be given as a uint between 0 and 100 (effectively 0% to 100%)
	 * @return true if the roll passed, or false
	 */
	static public function chanceRoll(chance:Int = 50):Bool
	{
		if (chance <= 0)
		{
			return false;
		}
		else if (chance >= 100)
		{
			return true;
		}
		else
		{
			if (Math.random() * 100 >= chance)
			{
				return false;
			}
			else
			{
				return true;
			}
		}
	}
	
	/**
	 * Randomly returns either a 1 or -1
	 * 
	 * @return	1 or -1
	 */
	inline static public function sign():Float
	{
		return (Math.random() > 0.5) ? 1 : -1;
	}
	
	/**
	 * Returns a random color value between black and white
	 * <p>Set the min value to start each channel from the given offset.</p>
	 * <p>Set the max value to restrict the maximum color used per channel</p>
	 * 
	 * @param	min		The lowest value to use for the color
	 * @param	max 	The highest value to use for the color
	 * @param	alpha	The alpha value of the returning color (default 255 = fully opaque)
	 * 
	 * @return 32-bit color value with alpha
	 */
	inline static public function color(min:Int = 0, max:Int = 255, alpha:Int = 255):Int
	{
		return FlxColor.getRandomColor(min, max, alpha);
	}
}