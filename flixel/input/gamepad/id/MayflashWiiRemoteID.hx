package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * WiiRemote hardware input ID's when using "Mode 3" of the MayFlash DolphinBar accessory
 *
 * @author larsiusprime
 */
class MayflashWiiRemoteID
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
	public static inline var REMOTE_ONE:Int = 0;
	public static inline var REMOTE_TWO:Int = 1;
	public static inline var REMOTE_A:Int = 2;
	public static inline var REMOTE_B:Int = 3;

	public static inline var REMOTE_MINUS:Int = 4;
	public static inline var REMOTE_PLUS:Int = 5;

	public static inline var REMOTE_HOME:Int = 11;

	// Nunchuk attachment:
	public static inline var NUNCHUK_Z:Int = 6;
	public static inline var NUNCHUK_C:Int = 7;

	public static inline var NUNCHUK_DPAD_DOWN:Int = 12;
	public static inline var NUNCHUK_DPAD_UP:Int = 13;
	public static inline var NUNCHUK_DPAD_LEFT:Int = 14;
	public static inline var NUNCHUK_DPAD_RIGHT:Int = 15;

	public static inline var NUNCHUK_MINUS:Int = 4;
	public static inline var NUNCHUK_PLUS:Int = 5;

	public static inline var NUNCHUK_HOME:Int = 11;

	public static inline var NUNCHUK_ONE:Int = 0;
	public static inline var NUNCHUK_TWO:Int = 1;
	public static inline var NUNCHUK_A:Int = 2;
	public static inline var NUNCHUK_B:Int = 3;

	// classic controller attachment:
	public static inline var CLASSIC_Y:Int = 0; // Identical to WiiRemote 1
	public static inline var CLASSIC_X:Int = 1; // Identical to WiiRemote 2
	public static inline var CLASSIC_B:Int = 2; // Identical to WiiRemote A
	public static inline var CLASSIC_A:Int = 3; // Identical to WiiRemote B

	public static inline var CLASSIC_L:Int = 4; // Identical to MINUS and PLUS
	public static inline var CLASSIC_R:Int = 5;
	public static inline var CLASSIC_ZL:Int = 6; // Identical to C and Z
	public static inline var CLASSIC_ZR:Int = 7;

	public static inline var CLASSIC_SELECT:Int = 8;
	public static inline var CLASSIC_START:Int = 9;

	public static inline var CLASSIC_HOME:Int = 11;

	public static inline var CLASSIC_DPAD_DOWN:Int = 12;
	public static inline var CLASSIC_DPAD_UP:Int = 13;
	public static inline var CLASSIC_DPAD_LEFT:Int = 14;
	public static inline var CLASSIC_DPAD_RIGHT:Int = 15;

	public static inline var CLASSIC_ONE:Int = -1;
	public static inline var CLASSIC_TWO:Int = -1;

	// Axis indices
	public static inline var NUNCHUK_POINTER_X:Int = 2;
	public static inline var NUNCHUK_POINTER_Y:Int = 3;

	// Yes, the WiiRemote DPAD is treated as ANALOG for some reason...so we have to pass in some "fake" ID's to get simulated digital inputs
	public static var REMOTE_DPAD(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: REMOTE_DPAD_UP,
		down: REMOTE_DPAD_DOWN,
		left: REMOTE_DPAD_LEFT,
		right: REMOTE_DPAD_RIGHT,
		threshold: 0.5,
		mode: ONLY_DIGITAL
	});

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	}); // the nunchuk only has the "left" analog stick
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 30,
		down: 31,
		left: 32,
		right: 33
	}); // the classic controller has both the "left" and "right" analog sticks

	// these aren't real axes, they're simulated when the right digital buttons are pushed
	public static inline var LEFT_TRIGGER_FAKE:Int = 4;
	public static inline var RIGHT_TRIGGER_FAKE:Int = 5;

	// "fake" IDs
	public static inline var REMOTE_DPAD_UP:Int = 22;
	public static inline var REMOTE_DPAD_DOWN:Int = 23;
	public static inline var REMOTE_DPAD_LEFT:Int = 24;
	public static inline var REMOTE_DPAD_RIGHT:Int = 25;
	#else // gamepad API
	// Standard Wii Remote inputs:
	public static inline var REMOTE_ONE:Int = 8;
	public static inline var REMOTE_TWO:Int = 9;
	public static inline var REMOTE_A:Int = 10;
	public static inline var REMOTE_B:Int = 11;

	public static inline var REMOTE_MINUS:Int = 12;
	public static inline var REMOTE_PLUS:Int = 13;

	public static inline var REMOTE_HOME:Int = 19;

	// Nunchuk attachment:
	public static inline var NUNCHUK_Z:Int = 14;
	public static inline var NUNCHUK_C:Int = 15;

	public static inline var NUNCHUK_DPAD_UP:Int = 4;
	public static inline var NUNCHUK_DPAD_DOWN:Int = 5;
	public static inline var NUNCHUK_DPAD_LEFT:Int = 6;
	public static inline var NUNCHUK_DPAD_RIGHT:Int = 7;

	public static inline var NUNCHUK_MINUS:Int = 12;
	public static inline var NUNCHUK_PLUS:Int = 13;

	public static inline var NUNCHUK_HOME:Int = 19;

	public static inline var NUNCHUK_A:Int = 10;
	public static inline var NUNCHUK_B:Int = 11;

	public static inline var NUNCHUK_ONE:Int = 8;
	public static inline var NUNCHUK_TWO:Int = 9;

	// classic controller attachment:
	public static inline var CLASSIC_Y:Int = 8;
	public static inline var CLASSIC_X:Int = 9;
	public static inline var CLASSIC_B:Int = 10;
	public static inline var CLASSIC_A:Int = 11;

	public static inline var CLASSIC_L:Int = 12;
	public static inline var CLASSIC_R:Int = 13;
	public static inline var CLASSIC_ZL:Int = 14;
	public static inline var CLASSIC_ZR:Int = 15;

	public static inline var CLASSIC_SELECT:Int = 16;
	public static inline var CLASSIC_START:Int = 17;

	public static inline var CLASSIC_HOME:Int = 19;

	public static inline var CLASSIC_ONE:Int = -1;
	public static inline var CLASSIC_TWO:Int = -1;

	// (input "10" does not seem to be defined)
	public static inline var CLASSIC_DPAD_UP:Int = 4;
	public static inline var CLASSIC_DPAD_DOWN:Int = 5;
	public static inline var CLASSIC_DPAD_LEFT:Int = 6;
	public static inline var CLASSIC_DPAD_RIGHT:Int = 7;

	// Axis indices
	public static inline var NUNCHUK_POINTER_X:Int = 2;
	public static inline var NUNCHUK_POINTER_Y:Int = 3;

	// Yes, the WiiRemote DPAD is treated as ANALOG for some reason...so we have to pass in some "fake" ID's to get simulated digital inputs
	public static var REMOTE_DPAD(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: REMOTE_DPAD_UP,
		down: REMOTE_DPAD_DOWN,
		left: REMOTE_DPAD_LEFT,
		right: REMOTE_DPAD_RIGHT,
		threshold: 0.5,
		mode: ONLY_DIGITAL
	});

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	}); // the nunchuk only has the "left" analog stick
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 26,
		down: 27,
		left: 28,
		right: 29
	}); // the classic controller has both the "left" and "right" analog sticks

	// these aren't real axes, they're simulated when the right digital buttons are pushed
	public static inline var LEFT_TRIGGER_FAKE:Int = 4;
	public static inline var RIGHT_TRIGGER_FAKE:Int = 5;

	// "fake" IDs
	public static inline var REMOTE_DPAD_UP:Int = 22;
	public static inline var REMOTE_DPAD_DOWN:Int = 23;
	public static inline var REMOTE_DPAD_LEFT:Int = 24;
	public static inline var REMOTE_DPAD_RIGHT:Int = 25;
	#end
}
