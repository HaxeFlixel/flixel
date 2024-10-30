package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for MFi controllers
 */
enum abstract MFiID(Int) to Int
{
	var A = 6;
	var B = 7;
	var X = 8;
	var Y = 9;
	var LB = 15;
	var RB = 16;
	var BACK = 10;
	var START = 12;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;

	var GUIDE = 11;

	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;

	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<MFiID>(0, 1, {
		up: 21,
		down: 22,
		left: 23,
		right: 24
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<MFiID>(2, 3, {
		up: 25,
		down: 26,
		left: 27,
		right: 28
	});

	var LEFT_TRIGGER = 4;
	var RIGHT_TRIGGER = 5;
}
