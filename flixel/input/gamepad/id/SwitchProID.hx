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
	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchProID>(0, 1, {
		up: 24,
		down: 25,
		left: 26,
		right: 27
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchProID>(2, 3, {
		up: 28,
		down: 29,
		left: 30,
		right: 31
	});
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
	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchProID>(0, 1, {
		up: 22,
		down: 23,
		left: 24,
		right: 25
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchProID>(2, 3, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	});
	#end
	
}
