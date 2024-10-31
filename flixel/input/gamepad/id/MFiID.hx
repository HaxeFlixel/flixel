package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for MFi controllers
 */
enum abstract MFiID(Int) to Int
{
	var LEFT_TRIGGER = 4;
	var RIGHT_TRIGGER = 5;
	
	var A = 6;
	var B = 7;
	var X = 8;
	var Y = 9;
	var LB = 15;
	var RB = 16;
	var BACK = 10;
	var GUIDE = 11;
	var START = 12;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;
	
	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;

	var LEFT_STICK_UP = 21;
	var LEFT_STICK_DOWN = 22;
	var LEFT_STICK_LEFT = 23;
	var LEFT_STICK_RIGHT = 24;
		
	var RIGHT_STICK_UP = 25;
	var RIGHT_STICK_DOWN = 26;
	var RIGHT_STICK_LEFT = 27;
	var RIGHT_STICK_RIGHT = 28;
	
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<MFiID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<MFiID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
}
