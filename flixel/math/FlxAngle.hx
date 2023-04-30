package flixel.math;

import haxe.macro.Context;
import haxe.macro.Expr;
#if !macro
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.util.FlxDirectionFlags;
#if FLX_TOUCH
import flixel.input.touch.FlxTouch;
#end
#end

/**
 * A set of functions related to angle calculations.
 * In degrees: (down = 90, right = 0, up = -90)
 * 
 * Note: in Flixel 5.0.0 all angle-related tools were changed so that 0 degrees points right, instead of up
 * @see [Flixel 5.0.0 Migration guide](https://github.com/HaxeFlixel/flixel/wiki/Flixel-5.0.0-Migration-guide)
 */
class FlxAngle
{
	/**
	 * Generate a sine and cosine table during compilation
	 *
	 * The parameters allow you to specify the length, amplitude and frequency of the wave.
	 * You have to call this function with constant parameters and either use it on your own or assign it to FlxAngle.sincos
	 *
	 * @param length 		The length of the wave
	 * @param sinAmplitude 	The amplitude to apply to the sine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param cosAmplitude 	The amplitude to apply to the cosine table (default 1.0) if you need values between say -+ 125 then give 125 as the value
	 * @param frequency 	The frequency of the sine and cosine table data
	 * @return	Returns the cosine/sine table in a FlxSinCos
	 */
	public static macro function sinCosGenerator(length:Int = 360, sinAmplitude:Float = 1.0, cosAmplitude:Float = 1.0, frequency:Float = 1.0):Expr
	{
		var table = {cos: [], sin: []};

		for (c in 0...length)
		{
			var radian = c * frequency * Math.PI / 180;
			table.cos.push(Math.cos(radian) * cosAmplitude);
			table.sin.push(Math.sin(radian) * sinAmplitude);
		}

		return Context.makeExpr(table, Context.currentPos());
	}

	#if !macro
	/**
	 * Convert radians to degrees by multiplying it with this value.
	 */
	public static var TO_DEG(get, never):Float;

	/**
	 * Convert degrees to radians by multiplying it with this value.
	 */
	public static var TO_RAD(get, never):Float;

	/**
	 * Calculates the angle from (0, 0) to (x, y), in radians
	 * @param x The x distance from the origin
	 * @param y The y distance from the origin
	 * @return The angle in radians between -PI to PI
	 */
	public static inline function radiansFromOrigin(x:Float, y:Float)
	{
		return angleFromOrigin(x, y, false);
	}

	/**
	 * Calculates the angle from (0, 0) to (x, y), in degrees
	 * @param x The x distance from the origin
	 * @param y The y distance from the origin
	 * @return The angle in degrees between -180 to 180
	 */
	public static inline function degreesFromOrigin(x:Float, y:Float)
	{
		return angleFromOrigin(x, y, true);
	}

	/**
	 * Calculates the angle from (0, 0) to (x, y)
	 * @param x         The x distance from the origin
	 * @param y         The y distance from the origin
	 * @param asDegrees If true, it gives the value in degrees
	 * @return The angle, either in degrees, between -180 and 180 or in radians, between -PI and PI
	 */
	public static inline function angleFromOrigin(x:Float, y:Float, asDegrees:Bool = false)
	{
		return if (asDegrees)
				Math.atan2(y, x) * TO_DEG;
			else
				Math.atan2(y, x);
	}

	/**
	 * Keeps an angle value between -180 and +180 by wrapping it
	 * e.g an angle of +270 will be converted to -90
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
			angle = wrapAngle(angle - 360);
		}
		else if (angle < -180)
		{
			angle = wrapAngle(angle + 360);
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

	/**
	 * Find the angle between the two FlxSprite, taking their x/y and origin into account.
	 *
	 * @param	SpriteA		The FlxSprite to test from
	 * @param	SpriteB		The FlxSprite to test to
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless asDegrees is true)
	 */
	public static function angleBetween(SpriteA:FlxSprite, SpriteB:FlxSprite, AsDegrees:Bool = false):Float
	{
		var dx:Float = (SpriteB.x + SpriteB.origin.x) - (SpriteA.x + SpriteA.origin.x);
		var dy:Float = (SpriteB.y + SpriteB.origin.y) - (SpriteA.y + SpriteA.origin.y);

		return angleFromOrigin(dx, dy, AsDegrees);
	}

	/**
	 * Find the angle (in degrees) between the two FlxSprite, taking their x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	SpriteA		The FlxSprite to test from
	 * @param	SpriteB		The FlxSprite to test to
	 * @return	The angle in degrees
	 */
	public static inline function degreesBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Float
	{
		return angleBetween(SpriteA, SpriteB, true);
	}

	/**
	 * Find the angle (in radians) between the two FlxSprite, taking their x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	SpriteA		The FlxSprite to test from
	 * @param	SpriteB		The FlxSprite to test to
	 * @return	The angle in radians
	 */
	public static inline function radiansBetween(SpriteA:FlxSprite, SpriteB:FlxSprite):Float
	{
		return angleBetween(SpriteA, SpriteB, false);
	}

	/**
	 * Find the angle between an FlxSprite and an FlxPoint.
	 * The source sprite takes its x/y and origin into account.
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

		Target.putWeak();

		return angleFromOrigin(dx, dy, AsDegrees);
	}

	/**
	 * Find the angle (in degrees) between an FlxSprite and an FlxPoint.
	 * The source sprite takes its x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	Sprite		The FlxSprite to test from
	 * @param	Target		The FlxPoint to angle the FlxSprite towards
	 * @return	The angle in degrees
	 */
	public static inline function degreesBetweenPoint(Sprite:FlxSprite, Target:FlxPoint):Float
	{
		return angleBetweenPoint(Sprite, Target, true);
	}

