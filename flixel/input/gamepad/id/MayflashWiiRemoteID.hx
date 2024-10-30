package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * WiiRemote hardware input ID's when using "Mode 3" of the MayFlash DolphinBar accessory
 *
 * @author larsiusprime
 */
enum abstract MayflashWiiRemoteID(Int) to Int
{
	/**
	 * Things to add:
	 * - Accelerometer (in both remote and nunchuk)
	 * - Gyroscope (in Motion-Plus version only)
	 * - IR camera (position tracking)
	 * - Rumble
	 * - Speaker
	 */
	#if FLX_JOYSTICK_API
	// Standard Wii Remote inputs:
	var REMOTE_ONE = 0;
	var REMOTE_TWO = 1;
	var REMOTE_A = 2;
	var REMOTE_B = 3;

	var REMOTE_MINUS = 4;
	var REMOTE_PLUS = 5;

	var REMOTE_HOME = 11;

	// Nunchuk attachment:
	var NUNCHUK_Z = 6;
	var NUNCHUK_C = 7;

	var NUNCHUK_DPAD_DOWN = 12;
	var NUNCHUK_DPAD_UP = 13;
	var NUNCHUK_DPAD_LEFT = 14;
	var NUNCHUK_DPAD_RIGHT = 15;

	var NUNCHUK_MINUS = 4;
	var NUNCHUK_PLUS = 5;

	var NUNCHUK_HOME = 11;

	var NUNCHUK_ONE = 0;
	var NUNCHUK_TWO = 1;
	var NUNCHUK_A = 2;
	var NUNCHUK_B = 3;

	// classic controller attachment:
	var CLASSIC_Y = 0; // Identical to WiiRemote 1
	var CLASSIC_X = 1; // Identical to WiiRemote 2
	var CLASSIC_B = 2; // Identical to WiiRemote A
	var CLASSIC_A = 3; // Identical to WiiRemote B

	var CLASSIC_L = 4; // Identical to MINUS and PLUS
	var CLASSIC_R = 5;
	var CLASSIC_ZL = 6; // Identical to C and Z
	var CLASSIC_ZR = 7;

	var CLASSIC_SELECT = 8;
	var CLASSIC_START = 9;

	var CLASSIC_HOME = 11;

	var CLASSIC_DPAD_DOWN = 12;
	var CLASSIC_DPAD_UP = 13;
	var CLASSIC_DPAD_LEFT = 14;
	var CLASSIC_DPAD_RIGHT = 15;

	var CLASSIC_ONE = -1;
	var CLASSIC_TWO = -1;

	// Axis indices
	var NUNCHUK_POINTER_X = 2;
	var NUNCHUK_POINTER_Y = 3;

	// Yes, the WiiRemote DPAD is treated as ANALOG for some reason...so we have to pass in some "fake" ID's to get simulated digital inputs
	public static var REMOTE_DPAD(default, null) = new FlxTypedGamepadAnalogStick<MayflashWiiRemoteID>(0, 1, {
		up: REMOTE_DPAD_UP,
		down: REMOTE_DPAD_DOWN,
		left: REMOTE_DPAD_LEFT,
		right: REMOTE_DPAD_RIGHT,
		threshold: 0.5,
		mode: ONLY_DIGITAL
	});

	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<MayflashWiiRemoteID>(0, 1, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	}); // the nunchuk only has the "left" analog stick
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<MayflashWiiRemoteID>(2, 3, {
		up: 30,
		down: 31,
		left: 32,
		right: 33
	}); // the classic controller has both the "left" and "right" analog sticks

	// these aren't real axes, they're simulated when the right digital buttons are pushed
	var LEFT_TRIGGER_FAKE = 4;
	var RIGHT_TRIGGER_FAKE = 5;

	// "fake" IDs
	var REMOTE_DPAD_UP = 22;
	var REMOTE_DPAD_DOWN = 23;
	var REMOTE_DPAD_LEFT = 24;
	var REMOTE_DPAD_RIGHT = 25;
	#else // gamepad API
	// Standard Wii Remote inputs:
	var REMOTE_ONE = 8;
	var REMOTE_TWO = 9;
	var REMOTE_A = 10;
	var REMOTE_B = 11;

	var REMOTE_MINUS = 12;
	var REMOTE_PLUS = 13;

	var REMOTE_HOME = 19;

	// Nunchuk attachment:
	var NUNCHUK_Z = 14;
	var NUNCHUK_C = 15;

	var NUNCHUK_DPAD_UP = 4;
	var NUNCHUK_DPAD_DOWN = 5;
	var NUNCHUK_DPAD_LEFT = 6;
	var NUNCHUK_DPAD_RIGHT = 7;

	var NUNCHUK_MINUS = 12;
	var NUNCHUK_PLUS = 13;

	var NUNCHUK_HOME = 19;

	var NUNCHUK_A = 10;
	var NUNCHUK_B = 11;

	var NUNCHUK_ONE = 8;
	var NUNCHUK_TWO = 9;

	// classic controller attachment:
	var CLASSIC_Y = 8;
	var CLASSIC_X = 9;
	var CLASSIC_B = 10;
	var CLASSIC_A = 11;

	var CLASSIC_L = 12;
	var CLASSIC_R = 13;
	var CLASSIC_ZL = 14;
	var CLASSIC_ZR = 15;

	var CLASSIC_SELECT = 16;
	var CLASSIC_START = 17;

	var CLASSIC_HOME = 19;

	var CLASSIC_ONE = -1;
	var CLASSIC_TWO = -1;

	// (input "10" does not seem to be defined)
	var CLASSIC_DPAD_UP = 4;
	var CLASSIC_DPAD_DOWN = 5;
	var CLASSIC_DPAD_LEFT = 6;
	var CLASSIC_DPAD_RIGHT = 7;

	// Axis indices
	var NUNCHUK_POINTER_X = 2;
	var NUNCHUK_POINTER_Y = 3;

	// Yes, the WiiRemote DPAD is treated as ANALOG for some reason...so we have to pass in some "fake" ID's to get simulated digital inputs
	public static var REMOTE_DPAD(default, null) = new FlxTypedGamepadAnalogStick<MayflashWiiRemoteID>
	(0, 1, {
		up: (cast REMOTE_DPAD_UP:Int),
		down: (cast REMOTE_DPAD_DOWN:Int),
		left: (cast REMOTE_DPAD_LEFT:Int),
		right: (cast REMOTE_DPAD_RIGHT:Int),
		threshold: 0.5,
		mode: ONLY_DIGITAL
	});

	public static var LEFT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<MayflashWiiRemoteID>(0, 1, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	}); // the nunchuk only has the "left" analog stick
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxTypedGamepadAnalogStick<MayflashWiiRemoteID>(2, 3, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	}); // the classic controller has both the "left" and "right" analog sticks

	// these aren't real axes, they're simulated when the right digital buttons are pushed
	var LEFT_TRIGGER_FAKE = 4;
	var RIGHT_TRIGGER_FAKE = 5;

	// "fake" IDs
	var REMOTE_DPAD_UP = 22;
	var REMOTE_DPAD_DOWN = 23;
	var REMOTE_DPAD_LEFT = 24;
	var REMOTE_DPAD_RIGHT = 25;
	#end
}
