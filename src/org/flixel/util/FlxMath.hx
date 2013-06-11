package org.flixel.util;

import flash.geom.Rectangle;

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
	 * Rotates a point in 2D space around another point by the given angle.
	 * @param	X		The X coordinate of the point you want to rotate.
	 * @param	Y		The Y coordinate of the point you want to rotate.
	 * @param	PivotX	The X coordinate of the point you want to rotate around.
	 * @param	PivotY	The Y coordinate of the point you want to rotate around.
	 * @param	Angle	Rotate the point by this many degrees.
	 * @param	Point	Optional <code>FlxPoint</code> to store the results in.
	 * @return	A <code>FlxPoint</code> containing the coordinates of the rotated point.
	 */
	inline static public function rotatePoint(X:Float, Y:Float, PivotX:Float, PivotY:Float, Angle:Float, point:FlxPoint = null):FlxPoint
	{
		var sin:Float = 0;
		var cos:Float = 0;
		var radians:Float = Angle * -0.017453293;
		while (radians < -3.14159265)
		{
			radians += 6.28318531;
		}
		while (radians >  3.14159265)
		{
			radians = radians - 6.28318531;
		}
		
		if (radians < 0)
		{
			sin = 1.27323954 * radians + .405284735 * radians * radians;
			if (sin < 0)
			{
				sin = .225 * (sin *-sin - sin) + sin;
			}
			else
			{
				sin = .225 * (sin * sin - sin) + sin;
			}
		}
		else
		{
			sin = 1.27323954 * radians - 0.405284735 * radians * radians;
			if (sin < 0)
			{
				sin = .225 * (sin *-sin - sin) + sin;
			}
			else
			{
				sin = .225 * (sin * sin - sin) + sin;
			}
		}
		
		radians += 1.57079632;
		if (radians >  3.14159265)
		{
			radians = radians - 6.28318531;
		}
		if (radians < 0)
		{
			cos = 1.27323954 * radians + 0.405284735 * radians * radians;
			if (cos < 0)
			{
				cos = .225 * (cos *-cos - cos) + cos;
			}
			else
			{
				cos = .225 * (cos * cos - cos) + cos;
			}
		}
		else
		{
			cos = 1.27323954 * radians - 0.405284735 * radians * radians;
			if (cos < 0)
			{
				cos = .225 * (cos *-cos - cos) + cos;
			}
			else
			{
				cos = .225 * (cos * cos - cos) + cos;
			}
		}
		
		var dx:Float = X - PivotX;
		// TODO: Uncomment this line if there will be problems
		//var dy:Float = PivotY + Y; //Y axis is inverted in flash, normally this would be a subtract operation
		var dy:Float = Y - PivotY;
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = PivotX + cos * dx - sin * dy;
		point.y = PivotY - sin * dx - cos * dy;
		return point;
	}
	
	/**
	 * Calculates the angle between two points.  0 degrees points straight up.
	 * @param	Point1		The X coordinate of the point.
	 * @param	Point2		The Y coordinate of the point.
	 * @return	The angle in degrees, between -180 and 180.
	 */
	inline static public function getAngle(Point1:FlxPoint, Point2:FlxPoint):Float
	{
		var x:Float = Point2.x - Point1.x;
		var y:Float = Point2.y - Point1.y;
		var angle:Float = 0;
		if ((x != 0) || (y != 0))
		{
			var c1:Float = 3.14159265 * 0.25;
			var c2:Float = 3 * c1;
			var ay:Float = (y < 0) ? -y : y;
			if (x >= 0)
			{
				angle = c1 - c1 * ((x - ay) / (x + ay));
			}
			else
			{
				angle = c2 - c1 * ((x + ay) / (ay - x));
			}
			angle = ((y < 0)? -angle:angle) * 57.2957796;
			if (angle > 90)
			{
				angle = angle - 270;
			}
			else
			{
				angle += 90;
			}
		}
		
		return angle;
	}
	
	/**
	 * Transforms degrees to radians
	 * @param 	degrees		Angle in degrees (0 - 360).
	 * @return	The andgle in radians.
	 */
	inline static public function degreesToRadians(degrees:Float):Float 
	{
		return degrees * FlxG.RAD;
	}
	
	/**
	 * Calculate the distance between two points.
	 * @param 	Point1		A <code>FlxPoint</code> object referring to the first location.
	 * @param 	Point2		A <code>FlxPoint</code> object referring to the second location.
	 * @return	The distance between the two points as a floating point <code>Number</code> object.
	 */
	inline static public function getDistance(Point1:FlxPoint, Point2:FlxPoint):Float
	{
		var dx:Float = Point1.x - Point2.x;
		var dy:Float = Point1.y - Point2.y;
		return Math.sqrt(dx * dx + dy * dy);
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
	public static function pointInRectangle(pointX:Float, pointY:Float, rect:Rectangle):Bool
	{
		if (pointX >= rect.x && pointX <= rect.right && pointY >= rect.y && pointY <= rect.bottom)
		{
			return true;
		}
		
		return false;
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
		return Math.sqrt(dx * dx + dy * dy);
	}
	
	#if (flash || js)
	inline public static var MIN_VALUE:Float = 0.0000000000000001;
	#else
	inline public static var MIN_VALUE:Float = 5e-324;
	#end
	inline public static var MAX_VALUE:Float = 1.79e+308;
}