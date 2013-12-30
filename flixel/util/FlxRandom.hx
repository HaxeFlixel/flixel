package flixel.util;

/**
 * A class containing a set of functions for random generation.
 */
class FlxRandom
{
	/**
	 * The global random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive. However, FlxG automatically sets this with a new random seed when starting your game. Altering this yourself may break recording functionality!
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
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator, and they use the full range of possible integer values.
	 * 
	 * @see 	http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see 	Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988). "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 */
	inline static private var MULTIPLIER:Int = 48271;
	inline static private var INCREMENT:Int = 0;
	inline static private var MODULUS:Int = 2147483647;
	
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
	 * Returns a pseudorandom number between 0 and 2,147,483,647, inclusive.
	 */
	inline static public function int():Int
	{
		return generate();
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 1, inclusive.
	 */
	inline static public function float():Float
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
				result = Math.floor( Min + float() * ( Max - Min + 1 ) );
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
	 * Pseudorandomly select from an array of weighted options. For example, if you passed in an array of [ 50, 30, 20 ] there would be a 50% chance of returning a 0, a 30% chance of returning a 1, and a 20% chance of returning a 2.
	 * Note that the values in the array do not have to add to 100 or any other number. The percent chance will be equal to a given value in the array divided by the total of all values in the array.
	 * 
	 * @param	WeightsArray		An array of weights.
	 * @return	A value between 0 and ( SelectionArray.length - 1 ), with a probability equivalent to the values in SelectionArray.
	 */
	inline static public function weightedPick( WeightsArray:Array<Float> ):Int
	{
		var pick:Int = 0;
		var sumOfWeights:Float = 0;
		
		for ( i in WeightsArray )
		{
			sumOfWeights += i;
		}
		
		var randSelect:Float = floatRanged( 0, sumOfWeights );
		
		for ( i in 0...WeightsArray.length )
		{
			if ( randSelect < WeightsArray[i] )
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
	@:generic inline static public function getObject<T>( Objects:Array<T>, StartIndex:Int = 0, EndIndex:Int = 0 ):T
	{
		var selected:Null<T> = null;
		
		if ( Objects.length != 0 )
		{
			if ( StartIndex < 0 )
			{
				StartIndex = 0;
			}
			
			// Swap values if reversed
			
			if ( EndIndex < StartIndex )
			{
				StartIndex = StartIndex + EndIndex;
				EndIndex = StartIndex - EndIndex;
				StartIndex = StartIndex - EndIndex;
			}
			
			if ( ( EndIndex <= 0 ) || ( EndIndex > Objects.length - 1 ) )
			{
				EndIndex = Objects.length - 1;
			}
			
			selected = Objects[ intRanged( StartIndex, EndIndex ) ];
		}
		
		return selected;
	}
	
	
	/**
	 * Shuffles the entries in an array into a new pseudorandom order.
	 * 
	 * @param	Objects			An array to shuffle.
	 * @param	HowManyTimes	How many swaps to perform during the shuffle operation.  A good rule of thumb is 2-4 times the number of objects in the list.
	 * @return	The newly shuffled array.
	 */
	@:generic inline static public function shuffleArray<T>( Objects:Array<T>, HowManyTimes:Int ):Array<T>
	{
		HowManyTimes = Std.int( Math.max( HowManyTimes, 0 ) );
		
		var index1:Int = 0;
		var index2:Int = 0;
		var tempObject:Null<T> = null;
		
		for ( i in 0...HowManyTimes )
		{
			index1 = intRanged( 0, Objects.length - 1 );
			index2 = intRanged( 0, Objects.length - 1 );
			tempObject = Objects[index1];
			Objects[index1] = Objects[index2];
			Objects[index2] = tempObject;
		}
		
		return Objects;
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
	@:generic inline static public function weightedGetObject<T>( Objects:Array<T>, WeightsArray:Array<Float>, StartIndex:Int = 0, EndIndex:Int = 0 ):T
	{
		var selected:Null<T> = null;
		
		if ( Objects.length != 0 )
		{
			if ( StartIndex < 0 )
			{
				StartIndex = 0;
			}
			
			// Swap values if reversed
			
			if ( EndIndex < StartIndex )
			{
				StartIndex = StartIndex + EndIndex;
				EndIndex = StartIndex - EndIndex;
				StartIndex = StartIndex - EndIndex;
			}
			
			if ( ( EndIndex <= 0 ) || ( EndIndex > Objects.length - 1 ) )
			{
				EndIndex = Objects.length - 1;
			}
			
			var weightedSubArray:Array<Float> = [ for ( i in StartIndex...EndIndex ) WeightsArray[i] ];
			
			var weightedSelect:Int = weightedPick( weightedSubArray );
			
			selected = Objects[ weightedSelect ];
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
	inline static public function color( Min:Int = 0, Max:Int = 255, Alpha:Int = 255 ):Int
	{
		if ( Min < 0 )
		{
			Min = 0;
		}
		
		if ( Min > 255 )
		{
			Min = 255;
		}
		
		if ( Max < 0 )
		{
			Max = 0;
		}
		
		if ( Max > 255 )
		{
			Max = 255;
		}
		
		// Swap values if reversed
		
		if ( Max < Min )
		{
			Min = Min + Max;
			Max = Min - Max;
			Min = Min - Max;
		}
		
		var red:Int = intRanged( Min, Max );
		var green:Int = intRanged( Min, Max );
		var blue:Int = intRanged( Min, Max );
		
		return FlxColorUtil.makeFromARGB( Alpha, red, green, blue );
	}
	
	/**
	 * Much like color(), but with much finer control over the output color.
	 * 
	 * @param	RedMinimum		The minimum amount of red in the output color, from 0 to 255.
	 * @param	RedMaximum		The maximum amount of red in the output color, from 0 to 255.
	 * @param	GreedMinimum	The minimum amount of green in the output color, from 0 to 255.
	 * @param	GreenMaximum	The maximum amount of green in the output color, from 0 to 255.
	 * @param	BlueMinimum		The minimum amount of blue in the output color, from 0 to 255.
	 * @param	BlueMaximum		The maximum amount of blue in the output color, from 0 to 255.
	 * @param	AlphaMinimum	The minimum alpha value for the output color, from 0 (fully transparent) to 255 (fully opaque). Set to -1 or ignore for the output to be always fully opaque.
	 * @param	AlphaMaximum	The maximum alpha value for the output color, from 0 (fully transparent) to 255 (fully opaque). Set to -1 or ignore for the output to be always fully opaque.
	 * @return	A pseudorandomly generated color within the ranges specified.
	 */
	inline static public function colorExt( RedMinimum:Int = 0, RedMaximum:Int = 255, GreenMinimum:Int = 0, GreenMaximum:Int = 255, BlueMinimum:Int = 0, BlueMaximum:Int = 255, AlphaMinimum:Int = -1, AlphaMaximum:Int = -1 ):Int
	{
		if ( RedMinimum < 0 ) RedMinimum = 0;
		if ( RedMinimum > 255 ) RedMinimum = 255;
		if ( RedMaximum < 0 ) RedMaximum = 0;
		if ( RedMaximum > 255 ) RedMaximum = 255;
		if ( GreenMinimum < 0 ) GreenMinimum = 0;
		if ( GreenMinimum > 255 ) GreenMinimum = 255;
		if ( GreenMaximum < 0 ) GreenMaximum = 0;
		if ( GreenMaximum > 255 ) GreenMaximum = 255;
		if ( BlueMinimum < 0 ) BlueMinimum = 0;
		if ( BlueMinimum > 255 ) BlueMinimum = 255;
		if ( BlueMaximum < 0 ) BlueMaximum = 0;
		if ( BlueMaximum > 255 ) BlueMaximum = 255;
		if ( AlphaMinimum == -1 ) AlphaMinimum = 255;
		if ( AlphaMaximum == -1 ) AlphaMaximum = 255;
		if ( AlphaMinimum < 0 ) AlphaMinimum = 0;
		if ( AlphaMinimum > 255 ) AlphaMinimum = 255;
		if ( AlphaMaximum < 0 ) AlphaMaximum = 0;
		if ( AlphaMaximum > 255 ) AlphaMaximum = 255;
		
		var red:Int = intRanged( RedMinimum, RedMaximum );
		var green:Int = intRanged( GreenMinimum, GreenMaximum );
		var blue:Int = intRanged( BlueMinimum, BlueMaximum );
		var alpha:Int = intRanged( AlphaMinimum, AlphaMaximum );
		
		return FlxColorUtil.makeFromARGB( alpha, red, green, blue );
	}
	
	/**
	 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
	 * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
	 * 
	 * @return	A new pseudorandom number.
	 */
	inline static private function generate():Int
	{
		return internalSeed = ( ( internalSeed * MULTIPLIER + INCREMENT ) % MODULUS ) & MODULUS;
	}
}