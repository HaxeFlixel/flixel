package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for OUYA controllers
 */
class OUYAID
{
	public static inline var O:Int = 6;
	public static inline var U:Int = 8;
	public static inline var Y:Int = 9;
	public static inline var A:Int = 7;
	public static inline var LB:Int = 15;
	public static inline var RB:Int = 16;
	public static inline var LEFT_STICK_CLICK:Int = 13;
	public static inline var RIGHT_STICK_CLICK:Int = 14;
	public static inline var HOME:Int = 0x01000012;	// Not sure if press HOME is taken in account on OUYA
	public static inline var LEFT_TRIGGER:Int = 4;
	public static inline var RIGHT_TRIGGER:Int = 5;

	// "fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_UP:Int = 17;

	// If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 23,
		down: 24,
		left: 25,
		right: 26
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 27,
		down: 28,
		left: 29,
		right: 30
	});
}
