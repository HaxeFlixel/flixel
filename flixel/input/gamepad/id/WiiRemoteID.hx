package flixel.input.gamepad.id;
import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModelAttachment;
import flixel.input.gamepad.FlxGamepadInputID;

/**
 * WiiRemote hardware input ID's when using the device directly
 * Hardware ID's: "Nintendo RVL-CNT-01-TR" and "Nintendo RVL-CNT-01" -- the latter does not have the Motion-Plus attachment
 * 
 * NOTE: On Windows this requires the HID-Wiimote driver by Julian Löhr, available here:
 * https://github.com/jloehr/HID-Wiimote
 * 
 * @author larsiusprime
 */
class WiiRemoteID
{
	public static inline var SUPPORTS_MOTION = true;
	public static inline var SUPPORTS_POINTER = false;		//when Julian updates his driver, this can be set to "true"
	
	/*Things to add:
	
	- Accelerometer (in both remote and nunchuk)
	- Gyroscope (in Motion-Plus version only)
	- IR camera (position tracking)
	- Rumble
	- Speaker
	
	*/
	
#if !html5
	
	public static function checkForFakeAxis(ID:FlxGamepadInputID, attachment:FlxGamepadModelAttachment):Int
	{
		if (attachment == WiiNunchuk)
		{
			if (ID == LEFT_TRIGGER) return NUNCHUK_Z;
		}
		return -1;
	}
	
	public static function isAxisForMotion(ID:FlxGamepadInputID, attachment:FlxGamepadModelAttachment):Bool
	{
		if (attachment == None)
		{
			if (ID == REMOTE_TILT_PITCH  || ID == REMOTE_TILT_ROLL ) return true;
		}
		else if (attachment == WiiNunchuk)
		{
			if (ID == NUNCHUK_TILT_PITCH || ID == NUNCHUK_TILT_ROLL) return true;
		}
		return false;
	}
	
	public static inline function getFlipAxis(AxisID:Int, attachment:FlxGamepadModelAttachment):Int
	{
		if (AxisID == LEFT_TRIGGER_FAKE)
		{
			return -1;
		}
		return 1;
	}
	
	//Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
	public static function axisIndexToRawID(index:Int, attachment:FlxGamepadModelAttachment):Int
	{
		     if (attachment == None       && index == REMOTE_NULL_AXIS ) return -1;					//return null for this unused access so it doesn't overlap a button input
		else if (attachment == WiiNunchuk && index == NUNCHUK_NULL_AXIS) return -1;					//return null for this unused access so it doesn't overlap a button input
		
		if (attachment == WiiNunchuk || attachment == WiiClassicController)
		{
			     if (index == LEFT_ANALOG_STICK.x) return LEFT_ANALOG_STICK_FAKE_X;
			else if (index == LEFT_ANALOG_STICK.y) return LEFT_ANALOG_STICK_FAKE_Y;
		}
		else
		{
			     if (index == LEFT_ANALOG_STICK.x) return REMOTE_DPAD_X;
			else if (index == LEFT_ANALOG_STICK.y) return REMOTE_DPAD_Y;
		}
		
		     if (index == RIGHT_ANALOG_STICK.x) return RIGHT_ANALOG_STICK_FAKE_X;
		else if (index == RIGHT_ANALOG_STICK.y) return RIGHT_ANALOG_STICK_FAKE_Y;
		
		return index;
	}
	
	#if FLX_JOYSTICK_API
	
	//Standard Wii Remote inputs:
	public static inline var REMOTE_ONE:Int = 0;
	public static inline var REMOTE_TWO:Int = 1;
	public static inline var REMOTE_A:Int = 2;
	public static inline var REMOTE_B:Int = 3;
	public static inline var REMOTE_PLUS:Int = 4;
	public static inline var REMOTE_MINUS:Int = 5;
	public static inline var REMOTE_HOME:Int = 6;
	
