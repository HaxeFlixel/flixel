package org.flixel.util;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.system.input.FlxTouch;

/**
 * A set of functions related to angle calculations.
 */
class FlxAngle
{
	static private var cosTable:Array<Float> = new Array<Float>();
	static private var sinTable:Array<Float> = new Array<Float>();
	
	/**
	 * Useful for rad-to-deg and deg-to-rad conversion.
	 */
	static public var DEG:Float = 180 / Math.PI;
	static public var RAD:Float = Math.PI / 180;
	
	static private var coefficient1:Float = Math.PI / 4;
	
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
	static public function atan2(y:Float, x:Float):Float
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
	 * 
	 * The parameters allow you to specify the length, amplitude and frequency of the wave. Once you have called this function
	 * you should get the results via getSinTable() and getCosTable(). This generator is fast enough to be used in real-time.
	 * 
	 * @param length 		The length of the wave
	 * @param sinAmplitude 	The amplitude to apply to the sine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param cosAmplitude 	The amplitude to apply to the cosine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param frequency 	The frequency of the sine and cosine table data
	 * @return	Returns the sine table
	 * @see getSinTable
	 * @see getCosTable
	 */
	static public function sinCosGenerator(length:Int, sinAmplitude:Float = 1.0, cosAmplitude:Float = 1.0, frequency:Float = 1.0):Array<Float>
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
	inline static public function getSinTable():Array<Float>
	{
		return sinTable;
	}
	
	/**
	 * Returns the cosine table generated by sinCosGenerator(), or an empty array object if not yet populated
	 * @return Array of cosine wave data
	 * @see sinCosGenerator
	 */
	inline static public function getCosTable():Array<Float>
	{
		return cosTable;
	}
	
	/**
	 * Keeps an angle value between -180 and +180
	 * Should be called whenever the angle is updated on a FlxSprite to stop it from going insane.
	 * 
	 * @param	angle	The angle value to check
	 * 
	 * @return	The new angle value, returns the same as the input angle if it was within bounds
	 */
	static public function wrapAngle(angle:Float):Int
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
	static public function angleLimit(angle:Int, min:Int, max:Int):Int
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
	 * Converts the radians value into degrees and returns
	 * 
	 * @param 	radians 	The value in radians
	 * @return	Degrees
	 */
	inline static public function asDegrees(radians:Float):Float
	{
		return radians * DEG;
	}
	
	/**
	 * Converts a Degrees value into a Radian
	 * Converts the degrees value into radians and returns
	 * 
	 * @param 	degrees The value in degrees
	 * @return	Radians
	 */
	inline static public function asRadians(degrees:Float):Float
	{
		return degrees * RAD;
	}
	
	/**
	 * Find the angle (in radians) between the two FlxSprite, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	SpriteA		The FlxSprite to test from
	 * @param	SpriteB		The FlxSprite to test to
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless asDegrees is true)
	 */
	inline static public function angleBetween(SpriteA:FlxSprite, SpriteB:FlxSprite, AsDegrees:Bool = false):Float
	{
		var dx:Float = (SpriteB.x + SpriteB.origin.x) - (SpriteA.x + SpriteA.origin.x);
		var dy:Float = (SpriteB.y + SpriteB.origin.y) - (SpriteA.y + SpriteA.origin.y);
		
		if (AsDegrees)
			return asDegrees(Math.atan2(dy, dx));
		else
			return Math.atan2(dy, dx);
	}
	
	/**
	 * Find the angle (in radians) between an FlxSprite and an FlxPoint. The source sprite takes its x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	Sprite		The FlxSprite to test from
	 * @param	Target		The FlxPoint to angle the FlxSprite towards
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	static public function angleBetweenPoint(Sprite:FlxSprite, Target:FlxPoint, AsDegrees:Bool = false):Float
	{
		var dx:Float = (Target.x) - (Sprite.x + Sprite.origin.x);
		var dy:Float = (Target.y) - (Sprite.y + Sprite.origin.y);
		
		if (AsDegrees)
			return asDegrees(Math.atan2(dy, dx));
		else
			return Math.atan2(dy, dx);
	}
	
	#if !FLX_NO_MOUSE
	/**
	 * Find the angle (in radians) between an FlxSprite and the mouse, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	Object		The FlxObject to test from
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	static public function angleBetweenMouse(Object:FlxObject, AsDegrees:Bool = false):Float
	{
		//	In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		if (Object == null)
			return 0;
		
		var p:FlxPoint = Object.getScreenXY();
		
		var dx:Float = FlxG.mouse.screenX - p.x;
		var dy:Float = FlxG.mouse.screenY - p.y;
		
		if (AsDegrees)
			return asDegrees(Math.atan2(dy, dx));
		else
			return Math.atan2(dy, dx);
	}
	#end
	
	#if !FLX_NO_TOUCH
	/**
	 * Find the angle (in radians) between an FlxSprite and a FlxTouch, taking their x/y and origin into account.
	 * The angle is calculated in clockwise positive direction (down = 90 degrees positive, right = 0 degrees positive, up = 90 degrees negative)
	 * 
	 * @param	Object		The FlxObject to test from
	 * @param	Touch		The FlxTouch to test to
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	inline static public function angleBetweenTouch(Object:FlxObject, Touch:FlxTouch, AsDegrees:Bool = false):Float
	{
		//	In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		var p:FlxPoint = Object.getScreenXY();
		
		var dx:Float = Touch.screenX - p.x;
		var dy:Float = Touch.screenY - p.y;
		
		if (AsDegrees)
			return asDegrees(Math.atan2(dy, dx));
		else
			return Math.atan2(dy, dx);
	}
	#end
}
