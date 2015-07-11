package flixel.input.gamepad.id;
import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModelAttachment;

/**
 * WiiRemote hardware input ID's -- note that on PC this requires the MayFlash DolphinBar accessory
 * @author larsiusprime
 */
class WiiRemoteID
{
#if !web
	#if FLX_JOYSTICK_API
	
	//Standard Wii Remote inputs:
	public static inline var REMOTE_ONE:Int = 0;
	public static inline var REMOTE_TWO:Int = 1;
	public static inline var REMOTE_A:Int = 2;
	public static inline var REMOTE_B:Int = 3;
	
	public static inline var REMOTE_MINUS:Int = 4;		//Identical to L and R, but NOT to SELECT and START, even though the latter have the same -/+ labels!!!
	public static inline var REMOTE_PLUS:Int = 5;
	
	//Nunchuk attachment:
	public static inline var NUNCHUK_Z:Int = 6;			//Identical to ZL and ZR
	public static inline var NUNCHUK_C:Int = 7;
	
	//classic controller attachment:
	public static inline var CLASSIC_Y:Int = 0;	//Identical to WiiRemote 1
	public static inline var CLASSIC_X:Int = 1;	//Identical to WiiRemote 2
	public static inline var CLASSIC_B:Int = 2;	//Identical to WiiRemote A
	public static inline var CLASSIC_A:Int = 3;	//Identical to WiiRemote B
	
	public static inline var CLASSIC_L:Int = 4;			//Identical to MINUS and PLUS
	public static inline var CLASSIC_R:Int = 5;
	public static inline var CLASSIC_ZL:Int = 6;		//Identical to C and Z
	public static inline var CLASSIC_ZR:Int = 7;
	
	public static inline var CLASSIC_SELECT:Int = 8;
	public static inline var CLASSIC_START:Int = 9;
	
	//(input "10" does not seem to be defined)
	
	public static inline var HOME:Int = 11;		//Same on both WiiRemote and Classic controller, finally!
	
	public static inline var CLASSIC_DPAD_DOWN:Int = 12;
	public static inline var CLASSIC_DPAD_UP:Int = 13;
	public static inline var CLASSIC_DPAD_LEFT:Int = 14;
	public static inline var CLASSIC_DPAD_RIGHT:Int = 15;

	// Axis indices
	
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
	
	//Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
	public static function axisIndexToRawID(index:Int, attachment:FlxGamepadModelAttachment):Int
	{
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
		
		if (attachment == WiiClassicController)
		{
			     if (index == RIGHT_ANALOG_STICK.x) return RIGHT_ANALOG_STICK_FAKE_X;
			else if (index == RIGHT_ANALOG_STICK.y) return RIGHT_ANALOG_STICK_FAKE_Y;
		}
		return index;
	}
	
	public static function checkForFakeAxis(ID:FlxGamepadInputID, attachment:FlxGamepadModelAttachment):Int
	{
		if (attachment == WiiNunchuk)
		{
			if (ID == LEFT_TRIGGER) return NUNCHUK_Z;
		}
		else if (attachment == WiiClassicController)
		{
			if (ID == LEFT_TRIGGER)  return CLASSIC_ZL;
			if (ID == RIGHT_TRIGGER) return CLASSIC_ZR;
		}
		return -1;
	}
	
	//"fake" IDs
	public static inline var REMOTE_DPAD_X:Int = 16;
	public static inline var REMOTE_DPAD_Y:Int = 17;
	
	public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 18;
	public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 19;
	public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 20;
	public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 21;
	
	public static inline var REMOTE_DPAD_UP:Int = 22;
	public static inline var REMOTE_DPAD_DOWN:Int = 23;
	public static inline var REMOTE_DPAD_LEFT:Int = 24;
	public static inline var REMOTE_DPAD_RIGHT:Int = 25;
	
	#end
#end
}