	//Nunchuk attachment:
	public static inline var NUNCHUK_A:Int = 0;
	public static inline var NUNCHUK_B:Int = 1;
	public static inline var NUNCHUK_C:Int = 2;
	public static inline var NUNCHUK_Z:Int = 3;
	public static inline var NUNCHUK_ONE:Int = 4;
	public static inline var NUNCHUK_TWO:Int = 5;
	public static inline var NUNCHUK_PLUS:Int = 6;
	public static inline var NUNCHUK_MINUS:Int = 7;
	public static inline var NUNCHUK_HOME:Int = 8;
	
	//classic controller attachment:
	public static inline var CLASSIC_A:Int = 0;
	public static inline var CLASSIC_B:Int = 1;
	public static inline var CLASSIC_Y:Int = 2;
	public static inline var CLASSIC_X:Int = 3;
	public static inline var CLASSIC_L:Int = 4;
	public static inline var CLASSIC_R:Int = 5;
	public static inline var CLASSIC_ZL:Int = 6;
	public static inline var CLASSIC_ZR:Int = 7;
	public static inline var CLASSIC_START:Int = 8;
	public static inline var CLASSIC_SELECT:Int = 9;
	public static inline var CLASSIC_HOME:Int = 10;
	public static inline var CLASSIC_ONE:Int = 11;
	public static inline var CLASSIC_TWO:Int = 12;
	
	// Axis indices
	public static inline var REMOTE_TILT_PITCH:Int = 2;
	public static inline var REMOTE_TILT_ROLL:Int = 3;
	
	public static inline var NUNCHUK_TILT_PITCH:Int = 3;
	public static inline var NUNCHUK_TILT_ROLL:Int = 2;
	
	public static inline var REMOTE_NULL_AXIS:Int = 4;
	public static inline var NUNCHUK_NULL_AXIS:Int = 4;
	
	//Yes, the WiiRemote DPAD is treated as ANALOG for some reason...so we have to pass in some "fake" ID's to get simulated digital inputs
	public static var REMOTE_DPAD(default, null) = new FlxGamepadAnalogStick(0, 1, {
			up:REMOTE_DPAD_UP,
			down:REMOTE_DPAD_DOWN,
			left:REMOTE_DPAD_LEFT,
			right:REMOTE_DPAD_RIGHT,
			threshold:0.5,
			mode:OnlyDigital
		});
	
