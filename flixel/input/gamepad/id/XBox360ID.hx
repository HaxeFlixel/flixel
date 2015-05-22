package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepad;

/**
 * IDs for Xbox 360 controllers
 */
class XBox360ID
{
#if flash
	// Button IDs
	public static inline var A:Int = 4;
	public static inline var B:Int = 5;
	public static inline var X:Int = 6;
	public static inline var Y:Int = 7;
	public static inline var LB:Int = 8;
	public static inline var RB:Int = 9;
	public static inline var BACK:Int = 12;
	public static inline var START:Int = 13;
	
	public static inline var LEFT_STICK_CLICK:Int = 14;
	public static inline var RIGHT_STICK_CLICK:Int = 15;
	
	public static inline var DPAD_UP:Int = 16;
	public static inline var DPAD_DOWN:Int = 17;
	public static inline var DPAD_LEFT:Int = 18;
	public static inline var DPAD_RIGHT:Int = 19;
	
	public static inline var XBOX:Int = -1;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
	
	public static inline var LEFT_TRIGGER:Int = 10;
	public static inline var RIGHT_TRIGGER:Int = 11;
#elseif js
	// Button IDs
	public static inline var A:Int = 0;
	public static inline var B:Int = 1;
	public static inline var X:Int = 2;
	public static inline var Y:Int = 3;
	public static inline var LB:Int = 4;
	public static inline var RB:Int = 5;
	public static inline var LEFT_TRIGGER:Int = 6;
	public static inline var RIGHT_TRIGGER:Int = 7;
	public static inline var BACK:Int = 8;
	public static inline var START:Int = 9;
	
	public static inline var LEFT_STICK_CLICK:Int = 10;
	public static inline var RIGHT_STICK_CLICK:Int = 11;
	
	public static inline var DPAD_UP:Int = 12;
	public static inline var DPAD_DOWN:Int = 13;
	public static inline var DPAD_LEFT:Int = 14;
	public static inline var DPAD_RIGHT:Int = 15;
	
	public static inline var XBOX:Int = -1;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3);
#elseif mac
	// Button IDs
	public static inline var A:Int = 0;
	public static inline var B:Int = 1;
	public static inline var X:Int = 2;
	public static inline var Y:Int = 3;
	public static inline var LB:Int = 4;
	public static inline var RB:Int = 5;
	public static inline var BACK:Int = 9;
	public static inline var START:Int = 8;
	public static inline var LEFT_STICK_CLICK:Int = 6;
	public static inline var RIGHT_STICK_CLICK:Int = 7;
	
	public static inline var XBOX:Int = 10;

	public static inline var DPAD_UP:Int = 11;
	public static inline var DPAD_DOWN:Int = 12;
	public static inline var DPAD_LEFT:Int = 13;
	public static inline var DPAD_RIGHT:Int = 14;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(3, 4);
	public static inline var LEFT_TRIGGER:Int = 2;
	public static inline var RIGHT_TRIGGER:Int = 5;
#elseif linux
	// Button IDs
	public static inline var A:Int = 0;
	public static inline var B:Int = 1;
	public static inline var X:Int = 2;
	public static inline var Y:Int = 3;
	public static inline var LB:Int = 4;
	public static inline var RB:Int = 5;
	public static inline var BACK:Int = 6;
	public static inline var START:Int = 7;
	public static inline var LEFT_STICK_CLICK:Int = 9;
	public static inline var RIGHT_STICK_CLICK:Int = 10;
	
	public static inline var XBOX:Int = 8;
	
	public static inline var DPAD_UP:Int = 13;
	public static inline var DPAD_DOWN:Int = 14;
	public static inline var DPAD_LEFT:Int = 11;
	public static inline var DPAD_RIGHT:Int = 12;
	
	// Axis indices
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(3, 4);
	public static inline var LEFT_TRIGGER:Int = 2;
	public static inline var RIGHT_TRIGGER:Int = 5;
#else // windows
	// Button IDs
	public static inline var A:Int = 0;
	public static inline var B:Int = 1;
	public static inline var X:Int = 2;
	public static inline var Y:Int = 3;
	public static inline var LB:Int = 4;
	public static inline var RB:Int = 5;
	public static inline var BACK:Int = 6;
	public static inline var START:Int = 7;
	public static inline var LEFT_STICK_CLICK:Int = 8;
	public static inline var RIGHT_STICK_CLICK:Int = 9;
	
	public static inline var XBOX:Int = 10;
	
	//"fake" IDs, we manually watch for hat axis changes and then send events using these otherwise unused joystick button codes
	public static inline var DPAD_UP:Int = 11;
	public static inline var DPAD_DOWN:Int = 12;
	public static inline var DPAD_LEFT:Int = 13;
	public static inline var DPAD_RIGHT:Int = 14;
	
	// Axis indices
	public static inline var LEFT_TRIGGER:Int = 2;
	public static inline var RIGHT_TRIGGER:Int = 5;
	
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1);
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(3, 4);
#end
}
