package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for OUYA controllers
 */
class OUYAID
{
	public static inline var SUPPORTS_MOTION = false;
	
	public static inline function getFlipAxis(AxisID:Int):Int { return 1; }
	public static function isAxisForMotion(ID:FlxGamepadInputID):Bool { return false; }
	
	// Button IDs
	public static inline var O:Int = 0;
	public static inline var U:Int = 3;
	public static inline var Y:Int = 4;
	public static inline var A:Int = 1;
	public static inline var LB:Int = 6;
	public static inline var RB:Int = 7;
	public static inline var LEFT_STICK_CLICK:Int = 10;
	public static inline var RIGHT_STICK_CLICK:Int = 11;
	public static inline var HOME:Int = 2;
	public static inline var LEFT_TRIGGER:Int = 8;
	public static inline var RIGHT_TRIGGER:Int = 9;
	
	//"fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	public static inline var DPAD_LEFT:Int = 13;
	public static inline var DPAD_RIGHT:Int = 14;
	public static inline var DPAD_DOWN:Int = 15;
	public static inline var DPAD_UP:Int = 16;
	
	// Axis indicies 
	// If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(11, 14);
	
	public static inline var LEFT_TRIGGER_ANALOG:Int = 17;
	public static inline var RIGHT_TRIGGER_ANALOG:Int = 18;
	
	#if FLX_JOYSTICK_API
	//Analog stick values overlap with regular buttons so we remap to "fake" button ID's
	public static function axisIndexToRawID(index:Int):Int
	{
		return   if (index == LEFT_ANALOG_STICK.x) LEFT_ANALOG_STICK_FAKE_X;
			else if (index == LEFT_ANALOG_STICK.y) LEFT_ANALOG_STICK_FAKE_Y;
			else if (index == RIGHT_ANALOG_STICK.x) RIGHT_ANALOG_STICK_FAKE_X;
			else if (index == RIGHT_ANALOG_STICK.y) RIGHT_ANALOG_STICK_FAKE_Y;
			else return index;
	}
	//"fake" IDs
	public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 19;
	public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 20;
	
	public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 21;
	public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 22;
	
	//Just pass back LEFT/RIGHT triggers
	public static inline var LEFT_TRIGGER_FAKE:Int = LEFT_TRIGGER;
	public static inline var RIGHT_TRIGGER_FAKE:Int = RIGHT_TRIGGER;
	#end
} 