	public static var LEFT_ANALOG_STICK(default, null)  = new FlxGamepadAnalogStick(0, 1);	//the nunchuk only has the "left" analog stick
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);	//the classic controller has both the "left" and "right" analog sticks
	
	//these aren't real axes, they're simulated when the right digital buttons are pushed
	public static inline var LEFT_TRIGGER_FAKE:Int = 4;
	public static inline var RIGHT_TRIGGER_FAKE:Int = 5;
	
	//"fake" ID's
	
	public static inline var REMOTE_DPAD_UP:Int = 14;
	public static inline var REMOTE_DPAD_DOWN:Int = 15;
	public static inline var REMOTE_DPAD_LEFT:Int = 16;
	public static inline var REMOTE_DPAD_RIGHT:Int = 17;
	
	public static inline var REMOTE_DPAD_X:Int = 18;
	public static inline var REMOTE_DPAD_Y:Int = 19;
	
	public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 20;
	public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 21;
	public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 22;
	public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 23;
	
	public static inline var CLASSIC_DPAD_DOWN:Int = 24;
	public static inline var CLASSIC_DPAD_UP:Int = 25;
	public static inline var CLASSIC_DPAD_LEFT:Int = 26;
	public static inline var CLASSIC_DPAD_RIGHT:Int = 27;
	
	public static inline var NUNCHUK_DPAD_DOWN:Int = 28;
	public static inline var NUNCHUK_DPAD_UP:Int = 29;
	public static inline var NUNCHUK_DPAD_LEFT:Int = 30;
	public static inline var NUNCHUK_DPAD_RIGHT:Int = 31;
	
	#else	//gamepad API
	
	//Standard Wii Remote inputs:
	public static inline var REMOTE_ONE:Int = 9;
	public static inline var REMOTE_TWO:Int = 10;
	public static inline var REMOTE_A:Int = 11;
	public static inline var REMOTE_B:Int = 12;
	public static inline var REMOTE_PLUS:Int = 13;
	public static inline var REMOTE_MINUS:Int = 14;
	public static inline var REMOTE_HOME:Int = 15;
	
	//Nunchuk attachment:
	
	public static inline var NUNCHUK_A:Int = 9;
	public static inline var NUNCHUK_B:Int = 10;
	public static inline var NUNCHUK_C:Int = 11;
	public static inline var NUNCHUK_Z:Int = 12;
	public static inline var NUNCHUK_ONE:Int = 13;
	public static inline var NUNCHUK_TWO:Int = 14;
	public static inline var NUNCHUK_PLUS:Int = 15;
	public static inline var NUNCHUK_MINUS:Int = 16;
	public static inline var NUNCHUK_HOME:Int = 17;
	
	public static inline var NUNCHUK_DPAD_UP:Int = 5;
	public static inline var NUNCHUK_DPAD_DOWN:Int = 6;
	public static inline var NUNCHUK_DPAD_LEFT:Int = 7;
	public static inline var NUNCHUK_DPAD_RIGHT:Int = 8;
	
	//classic controller attachment:
	public static inline var CLASSIC_A:Int = 9;
	public static inline var CLASSIC_B:Int = 10;
	public static inline var CLASSIC_Y:Int = 11;
	public static inline var CLASSIC_X:Int = 12;
	public static inline var CLASSIC_L:Int = 13;
	public static inline var CLASSIC_R:Int = 14;
	public static inline var CLASSIC_ZL:Int = 15;
	public static inline var CLASSIC_ZR:Int = 16;
	public static inline var CLASSIC_START:Int = 17;
	public static inline var CLASSIC_SELECT:Int = 18;
	public static inline var CLASSIC_HOME:Int = 19;
	public static inline var CLASSIC_ONE:Int = 20;
	public static inline var CLASSIC_TWO:Int = 21;
	
	public static inline var CLASSIC_DPAD_UP:Int = 5;
	public static inline var CLASSIC_DPAD_DOWN:Int = 6;
	public static inline var CLASSIC_DPAD_LEFT:Int = 7;
	public static inline var CLASSIC_DPAD_RIGHT:Int = 8;
	
	// Axis indices
	
	public static inline var REMOTE_TILT_PITCH:Int = 2;
	public static inline var REMOTE_TILT_ROLL:Int = 3;
	
	public static inline var NUNCHUK_TILT_PITCH:Int = 3;
	public static inline var NUNCHUK_TILT_ROLL:Int = 2;
	
	public static inline var REMOTE_NULL_AXIS:Int = 4;
	public static inline var NUNCHUK_NULL_AXIS:Int = 4;
	
	//Yes, the WiiRemote DPAD is treated as ANALOG for some reason...so we have to pass in some "fake" ID's to get simulated digital inputs
	public static var REMOTE_DPAD(default, null) = new FlxGamepadAnalogStick(0, 1, {
			up:REMOTE_DPAD_UP,
			down:REMOTE_DPAD_DOWN,
			left:REMOTE_DPAD_LEFT,
			right:REMOTE_DPAD_RIGHT,
			threshold:0.5,
			mode:SendOnlyDigital
		});
	
	public static var LEFT_ANALOG_STICK(default, null)  = new FlxGamepadAnalogStick(0, 1);	//the nunchuk only has the "left" analog stick
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);	//the classic controller has both the "left" and "right" analog sticks
	
	//these aren't real axes, they're simulated when the right digital buttons are pushed
	public static inline var LEFT_TRIGGER_FAKE:Int = 4;
	public static inline var RIGHT_TRIGGER_FAKE:Int = 5;
	
	//"fake" ID's
	public static inline var REMOTE_DPAD_UP:Int = 22;
	public static inline var REMOTE_DPAD_DOWN:Int = 23;
	public static inline var REMOTE_DPAD_LEFT:Int = 24;
	public static inline var REMOTE_DPAD_RIGHT:Int = 25;
	
	public static inline var REMOTE_DPAD_X:Int = 26;
	public static inline var REMOTE_DPAD_Y:Int = 27;
	
	public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 28;
	public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 29;
	public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 30;
	public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 31;
	
	#end
#end
}