	/**
	 * Find the angle (in radians) between an FlxSprite and an FlxPoint.
	 * The source sprite takes its x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	Sprite		The FlxSprite to test from
	 * @param	Target		The FlxPoint to angle the FlxSprite towards
	 * @return	The angle in radians
	 */
	public static inline function radiansBetweenPoint(Sprite:FlxSprite, Target:FlxPoint):Float
	{
		return angleBetweenPoint(Sprite, Target, false);
	}

	#if FLX_MOUSE
	/**
	 * Find the angle between an FlxSprite and the mouse,
	 * taking their **screen** x/y and origin into account.
	 *
	 * @param	Object		The FlxObject to test from
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	public static function angleBetweenMouse(Object:FlxObject, AsDegrees:Bool = false):Float
	{
		if (Object == null)
			return 0;

		var p:FlxPoint = Object.getScreenPosition();

		var dx:Float = FlxG.mouse.screenX - p.x;
		var dy:Float = FlxG.mouse.screenY - p.y;

		p.put();

		return angleFromOrigin(dx, dy, AsDegrees);
	}

	/**
	 * Find the angle (in degrees) between an FlxSprite and the mouse,
	 * taking their **screen** x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	Object		The FlxObject to test from
	 * @return	The angle in degrees
	 */
	public static inline function degreesBetweenMouse(Object:FlxObject):Float
	{
		return angleBetweenMouse(Object, true);
	}

	/**
	 * Find the angle (in radians) between an FlxSprite and the mouse,
	 * taking their **screen** x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	Object		The FlxObject to test from
	 * @return	The angle in radians
	 */
	public static inline function radiansBetweenMouse(Object:FlxObject):Float
	{
		return angleBetweenMouse(Object, false);
	}
	#end

	#if FLX_TOUCH
	/**
	 * Find the angle between an FlxSprite and a FlxTouch,
	 * taking their **screen** x/y and origin into account.
	 *
	 * @param	Object		The FlxObject to test from
	 * @param	Touch		The FlxTouch to test to
	 * @param	AsDegrees	If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	public static function angleBetweenTouch(Object:FlxObject, Touch:FlxTouch, AsDegrees:Bool = false):Float
	{
		// In order to get the angle between the object and mouse, we need the objects screen coordinates (rather than world coordinates)
		var p:FlxPoint = Object.getScreenPosition();

		var dx:Float = Touch.screenX - p.x;
		var dy:Float = Touch.screenY - p.y;

		p.put();

		return angleFromOrigin(dx, dy, AsDegrees);
	}

	/**
	 * Find the angle (in degrees) between an FlxSprite and a FlxTouch,
	 * taking their **screen** x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	Object		The FlxObject to test from
	 * @param	Touch		The FlxTouch to test to
	 * @return	The angle in degrees
	 */
	public static inline function degreesBetweenTouch(Object:FlxObject, Touch:FlxTouch):Float
	{
		return angleBetweenTouch(Object, Touch, true);
	}

	/**
	 * Find the angle (in radians) between an FlxSprite and a FlxTouch,
	 * taking their **screen** x/y and origin into account.
	 * @since 5.0.0
	 *
	 * @param	Object		The FlxObject to test from
	 * @param	Touch		The FlxTouch to test to
	 * @return	The angle in radians
	 */
	public static inline function radiansBetweenTouch(Object:FlxObject, Touch:FlxTouch):Float
	{
		return angleBetweenTouch(Object, Touch, false);
	}
	#end

	/**
	 *  Translate an object's facing to angle.
	 *
	 * @param	FacingBitmask	Bitmask from which to calculate the angle, as in FlxSprite::facing
	 * @param	AsDegrees		If you need the value in degrees instead of radians, set to true
	 * @return	The angle (in radians unless AsDegrees is true)
	 */
	@:deprecated("FlxAngle.angleFromFacing is deprecated, use flags.degrees.")
	public static function angleFromFacing(Facing:FlxDirectionFlags, AsDegrees:Bool = false):Float
	{
		var degrees = Facing.degrees;
		return AsDegrees ? degrees : asRadians(degrees);
	}

	/**
	 * Convert polar coordinates (radius + angle) to cartesian coordinates (x + y)
	 *
	 * @param	Radius	The radius
	 * @param	Angle	The angle, in degrees
	 * @param	point	Optional FlxPoint if you don't want a new one created
	 * @return	The point in cartesian coords
	 */
	@:deprecated("FlxAngle.getCartesianCoords is deprecated, use FlxVector.setPolarDegrees")
	public static function getCartesianCoords(Radius:Float, Angle:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point;
		if (p == null)
			p = FlxPoint.get();

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
	 * @return	The point in polar coords (x = Radius, y = Angle (degrees))
	 */
	@:deprecated("FlxAngle.getCartesianCoords is deprecated, use FlxPoint")
	public static function getPolarCoords(X:Float, Y:Float, ?point:FlxPoint):FlxPoint
	{
		var p = point;
		if (p == null)
			p = FlxPoint.get();

		p.x = Math.sqrt((X * X) + (Y * Y));
		p.y = degreesFromOrigin(X, Y);
		return p;
	}

	static inline function get_TO_DEG():Float
	{
		return 180 / Math.PI;
	}

	static inline function get_TO_RAD():Float
	{
		return Math.PI / 180;
	}
	#end
}

typedef FlxSinCos =
{
	var cos:Array<Float>;
	var sin:Array<Float>;
};
