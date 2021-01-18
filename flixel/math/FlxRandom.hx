package flixel.math;

import flixel.util.FlxColor;

/**
 * A class containing a set of functions for random generation.
 */
class FlxRandom
{
	/**
	 * The global base random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive.
	 * Altering this yourself may break recording functionality!
	 */
	public var initialSeed(default, set):Int = 1;

	/**
	 * Current seed used to generate new random numbers. You can retrieve this value if,
	 * for example, you want to store the seed that was used to randomly generate a level.
	 */
	public var currentSeed(get, set):Int;

	/**
	 * Create a new FlxRandom object.
	 *
	 * @param	InitialSeed  The first seed of this FlxRandom object. If ignored, a random seed will be generated.
	 */
	public function new(?InitialSeed:Int)
	{
		if (InitialSeed != null)
		{
			initialSeed = InitialSeed;
		}
		else
		{
			resetInitialSeed();
		}
	}

	/**
	 * Function to easily set the global seed to a new random number.
	 * Please note that this function is not deterministic!
	 * If you call it in your game, recording may not function as expected.
	 *
	 * @return  The new initial seed.
	 */
	public inline function resetInitialSeed():Int
	{
		return initialSeed = rangeBound(Std.int(Math.random() * FlxMath.MAX_VALUE_INT));
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
	public function int(Min:Int = 0, Max:Int = FlxMath.MAX_VALUE_INT, ?Excludes:Array<Int>):Int
	{
		if (Min == 0 && Max == FlxMath.MAX_VALUE_INT && Excludes == null)
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
					result = Math.floor(Min + generate() / MODULUS * (Max - Min + 1));
				}
				while (Excludes.indexOf(result) >= 0);

				return result;
			}
		}
	}

	/**
	 * Returns a pseudorandom float value between Min (inclusive) and Max (exclusive).
	 * Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 *
	 * @param   Min        The minimum value that should be returned. 0 by default.
	 * @param   Max        The maximum value that should be returned. 1 by default.
	 * @param   Excludes   Optional array of values that should not be returned.
	 */
	public function float(Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float>):Float
	{
		var result:Float = 0;

		if (Min == 0 && Max == 1 && Excludes == null)
		{
			return generate() / MODULUS;
		}
		else if (Min == Max)
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

	// helper variables for floatNormal -- it produces TWO random values with each call so we have to store some state outside the function
	var _hasFloatNormalSpare:Bool = false;
	var _floatNormalRand1:Float = 0;
	var _floatNormalRand2:Float = 0;
	var _twoPI:Float = Math.PI * 2;
	var _floatNormalRho:Float = 0;

	/**
	 * Returns a pseudorandom float value in a statistical normal distribution centered on Mean with a standard deviation size of StdDev.
	 * (This uses the Box-Muller transform algorithm for gaussian pseudorandom numbers)
	 *
	 * Normal distribution: 68% values are within 1 standard deviation, 95% are in 2 StdDevs, 99% in 3 StdDevs.
	 * See this image: https://github.com/HaxeFlixel/flixel-demos/blob/dev/Performance/FlxRandom/normaldistribution.png
	 *
	 * @param	Mean		The Mean around which the normal distribution is centered
	 * @param	StdDev		Size of the standard deviation
	 */
	public function floatNormal(Mean:Float = 0, StdDev:Float = 1):Float
	{
		if (_hasFloatNormalSpare)
		{
			_hasFloatNormalSpare = false;
			var scale:Float = StdDev * _floatNormalRho;
			return Mean + scale * _floatNormalRand2;
		}

		_hasFloatNormalSpare = true;

		var theta:Float = _twoPI * (generate() / MODULUS);
		_floatNormalRho = Math.sqrt(-2 * Math.log(1 - (generate() / MODULUS)));
		var scale:Float = StdDev * _floatNormalRho;

		_floatNormalRand1 = Math.cos(theta);
		_floatNormalRand2 = Math.sin(theta);

		return Mean + scale * _floatNormalRand1;
	}

	/**
	 * Returns true or false based on the chance value (default 50%).
	 * For example if you wanted a player to have a 30.5% chance of getting a bonus,
	 * call bool(30.5) - true means the chance passed, false means it failed.
	 *
	 * @param   Chance   The chance of receiving the value.
	 *                   Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return  Whether the roll passed or not.
	 */
	public inline function bool(Chance:Float = 50):Bool
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
	public inline function sign(Chance:Float = 50):Int
	{
		return bool(Chance) ? 1 : -1;
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
	public function weightedPick(WeightsArray:Array<Float>):Int
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
	public function getObject<T>(Objects:Array<T>, ?WeightsArray:Array<Float>, StartIndex:Int = 0, ?EndIndex:Null<Int>):T
	{
		var selected:Null<T> = null;

		if (Objects.length != 0)
		{
			if (WeightsArray == null)
			{
				WeightsArray = [for (i in 0...Objects.length) 1];
			}

			if (EndIndex == null)
			{
				EndIndex = Objects.length - 1;
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
			selected = Objects[StartIndex + weightedPick(_arrayFloatHelper)];
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
	@:deprecated("Unless you rely on reproducing the exact output of shuffleArray(), you should use shuffle() instead, which is both faster and higher quality.")
	public function shuffleArray<T>(Objects:Array<T>, HowManyTimes:Int):Array<T>
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
	 * Shuffles the entries in an array in-place into a new pseudorandom order,
	 * using the standard Fisher-Yates shuffle algorithm.
	 *
	 * @param  array  The array to shuffle.
	 * @since  4.2.0
	 */
	@:generic
	public function shuffle<T>(array:Array<T>):Void
	{
		var maxValidIndex = array.length - 1;
		for (i in 0...maxValidIndex)
		{
			var j = int(i, maxValidIndex);
			var tmp = array[i];
			array[i] = array[j];
			array[j] = tmp;
		}
	}

	/**
	 * Returns a random color.
	 *
	 * @param   Min        An optional FlxColor representing the lower bounds for the generated color.
	 * @param   Max        An optional FlxColor representing the upper bounds for the generated color.
	 * @param 	Alpha      An optional value for the alpha channel of the generated color.
	 * @param   GreyScale  Whether or not to create a color that is strictly a shade of grey. False by default.
	 * @return  A color value as a FlxColor.
	 */
	public function color(?Min:FlxColor, ?Max:FlxColor, ?Alpha:Int, GreyScale:Bool = false):FlxColor
	{
		var red:Int;
		var green:Int;
		var blue:Int;
		var alpha:Int;

		if (Min == null && Max == null)
		{
			red = int(0, 255);
			green = int(0, 255);
			blue = int(0, 255);
			alpha = Alpha == null ? int(0, 255) : Alpha;
		}
		else if (Max == null)
		{
			red = int(Min.red, 255);
			green = GreyScale ? red : int(Min.green, 255);
			blue = GreyScale ? red : int(Min.blue, 255);
			alpha = Alpha == null ? int(Min.alpha, 255) : Alpha;
		}
		else if (Min == null)
		{
			red = int(0, Max.red);
			green = GreyScale ? red : int(0, Max.green);
			blue = GreyScale ? red : int(0, Max.blue);
			alpha = Alpha == null ? int(0, Max.alpha) : Alpha;
		}
		else
		{
			red = int(Min.red, Max.red);
			green = GreyScale ? red : int(Min.green, Max.green);
			blue = GreyScale ? red : int(Min.blue, Max.blue);
			alpha = Alpha == null ? int(Min.alpha, Max.alpha) : Alpha;
		}

		return FlxColor.fromRGB(red, green, blue, alpha);
	}

	/**
	 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
	 * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
	 *
	 * @return  A new pseudorandom number.
	 */
	inline function generate():Float
	{
		return internalSeed = (internalSeed * MULTIPLIER) % MODULUS;
	}

	/**
	 * The actual internal seed. Stored as a Float value to prevent inaccuracies due to
	 * integer overflow in the generate() equation.
	 */
	var internalSeed:Float = 1;

	/**
	 * Internal function to update the current seed whenever the initial seed is reset,
	 * and keep the initial seed's value in range.
	 */
	inline function set_initialSeed(NewSeed:Int):Int
	{
		return initialSeed = currentSeed = rangeBound(NewSeed);
	}

	/**
	 * Returns the internal seed as an integer.
	 */
	inline function get_currentSeed():Int
	{
		return Std.int(internalSeed);
	}

	/**
	 * Sets the internal seed to an integer value.
	 */
	inline function set_currentSeed(NewSeed:Int):Int
	{
		return Std.int(internalSeed = rangeBound(NewSeed));
	}

	/**
	 * Internal shared function to ensure an arbitrary value is in the valid range of seed values.
	 */
	static inline function rangeBound(Value:Int):Int
	{
		return Std.int(FlxMath.bound(Value, 1, MODULUS - 1));
	}

	/**
	 * Internal shared helper variable. Used by getObject().
	 */
	static var _arrayFloatHelper:Array<Float> = null;

	/**
	 * Constants used in the pseudorandom number generation equation.
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator,
	 * and they use the full range of possible integer values.
	 *
	 * @see http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988).
	 *      "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 */
	static inline var MULTIPLIER:Float = 48271.0;

	static inline var MODULUS:Int = FlxMath.MAX_VALUE_INT;

	#if FLX_RECORD
	/**
	 * Internal storage for the seed used to generate the most recent state.
	 */
	static var _stateSeed:Int = 1;

	/**
	 * The seed to be used by the recording requested in FlxGame.
	 */
	static var _recordingSeed:Int = 1;

	/**
	 * Update the seed that was used to create the most recent state.
	 * Called by FlxGame, needed for replays.
	 *
	 * @return  The new value of the state seed.
	 */
	@:allow(flixel.FlxGame)
	static inline function updateStateSeed():Int
	{
		return _stateSeed = FlxG.random.currentSeed;
	}

	/**
	 * Used to store the seed for a requested recording. If StandardMode is false, this will also reset the global seed!
	 * This ensures that the state is created in the same way as just before the recording was requested.
	 *
	 * @param   StandardMode   If true, entire game will be reset, else just the current state will be reset.
	 */
	@:allow(flixel.system.frontEnds.VCRFrontEnd)
	static inline function updateRecordingSeed(StandardMode:Bool = true):Int
	{
		return _recordingSeed = FlxG.random.initialSeed = StandardMode ? FlxG.random.initialSeed : _stateSeed;
	}

	/**
	 * Returns the seed to use for the requested recording.
	 */
	@:allow(flixel.FlxGame.handleReplayRequests)
	static inline function getRecordingSeed():Int
	{
		return _recordingSeed;
	}
	#end
}
