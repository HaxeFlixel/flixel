package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * Native PSVita input values.
 * (The only way to use these is to actually be using a PSVita with the upcoming openfl vita target!)
 *
 * This will ONLY work with the gamepad API (available only in OpenFL "next", not "legacy") and will NOT work with the joystick API
 */
enum abstract PSVitaID(Int) to Int
{
	var X = 6;
	var CIRCLE = 7;
	var SQUARE = 8;
	var TRIANGLE = 9;
	var SELECT = 10;
	var START = 12;
	var L = 15;
	var R = 16;

	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;

	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<PSVitaID>(0, 1, {
		up: 21,
		down: 22,
		left: 23,
		right: 24
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<PSVitaID>(2, 3, {
		up: 25,
		down: 26,
		left: 27,
		right: 28
	});
}
