package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for Switch's Left JoyCon controllers
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
enum abstract SwitchJoyconLeftID(Int) to Int
{
	#if flash
	var UP = 8;
	var LEFT = 9;
	var DOWN = 10;
	var RIGHT = 11;
	var SL = 12;
	var SR = 13;
	var ZL = 14;
	var L = 15;
	var MINUS = 17;
	var CAPTURE = 21;
	var LEFT_STICK_CLICK = 22;
	
	var LEFT_STICK_UP = 24;
	var LEFT_STICK_DOWN = 25;
	var LEFT_STICK_LEFT = 26;
	var LEFT_STICK_RIGHT = 27;
	#else
	var ZL = 4;
	var DOWN = 6;
	var RIGHT = 7;
	var LEFT = 8;
	var UP = 9;
	var L = 10;
	var MINUS = 12;
	var LEFT_STICK_CLICK = 13;
	var SL = 15;
	var SR = 16;
	var CAPTURE = 21;
	
	var LEFT_STICK_UP = 22;
	var LEFT_STICK_DOWN = 23;
	var LEFT_STICK_LEFT = 24;
	var LEFT_STICK_RIGHT = 25;
	#end
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<SwitchJoyconLeftID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	
}
