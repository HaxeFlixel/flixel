package flixel.util;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.system.frontEnds.VCRFrontEnd;

/**
 * A class containing a set of functions for random generation.
 */
class FlxRandom
{
	/**
	 * The global random number generator seed (for deterministic behavior in recordings and saves).
	 * If you want, you can set the seed with an integer between 1 and 2,147,483,647 inclusive. However, FlxG automatically sets this with a new random seed when starting your game. Altering this yourself may break recording functionality!
	 */
	public static var globalSeed(default, set):Int = 1;
	
	/**
	 * Internal function to update the internal seed whenever the global seed is reset, and keep the global seed's value in range.
	 */
	private static function set_globalSeed( NewSeed:Int ):Int
	{
		if ( NewSeed < 1 )
		{
			NewSeed = 1;
		}
		
		if ( NewSeed > MODULUS )
		{
			NewSeed = MODULUS;
		}
		
		_internalSeed = NewSeed;
		globalSeed = NewSeed;
		
		return globalSeed;
	}
	
	/**
	 * Internal seed used to generate new random numbers.
	 */
	private static var _internalSeed:Int = 1;
	
	/**
	 * Constants used in the pseudorandom number generation equation.
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator, and they use the full range of possible integer values.
	 * 
	 * @see 	http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see 	Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988). "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
	 */
	private static inline var MULTIPLIER:Int = 48271;
	private static inline var MODULUS:Int = 2147483647;
	
	/**
	 * Internal helper variables.
	 */
	private static var _intHelper:Int = 0;
	private static var _intHelper2:Int = 0;
	private static var _intHelper3:Int = 0;
	private static var _floatHelper:Float = 0;
	private static var _arrayFloatHelper:Array<Float> = null;
	private static var _red:Int = 0;
	private static var _green:Int = 0;
	private static var _blue:Int = 0;
	private static var _alpha:Int = 0;
	
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
	 * @return	The new value of the state seed.
	 */
	@:allow(flixel.FlxGame.switchState) // Access to this function is only needed in FlxGame::switchState()
	inline private static function updateStateSeed():Int
	{
		return _stateSeed = _internalSeed;
	}
	
	/**
	 * Used to store the seed for a requested recording.
	 * If StandardMode is false, this will also reset the global seed! This ensures that the state is created in the same way as just before the recording was requested.
	 * 
	 * @param	StandardMode	If true, entire game will be reset, else just the current state will be reset.
	 * @return
	 */
	@:allow(flixel.system.frontEnds.VCRFrontEnd.startRecording)// Access to this function is only needed in VCRFrontEnd::startRecording()
	inline private static function updateRecordingSeed( StandardMode:Bool = true ):Int
	{
		return _recordingSeed = globalSeed = StandardMode ? globalSeed : _stateSeed;
	}
	
	/**
	 * Returns the seed to use for the requested recording.
	 */
	@:allow(flixel.FlxGame.step) // Access to this function is only needed in FlxGame.step()
	inline private static function getRecordingSeed():Int
	{
		return _recordingSeed;
	}
	#end
	
	/**
	 * Function to easily set the global seed to a new random number. Used primarily by FlxG whenever the game is reset.
	 * Please note that this function is not deterministic! If you call it in your game, recording may not work.
	 * 
	 * @return	The new global seed.
	 */
	public static inline function resetGlobalSeed():Int
	{
		return globalSeed = Std.int( Math.random() * MODULUS );
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 2,147,483,647, inclusive.
	 */
	public static inline function int():Int
	{
		return generate();
	}
	
	/**
	 * Returns a pseudorandom number between 0 and 1, inclusive.
	 */
	public static inline function float():Float
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
	public static function intRanged( Min:Int = 0, Max:Int = MODULUS, ?Excludes:Array<Int> ):Int
	{
		if ( Min == Max )
		{
			_intHelper = Min;
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
				_intHelper = Math.floor( Min + float() * ( Max - Min + 1 ) );
			}
			else
			{
				do
				{
					_intHelper = Math.floor( Min + float() * ( Max - Min + 1 ) );
				}
				while ( FlxArrayUtil.indexOf( Excludes, _intHelper ) >= 0 );
			}
		}
		
		return _intHelper;
	}
	
	/**
	 * Returns a pseudorandom float value between Min and Max, inclusive. Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 * 
	 * @param	Min			The minimum value that should be returned. 0 by default.
	 * @param	Max			The maximum value that should be returned. 33,554,429 by default.
	 * @param	?Excludes	An optional array of values that should not be returned.
	 */
	public static function floatRanged( Min:Float = 0, Max:Float = 1, ?Excludes:Array<Float> ):Float
	{
		if ( Min == Max )
		{
			_floatHelper = Min;
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
				_floatHelper = Min + float() * ( Max - Min );
			}
			else
			{
				do
				{
					_floatHelper = Min + float() * ( Max - Min );
				}
				while ( FlxArrayUtil.indexOf( Excludes, _floatHelper ) >= 0 );
			}
		}
		
