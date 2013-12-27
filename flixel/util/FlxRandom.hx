package flixel.util;

/**
 * A class containing a set of functions for randomn generation.
 */
class FlxRandom
{
	/**
	 * The global random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive.
	 * However, FlxG automatically sets this with a new random seed when starting your game.
	 */
	static public var globalSeed(default, set):Int = 1;
	
	/**
	 * Internal function to update the internal seed whenever the global seed is reset, and keep the global seed's value in range.
	 */
	static private function set_globalSeed( NewSeed:Int ):Int
	{
		if ( NewSeed < 1 )
		{
			NewSeed = 1;
		}
		
		if ( NewSeed > MODULUS )
		{
			NewSeed = MODULUS;
		}
		
		internalSeed = NewSeed;
		globalSeed = NewSeed;
		
		return globalSeed;
	}
	
	/**
	 * Internal seed used to generate new random numbers.
	 */
	static private var internalSeed:Int = 1;
	
	/**
	 * Constants used in the pseudorandom number generation equation.
	 * These are identical to the constants for Microsoft Visual Basic 6 as they are well-tested, produce a wide period of results, and can be used to produce only positive numbers without exceeding 31 bits.
	 * 
	 * @see 	http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see 	http://support.microsoft.com/kb/231847
	 */
	inline static private var MULTIPLIER:Int = 1140671485;
	inline static private var INCREMENT:Int = 12820163;
	inline static private var MODULUS:Int = 16777216;
	
	/**
	 * Function to easily set the global seed to a new random number. Used primarily by FlxG whenever the game is reset.
	 * Please note that this function is not deterministic! If you call it in your game, recording may not work.
	 * 
	 * @return	The new global seed.
	 */
	static public function resetGlobalSeed():Int
	{
		return globalSeed = Std.int( Math.random() * MODULUS );
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 33,554,429, inclusive.
	 */
	static public function int():Int
	{
		return generate();
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 1, inclusive.
	 */
	inline static public function float():Float
	{
		return generate() / ( MODULUS + MODULUS );
	}
	
	/**
	 * Returns a pseudorandom integer between Min and Max, inclusive. Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 * 
	 * @param	Min			The minimum value that should be returned. 0 by default.
	 * @param	Max			The maximum value that should be returned. 33,554,429 by default.
	 * @param	?Excludes	An optional array of values that should not be returned.
	 */
	inline static public function intRanged( Min:Int = 0, Max:Int = MODULUS, ?Excludes:Array<Int> ):Int
	{
		var result:Int = 0;
		
		if ( Min == Max )
		{
			result = Min;
		}
		else
		{
			// Swap values if reversed
			
			if ( Min > Max )
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}
			
			if ( Excludes == null )
			{
				Excludes = [];
			}
			
			do
			{
				result = Math.round( Min + float() * ( Max - Min ) );
			}
			while ( FlxArrayUtil.indexOf( Excludes, result ) >= 0 );
		}
		
		return result;
	}
	
	/**
	 * Returns a pseudorandom float value between Min and Max, inclusive. Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 * 
	 * @param	Min			The minimum value that should be returned. 0 by default.
	 * @param	Max			The maximum value that should be returned. 33,554,429 by default.
	 * @param	?Excludes	An optional array of values that should not be returned.
	 */
	inline static public function floatRanged( Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float> ):Float
	{
		var result:Float = 0;
		
		if ( Min == Max )
		{
			result = Min;
		}
		else
		{
			// Swap values if reversed.
			
			if ( Min > Max )
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}
			
			if ( Excludes == null )
			{
				Excludes = [];
			}
			
			do
			{
				result = Min + float() * ( Max - Min );
			}
			while ( FlxArrayUtil.indexOf( Excludes, result ) >= 0 );
		}
		
		return result;
	}
	
	/**
	 * Returns true or false based on the chance value (default 50%). 
	 * For example if you wanted a player to have a 30% chance of getting a bonus, call chanceRoll(30) - true means the chance passed, false means it failed.
	 * 
	 * @param 	Chance 	The chance of receiving the value. Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return 	Whether the roll passed or not.
	 */
	inline static public function chanceRoll( Chance:Float = 50 ):Bool
	{
		var result:Bool = false;
		
		if ( floatRanged( 0, 100 ) < Chance )
		{
			result = true;
		}
		
		return result;
	}
	
	/**
	 * Returns either a 1 or -1. 
	 * 
	 * @param	Chance	The chance of receiving a positive value. Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return	1 or -1
	 */
	inline static public function sign( Chance:Float = 50 ):Int
	{
		return chanceRoll( Chance ) ? 1 : -1;
	}
	
	/**
	 * Pseudorandomly select from an array of weighted options.
	 * For example, if you passed in an array of [ 50, 30, 20 ] there would be a 50% chance of returning a 0, a 30% chance of returning a 1, and a 20% chance of returning a 2.
	 * Note that the values in the array do not have to add to 100 or any other number. The percent chance will be equal to a given value in the array divided by the total of all values in the array.
	 * 
	 * @param	SelectionArray		An array of weights.
	 * @return	A value between 0 and ( SelectionArray.length - 1 ), with a probability equivalent to the values in SelectionArray.
	 */
	inline static public function weightedPick( SelectionArray:Array<Float> ):Int
	{
		var pick:Int = 0;
		var sumOfWeights:Float = 0;
		
		for ( i in SelectionArray )
		{
			sumOfWeights += i;
		}
		
		var randSelect:Float = floatRanged( 0, sumOfWeights );
		
		for ( i in 0...SelectionArray.length - 1 )
		{
			if ( randSelect < SelectionArray[i] )
			{
				pick = i;
				break;
			}
			
			randSelect -= SelectionArray[i];
		}
		
		return pick;
	}
	
	/**
	 * Returns a pseudorandom color value in hex ARGB format.
	 * 
	 * @param	Min		The lowest value to use for each channel.
	 * @param	Max 	The highest value to use for each channel.
	 * @param	Alpha	The alpha value of the returning color (default 255 = fully opaque).
	 * @return 	A color value in hex ARGB format.
	 */
	inline static public function color( Min:Int = 0, Max:Int = 255, Alpha:Int = 255 ):Int
	{
		var red:Int = intRanged( Min, Max );
		var green:Int = intRanged( Min, Max );
		var blue:Int = intRanged( Min, Max );
		
		return FlxColorUtil.makeFromARGB( Alpha, red, green, blue );
	}
	
	/**
	 * Internal method to quickly generate a number between 1 and 2,147,483,647 inclusive. Used only by other functions of this class.
	 * 
	 * @return	A new pseudorandom number.
	 */
	static private function generate():Int
	{
		return internalSeed = ( internalSeed * MULTIPLIER + INCREMENT ) % MODULUS + MODULUS;
	}
}