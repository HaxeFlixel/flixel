package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for Switch's Right JoyCon controllers
 *
 *-------
 * NOTES
 *-------
 *
 * WINDOWS: untested.
 *
 * LINUX: untested.
 *
 * MAC: Worked on html out of box for me when connected via microUSB cable or Bluetooth.
 * Flash and neko couldn't detect the controller via bluetooth,
 * which is weird because The pro worked wirelessly.
 * 
 * @since 4.8.0
 */

enum abstract SwitchJoyconRightID(Int) to Int
{
	#if flash
	var A = 8;
	var B = 9;
	var X = 10;
	var Y = 11;
	var SL = 12;
	var SR = 13;
	var ZR = 15;
	var R = 16;
	var PLUS = 17;
	var HOME = 20;
	var CAPTURE = 21;
	var LEFT_STICK_CLICK = 22;
	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchJoyconRightID>(0, 1, {
		up: 24,
		down: 25,
		left: 26,
		right: 27
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchJoyconRightID>(2, 3, {
		up: 28,
		down: 29,
		left: 30,
		right: 31
	});
	#else
	var ZR = 5;
	var A = 6;
	var X = 7;
	var B = 8;
	var Y = 9;
	var R = 10;
	var HOME = 11;
	var PLUS = 12;
	var LEFT_STICK_CLICK = 13;
	var SL = 15;
	var SR = 16;
	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<SwitchJoyconRightID>(0, 1, {
		up: 22,
		down: 23,
		left: 24,
		right: 25
	});
	#end
	
}
