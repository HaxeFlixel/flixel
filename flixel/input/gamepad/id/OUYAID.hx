package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for OUYA controllers
 */
enum abstract OUYAID(Int) to Int
{
	var O = 6;
	var U = 8;
	var Y = 9;
	var A = 7;
	var LB = 15;
	var RB = 16;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;
	var HOME = 0x01000012;	// Not sure if press HOME is taken in account on OUYA
	var LEFT_TRIGGER = 4;
	var RIGHT_TRIGGER = 5;

	// "fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;
	var DPAD_DOWN = 18;
	var DPAD_UP = 17;

	// If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<OUYAID>(0, 1, {
		up: 23,
		down: 24,
		left: 25,
		right: 26
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<OUYAID>(2, 3, {
		up: 27,
		down: 28,
		left: 29,
		right: 30
	});
}
