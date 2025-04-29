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
enum abstract SwitchProID(Int) to Int
{
	#if flash
	var DPAD_UP = 4;
	var DPAD_DOWN = 5;
	var DPAD_LEFT = 6;
	var DPAD_RIGHT = 7;
	var A = 8;
	var B = 9;
	var X = 10;
	var Y = 11;
	var L = 12;
	var R = 13;
	var ZL = 14;
	var ZR = 15;
	var MINUS = 16;
	var PLUS = 17;
	var HOME = 20;
	var CAPTURE = 21;
	var LEFT_STICK_CLICK = 22;
	var RIGHT_STICK_CLICK = 23;
	
	var LEFT_STICK_UP = 24;
	var LEFT_STICK_DOWN = 25;
	var LEFT_STICK_LEFT = 26;
	var LEFT_STICK_RIGHT = 27;
	
	var RIGHT_STICK_UP = 28;
	var RIGHT_STICK_DOWN = 29;
	var RIGHT_STICK_LEFT = 30;
	var RIGHT_STICK_RIGHT = 31;
	
	#else
	var ZL = 4;
	var ZR = 5;
	var B = 6;
	var A = 7;
	var Y = 8;
	var X = 9;
	var MINUS = 10;
	var HOME = 11;
	var PLUS = 12;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;
	var L = 15;
	var R = 16;
	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;
	var CAPTURE = 21;
	
	var LEFT_STICK_UP = 22;
	var LEFT_STICK_DOWN = 23;
	var LEFT_STICK_LEFT = 24;
	var LEFT_STICK_RIGHT = 25;
	
	var RIGHT_STICK_UP = 26;
	var RIGHT_STICK_DOWN = 27;
	var RIGHT_STICK_LEFT = 28;
	var RIGHT_STICK_RIGHT = 29;
	#end
	
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<SwitchProID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<SwitchProID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
	
}
