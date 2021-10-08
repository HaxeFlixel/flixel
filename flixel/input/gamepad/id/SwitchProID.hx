package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for Switch Pro controllers
 *
 *-------
 * NOTES
 *-------
 *
 * WINDOWS: untested.
 *
 * LINUX: untested
 *
 * MAC: Worked out of box for me when connected via microUSB cable or Bluetooth
 * 
 * @since 4.8.0
 */
class SwitchProID
{
	#if flash
	public static inline var DPAD_UP:Int = 4;
	public static inline var DPAD_DOWN:Int = 5;
	public static inline var DPAD_LEFT:Int = 6;
	public static inline var DPAD_RIGHT:Int = 7;
	public static inline var A:Int = 8;
	public static inline var B:Int = 9;
	public static inline var X:Int = 10;
	public static inline var Y:Int = 11;
	public static inline var L:Int = 12;
	public static inline var R:Int = 13;
	public static inline var ZL:Int = 14;
	public static inline var ZR:Int = 15;
	public static inline var MINUS:Int = 16;
	public static inline var PLUS:Int = 17;
	public static inline var HOME:Int = 20;
	public static inline var CAPTURE:Int = 21;
	public static inline var LEFT_STICK_CLICK:Int = 22;
	public static inline var RIGHT_STICK_CLICK:Int = 23;
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 24,
		down: 25,
		left: 26,
		right: 27
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 28,
		down: 29,
		left: 30,
		right: 31
	});
	#else
	public static inline var ZL:Int = 4;
	public static inline var ZR:Int = 5;
	public static inline var B:Int = 6;
	public static inline var A:Int = 7;
	public static inline var Y:Int = 8;
	public static inline var X:Int = 9;
	public static inline var MINUS:Int = 10;
	public static inline var HOME:Int = 11;
	public static inline var PLUS:Int = 12;
	public static inline var LEFT_STICK_CLICK:Int = 13;
	public static inline var RIGHT_STICK_CLICK:Int = 14;
	public static inline var L:Int = 15;
	public static inline var R:Int = 16;
	public static inline var DPAD_UP:Int = 17;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;
	public static inline var CAPTURE:Int = 21;
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 22,
		down: 23,
		left: 24,
		right: 25
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	});
	#end
	
}
