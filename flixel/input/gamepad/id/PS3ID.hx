package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for PlayStation 3 controllers
 */
class PS3ID
{
	public static inline var TRIANGLE:Int = 12;
	public static inline var CIRCLE:Int = 13;
	public static inline var X:Int = 14;
	public static inline var SQUARE:Int = 15;
	public static inline var L1:Int = 10;
	public static inline var R1:Int = 11;
	public static inline var L2:Int = 8;
	public static inline var R2:Int = 9;
	public static inline var SELECT:Int = 0;
	public static inline var START:Int = 3;
	public static inline var PS:Int = 16;
	public static inline var LEFT_STICK_CLICK:Int = 1;
	public static inline var RIGHT_STICK_CLICK:Int = 2;
	
	public static inline var DPAD_UP:Int = 4;
	public static inline var DPAD_DOWN:Int = 6;
	public static inline var DPAD_LEFT:Int = 7;
	public static inline var DPAD_RIGHT:Int = 5;
	
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
	
	public static inline var TRIANGLE_PRESSURE:Int = 16;
	public static inline var CIRCLE_PRESSURE:Int = 17;
	public static inline var X_PRESSURE:Int = 18;
	public static inline var SQUARE_PRESSURE:Int = 19;
}
