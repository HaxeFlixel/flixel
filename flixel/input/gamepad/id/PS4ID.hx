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
enum abstract PS4ID(Int) to Int
{
	#if flash
	var SQUARE = 10;
	var X = 11;
	var CIRCLE = 12;
	var TRIANGLE = 13;
	var L1 = 14;
	var R1 = 15;
	var L2 = 16;
	var R2 = 17;
	var SHARE = 18;
	var OPTIONS = 19;
	var LEFT_STICK_CLICK = 20;
	var RIGHT_STICK_CLICK = 21;
	var PS = 22;
	var TOUCHPAD_CLICK = 23;
	
	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 2;
	static inline final RIGHT_Y = 5;
	
	var LEFT_STICK_UP = 24;
	var LEFT_STICK_DOWN = 25;
	var LEFT_STICK_LEFT = 26;
	var LEFT_STICK_RIGHT = 27;
	
	var RIGHT_STICK_UP = 28;
	var RIGHT_STICK_DOWN = 29;
	var RIGHT_STICK_LEFT = 30;
	var RIGHT_STICK_RIGHT = 31;
	
	var DPAD_UP = 6;
	var DPAD_DOWN = 7;
	var DPAD_LEFT = 8;
	var DPAD_RIGHT = 9;
	#elseif FLX_GAMEINPUT_API
	// #if (html5 || windows || mac || linux)
	var X = 6;
	var CIRCLE = 7;
	var SQUARE = 8;
	var TRIANGLE = 9;
	var PS = 11;
	var OPTIONS = 12;
	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;
	var L1 = 15;
	var R1 = 16;

	#if ps4
	var TOUCHPAD_CLICK = 10; // On an actual PS4, share is reserved by the system, and the touchpad click can serve more or less as a replacement for the "back/select" button
	
	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 2;
	static inline final RIGHT_Y = 3;
	
	var LEFT_STICK_UP = 32;
	var LEFT_STICK_DOWN = 33;
	var LEFT_STICK_LEFT = 34;
	var LEFT_STICK_RIGHT = 35;
	
	var RIGHT_STICK_UP = 36;
	var RIGHT_STICK_DOWN = 37;
	var RIGHT_STICK_LEFT = 38;
	var RIGHT_STICK_RIGHT = 39;
	
	var SHARE = 40; // Not accessible on an actual PS4, just setting it to a dummy value
	#else
	var SHARE = 10; // This is only accessible when not using an actual Playstation 4, otherwise it's reserved by the system

	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 2;
	static inline final RIGHT_Y = 3;
	
	var LEFT_STICK_UP = 22;
	var LEFT_STICK_DOWN = 23;
	var LEFT_STICK_LEFT = 24;
	var LEFT_STICK_RIGHT = 25;
	
	var RIGHT_STICK_UP = 26;
	var RIGHT_STICK_DOWN = 27;
	var RIGHT_STICK_LEFT = 28;
	var RIGHT_STICK_RIGHT = 29;
	
	var TOUCHPAD_CLICK = 30; // I don't believe this is normally accessible on PC, just setting it to a dummy value
	#end
	var L2 = 4;
	var R2 = 5;

	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;

	// On linux the drivers we're testing with just make the PS4 controller look like an XInput device,
	// So strictly speaking these ID's will probably not be used, but the compiler needs something or
	// else it will not compile on Linux
	#else // "legacy"
	var SQUARE = 0;
	var X = 1;
	var CIRCLE = 2;
	var TRIANGLE = 3;
	var L1 = 4;
	var R1 = 5;

	var SHARE = 8;
	var OPTIONS = 9;
	var LEFT_STICK_CLICK = 10;
	var RIGHT_STICK_CLICK = 11;
	var PS = 12;
	var TOUCHPAD_CLICK = 13;

	var L2 = 3;
	var R2 = 4;

	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 2;
	static inline final RIGHT_Y = 5;
	
	var LEFT_STICK_UP = 27;
	var LEFT_STICK_DOWN = 28;
	var LEFT_STICK_LEFT = 29;
	var LEFT_STICK_RIGHT = 30;
	
	var RIGHT_STICK_UP = 31;
	var RIGHT_STICK_DOWN = 32;
	var RIGHT_STICK_LEFT = 33;
	var RIGHT_STICK_RIGHT = 34;
	
	// "fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	var DPAD_LEFT = 15;
	var DPAD_RIGHT = 16;
	var DPAD_DOWN = 17;
	var DPAD_UP = 18;
	#end
	
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<PS4ID>(LEFT_X, LEFT_Y, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<PS4ID>(RIGHT_X, RIGHT_Y, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
}
