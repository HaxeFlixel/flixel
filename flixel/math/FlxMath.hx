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
	#if (flash || js || ios || blackberry)
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
	/**
	 * Used to account for floating-point inaccuracies.
	 */
	public static inline var EPSILON:Float = 0.0000001;
	
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
	public static inline function bound(Value:Float, ?Min:Float, ?Max:Float):Float
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
	 * Returns true if the given number is odd.
	 * 
	 * @param	n	The number to check 
	 * @return	Whether the number is odd
	 */
	public static inline function isOdd(n:Float):Bool
	{
		return (Std.int(n) & 1) != 0;
	}
	
	/**
	 * Returns true if the given number is even.
	 * 
	 * @param	n	The number to check
	 * @return	Whether the number is even
	 */
	public static inline function isEven(n:Float):Bool
	{
		return (Std.int(n) & 1) == 0;
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
	public static function pointInCoordinates(pointX:Float, pointY:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float):Bool
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
	public static function pointInFlxRect(pointX:Float, pointY:Float, rect:FlxRect):Bool
	{
		return pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom;
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
	public static function pointInRectangle(pointX:Float, pointY:Float, rect:Rectangle):Bool
	{
		return pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom;
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
	 * Makes sure that value always stays between 0 and max,
	 * by wrapping the value around.
	 * 
	 * @param 	value 	The value to wrap around
	 * @param 	min		The minimum the value is allowed to be
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	public static function wrap(value:Int, min:Int, max:Int):Int
	{
		var range:Int = max - min + 1;

		if (value < min)
			value += range * Std.int((min - value) / range + 1);

		return min + (value - min) % range;
	}

	/**
	 * Remaps a number from one range to another.
	 * 
	 * @param 	value	The incoming value to be converted
	 * @param 	start1 	Lower bound of the value's current range
	 * @param 	stop1 	Upper bound of the value's current range
	 * @param 	start2  Lower bound of the value's target range
	 * @param 	stop2 	Upper bound of the value's target range
	 * @return The remapped value
	 */
	public static function remapToRange(value:Float, start1:Float, stop1:Float, start2:Float, stop2:Float)
	{
		return start2 + (value - start1) * ((stop2 - start2) / (stop1 - start1));
	}
	
	/**
	 * Finds the dot product value of two vectors
	 * 
	 * @param	ax		Vector X
	 * @param	ay		Vector Y
	 * @param	bx		Vector X
	 * @param	by		Vector Y
	 * 
	 * @return	Result of the dot product
	 */
	public static inline function dotProduct(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return ax * bx + ay * by;
	}

	/**
	 * Finds the length of the given vector
	 * 
	 * @return The length
	 */
	public static inline function vectorLength(dx:Float, dy:Float):Float
	{
		return Math.sqrt(dx * dx + dy * dy);
	}

	/**
	 * Find the distance (in pixels, rounded) between two FlxSprites, taking their origin into account
	 * 
	 * @param	SpriteA		The first FlxSprite
	 * @param	SpriteB		The second FlxSprite
	 * @return	Distance between the sprites in pixels
	 */
	public static inline function distanceBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Int
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Check if the distance between two FlxSprites is within a specified number. 
	 * A faster algoritm than distanceBetween because the Math.sqrt() is avoided.
	 *
	 * @param	SpriteA		The first FlxSprite
	 * @param	SpriteB		The second FlxSprite
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calcualted distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance 
	 */
	public static inline function isDistanceWithin(SpriteA:FlxSprite, SpriteB:FlxSprite, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);
		
		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	
	/**
	 * Find the distance (in pixels, rounded) from an FlxSprite
	 * to the given FlxPoint, taking the source origin into account.
	 * 
	 * @param	Sprite	The FlxSprite
	 * @param	Target	The FlxPoint
	 * @return	Distance in pixels
	 */
	public static inline function distanceToPoint(Sprite:FlxSprite, Target:FlxPoint):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Target.x;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Target.y;
		Target.putWeak();
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Check if the distance from an FlxSprite to the given
	 * FlxPoint is within a specified number. 
	 * A faster algoritm than distanceToPoint because the Math.sqrt() is avoided.
	 * 
	 * @param	Sprite	The FlxSprite
	 * @param	Target	The FlxPoint
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calcualted distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance 
	 */
	public static inline function isDistanceToPointWithin(Sprite:FlxSprite, Target:FlxPoint, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - (Target.x);
		var dy:Float = (Sprite.y + Sprite.origin.y) - (Target.y);
		
		Target.putWeak();
		
		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the mouse x/y
	 * 
	 * @param	Sprite	The FlxSprite to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	public static inline function distanceToMouse(Sprite:FlxSprite):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Check if the distance from the object x/y and the mouse x/y is within a specified number. 
	 * A faster algoritm than distanceToMouse because the Math.sqrt() is avoided.
	 *
	 * @param	Sprite		The FlxSprite to test against
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calcualted distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance 
	 */
	public static inline function isDistanceToMouseWithin(Sprite:FlxSprite, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;
		
		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the FlxPoint screen x/y
	 * 
	 * @param	Sprite	The FlxSprite to test against
	 * @param	Touch	The FlxTouch to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	public static inline function distanceToTouch(Sprite:FlxSprite, Touch:FlxTouch):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Check if the distance from the object x/y and the FlxPoint screen x/y is within a specified number. 
	 * A faster algoritm than distanceToTouch because the Math.sqrt() is avoided.
	 *
	 * @param	Sprite	The FlxSprite to test against
	 * @param	Distance	The distance to check
	 * @param	IncludeEqual	If set to true, the function will return true if the calcualted distance is equal to the given Distance
	 * @return	True if the distance between the sprites is less than the given Distance 
	 */
	public static inline function isDistanceToTouchWithin(Sprite:FlxSprite, Touch:FlxTouch, Distance:Float, IncludeEqual:Bool = false):Bool
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;
		
		if (IncludeEqual)
			return dx * dx + dy * dy <= Distance * Distance;
		else
			return dx * dx + dy * dy < Distance * Distance;
	}
	#end
	
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
		return Math.abs(aValueA - aValueB) <= aDiff;
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
	
	/**
	 * A faster but slightly less accurate version of Math.sin.
	 * About 2-6 times faster with < 0.05% average error.
	 * @param	f	The angle in radians.
	 * @return	An approximated sine of f.
	 */
	public static inline function fastSin(f:Float):Float
	{
		f *= 0.3183098862; // divide by pi to normalize
		
		// bound between -1 and 1
		if (f > 1) 
		{
			f -= (Math.ceil(f) >> 1) << 1;
		}
		else if (f < -1)
		{
			f += (Math.ceil( -f) >> 1) << 1;
		}
		
		// this approx only works for -pi <= rads <= pi, but it's quite accurate in this region
		if (f > 0)
		{
			return f * (3.1 + f * (0.5 + f * ( -7.2 + f * 3.6)));
		}
		else
		{
			return f * (3.1 - f * (0.5 + f * (7.2 + f * 3.6)));
		}
	}
	
	/**
	 * A faster but less accurate version of Math.cos.
	 * About 2-6 times faster with < 0.05% average error.
	 * @param	f	The angle in radians.
	 * @return	An approximated cosine of f.
	 */
	public static inline function fastCos(f:Float):Float
	{
		return fastSin(f + 1.570796327); // sin and cos are the same, offset by pi/2
	}
	
	/**
	 * Hyperbolic sine.
	 */
	public static inline function sinh(f:Float):Float
	{
		return (Math.exp(f) - Math.exp(-f)) / 2;
	}
	
	/**
	 * Returns bigger argument.
	 */
	public static inline function maxInt(a:Int, b:Int):Int
	{
		return (a > b) ? a : b;
	}
	
	/**
	 * Returns smaller argument.
	 */
	public static inline function minInt(a:Int, b:Int):Int
	{
		return (a > b) ? b : a;
	}
	
	/**
	 * Returns absolute integer value.
	 */
	public static inline function absInt(a:Int):Int
	{
		return (a > 0) ? a : -a;
	}
	
}
