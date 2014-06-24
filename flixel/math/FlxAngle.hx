package flixel.math;

import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
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
	public static var TO_DEG(get, never):Float;
	/**
	 * Convert degrees to radians by multiplying it with this value.
	 */
	public static var TO_RAD(get, never):Float;
	
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
	public static function wrapAngle(angle:Float):Float
	{
		if (angle > 180)
		{
			angle = -180;
		}
		else if (angle < -180)
		{
			angle = 180;
		}
		
		return angle;
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
	public static function angleLimit(angle:Float, min:Float, max:Float):Float
	{
		if (angle > max)
		{
			angle = max;
		}
		else if (angle < min)
		{
			angle = min;
		}
		
		return angle;
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
	
	private static inline function get_TO_DEG():Float
	{
		return 180 / Math.PI;
	}
	
	private static inline function get_TO_RAD():Float
	{
		return Math.PI / 180;
	}
}
