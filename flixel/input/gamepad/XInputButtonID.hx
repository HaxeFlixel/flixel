package flixel.input.gamepad;

import flixel.input.gamepad.FlxGamepad;

/**
 * Button IDs for generic XInput controllers
 */
class XInputButtonID
{
	/**
	* Button IDs
	*/
	public static inline var A:Int = 6;
	public static inline var B:Int = 7;
	public static inline var X:Int = 8;
	public static inline var Y:Int = 9;
	public static inline var LB:Int = 15;
	public static inline var RB:Int = 16;
	public static inline var BACK:Int = 10;
	public static inline var START:Int = 12;
	public static inline var LEFT_ANALOG:Int = 13;
	public static inline var RIGHT_ANALOG:Int = 14;
	
	public static inline var GUIDE:Int = 11;
	
	//real dpad id's this time, no need for hats!
	public static inline var DPAD_UP:Int = 17;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;
	
	/**
	* Axis array indicies
	*/
	public static var LEFT_ANALOG_STICK(default, null):FlxGamepadAnalogStick = [FlxAxes.X => 0, FlxAxes.Y => 1];
	public static var RIGHT_ANALOG_STICK(default, null):FlxGamepadAnalogStick = [FlxAxes.X => 3, FlxAxes.Y => 4];
	public static inline var LEFT_TRIGGER:Int = 2;
	public static inline var RIGHT_TRIGGER:Int = 5;
}
