package flixel.util;

import flash.geom.Rectangle;
import flixel.system.input.FlxTouch;

/**
 * A class containing a set of math-related functions.
 */
class FlxMath
{	
	/**
	 * Round a decimal number to have reduced precision (less decimal numbers).
	 * Ex: roundDecimal(1.2485, 2) -> 1.25
	 * 
	 * @param	Value		Any number.
	 * @param	Precision	Number of decimal points to leave in float.
	 * @return	The rounded value of that number.
	 */
	inline static public function roundDecimal(Value:Float, Precision:Int):Float
	{
		var num = Value * Math.pow(10, Precision);
		return Math.round( num ) / Math.pow(10, Precision);
	}
	
	/**
	 * Bound a number by a minimum and maximum.
	 * Ensures that this number is no smaller than the minimum,
	 * and no larger than the maximum.
	 * @param	Value	Any number.
	 * @param	Min		Any number.
	 * @param	Max		Any number.
	 * @return	The bounded value of the number.
	 */
	inline static public function bound(Value:Float, Min:Float, Max:Float):Float
	{
		var lowerBound:Float = (Value < Min) ? Min : Value;
		return (lowerBound > Max) ? Max : lowerBound;
	}
	
	/**
	 * A tween-like function that takes a starting velocity
	 * and some other factors and returns an altered velocity.
	 * @param	Velocity		Any component of velocity (e.g. 20).
	 * @param	Acceleration	Rate at which the velocity is changing.
	 * @param	Drag			Really kind of a deceleration, this is how much the velocity changes if Acceleration is not set.
	 * @param	Max				An absolute value cap for the velocity (0 for no cap).
	 * @return	The altered Velocity value.
	 */
	inline static public function computeVelocity(Velocity:Float, Acceleration:Float, Drag:Float, Max:Float):Float
	{
		if (Acceleration != 0)
		{
			Velocity += Acceleration * FlxG.elapsed;
		}
		else if(Drag != 0)
		{
			var drag:Float = Drag * FlxG.elapsed;
			if (Velocity - drag > 0)
			{
				Velocity = Velocity - drag;
			}
			else if (Velocity + drag < 0)
			{
				Velocity += drag;
			}
			else
			{
				Velocity = 0;
			}
		}
		if((Velocity != 0) && (Max != 0))
		{
			if (Velocity > Max)
			{
				Velocity = Max;
			}
			else if (Velocity < -Max)
			{
				Velocity = -Max;
			}
		}
		return Velocity;
	}
	
