package org.flixel.util;

/**
 * A class containing a set of functions for randomnly 
 * generating numbers or other random things.
 */
class FlxRandom
{
	public static inline var getrandmax:Int = 0xffffff; // Std.int(FlxMath.MAX_VALUE);
	private static var mr:Int = 0;
		
	/**
	 * Generates a random number based on the seed provided.
	 * @param	Seed	A number between 0 and 1, used to generate a predictable random number (very optional).
	 * @return	A <code>Number</code> between 0 and 1.
	 */
	inline static public function srand(Seed:Float):Float
	{
		#if !neko
		return ((69621 * Std.int(Seed * 0x7FFFFFFF)) % 0x7FFFFFFF) / 0x7FFFFFFF;
		#else
		return Math.random();
		#end
	}
	
	/**
	 * Shuffles the entries in an array into a new random order.
	 * <code>FlxG.shuffle()</code> is deterministic and safe for use with replays/recordings.
	 * HOWEVER, <code>FlxMath.shuffle()</code> is NOT deterministic and unsafe for use with replays/recordings.
	 * @param	A				A Flash <code>Array</code> object containing...stuff.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  Good rule of thumb is 2-4 times as many objects are in the list.
	 * @return	The same Flash <code>Array</code> object that you passed in in the first place.
	 */
	inline static public function shuffle(Objects:Array<Dynamic>, HowManyTimes:Int):Array<Dynamic>
	{
		var i:Int = 0;
		var index1:Int;
		var index2:Int;
		var object:Dynamic;
		while(i < HowManyTimes)
		{
			index1 = Std.int(Math.random() * Objects.length);
			index2 = Std.int(Math.random() * Objects.length);
			object = Objects[index2];
			Objects[index2] = Objects[index1];
			Objects[index1] = object;
			i++;
		}
		return Objects;
	}
	
	/**
	 * Fetch a random entry from the given array.
	 * Will return null if random selection is missing, or array has no entries.
	 * <code>FlxG.getRandom()</code> is deterministic and safe for use with replays/recordings.
	 * HOWEVER, <code>FlxMath.getRandom()</code> is NOT deterministic and unsafe for use with replays/recordings.
	 * @param	Objects		A Flash array of objects.
	 * @param	StartIndex	Optional offset off the front of the array. Default value is 0, or the beginning of the array.
	 * @param	Length		Optional restriction on the number of values you want to randomly select from.
	 * @return	The random object that was selected.
	 */
	inline static public function getRandom(Objects:Array<Dynamic>, StartIndex:Int = 0, Length:Int = 0):Dynamic
	{
		var res:Dynamic = null;
		if (Objects != null)
		{
			if (StartIndex < 0) StartIndex = 0;
			if (Length < 0) Length = 0;
			
			var l:Int = Length;
			if ((l == 0) || (l > Objects.length - StartIndex))
			{
				l = Objects.length - StartIndex;
			}
			if (l > 0)
			{
				res = Objects[StartIndex + Std.int(Math.random() * l)];
			}
		}
		return res;
	}
	
	/**
	 * Generate a random integer
	 * <p>
	 * If called without the optional min, max arguments rand() returns a peudo-random integer between 0 and getrandmax().
	 * If you want a random number between 5 and 15, for example, (inclusive) use rand(5, 15)
	 * Parameter order is insignificant, the return will always be between the lowest and highest value.
	 * </p>
	 * @param 	min 		The lowest value to return (default: 0)
	 * @param 	max 		The highest value to return (default: getrandmax)
	 * @param 	excludes 	An Array of integers that will NOT be returned (default: null)
	 * @return A pseudo-random value between min (or 0) and max (or getrandmax, inclusive)
	 */
	public static function rand(?min:Float, ?max:Float, ?excludes:Array<Float> = null):Int
	{
		if (min == null)
		{
			min = 0;
		}
		
		if (max == null)
		{
			max = getrandmax;
		}
		
		if (min == max)
		{
			return Math.floor(min);
		}
		
		if (excludes != null)
		{
			//	Sort the exclusion array
			//excludes.sort(Array.NUMERIC);
			excludes.sort(FlxRandom.numericComparison);
			
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
			while (FlxMisc.arrayIndexOf(excludes, result) >= 0);
			
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
	 * Generates a small random number between 0 and 65535 very quickly
	 * <p>
	 * Generates a small random number between 0 and 65535 using an extremely fast cyclical generator, 
	 * with an even spread of numbers. After the 65536th call to this function the value resets.
	 * </p>
	 * @return A pseudo random value between 0 and 65536 inclusive.
	 */
	public static function miniRand():Int
	{
		var result:Int = Std.int(mr);
		
		result++;
		result *= 75;
		result %= 65537;
		result--;
		
		mr++;
		
		if (mr == 65536)
		{
			mr = 0;
		}
		
		return result;
	}
	
	public static function numericComparison(int1:Float, int2:Float):Int
	{
		if (int2 > int1)
		{
			return -1;
		}
		else if (int1 > int2)
		{
			return 1;
		}
		return 0;
	}
	
	/**
	 * Generate a random float (number)
	 * <p>
	 * If called without the optional min, max arguments rand() returns a peudo-random float between 0 and getrandmax().
	 * If you want a random number between 5 and 15, for example, (inclusive) use rand(5, 15)
	 * Parameter order is insignificant, the return will always be between the lowest and highest value.
	 * </p>
	 * @param 	min 	The lowest value to return (default: 0)
	 * @param 	max 	The highest value to return (default: getrandmax)
	 * @return A pseudo random value between min (or 0) and max (or getrandmax, inclusive)
	 */
	public static function randFloat(?min:Float, ?max:Float):Float
	{
		if (min == null)
		{
			min = 0;
		}
		
		if (max == null)
		{
			max = getrandmax;
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
	 * Generate a random boolean result based on the chance value
	 * <p>
	 * Returns true or false based on the chance value (default 50%). For example if you wanted a player to have a 30% chance
	 * of getting a bonus, call chanceRoll(30) - true means the chance passed, false means it failed.
	 * </p>
	 * @param 	chance 	The chance of receiving the value. Should be given as a uint between 0 and 100 (effectively 0% to 100%)
	 * @return true if the roll passed, or false
	 */
	public static function chanceRoll(chance:Int = 50):Bool
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
	public static function sign():Float
	{
		return (Math.random() > 0.5) ? 1 : -1;
	}
}