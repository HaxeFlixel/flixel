package flixel.util;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
#if !FLX_NO_TOUCH
import flixel.input.touch.FlxTouch;
#end

/**
 * A set of functions related to angle calculations.
 */
class FlxAngle
{
	/**
	 * Use this to access the cos-table generated via sinCosGenerator().
	 */
	public static var cosTable:Array<Float> = new Array<Float>();
	/**
	 * Use this to access the sin-table generated via sinCosGenerator().
	 */
	public static var sinTable:Array<Float> = new Array<Float>();
	/**
	 * Convert radians to degrees by multiplying it with this value.
	 */
	public static var TO_DEG:Float = 180 / Math.PI;
	/**
	 * Convert degrees to radians by multiplying it with this value.
	 */
	public static var TO_RAD:Float = Math.PI / 180;
	
	/**
	 * Rotates a point in 2D space around another point by the given angle.
	 * @param	X		The X coordinate of the point you want to rotate.
	 * @param	Y		The Y coordinate of the point you want to rotate.
	 * @param	PivotX	The X coordinate of the point you want to rotate around.
	 * @param	PivotY	The Y coordinate of the point you want to rotate around.
	 * @param	Angle	Rotate the point by this many degrees.
	 * @param	Point	Optional FlxPoint to store the results in.
	 * @return	A FlxPoint containing the coordinates of the rotated point.
	 */
	public static inline function rotatePoint(X:Float, Y:Float, PivotX:Float, PivotY:Float, Angle:Float, ?point:FlxPoint):FlxPoint
	{
		var sin:Float = 0;
		var cos:Float = 0;
		var radians:Float = Angle * -TO_RAD;
		while (radians < -Math.PI)
		{
			radians += Math.PI * 2;
		}
		while (radians >  Math.PI)
		{
			radians = radians - Math.PI * 2;
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
		
		radians += Math.PI / 2;
		if (radians >  Math.PI)
		{
			radians = radians - Math.PI * 2;
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
	 * 
	 * @param	Point1		The X coordinate of the point.
	 * @param	Point2		The Y coordinate of the point.
	 * @return	The angle in degrees, between -180 and 180.
	 */
	public static inline function getAngle(Point1:FlxPoint, Point2:FlxPoint):Float
	{
		var x:Float = Point2.x - Point1.x;
		var y:Float = Point2.y - Point1.y;
		var angle:Float = 0;
		
		if ((x != 0) || (y != 0))
		{
			var c1:Float = Math.PI * 0.25;
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
			angle = ((y < 0) ? - angle : angle) * TO_DEG;
			
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
	 * Generate a sine and cosine table simultaneously and extremely quickly. Based on research by Franky of scene.at
	 * 
	 * The parameters allow you to specify the length, amplitude and frequency of the wave. Once you have called this function
	 * you should get the results via sinTable and cosTable. This generator is fast enough to be used in real-time.
	 * 
	 * @param length 		The length of the wave
	 * @param sinAmplitude 	The amplitude to apply to the sine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param cosAmplitude 	The amplitude to apply to the cosine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param frequency 	The frequency of the sine and cosine table data
	 * @return	Returns the sine table
	 * @see getSinTable
	 * @see getCosTable
	 */
	public static function sinCosGenerator(length:Int, sinAmplitude:Float = 1.0, cosAmplitude:Float = 1.0, frequency:Float = 1.0):Void
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
	}
	
	/**
	 * Keeps an angle value between -180 and +180
	 * Should be called whenever the angle is updated on a FlxSprite to stop it from going insane.
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
	 * Converts the radians value into degrees and returns
	 * 
	 * @param 	radians 	The value in radians
	 * @return	Degrees
	 */
	public static inline function asDegrees(radians:Float):Float
	{
		return radians * TO_DEG;
	}
	
	/**
	 * Converts a Degrees value into a Radian
	 * Converts the degrees value into radians and returns
	 * 
	 * @param 	degrees The value in degrees
	 * @return	Radians
	 */
	public static inline function asRadians(degrees:Float):Float
	{
		return degrees * TO_RAD;
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
	public static inline function angleBetween(SpriteA:FlxSprite, SpriteB:FlxSprite, AsDegrees:Bool = false):Float
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
	public static function angleBetweenPoint(Sprite:FlxSprite, Target:FlxPoint, AsDegrees:Bool = false):Float
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
	public static function angleBetweenMouse(Object:FlxObject, AsDegrees:Bool = false):Float
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
	public static inline function angleBetweenTouch(Object:FlxObject, Touch:FlxTouch, AsDegrees:Bool = false):Float
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
	
	/**
	 * Convert polar coordinates (radius + angle) to cartesian coordinates (x + y)
	 * 
	 * @param	Radius	The radius
	 * @param	Angle	The angle, in degrees
	 * @param	point	Optional FlxPoint if you don't want a new one created
	 * @return	The point in cartesian coords
	 */
	public static function getCartesianCoords(Radius:Float, Angle:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point;
		if (p == null)
		{
			p = FlxPoint.get();
		}
		
		p.x = Radius * Math.cos(Angle * TO_RAD);
		p.y = Radius * Math.sin(Angle * TO_RAD);
		return p;
	}
	
	/**
	 * Convert cartesian coordinates (x + y) to polar coordinates (radius + angle) 
	 * 
	 * @param	X		x position
	 * @param	Y		y position
	 * @param	point	Optional FlxPoint if you don't want a new one created
	 * @return	The point in polar coords (x = Radius (degrees), y = Angle)
	 */
	public static function getPolarCoords(X:Float, Y:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point;
		if (p == null)
		{
			p = FlxPoint.get();
		}
		
		p.x = Math.sqrt((X * X) + (Y * Y));
		p.y = Math.atan2(Y, X) * TO_DEG;
		return p;
	}
}