	/**
	 * Returns true if the number given is odd.
	 * 
	 * @param	n	The number to check
	 * 
	 * @return	True if the given number is odd. False if the given number is even.
	 */
	inline static public function isOdd(n:Float):Bool
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
	inline static public function isEven(n:Float):Bool
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
	 * 
	 * @return	-1 if num1 is smaller, 1 if num2 is bigger, 0 if they are equal
	 */
	static public function numericComparison(num1:Float, num2:Float):Int
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
	static public function pointInCoordinates(pointX:Float, pointY:Float, rectX:Float, rectY:Float, rectWidth:Float, rectHeight:Float):Bool
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
	static public function pointInFlxRect(pointX:Float, pointY:Float, rect:FlxRect):Bool
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
	static public function mouseInFlxRect(useWorldCoords:Bool, rect:FlxRect):Bool
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
	static public function pointInRectangle(pointX:Float, pointY:Float, rect:Rectangle):Bool
	{
		if (pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom)
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * Adds the given amount to the value, but never lets the value go over the specified maximum
	 * 
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The new value
	 */
	static public function maxAdd(value:Int, amount:Int, max:Int):Int
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
	 * Values must be positive integers, and are passed through <code>Math.abs</code>
	 * 
	 * @param 	value 	The value to add the amount to
	 * @param 	amount 	The amount to add to the value
	 * @param 	max 	The maximum the value is allowed to be
	 * @return The wrapped value
	 */
	static public function wrapValue(value:Int, amount:Int, max:Int):Int
	{
		var diff:Int;

		value = Std.int(Math.abs(value));
		amount = Std.int(Math.abs(amount));
		max = Std.int(Math.abs(max));
		
		diff = (value + amount) % max;
		
		return diff;
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
	inline static public function dotProduct(ax:Float, ay:Float, bx:Float, by:Float):Float
	{
		return ax * bx + ay * by;
	}
	
	/**
	 * Finds the length of the given vector
	 * 
	 * @param	dx
	 * @param	dy
	 * 
	 * @return The length
	 */
	inline static public function vectorLength(dx:Float, dy:Float):Float
	{
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	/**
	 * Calculate the distance between two points.
	 * 
	 * @param 	Point1		A <code>FlxPoint</code> object referring to the first location.
	 * @param 	Point2		A <code>FlxPoint</code> object referring to the second location.
	 * @return	The distance between the two points as a floating point <code>Number</code> object.
	 */
	inline static public function getDistance(Point1:FlxPoint, Point2:FlxPoint):Float
	{
		var dx:Float = Point1.x - Point2.x;
		var dy:Float = Point1.y - Point2.y;
		return vectorLength(dx, dy);
	}
	
	/**
	 * Find the distance (in pixels, rounded) between two FlxSprites, taking their origin into account
	 * 
	 * @param	SpriteA		The first FlxSprite
	 * @param	SpriteB		The second FlxSprite
	 * @return	Distance between the sprites in pixels
	 */
	inline static public function distanceBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Int
	{
		var dx:Float = (SpriteA.x + SpriteA.origin.x) - (SpriteB.x + SpriteB.origin.x);
		var dy:Float = (SpriteA.y + SpriteA.origin.y) - (SpriteB.y + SpriteB.origin.y);
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	/**
	 * Find the distance (in pixels, rounded) from an <code>FlxSprite</code>
	 * to the given <code>FlxPoint</code>, taking the source origin into account.
	 * 
	 * @param	Sprite	The FlxSprite
	 * @param	Target	The FlxPoint
	 * @return	Distance in pixels
	 */
	inline static public function distanceToPoint(Sprite:FlxSprite, Target:FlxPoint):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - (Target.x);
		var dy:Float = (Sprite.y + Sprite.origin.y) - (Target.y);
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the distance (in pixels, rounded) from the object x/y and the mouse x/y
	 * 
	 * @param	Sprite	The FlxSprite to test against
	 * @return	The distance between the given sprite and the mouse coordinates
	 */
	inline static public function distanceToMouse(Sprite:FlxSprite):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - FlxG.mouse.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - FlxG.mouse.screenY;
		
		return Std.int(FlxMath.vectorLength(dx, dy));
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
	inline static public function distanceToTouch(Sprite:FlxSprite, Touch:FlxTouch):Int
	{
		var dx:Float = (Sprite.x + Sprite.origin.x) - Touch.screenX;
		var dy:Float = (Sprite.y + Sprite.origin.y) - Touch.screenY;
		
		return Std.int(FlxMath.vectorLength(dx, dy));
	}
	#end
	
	/**
	 * Returns the amount of decimals a Float has
	 * 
	 * @param	Number	The floating point number
	 * @return	Amount of decimals
	 */
	inline static public function getDecimals(Number:Float):Int
	{
		var helperArray:Array<String> = Std.string(Number).split(".");
		var decimals:Int = 0;
		
		if (helperArray.length > 1)
		{
			decimals = helperArray[1].length;
		}
		
		return decimals;
	}
	
	#if (flash || js)
	/**
	 * Minimum value of a floating point number.
	 */
	inline public static var MIN_VALUE:Float = 0.0000000000000001;
	#else
	/**
	 * Minimum value of a floating point number.
	 */
	inline public static var MIN_VALUE:Float = 5e-324;
	#end
	/**
	 * Maximum value of a floating point number.
	 */
	inline public static var MAX_VALUE:Float = 1.79e+308;
}