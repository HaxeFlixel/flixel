package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;

/**
 * Native PSVita input values.
 * (The only way to use these is to actually be using a PSVita with the upcoming openfl vita target!)
 * 
 * This will ONLY work with the gamepad API (available only in OpenFL "next", not "legacy") and will NOT work with the joystick API
 */
class PSVitaID
{
	//TODO:
	//Analog sticks work, but vertical axis is flipped
	//X = start
	//TRIANGLE = L
	//SELECT = R
	//START = Dpad down
	//LH = A
	//LV = B
	//RH = X
	//RV = Y
	
	public static inline var SUPPORTS_MOTION = false;
	public static inline var SUPPORTS_POINTER = false;
	
	public static inline function getFlipAxis(AxisID:Int):Int
	{
		return switch (AxisID)
		{
			case LEFT_STICK_V : -1;
			case RIGHT_STICK_V: -1;
			default: 1;
		}
	}
	
	public static function isAxisForMotion(ID:FlxGamepadInputID):Bool { return false; }
	
	// Button IDs
	public static inline var X:Int = 6;
	public static inline var CIRCLE:Int = 7;
	public static inline var SQUARE:Int = 8;
	public static inline var TRIANGLE:Int = 9;
	public static inline var SELECT:Int = 10;
	public static inline var START:Int = 12;
	public static inline var L:Int = 15;
	public static inline var R:Int = 16;
	
	public static inline var DPAD_UP:Int = 17;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(LEFT_STICK_H, LEFT_STICK_V);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(RIGHT_STICK_H, RIGHT_STICK_V);
	
	private static inline var LEFT_STICK_H:Int = 0;
	private static inline var LEFT_STICK_V:Int = 1;
	private static inline var RIGHT_STICK_H:Int = 2;
	private static inline var RIGHT_STICK_V:Int = 3;
}