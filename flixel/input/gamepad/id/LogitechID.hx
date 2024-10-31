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
	
	var LEFT_STICK_UP = 24;
	var LEFT_STICK_DOWN = 25;
	var LEFT_STICK_LEFT = 26;
	var LEFT_STICK_RIGHT = 27;
	
	var RIGHT_STICK_UP = 28;
	var RIGHT_STICK_DOWN = 29;
	var RIGHT_STICK_LEFT = 30;
	var RIGHT_STICK_RIGHT = 31;
		
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<LogitechID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<LogitechID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
}
