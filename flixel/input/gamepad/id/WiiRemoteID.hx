package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * WiiRemote hardware input ID's when using the device directly
 * Hardware ID's: "Nintendo RVL-CNT-01-TR" and "Nintendo RVL-CNT-01" -- the latter does not have the Motion-Plus attachment
 *
 * NOTE: On Windows this requires the HID-Wiimote driver by Julian Löhr, available here:
 * https://github.com/jloehr/HID-Wiimote
 *
 * @author larsiusprime
 */
enum abstract WiiRemoteID(Int) to Int
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
	var REMOTE_PLUS = 4;
	var REMOTE_MINUS = 5;
	var REMOTE_HOME = 6;

	// Nunchuk attachment:
	var NUNCHUK_A = 0;
	var NUNCHUK_B = 1;
	var NUNCHUK_C = 2;
	var NUNCHUK_Z = 3;
	var NUNCHUK_ONE = 4;
	var NUNCHUK_TWO = 5;
	var NUNCHUK_PLUS = 6;
	var NUNCHUK_MINUS = 7;
	var NUNCHUK_HOME = 8;

	// classic controller attachment:
	var CLASSIC_A = 0;
	var CLASSIC_B = 1;
	var CLASSIC_Y = 2;
	var CLASSIC_X = 3;
	var CLASSIC_L = 4;
	var CLASSIC_R = 5;
	var CLASSIC_ZL = 6;
	var CLASSIC_ZR = 7;
	var CLASSIC_START = 8;
	var CLASSIC_SELECT = 9;
	var CLASSIC_HOME = 10;
	var CLASSIC_ONE = 11;
	var CLASSIC_TWO = 12;

	var REMOTE_TILT_PITCH = 2;
	var REMOTE_TILT_ROLL = 3;

	var NUNCHUK_TILT_PITCH = 3;
	var NUNCHUK_TILT_ROLL = 2;

	var REMOTE_NULL_AXIS = 4;
	var NUNCHUK_NULL_AXIS = 4;

	var LEFT_STICK_UP = 32;
	var LEFT_STICK_DOWN = 33;
	var LEFT_STICK_LEFT = 34;
	var LEFT_STICK_RIGHT = 35;
	
	var RIGHT_STICK_UP = 36;
	var RIGHT_STICK_DOWN = 37;
	var RIGHT_STICK_LEFT = 38;
	var RIGHT_STICK_RIGHT = 39;
	
	// these aren't real axes, they're simulated when the right digital buttons are pushed
	var LEFT_TRIGGER_FAKE = 4;
	var RIGHT_TRIGGER_FAKE = 5;

	// "fake" ID's
	var REMOTE_DPAD_UP = 14;
	var REMOTE_DPAD_DOWN = 15;
	var REMOTE_DPAD_LEFT = 16;
	var REMOTE_DPAD_RIGHT = 17;

	var REMOTE_DPAD_X = 18;
	var REMOTE_DPAD_Y = 19;

	var CLASSIC_DPAD_DOWN = 24;
	var CLASSIC_DPAD_UP = 25;
	var CLASSIC_DPAD_LEFT = 26;
	var CLASSIC_DPAD_RIGHT = 27;

	var NUNCHUK_DPAD_DOWN = 28;
	var NUNCHUK_DPAD_UP = 29;
	var NUNCHUK_DPAD_LEFT = 30;
	var NUNCHUK_DPAD_RIGHT = 31;
	#else // gamepad API
	// Standard Wii Remote inputs:
	var REMOTE_ONE = 9;
	var REMOTE_TWO = 10;
	var REMOTE_A = 11;
	var REMOTE_B = 12;
	var REMOTE_PLUS = 13;
	var REMOTE_MINUS = 14;
	var REMOTE_HOME = 15;

	// Nunchuk attachment:
	var NUNCHUK_A = 9;
	var NUNCHUK_B = 10;
	var NUNCHUK_C = 11;
	var NUNCHUK_Z = 12;
	var NUNCHUK_ONE = 13;
	var NUNCHUK_TWO = 14;
	var NUNCHUK_PLUS = 15;
	var NUNCHUK_MINUS = 16;
	var NUNCHUK_HOME = 17;

	var NUNCHUK_DPAD_UP = 5;
	var NUNCHUK_DPAD_DOWN = 6;
	var NUNCHUK_DPAD_LEFT = 7;
	var NUNCHUK_DPAD_RIGHT = 8;

	// classic controller attachment:
	var CLASSIC_A = 9;
	var CLASSIC_B = 10;
	var CLASSIC_Y = 11;
	var CLASSIC_X = 12;
	var CLASSIC_L = 13;
	var CLASSIC_R = 14;
	var CLASSIC_ZL = 15;
	var CLASSIC_ZR = 16;
	var CLASSIC_START = 17;
	var CLASSIC_SELECT = 18;
	var CLASSIC_HOME = 19;
	var CLASSIC_ONE = 20;
	var CLASSIC_TWO = 21;

	var CLASSIC_DPAD_UP = 5;
	var CLASSIC_DPAD_DOWN = 6;
	var CLASSIC_DPAD_LEFT = 7;
	var CLASSIC_DPAD_RIGHT = 8;

	var REMOTE_TILT_PITCH = 2;
	var REMOTE_TILT_ROLL = 3;

	var NUNCHUK_TILT_PITCH = 3;
	var NUNCHUK_TILT_ROLL = 2;

	var REMOTE_NULL_AXIS = 4;
	var NUNCHUK_NULL_AXIS = 4;

	var LEFT_STICK_UP = 28;
	var LEFT_STICK_DOWN = 29;
	var LEFT_STICK_LEFT = 30;
	var LEFT_STICK_RIGHT = 31;
	
	var RIGHT_STICK_UP = 32;
	var RIGHT_STICK_DOWN = 33;
	var RIGHT_STICK_LEFT = 34;
	var RIGHT_STICK_RIGHT = 35;
	
	// these aren't real axes, they're simulated when the right digital buttons are pushed
	var LEFT_TRIGGER_FAKE = 4;
	var RIGHT_TRIGGER_FAKE = 5;

	// "fake" ID's
	var REMOTE_DPAD_UP = 22;
	var REMOTE_DPAD_DOWN = 23;
	var REMOTE_DPAD_LEFT = 24;
	var REMOTE_DPAD_RIGHT = 25;

	var REMOTE_DPAD_X = 26;
	var REMOTE_DPAD_Y = 27;
	#end
	
	// Yes, the WiiRemote DPAD is treated as ANALOG for some reason...
	// so we have to pass in some "fake" ID's to get simulated digital inputs
	public static final REMOTE_DPAD = new FlxTypedGamepadAnalogStick<WiiRemoteID>(0, 1, {
		up: REMOTE_DPAD_UP,
		down: REMOTE_DPAD_DOWN,
		left: REMOTE_DPAD_LEFT,
		right: REMOTE_DPAD_RIGHT,
		threshold: 0.5,
		mode: ONLY_DIGITAL
	});
	
	/**
	 * the nunchuk only has the "left" analog stick
	 */
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<WiiRemoteID>(0, 1, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});

	/**
	 * the classic controller has both the "left" and "right" analog sticks
	 */
	public static final RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<WiiRemoteID>(2, 3, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});

}
