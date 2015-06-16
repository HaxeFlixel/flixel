package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for PlayStation 4 controllers
 * (D-pad values are obtained from FlxGamepad.hat)
 */
class PS4ID
{
	public static inline var TRIANGLE:Int = 3;
	public static inline var CIRCLE:Int = 2;
	public static inline var X:Int = 1;
	public static inline var SQUARE:Int = 0;
	public static inline var L1:Int = 4;
	public static inline var R1:Int = 5;
	public static inline var L2:Int = 6;
	public static inline var R2:Int = 7;
	public static inline var SHARE:Int = 0;
	public static inline var SELECT:Int = 8;
	public static inline var START:Int = 9;
	public static inline var PS:Int = 12;
	public static inline var TOUCHPAD:Int = 13;
	public static inline var LEFT_STICK_CLICK:Int = 10;
	public static inline var RIGHT_STICK_CLICK:Int = 11;
	
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0 , 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 5);
	
	//TODO: these look like axis values. Can anyone confirm whether the PS4 has a separate digital button input click for L2 & R2 at the end of the squeeze
	//that is different from just a maximum analog pressure from L2 & R2?
	public static inline var L2_PRESSURE:Int = 3;
	public static inline var R2_PRESSURE:Int = 4;
	
	//TODO: someone needs to look these up and define them!
	public static inline var DPAD_LEFT:Int = 100;
	public static inline var DPAD_RIGHT:Int = 101;
	public static inline var DPAD_DOWN:Int = 102;
	public static inline var DPAD_UP:Int = 103;
	
	#if FLX_JOYSTICK_API
	//Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
	public static function axisIndexToRawID(index:Int):Int
	{
		return   if (index == LEFT_ANALOG_STICK.x) LEFT_ANALOG_STICK_FAKE_X;
			else if (index == LEFT_ANALOG_STICK.y) LEFT_ANALOG_STICK_FAKE_Y;
			else if (index == RIGHT_ANALOG_STICK.x) RIGHT_ANALOG_STICK_FAKE_X;
			else if (index == RIGHT_ANALOG_STICK.y) RIGHT_ANALOG_STICK_FAKE_Y;
			else if (index == L2_PRESSURE) LEFT_TRIGGER_FAKE;
			else if (index == R2_PRESSURE) RIGHT_TRIGGER_FAKE;
			else index;
	}
	//"fake" IDs
	public static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 18;
	public static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 19;
	
	public static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 20;
	public static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 21;
	
	public static inline var LEFT_TRIGGER_FAKE:Int = 22;
	public static inline var RIGHT_TRIGGER_FAKE:Int = 23;
	#end
}
