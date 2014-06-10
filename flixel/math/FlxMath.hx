package flixel.math;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.FlxSprite;
#if !FLX_NO_TOUCH
import flixel.input.touch.FlxTouch;
#end

/**
 * A class containing a set of math-related functions.
 */
class FlxMath
{	
	#if (flash || js || ios)
	/**
	 * Minimum value of a floating point number.
	 */
	public static inline var MIN_VALUE_FLOAT:Float = 0.0000000000000001;
	#else
	/**
	 * Minimum value of a floating point number.
	 */
	public static inline var MIN_VALUE_FLOAT:Float = 5e-324;
	#end
	/**
	 * Maximum value of a floating point number.
	 */
	public static inline var MAX_VALUE_FLOAT:Float = 1.79e+308;
	/**
	 * Minimum value of an integer.
	 */
	public static inline var MIN_VALUE_INT:Int = -MAX_VALUE_INT;
	/**
	 * Maximum value of an integer.
	 */
	public static inline var MAX_VALUE_INT:Int = 0x7FFFFFFF;
	/**
	 * Approximation of Math.sqrt(2).
	 */
	public static inline var SQUARE_ROOT_OF_TWO:Float = 1.41421356237;
	
	public static inline var EPSILON:Float = 0.0000001;
	public static inline var EPSILON_SQUARED:Float = EPSILON * EPSILON;
	
	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 * Ex: roundDecimal(1.2485, 2) -> 1.25
	 * 
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimal points to leave in float. Should be a positive number
	 * @return	The rounded value of that number.
	 */
	public static function roundDecimal(Value:Float, Precision:Int):Float
	{
		var mult:Float = 1;
		for (i in 0...Precision)
		{
			mult *= 10;
		}
		return Math.round(Value * mult) / mult;
	}
	
	/**
	 * Bound a number by a minimum and maximum. Ensures that this number is 
	 * no smaller than the minimum, and no larger than the maximum.
	 * Leaving a bound null means that side is unbounded.
	 * 
	 * @param	Value	Any number.
	 * @param	Min		Any number.
	 * @param	Max		Any number.
	 * @return	The bounded value of the number.
	 */
	public static inline function bound(Value:Float, Min:Null<Float>, Max:Null<Float>):Float
	{
		var lowerBound:Float = (Min != null && Value < Min) ? Min : Value;
		return (Max != null && lowerBound > Max) ? Max : lowerBound;
	}
	
	/**
	 * Returns linear interpolated value between Max and Min numbers
	 *
	 * @param Min 		Lower bound.
	 * @param Max	 	Higher bound.
	 * @param Ratio 	Defines which number is closer to desired value.
	 * @return 			Interpolated number.
	 */
	public static inline function lerp(Min:Float, Max:Float, Ratio:Float):Float
	{
		return Min + Ratio * (Max - Min);
	}
	
	/**
	 * Checks if number is in defined range. A null bound means that side is unbounded.
	 *
	 * @param Value		Number to check.
	 * @param Min		Lower bound of range.
	 * @param Max 		Higher bound of range.
	 * @return Returns true if Value is in range.
	 */
	public static inline function inBounds(Value:Float, Min:Null<Float>, Max:Null<Float>):Bool
	{
		return ((Min == null || Value >= Min) && (Max == null || Value <= Max));
	}
	
	/**
	 * Returns true if the number given is odd.
	 * 
	 * @param	n	The number to check 
	 * @return	True if the given number is odd. False if the given number is even.
	 */
	public static function isOdd(n:Float):Bool
	{
		if ((Std.int(n) & 1) != 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * Returns true if the number given is even.
	 * 
	 * @param	n	The number to check
	 * @return	True if the given number is even. False if the given number is odd.
	 */
	public static function isEven(n:Float):Bool
	{
		if ((Std.int(n) & 1) != 0)
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	
	/**
	 * Compare two numbers.
	 * 
	 * @param	num1	The first number
	 * @param	num2	The second number
	 * @return	-1 if num1 is smaller, 1 if num2 is bigger, 0 if they are equal
	 */
	public static function numericComparison(num1:Float, num2:Float):Int
	{
		if (num2 > num1)
		{
			return -1;
		}
		else if (num1 > num2)
		{
			return 1;
		}
		return 0;
	}
	
	/**
	 * Adds the given amount to the value, but never lets the value
	 * go over the specified maximum or under the specified minimum.
	 * 
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @param 	min 	The minimum the value is allowed to be
	 * @return The new value
	 */
	public static function maxAdd(value:Int, amount:Int, max:Int, min:Int = 0):Int
	{
		value += amount;
		
		if (value > max)
		{
			value = max;
		}
		else if (value <= min)
		{
			value = min;
		}
		
		return value;
	}
	
	/**
	 * Adds value to amount and ensures that the result always stays between 0 and max, by wrapping the value around.
	 * 
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrapValue(value:Int, amount:Int, max:Int):Int
	{
		var output:Int = value + amount;
		
		if (output >= max)
		{
			output %= max;
		}
		
		while (output < 0)
		{
			output += max;
		}
		
		return output;
	}
	
	/**
	 * Returns the amount of decimals a Float has
	 * 
	 * @param	Number	The floating point number
	 * @return	Amount of decimals
	 */
	public static function getDecimals(Number:Float):Int
	{
		var helperArray:Array<String> = Std.string(Number).split(".");
		var decimals:Int = 0;
		
		if (helperArray.length > 1)
		{
			decimals = helperArray[1].length;
		}
		
		return decimals;
	}
	
	public static inline function equal(aValueA:Float, aValueB:Float, aDiff:Float = EPSILON):Bool
	{
		return (Math.abs(aValueA - aValueB) <= aDiff);
	}
	
	/**
	 * Returns -1 if the number is smaller than 0 and 1 otherwise
	 */
	public static inline function signOf(f:Float):Int
	{
		return (f < 0) ? -1 : 1;
	}
	
	/**
	 * Checks if two numbers have the same sign (using signOf()).
	 */
	public static inline function sameSign(f1:Float, f2:Float):Bool
	{
		return signOf(f1) == signOf(f2);
	}
}
