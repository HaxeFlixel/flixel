package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for MFi controllers
 */
class MFiID
{
	public static inline var SUPPORTS_MOTION = false;
	public static inline var SUPPORTS_POINTER = false;
	
	public static inline function getFlipAxis(AxisID:Int):Int { return 1; }
	public static function isAxisForMotion(ID:FlxGamepadInputID):Bool { return false; }
	
	// Button IDs
	public static inline var A:Int = 6;
	public static inline var B:Int = 7;
	public static inline var X:Int = 8;
	public static inline var Y:Int = 9;
	public static inline var LB:Int = 15;
	public static inline var RB:Int = 16;
	public static inline var BACK:Int = 10;
	public static inline var START:Int = 12;
	public static inline var LEFT_STICK_CLICK:Int = 13;
	public static inline var RIGHT_STICK_CLICK:Int = 14;
	
	public static inline var GUIDE:Int = 11;
	
	// real dpad id's this time, no need for hats!
	public static inline var DPAD_UP:Int = 17;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
	
	public static inline var LEFT_TRIGGER:Int = 4;
	public static inline var RIGHT_TRIGGER:Int = 5;
	
	#if FLX_JOYSTICK_API
	//the axis index values for this don't overlap with anything so we can just return the original values!
	public static function axisIndexToRawID(index:Int):Int
	{
		return index;
	}
	
	//Just pass back LEFT/RIGHT trigger
	public static inline var LEFT_TRIGGER_FAKE:Int = LEFT_TRIGGER;
	public static inline var RIGHT_TRIGGER_FAKE:Int = RIGHT_TRIGGER;
	#end
}
