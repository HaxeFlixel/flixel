package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for Logitech controllers (key codes based on Cordless Rumblepad 2)
 */
enum abstract LogitechID(Int) to Int
{
	#if flash
	var ONE = 8;
	var TWO = 9;
	var THREE = 10;
	var FOUR = 11;
	var FIVE = 12;
	var SIX = 13;
	var SEVEN = 14;
	var EIGHT = 15;
	var NINE = 16;
	var TEN = 17;
	var LEFT_STICK_CLICK = 18;
	var RIGHT_STICK_CLICK = 19;

	var DPAD_UP = 4;
	var DPAD_DOWN = 5;
	var DPAD_LEFT = 6;
	var DPAD_RIGHT = 7;

	// TODO: Someone needs to look this up and define it! (NOTE: not all logitech controllers have this)
	var LOGITECH = -1;
	#else // native and html5
	var ONE = 0;
	var TWO = 1;
	var THREE = 2;
	var FOUR = 3;
	var FIVE = 4;
	var SIX = 5;
	var SEVEN = 6;
	var EIGHT = 7;
	var NINE = 8;
	var TEN = 9;
	var LEFT_STICK_CLICK = 10;
	var RIGHT_STICK_CLICK = 11;

	// "fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	var DPAD_UP = 16;
	var DPAD_DOWN = 17;
	var DPAD_LEFT = 18;
	var DPAD_RIGHT = 19;

	// TODO: Someone needs to look this up and define it! (NOTE: not all logitech controllers have this)
	var LOGITECH = -5;
	#end

	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<LogitechID>(0, 1, {
		up: 24,
		down: 25,
		left: 26,
		right: 27
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<LogitechID>(2, 3, {
		up: 28,
		down: 29,
		left: 30,
		right: 31
	});
}
