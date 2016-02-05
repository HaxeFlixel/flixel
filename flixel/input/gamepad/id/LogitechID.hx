package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for Logitech controllers (key codes based on Cordless Rumblepad 2)
 */
class LogitechID
{
	public static inline var SUPPORTS_MOTION = false;
	public static inline var SUPPORTS_POINTER = false;
	
	public static inline function getFlipAxis(AxisID:Int):Int { return 1; }
	
	public static function isAxisForMotion(ID:FlxGamepadInputID):Bool { return false; }
	
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
	
	//"fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	public static inline var DPAD_UP:Int = 16;
	public static inline var DPAD_DOWN:Int = 17;
	public static inline var DPAD_LEFT:Int = 18;
	public static inline var DPAD_RIGHT:Int = 19;
	
	//TODO: Someone needs to look this up and define it! (NOTE: not all logitech controllers have this)
	public static inline var LOGITECH:Int = -5;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
	
	#if FLX_JOYSTICK_API
	// Analog stick values overlap with regular buttons so we remap to "fake" button ID's
	public static function axisIndexToRawID(index:Int):Int
	{
		return if (index == LEFT_ANALOG_STICK.x) LEFT_ANALOG_STICK_FAKE_X;
			else if (index == LEFT_ANALOG_STICK.y) LEFT_ANALOG_STICK_FAKE_Y;
			else if (index == RIGHT_ANALOG_STICK.x) RIGHT_ANALOG_STICK_FAKE_X;
			else if (index == RIGHT_ANALOG_STICK.y) RIGHT_ANALOG_STICK_FAKE_Y;
			else return index;  // return what was passed in, no overlaps for other IDs
	}
	//"fake" IDs
	public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 20;
	public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 21;
	
	public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 22;
	public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 23;
	
	//just pass back SEVEN/EIGHT (the left/right triggers)
	public static inline var LEFT_TRIGGER_FAKE:Int = SEVEN;
	public static inline var RIGHT_TRIGGER_FAKE:Int = EIGHT;
	#end
#end
}