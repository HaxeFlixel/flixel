package flixel.math;

import flixel.FlxGame;
import flixel.system.frontEnds.VCRFrontEnd;
import flixel.util.FlxColor;

#if js
import haxe.Int64;
#end

/**
 * A class containing a set of functions for random generation.
 */
class FlxRandom
{
	/**
	 * The global base random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive.
	 * However, FlxG automatically sets this with a new random seed when starting your game.
	 * Altering this yourself may break recording functionality!
	 */
	public static var globalSeed(default, set):Int = 1;
	
	/**
	 * Current seed used to generate new random numbers. You can retrieve this value if,
	 * for example, you want to store the seed that was used to randomly generate a level.
	 */
	public static var currentSeed(get, set):Int;
	
	/**
	 * Function to easily set the global seed to a new random number.
	 * Used primarily by FlxG whenever the game is reset.
	 * Please note that this function is not deterministic!
	 * If you call it in your game, recording may not function as expected.
	 * 
	 * @return  The new global seed.
	 */
	public static inline function resetGlobalSeed():Int
	{
		return globalSeed = Std.int(Math.random() * MODULUS);
	}
	
	/**
	 * Returns a pseudorandom integer between Min and Max, inclusive.
	 * Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 * 
	 * @param   Min        The minimum value that should be returned. 0 by default.
	 * @param   Max        The maximum value that should be returned. 2,147,483,647 by default.
	 * @param   Excludes   Optional array of values that should not be returned.
	 */
	public static function int(Min:Int = 0, Max:Int = MODULUS, ?Excludes:Array<Int>):Int
	{
		if (Min == 0 && Max == MODULUS && Excludes == null)
		{
			return Std.int(generate());
		}
		else if (Min == Max)
		{
			return Min;
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
				return Math.floor(Min + generate() / MODULUS * (Max - Min + 1));
			}
			else
			{
				var result:Int = 0;
				
				do
				{
					return Math.floor(Min + generate() / MODULUS * (Max - Min + 1));
				}
				while (Excludes.indexOf(result) >= 0);
				
				return result;
			}
		}
	}
	
	/**
	 * Returns a pseudorandom float value between Min and Max, inclusive.
	 * Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 * 
	 * @param   Min        The minimum value that should be returned. 0 by default.
	 * @param   Max        The maximum value that should be returned. 1 by default.
	 * @param   Excludes   Optional array of values that should not be returned.
	 */
	public static function float(Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float>):Float
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
				result = Min + (generate() / MODULUS) * (Max - Min);
			}
			else
			{
				do
				{
					result = Min + (generate() / MODULUS) * (Max - Min);
				}
				while (Excludes.indexOf(result) >= 0);
			}
		}
		
		return result;
	}
	
	/**
	 * Returns true or false based on the chance value (default 50%). 
	 * For example if you wanted a player to have a 30% chance of getting a bonus,
	 * call chanceRoll(30) - true means the chance passed, false means it failed.
	 * 
	 * @param   Chance   The chance of receiving the value.
	 *                   Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return  Whether the roll passed or not.
	 */
	public static inline function chanceRoll(Chance:Float = 50):Bool
	{
		return float(0, 100) < Chance;
	}
	
	/**
	 * Returns either a 1 or -1. 
	 * 
	 * @param   Chance   The chance of receiving a positive value.
	 *                   Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return  1 or -1
	 */
	public static inline function sign(Chance:Float = 50):Int
	{
		return chanceRoll(Chance) ? 1 : -1;
	}
	
	/**
	 * Pseudorandomly select from an array of weighted options. For example, if you passed in an array of [50, 30, 20]
	 * there would be a 50% chance of returning a 0, a 30% chance of returning a 1, and a 20% chance of returning a 2.
	 * Note that the values in the array do not have to add to 100 or any other number.
	 * The percent chance will be equal to a given value in the array divided by the total of all values in the array.
	 * 
	 * @param   WeightsArray   An array of weights.
	 * @return  A value between 0 and (SelectionArray.length - 1), with a probability equivalent to the values in SelectionArray.
	 */
	public static function weightedPick(WeightsArray:Array<Float>):Int
	{
		var totalWeight:Float = 0;
		var pick:Int = 0;
		
		for (i in WeightsArray)
		{
			totalWeight += i;
		}
		
		totalWeight = float(0, totalWeight);
		
		for (i in 0...WeightsArray.length)
		{
			if (totalWeight < WeightsArray[i])
			{
				pick = i;
				break;
			}
			
			totalWeight -= WeightsArray[i];
		}
		
		return pick;
	}
	
	/**
	 * Returns a random object from an array.
	 * 
	 * @param   Objects        An array from which to return an object.
	 * @param   WeightsArray   Optional array of weights which will determine the likelihood of returning a given value from Objects.
	 * 						   If none is passed, all objects in the Objects array will have an equal likelihood of being returned.
	 *                         Values in WeightsArray will correspond to objects in Objects exactly.
	 * @param   StartIndex     Optional index from which to restrict selection. Default value is 0, or the beginning of the Objects array.
	 * @param   EndIndex       Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return  A pseudorandomly chosen object from Objects.
	 */
	@:generic
	public static function getObject<T>(Objects:Array<T>, ?WeightsArray:Array<Float>, StartIndex:Int = 0, EndIndex:Int = 0):T
	{
		var selected:Null<T> = null;
		
		if (Objects.length != 0)
		{
			if (WeightsArray == null)
			{
				WeightsArray = [for (i in 0...Objects.length) 1];
			}
			
			StartIndex = Std.int(FlxMath.bound(StartIndex, 0, Objects.length - 1));
			EndIndex = Std.int(FlxMath.bound(EndIndex, 0, Objects.length - 1));
			
			// Swap values if reversed
			if (EndIndex < StartIndex)
			{
				StartIndex = StartIndex + EndIndex;
				EndIndex = StartIndex - EndIndex;
				StartIndex = StartIndex - EndIndex;
			}
			
			
			if (EndIndex > WeightsArray.length - 1)
			{
				EndIndex = WeightsArray.length - 1;
			}
			
			_arrayFloatHelper = [for (i in StartIndex...EndIndex + 1) WeightsArray[i]];
			selected = Objects[weightedPick(_arrayFloatHelper)];
		}
		
		return selected;
	}
	
	/**
	 * Shuffles the entries in an array into a new pseudorandom order.
	 * 
	 * @param   Objects        An array to shuffle.
	 * @param   HowManyTimes   How many swaps to perform during the shuffle operation. 
	 *                         A good rule of thumb is 2-4 times the number of objects in the list.
	 * @return  The newly shuffled array.
	 */
	@:generic
	public static function shuffleArray<T>(Objects:Array<T>, HowManyTimes:Int):Array<T>
	{
		HowManyTimes = Std.int(Math.max(HowManyTimes, 0));
		
		var tempObject:Null<T> = null;
		
		for (i in 0...HowManyTimes)
		{
			var pick1:Int = int(0, Objects.length - 1);
			var pick2:Int = int(0, Objects.length - 1);
			
			tempObject = Objects[pick1];
			Objects[pick1] = Objects[pick2];
			Objects[pick2] = tempObject;
		}
		
		return Objects;
	}
	
	/**
	 * Returns a random color value in hex ARGB format.
	 * 
	 * @param   Min         The lowest value to use for each channel.
	 * @param   Max         The highest value to use for each channel.
	 * @param   Alpha       The alpha value of the returning color (default 255 = fully opaque).
	 * @param   GreyScale   Whether or not to create a color that is strictly a shade of grey. False by default.
	 * @return  A color value in hex ARGB format.
	 */
	public static function color(Min:Int = 0, Max:Int = 255, Alpha:Int = 255, GreyScale:Bool = false):FlxColor
	{
		Min = Std.int(FlxMath.bound(Min, 0, 255));
		Max = Std.int(FlxMath.bound(Max, 0, 255));
		Alpha = Std.int(FlxMath.bound(Alpha, 0, 255));
		
		var red = int(Min, Max);
		var green = GreyScale ? red : int(Min, Max);
		var blue = GreyScale ? red : int(Min, Max);
		
		return FlxColor.fromRGB(red, green, blue, Alpha);
	}
	
	/**
	 * Much like color(), but with finer control over the output color.
	 * 
	 * @param   RedMinimum     The minimum amount of red in the output color, from 0 to 255.
	 * @param   RedMaximum     The maximum amount of red in the output color, from 0 to 255.
	 * @param   GreedMinimum   The minimum amount of green in the output color, from 0 to 255.
	 * @param   GreenMaximum   The maximum amount of green in the output color, from 0 to 255.
	 * @param   BlueMinimum    The minimum amount of blue in the output color, from 0 to 255.
	 * @param   BlueMaximum    The maximum amount of blue in the output color, from 0 to 255.
	 * @param   AlphaMinimum   The minimum alpha value for the output color, from 0 (fully transparent) to 255 (fully opaque).
	 * @param   AlphaMaximum   The maximum alpha value for the output color, from 0 (fully transparent) to 255 (fully opaque).
	 * @return  A pseudorandomly generated color within the ranges specified.
	 */
	public static function colorExt(RedMinimum:Int = 0, RedMaximum:Int = 255, GreenMinimum:Int = 0, GreenMaximum:Int = 255, BlueMinimum:Int = 0, BlueMaximum:Int = 255, AlphaMinimum:Int = 255, AlphaMaximum:Int = 255):FlxColor
	{		
		var red = int(Std.int(FlxMath.bound(RedMinimum, 0, 255)), Std.int(FlxMath.bound(RedMaximum, 0, 255)));
		var green = int(Std.int(FlxMath.bound(GreenMinimum, 0, 255)), Std.int(FlxMath.bound(GreenMaximum, 0, 255)));
		var blue = int(Std.int(FlxMath.bound(BlueMinimum, 0, 255)), Std.int(FlxMath.bound(BlueMaximum, 0, 255)));
		var alpha = int(Std.int(FlxMath.bound(AlphaMinimum, 0, 255)), Std.int(FlxMath.bound(AlphaMaximum, 0, 255)));
		
		return FlxColor.fromRGB(red, green, blue, alpha);
	}
	
	public static function perlinNoise():Array<Float>
	{
		// do magic
		
		return [];
	}
	
	/**
	 * The actual internal seed. Stored as a Float value to prevent inaccuracies due to
	 * integer overflow in the generate() equation.
	 */
	private static var internalSeed:Float = 1;
	
	/**
	 * Internal helper variable.
	 */
	private static var _arrayFloatHelper:Array<Float> = null;
	
	/**
	 * Internal function to update the internal seed whenever the global seed is reset,
	 * and keep the global seed's value in range.
	 */
	private static inline function set_globalSeed(NewSeed:Int):Int
	{
		return globalSeed = currentSeed = Std.int(FlxMath.bound(NewSeed, 1, MODULUS));
	}
	
	/**
	 * Internal function to return the internal seed as an integer.
	 */
	private static inline function get_currentSeed():Int
	{
		return Std.int(internalSeed);
	}
	
	/**
	 * Internal function to set the internal seed to an integer value.
	 */
	private static inline function set_currentSeed(NewSeed:Int):Int
	{
		return Std.int(internalSeed = NewSeed);
	}
	
	/**
	 * Constants used in the pseudorandom number generation equation.
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator,
	 * and they use the full range of possible integer values.
	 * 
	 * @see http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988).
	 *      "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 */
	private static inline var MULTIPLIER:Int = 48271;
	private static inline var MODULUS:Int = 2147483647;
	
	/**
	 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
	 * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
	 * 
	 * @return  A new pseudorandom number.
	 */
	private static inline function generate():Float
	{
		return internalSeed = (internalSeed * MULTIPLIER) % MODULUS;
	}
	
	#if FLX_RECORD
	/**
	 * Internal storage for the seed used to generate the most recent state.
	 */
	private static var _stateSeed:Int = 1;
	
	/**
	 * The seed to be used by the recording requested in FlxGame.
	 */
	private static var _recordingSeed:Int = 1;
	
	/**
	 * Update the seed that was used to create the most recent state.
	 * Called by FlxGame, needed for replays.
	 * 
	 * @return  The new value of the state seed.
	 */
	@:allow(flixel.FlxGame.switchState)
	private static inline function updateStateSeed():Int
	{
		return _stateSeed = internalSeed;
	}
	
	/**
	 * Used to store the seed for a requested recording. If StandardMode is false, this will also reset the global seed!
	 * This ensures that the state is created in the same way as just before the recording was requested.
	 * 
	 * @param   StandardMode   If true, entire game will be reset, else just the current state will be reset.
	 */
	@:allow(flixel.system.frontEnds.VCRFrontEnd.startRecording)
	private static inline function updateRecordingSeed(StandardMode:Bool = true):Int
	{
		return _recordingSeed = globalSeed = StandardMode ? globalSeed : _stateSeed;
	}
	
	/**
	 * Returns the seed to use for the requested recording.
	 */
	@:allow(flixel.FlxGame.step)
	private static inline function getRecordingSeed():Int
	{
		return _recordingSeed;
	}
	#end
}