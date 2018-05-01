package;

import flixel.util.FlxColor;

/**
 * Identical to the FlxRandom class in HaxeFlixel, but with no inlining, for speed comparison.
 */
class NonInlineFlxRandom
{
	/**
	 * The global random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive. However, FlxG automatically sets this with a new random seed when starting your game. Altering this yourself may break recording functionality!
	 */
	public static var globalSeed(default, set):Int = 1;
	
	/**
	 * Internal function to update the internal seed whenever the global seed is reset, and keep the global seed's value in range.
	 */
	static function set_globalSeed(NewSeed:Int):Int
	{
		if (NewSeed < 1)
		{
			NewSeed = 1;
		}
		
		if (NewSeed > MODULUS)
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
	static var internalSeed:Int = 1;
	
	/**
	 * Constants used in the pseudorandom number generation equation.
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator, and they use the full range of possible integer values.
	 * 
	 * @see 	http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see 	Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988). "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 */
	static var MULTIPLIER:Int = 48271;
	static var INCREMENT:Int = 0;
	static var MODULUS:Int = 2147483647;
	
	/**
	 * Function to easily set the global seed to a new random number. Used primarily by FlxG whenever the game is reset.
	 * Please note that this function is not deterministic! If you call it in your game, recording may not work.
	 * 
	 * @return	The new global seed.
	 */
	public static function resetGlobalSeed():Int
	{
		return globalSeed = Std.int(Math.random() * MODULUS);
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 2,147,483,647, inclusive.
	 */
	public static function int():Int
	{
		return generate();
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 1, inclusive.
	 */
	public static function float():Float
	{
		return generate() / MODULUS;
	}
	
	/**
	 * Returns a pseudorandom integer between Min and Max, inclusive. Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 * 
	 * @param	Min			The minimum value that should be returned. 0 by default.
	 * @param	Max			The maximum value that should be returned. 2,147,483,647 by default.
	 * @param	?Excludes	An optional array of values that should not be returned.
	 */
	public static function intRanged(Min:Int = 0, Max:Int = 2147483647, ?Excludes:Array<Int>):Int
	{
		var result:Int = 0;
		
		if (Min == Max)
		{
			result = Min;
		}
		else
		{
			// Swap values if reversed
			
			if (Min > Max)
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}
			
			if (Excludes == null)
			{
				Excludes = [];
			}
			
			do
			{
				result = Math.round(Min + float() * (Max - Min));
			}
			while (Excludes.indexOf(result) >= 0);
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
	public static function floatRanged(Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float>):Float
	{
		var result:Float = 0;
		
		if (Min == Max)
		{
			result = Min;
		}
		else
		{
			// Swap values if reversed.
			
			if (Min > Max)
			{
				Min = Min + Max;
				Max = Min - Max;
				Min = Min - Max;
			}
			
			if (Excludes == null)
			{
				Excludes = [];
			}
			
			do
			{
				result = Min + float() * (Max - Min);
			}
			while (Excludes.indexOf(result) >= 0);
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
	public static function chanceRoll(Chance:Float = 50):Bool
	{
		var result:Bool = false;
		
		if (floatRanged(0, 100) < Chance)
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
	public static function sign(Chance:Float = 50):Int
	{
		return chanceRoll(Chance) ? 1 : -1;
	}
	
	/**
	 * Pseudorandomly select from an array of weighted options. For example, if you passed in an array of [ 50, 30, 20 ] there would be a 50% chance of returning a 0, a 30% chance of returning a 1, and a 20% chance of returning a 2.
	 * Note that the values in the array do not have to add to 100 or any other number. The percent chance will be equal to a given value in the array divided by the total of all values in the array.
	 * 
	 * @param	WeightsArray		An array of weights.
	 * @return	A value between 0 and ( SelectionArray.length - 1 ), with a probability equivalent to the values in SelectionArray.
	 */
	public static function weightedPick(WeightsArray:Array<Float>):Int
	{
		var pick:Int = 0;
		var sumOfWeights:Float = 0;
		
		for (i in WeightsArray)
		{
			sumOfWeights += i;
		}
		
		var randSelect:Float = floatRanged(0, sumOfWeights);
		
		for (i in 0...WeightsArray.length - 1)
		{
			if (randSelect < WeightsArray[i])
			{
				pick = i;
				break;
			}
			
			randSelect -= WeightsArray[i];
		}
		
		return pick;
	}
	
	/**
	 * Fetch a random entry from the given array from StartIndex to EndIndex. Will return null if random selection is missing, or array has no entries.
	 * Deterministic and safe for use with replays/recordings.
	 * 
	 * @param	Objects			An array from which to select a random entry.
	 * @param	StartIndex		Optional index from which to restrict selection. Default value is 0, or the beginning of the array.
	 * @param	EndIndex		Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return	The random object that was selected.
	 */
	@:generic public static function getObject<T>(Objects:Array<T>, StartIndex:Int = 0, EndIndex:Int = 0):T
	{
		var selected:Null<T> = null;
		
		if (Objects.length != 0)
		{
			if (StartIndex < 0)
			{
				StartIndex = 0;
			}
			
			// Swap values if reversed
			
			if (EndIndex < StartIndex)
			{
				StartIndex = StartIndex + EndIndex;
				EndIndex = StartIndex - EndIndex;
				StartIndex = StartIndex - EndIndex;
			}
			
			if ((EndIndex <= 0) || (EndIndex > Objects.length - 1))
			{
				EndIndex = Objects.length - 1;
			}
			
			selected = Objects[intRanged(StartIndex, EndIndex)];
		}
		
		return selected;
	}
	
	
	/**
	 * Returns an object pseudorandomly from an array between StartIndex and EndIndex with a weighted chance from WeightsArray.
	 * This function is essentially a combination of weightedPick and getObject.
	 * 
	 * @param	Objects			An array from which to return an object.
	 * @param	WeightsArray	An array of weights which will determine the likelihood of returning a given value from Objects. Values in WeightsArray will correspond to objects in Objects exactly.
	 * @param	StartIndex		Optional index from which to restrict selection. Default value is 0, or the beginning of the array.
	 * @param 	EndIndex 		Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return	A pseudorandomly chosen object from Objects.
	 */
	@:generic public static function weightedGetObject<T>(Objects:Array<T>, WeightsArray:Array<Float>, StartIndex:Int = 0, EndIndex:Int = 0):T
	{
		var selected:Null<T> = null;
		
		if (Objects.length != 0)
		{
			if (StartIndex < 0)
			{
				StartIndex = 0;
			}
			
			// Swap values if reversed
			
			if (EndIndex < StartIndex)
			{
				StartIndex = StartIndex + EndIndex;
				EndIndex = StartIndex - EndIndex;
				StartIndex = StartIndex - EndIndex;
			}
			
			if ((EndIndex <= 0) || (EndIndex > Objects.length - 1) || (EndIndex > WeightsArray.length - 1))
			{
				EndIndex = Objects.length - 1;
			}
			
			var subArray:Array<T> = [];
			
			for (i in StartIndex...EndIndex)
			{
				subArray.push(Objects[i]);
			}
			
			var weightedSubArray:Array<Float> = [];
			
			for (i in StartIndex...EndIndex)
			{
				weightedSubArray.push(WeightsArray[i]);
			}
			
			var selectionInt:Int = weightedPick(weightedSubArray);
			
			selected = Objects[selectionInt];
		}
		
		return selected;
	}
	
	/**
	 * Returns a pseudorandom color value in hex ARGB format.
	 * 
	 * @param	Min		The lowest value to use for each channel.
	 * @param	Max 	The highest value to use for each channel.
	 * @param	Alpha	The alpha value of the returning color (default 255 = fully opaque).
	 * @return 	A color value in hex ARGB format.
	 */
	public static function color(Min:Int = 0, Max:Int = 255, Alpha:Int = 255):FlxColor
	{
		var red:Int = intRanged(Min, Max);
		var green:Int = intRanged(Min, Max);
		var blue:Int = intRanged(Min, Max);
		
		return FlxColor.fromRGB(Alpha, red, green, blue);
	}
	
	/**
	 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
	 * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
	 * 
	 * @return	A new pseudorandom number.
	 */
	static function generate():Int
	{
		return internalSeed = ((internalSeed * MULTIPLIER + INCREMENT) % MODULUS) & MODULUS;
	}
}