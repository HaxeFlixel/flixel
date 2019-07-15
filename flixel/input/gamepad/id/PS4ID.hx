package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
	* IDs for PlayStation 4 controllers
	*
	*-------
	* NOTES
	*-------
	*
	* WINDOWS: seems to work fine without any special drivers on Windows 10 (and I seem to recall the same on Windows 7).
	* DS4Windows is the popular 3rd-party utility here, but it will make the PS4 controller look like a 360 controller, which
	* means that it will be indistinguishable from an XInput device to flixel (DS4Windows: http://ds4windows.com).
	*
	* LINUX: the PS4 controller will be detected as an XInput device when using xpad (see notes in XInputID.hx)
	*
	* MAC: the PS4 controller seemed to work perfectly without anything special installed, and was not detected in the 360Controller
	* control panel, so it might just work right out of the box!
 */
class PS4ID
{
	#if flash
	public static inline var SQUARE:Int = 10;
	public static inline var X:Int = 11;
	public static inline var CIRCLE:Int = 12;
	public static inline var TRIANGLE:Int = 13;
	public static inline var L1:Int = 14;
	public static inline var R1:Int = 15;
	public static inline var L2:Int = 16;
	public static inline var R2:Int = 17;
	public static inline var SHARE:Int = 18;
	public static inline var OPTIONS:Int = 19;
	public static inline var LEFT_STICK_CLICK:Int = 20;
	public static inline var RIGHT_STICK_CLICK:Int = 21;
	public static inline var PS:Int = 22;
	public static inline var TOUCHPAD_CLICK:Int = 23;

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 24,
		down: 25,
		left: 26,
		right: 27
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 5, {
		up: 28,
		down: 29,
		left: 30,
		right: 31
	});

	public static inline var DPAD_UP:Int = 6;
	public static inline var DPAD_DOWN:Int = 7;
	public static inline var DPAD_LEFT:Int = 8;
	public static inline var DPAD_RIGHT:Int = 9;
	#elseif FLX_GAMEINPUT_API
	// #if (html5 || windows || mac || linux)
	public static inline var X:Int = 6;
	public static inline var CIRCLE:Int = 7;
	public static inline var SQUARE:Int = 8;
	public static inline var TRIANGLE:Int = 9;
	public static inline var PS:Int = 11;
	public static inline var OPTIONS:Int = 12;
	public static inline var LEFT_STICK_CLICK:Int = 13;
	public static inline var RIGHT_STICK_CLICK:Int = 14;
	public static inline var L1:Int = 15;
	public static inline var R1:Int = 16;

	#if ps4
	public static inline var TOUCHPAD_CLICK:Int = 10; // On an actual PS4, share is reserved by the system, and the touchpad click can serve more or less as a replacement for the "back/select" button

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 32,
		down: 33,
		left: 34,
		right: 35
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 36,
		down: 37,
		left: 38,
		right: 39
	});

	public static inline var SHARE:Int = 40; // Not accessible on an actual PS4, just setting it to a dummy value
	#else
	public static inline var SHARE:Int = 10; // This is only accessible when not using an actual Playstation 4, otherwise it's reserved by the system

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 22,
		down: 23,
		left: 24,
		right: 25
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	});

	public static inline var TOUCHPAD_CLICK:Int = 30; // I don't believe this is normally accessible on PC, just setting it to a dummy value

	#end
	public static inline var L2:Int = 4;
	public static inline var R2:Int = 5;

	public static inline var DPAD_UP:Int = 17;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;

	// On linux the drivers we're testing with just make the PS4 controller look like an XInput device,
	// So strictly speaking these ID's will probably not be used, but the compiler needs something or
	// else it will not compile on Linux
	#else // "legacy"
	public static inline var SQUARE:Int = 0;
	public static inline var X:Int = 1;
	public static inline var CIRCLE:Int = 2;
	public static inline var TRIANGLE:Int = 3;
	public static inline var L1:Int = 4;
	public static inline var R1:Int = 5;

	public static inline var SHARE:Int = 8;
	public static inline var OPTIONS:Int = 9;
	public static inline var LEFT_STICK_CLICK:Int = 10;
	public static inline var RIGHT_STICK_CLICK:Int = 11;
	public static inline var PS:Int = 12;
	public static inline var TOUCHPAD_CLICK:Int = 13;

	public static inline var L2:Int = 3;
	public static inline var R2:Int = 4;

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 27,
		down: 28,
		left: 29,
		right: 30
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 5, {
		up: 31,
		down: 32,
		left: 33,
		right: 34
	});

	// "fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	public static inline var DPAD_LEFT:Int = 15;
	public static inline var DPAD_RIGHT:Int = 16;
	public static inline var DPAD_DOWN:Int = 17;
	public static inline var DPAD_UP:Int = 18;
	#end
}
