package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for Logitech controllers (key codes based on Cordless Rumblepad 2)
 */
class LogitechID
{
#if flash
	// Button IDs
	public static inline var ONE:Int = 8;
	public static inline var TWO:Int = 9;
	public static inline var THREE:Int = 10;
	public static inline var FOUR:Int = 11;
	public static inline var FIVE:Int = 12;
	public static inline var SIX:Int = 13;
	public static inline var SEVEN:Int = 14;
	public static inline var EIGHT:Int = 15;
	public static inline var NINE:Int = 16;
	public static inline var TEN:Int = 17;
	public static inline var LEFT_STICK_CLICK:Int = 18;
	public static inline var RIGHT_STICK_CLICK:Int = 19;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
	
	public static inline var DPAD_UP:Int = 4;
	public static inline var DPAD_DOWN:Int = 5;
	public static inline var DPAD_LEFT:Int = 6;
	public static inline var DPAD_RIGHT:Int = 7;
	
	//TODO: Someone needs to look this up and define it! (NOTE: not all logitech controllers have this)
	public static inline var LOGITECH:Int = -1;
	
#else // native and html5
	// Button IDs
	public static inline var ONE:Int = 0;
	public static inline var TWO:Int = 1;
	public static inline var THREE:Int = 2;
	public static inline var FOUR:Int = 3;
	public static inline var FIVE:Int = 4;
	public static inline var SIX:Int = 5;
	public static inline var SEVEN:Int = 6;
	public static inline var EIGHT:Int = 7;
	public static inline var NINE:Int = 8;
	public static inline var TEN:Int = 9;
	public static inline var LEFT_STICK_CLICK:Int = 10;
	public static inline var RIGHT_STICK_CLICK:Int = 11;
	
	//TODO: someone needs to look these up and define them!
	public static inline var DPAD_UP:Int = -1;
	public static inline var DPAD_DOWN:Int = -2;
	public static inline var DPAD_LEFT:Int = -3;
	public static inline var DPAD_RIGHT:Int = -4;
	
	//TODO: Someone needs to look this up and define it! (NOTE: not all logitech controllers have this)
	public static inline var LOGITECH:Int = -5;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
#end
}