		return _floatHelper;
	}
	
	/**
	 * Returns true or false based on the chance value (default 50%). 
	 * For example if you wanted a player to have a 30% chance of getting a bonus, call chanceRoll(30) - true means the chance passed, false means it failed.
	 * 
	 * @param 	Chance 	The chance of receiving the value. Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return 	Whether the roll passed or not.
	 */
	public static inline function chanceRoll( Chance:Float = 50 ):Bool
	{
		return floatRanged( 0, 100 ) < Chance;
	}
	
	/**
	 * Returns either a 1 or -1. 
	 * 
	 * @param	Chance	The chance of receiving a positive value. Should be given as a number between 0 and 100 (effectively 0% to 100%)
	 * @return	1 or -1
	 */
	public static inline function sign( Chance:Float = 50 ):Int
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
	public static function weightedPick( WeightsArray:Array<Float> ):Int
	{
		for ( i in WeightsArray )
		{
			_floatHelper += i;
		}
		
		_floatHelper = floatRanged( 0, _floatHelper );
		
		for ( i in 0...WeightsArray.length )
		{
			if ( _floatHelper < WeightsArray[i] )
			{
				_intHelper = i;
				break;
			}
			
			_floatHelper -= WeightsArray[i];
		}
		
		return _intHelper;
	}
	
	/**
	 * Fetch a random entry from the given array from StartIndex to EndIndex.
	 * Will return null if random selection is missing, or array has no entries.
	 * 
	 * @param	Objects			An array from which to select a random entry.
	 * @param	StartIndex		Optional index from which to restrict selection. Default value is 0, or the beginning of the array.
	 * @param	EndIndex		Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return	The random object that was selected.
	 */
	@:generic public static function getObject<T>( Objects:Array<T>, StartIndex:Int = 0, EndIndex:Int = 0 ):T
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
	@:generic public static function shuffleArray<T>( Objects:Array<T>, HowManyTimes:Int ):Array<T>
	{
		HowManyTimes = Std.int( Math.max( HowManyTimes, 0 ) );
		
		var tempObject:Null<T> = null;
		
		for ( i in 0...HowManyTimes )
		{
			_intHelper2 = intRanged( 0, Objects.length - 1 );
			_intHelper3 = intRanged( 0, Objects.length - 1 );
			tempObject = Objects[_intHelper2];
			Objects[_intHelper2] = Objects[_intHelper3];
			Objects[_intHelper3] = tempObject;
		}
		
		return Objects;
	}
	
	/**
	 * Returns a random object from an array between StartIndex and EndIndex with a weighted chance from WeightsArray.
	 * This function is essentially a combination of weightedPick and getObject.
	 * 
	 * @param	Objects			An array from which to return an object.
	 * @param	WeightsArray	An array of weights which will determine the likelihood of returning a given value from Objects. Values in WeightsArray will correspond to objects in Objects exactly.
	 * @param	StartIndex		Optional index from which to restrict selection. Default value is 0, or the beginning of the Objects array.
	 * @param 	EndIndex 		Optional index at which to restrict selection. Ignored if 0, which is the default value.
	 * @return	A pseudorandomly chosen object from Objects.
	 */
	@:generic public static function weightedGetObject<T>( Objects:Array<T>, WeightsArray:Array<Float>, StartIndex:Int = 0, EndIndex:Int = 0 ):T
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
			
			if ( EndIndex > WeightsArray.length - 1 )
			{
				EndIndex = WeightsArray.length - 1;
			}
			
			_arrayFloatHelper = [ for ( i in StartIndex...EndIndex + 1 ) WeightsArray[i] ];
			selected = Objects[ weightedPick( _arrayFloatHelper ) ];
		}
		
		return selected;
	}
	
	/**
	 * Returns a random color value in hex ARGB format.
	 * 
	 * @param	Min			The lowest value to use for each channel.
	 * @param	Max 		The highest value to use for each channel.
	 * @param	Alpha		The alpha value of the returning color (default 255 = fully opaque).
	 * @param 	GreyScale	Whether or not to create a color that is strictly a shade of grey. False by default.
	 * @return 	A color value in hex ARGB format.
	 */
	public static function color( Min:Int = 0, Max:Int = 255, Alpha:Int = 255, GreyScale:Bool = false ):Int
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
		
		if ( Alpha < 0 )
		{
			Alpha = 0;
		}
		
		if ( Alpha > 255 )
		{
			Alpha = 255;
		}
		
		// Swap values if reversed
		
		if ( Max < Min )
		{
			Min = Min + Max;
			Max = Min - Max;
			Min = Min - Max;
		}
		
		_red = intRanged( Min, Max );
		_green = GreyScale ? _red : intRanged( Min, Max );
		_blue = GreyScale ? _red : intRanged( Min, Max );
		
		return FlxColorUtil.makeFromARGB( Alpha, _red, _green, _blue );
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
	public static function colorExt( RedMinimum:Int = 0, RedMaximum:Int = 255, GreenMinimum:Int = 0, GreenMaximum:Int = 255, BlueMinimum:Int = 0, BlueMaximum:Int = 255, AlphaMinimum:Int = -1, AlphaMaximum:Int = -1 ):Int
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
		
		_red = intRanged( RedMinimum, RedMaximum );
		_green = intRanged( GreenMinimum, GreenMaximum );
		_blue = intRanged( BlueMinimum, BlueMaximum );
		_alpha = intRanged( AlphaMinimum, AlphaMaximum );
		
		return FlxColorUtil.makeFromARGB( _alpha, _red, _green, _blue );
	}
	
	/**
	 * Internal method to quickly generate a pseudorandom number. Used only by other functions of this class.
	 * Also updates the internal seed, which will then be used to generate the next pseudorandom number.
	 * 
	 * @return	A new pseudorandom number.
	 */
	inline private static function generate():Int
	{
		return _internalSeed = ( ( _internalSeed * MULTIPLIER ) % MODULUS ) & MODULUS;
	}
}