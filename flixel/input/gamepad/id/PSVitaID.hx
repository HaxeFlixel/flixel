package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * Native PSVita input values.
 * (The only way to use these is to actually be using a PSVita with the upcoming openfl vita target!)
 *
 * This will ONLY work with the gamepad API (available only in OpenFL "next", not "legacy") and will NOT work with the joystick API
 */
class PSVitaID
{
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

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 21,
		down: 22,
		left: 23,
		right: 24
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 25,
		down: 26,
		left: 27,
		right: 28
	});
}
