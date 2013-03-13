/**
* FlxMath
* -- Part of the Flixel Power Tools set
* 
* v1.7 Added mouseInFlxRect
* v1.6 Added wrapAngle, angleLimit and more documentation
* v1.5 Added pointInCoordinates, pointInFlxRect and pointInRectangle
* v1.4 Updated for the Flixel 2.5 Plugin system
* 
* @version 1.7 - June 28th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import flash.geom.Rectangle;
import org.flixel.FlxG;
import org.flixel.FlxRect;

import org.flixel.FlxU;

/**
 * Adds a set of fast Math functions and extends a few commonly used ones
 */
class FlxMath
{
	public static inline var getrandmax:Int = 0xffffff; // Std.int(FlxU.MAX_VALUE);
	
	private static var mr:Int = 0;
	
	private static var cosTable:Array<Float> = new Array<Float>();
	private static var sinTable:Array<Float> = new Array<Float>();
	
	private static var coefficient1:Float = Math.PI / 4;
	private static inline var RADTODEG:Float = 180 / Math.PI;
	private static inline var DEGTORAD:Float = Math.PI / 180;
	
	public function new() { }
	
	/**
	 * Returns true if the given x/y coordinate is within the given rectangular block
	 * 
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rectX		The X value of the region to test within
	 * @param	rectY		The Y value of the region to test within
	 * @param	rectWidth	The width of the region to test within
	 * @param	rectHeight	The height of the region to test within
	 * 
	 * @return	true if pointX/pointY is within the region, otherwise false
	 */
	public static function pointInCoordinates(pointX:Int, pointY:Int, rectX:Int, rectY:Int, rectWidth:Int, rectHeight:Int):Bool
	{
		if (pointX >= rectX && pointX <= (rectX + rectWidth))
		{
			if (pointY >= rectY && pointY <= (rectY + rectHeight))
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Returns true if the given x/y coordinate is within the given rectangular block
	 * 
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rect		The FlxRect to test within
	 * @return	true if pointX/pointY is within the FlxRect, otherwise false
	 */
	public static function pointInFlxRect(pointX:Int, pointY:Int, rect:FlxRect):Bool
	{
		if (pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom)
		{
			return true;
		}
		
		return false;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Returns true if the mouse world x/y coordinate are within the given rectangular block
	 * 
	 * @param	useWorldCoords	If true the world x/y coordinates of the mouse will be used, otherwise screen x/y
	 * @param	rect			The FlxRect to test within. If this is null for any reason this function always returns true.
	 * 
	 * @return	true if mouse is within the FlxRect, otherwise false
	 */
	public static function mouseInFlxRect(useWorldCoords:Bool, rect:FlxRect):Bool
	{
		if (rect == null)
		{
			return true;
		}
		
		if (useWorldCoords)
		{
			return pointInFlxRect(Math.floor(FlxG.mouse.x), Math.floor(FlxG.mouse.y), rect);
		}
		else
		{
			return pointInFlxRect(FlxG.mouse.screenX, FlxG.mouse.screenY, rect);
		}
	}
	#end
	
	/**
	 * Returns true if the given x/y coordinate is within the Rectangle
	 * 
	 * @param	pointX		The X value to test
	 * @param	pointY		The Y value to test
	 * @param	rect		The Rectangle to test within
	 * @return	true if pointX/pointY is within the Rectangle, otherwise false
	 */
	public static function pointInRectangle(pointX:Int, pointY:Int, rect:Rectangle):Bool
	{
		if (pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom)
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * A faster (but much less accurate) version of Math.atan2(). For close range / loose comparisons this works very well, 
	 * but avoid for long-distance or high accuracy simulations.
	 * Based on: http://blog.gamingyourway.com/PermaLink,guid,78341247-3344-4a7a-acb2-c742742edbb1.aspx
	 * <p>
	 * Computes and returns the angle of the point y/x in radians, when measured counterclockwise from a circle's x axis 
	 * (where 0,0 represents the center of the circle). The return value is between positive pi and negative pi. 
	 * Note that the first parameter to atan2 is always the y coordinate.
	 * </p>
	 * @param y The y coordinate of the point
	 * @param x The x coordinate of the point
	 * @return The angle of the point x/y in radians
	 */
	public static function atan2(y:Float, x:Float):Float
	{
		var absY:Float = y;
		var coefficient2:Float = 3 * coefficient1;
		var r:Float;
		var angle:Float;
		
		if (absY < 0)
		{
			absY = -absY;
		}

		if (x >= 0)
		{
			r = (x - absY) / (x + absY);
			angle = coefficient1 - coefficient1 * r;
		}
		else
		{
			r = (x + absY) / (absY - x);
			angle = coefficient2 - coefficient1 * r;
		}

		return y < 0 ? -angle : angle;
	}
	
	/**
	 * Generate a sine and cosine table simultaneously and extremely quickly. Based on research by Franky of scene.at
	 * <p>
	 * The parameters allow you to specify the length, amplitude and frequency of the wave. Once you have called this function
	 * you should get the results via getSinTable() and getCosTable(). This generator is fast enough to be used in real-time.
	 * </p>
	 * @param length 		The length of the wave
	 * @param sinAmplitude 	The amplitude to apply to the sine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param cosAmplitude 	The amplitude to apply to the cosine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param frequency 	The frequency of the sine and cosine table data
	 * @return	Returns the sine table
	 * @see getSinTable
	 * @see getCosTable
	 */
	public static function sinCosGenerator(length:Int, sinAmplitude:Float = 1.0, cosAmplitude:Float = 1.0, frequency:Float = 1.0):Array<Float>
	{
		var sin:Float = sinAmplitude;
		var cos:Float = cosAmplitude;
		var frq:Float = frequency * Math.PI / length;
		
		cosTable = new Array();
		sinTable = new Array();
		
		for (c in 0...length)
		{
			cos -= sin * frq;
			sin += cos * frq;
			
			cosTable[c] = cos;
			sinTable[c] = sin;
		}
		
		return sinTable;
	}
	
	/**
	 * Returns the sine table generated by sinCosGenerator(), or an empty array object if not yet populated
	 * @return Array of sine wave data
	 * @see sinCosGenerator
	 */
	public static inline function getSinTable():Array<Float>
	{
		return sinTable;
	}
	
	/**
	 * Returns the cosine table generated by sinCosGenerator(), or an empty array object if not yet populated
	 * @return Array of cosine wave data
	 * @see sinCosGenerator
	 */
	public static inline function getCosTable():Array<Float>
	{
		return cosTable;
	}
	
	/**
	 * A faster version of Math.sqrt
	 * <p>
	 * Computes and returns the square root of the specified number.
	 * </p>
	 * @link http://osflash.org/as3_speed_optimizations#as3_speed_tests
	 * @param val A number greater than or equal to 0
	 * @return If the parameter val is greater than or equal to zero, a number; otherwise NaN (not a number).
	 */
	public static function sqrt(val:Float):Float
	{
		if (Math.isNaN(val))
		{
			return Math.NaN;
		}
		
		var thresh:Float = 0.002;
		var b:Float = val * 0.25;
		var a:Float;
		var c:Float;
		
		if (val == 0)
		{
			return 0;
		}
		
		do {
			c = val / b;
			b = (b + c) * 0.5;
			a = b - c;
			if (a < 0) a = -a;
		}
		while (a > thresh);
		
		return b;
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
	
	/**
	 * Generate a random integer
	 * <p>
	 * If called without the optional min, max arguments rand() returns a peudo-random integer between 0 and getrandmax().
	 * If you want a random number between 5 and 15, for example, (inclusive) use rand(5, 15)
	 * Parameter order is insignificant, the return will always be between the lowest and highest value.
	 * </p>
	 * @param min The lowest value to return (default: 0)
	 * @param max The highest value to return (default: getrandmax)
	 * @param excludes An Array of integers that will NOT be returned (default: null)
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
			while (FlxU.ArrayIndexOf(excludes, result) >= 0);
			
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
	 * @param min The lowest value to return (default: 0)
	 * @param max The highest value to return (default: getrandmax)
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
	 * @param chance The chance of receiving the value. Should be given as a uint between 0 and 100 (effectively 0% to 100%)
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
	 * Adds the given amount to the value, but never lets the value go over the specified maximum
	 * 
	 * @param value The value to add the amount to
	 * @param amount The amount to add to the value
	 * @param max The maximum the value is allowed to be
	 * @return The new value
	 */
	public static function maxAdd(value:Int, amount:Int, max:Int):Int
	{
		value += amount;
		
		if (value > max)
		{
			value = max;
		}
		
		return value;
	}
	
	/**
	 * Adds value to amount and ensures that the result always stays between 0 and max, by wrapping the value around.
	 * <p>Values must be positive integers, and are passed through Math.abs</p>
	 * 
	 * @param value The value to add the amount to
	 * @param amount The amount to add to the value
	 * @param max The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrapValue(value:Int, amount:Int, max:Int):Int
	{
		var diff:Int;

		value = Std.int(Math.abs(value));
		amount = Std.int(Math.abs(amount));
		max = Std.int(Math.abs(max));
		
		diff = (value + amount) % max;
		
		return diff;
	}
	
	/**
	 * Finds the length of the given vector
	 * 
	 * @param	dx
	 * @param	dy
	 * 
	 * @return
	 */
	public static inline function vectorLength(dx:Float, dy:Float):Float
	{
		return sqrt(dx * dx + dy * dy);
	}
	
	/**
	 * Finds the dot product value of two vectors
	 * 
	 * @param	ax		Vector X
	 * @param	ay		Vector Y
	 * @param	bx		Vector X
	 * @param	by		Vector Y
	 * 
	 * @return	Dot product
	 */
	public static inline function dotProduct(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return ax * bx + ay * by;
	}
	
	/**
	 * Randomly returns either a 1 or -1
	 * 
	 * @return	1 or -1
	 */
	public static function randomSign():Float
	{
		return (Math.random() > 0.5) ? 1 : -1;
	}
	
	/**
	 * Returns true if the number given is odd.
	 * 
	 * @param	n	The number to check
	 * 
	 * @return	True if the given number is odd. False if the given number is even.
	 */
	public static inline function isOdd(n:Float):Bool
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
	 * 
	 * @return	True if the given number is even. False if the given number is odd.
	 */
	public static inline function isEven(n:Float):Bool
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
	 * Keeps an angle value between -180 and +180<br>
	 * Should be called whenever the angle is updated on the FlxSprite to stop it from going insane.
	 * 
	 * @param	angle	The angle value to check
	 * 
	 * @return	The new angle value, returns the same as the input angle if it was within bounds
	 */
	public static function wrapAngle(angle:Float):Int
	{
		var result:Int = Std.int(angle);
		
		if (angle > 180)
		{
			result = -180;
		}
		else if (angle < -180)
		{
			result = 180;
		}
		
		return result;
	}
	
	/**
	 * Keeps an angle value between the given min and max values
	 * 
	 * @param	angle	The angle value to check. Must be between -180 and +180
	 * @param	min		The minimum angle that is allowed (must be -180 or greater)
	 * @param	max		The maximum angle that is allowed (must be 180 or less)
	 * 
	 * @return	The new angle value, returns the same as the input angle if it was within bounds
	 */
	public static function angleLimit(angle:Int, min:Int, max:Int):Int
	{
		var result:Int = angle;
		
		if (angle > max)
		{
			result = max;
		}
		else if (angle < min)
		{
			result = min;
		}
		
		return result;
	}
	
	/**
	 * Converts a Radian value into a Degree
	 * <p>
	 * Converts the radians value into degrees and returns
	 * </p>
	 * @param radians The value in radians
	 * @return Number Degrees
	 */
	public static inline function asDegrees(radians:Float):Float
	{
		return radians * RADTODEG;
	}
	
	/**
	 * Converts a Degrees value into a Radian
	 * <p>
	 * Converts the degrees value into radians and returns
	 * </p>
	 * @param degrees The value in degrees
	 * @return Number Radians
	 */
	public static inline function asRadians(degrees:Float):Float
	{
		return degrees * DEGTORAD;
	}
	
}