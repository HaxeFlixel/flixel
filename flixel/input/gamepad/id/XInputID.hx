package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
	* IDs for generic XInput controllers
	*
	* Compatible with the Xbox 360 controller, the Xbox One controller, and anything that masquerades as either of those.
	*
	*-------
	* NOTES
	*-------
	*
	* WINDOWS: we assume the user is using the default drivers that ship with windows.
	*
	* LINUX: we assume the user is using the xpad driver, specifically Valve's version, steamos-xpad-dkms
	* (we got weird errors when using xboxdrv). For full instructions on installation, see:
	* http://askubuntu.com/questions/165210/how-do-i-get-an-xbox-360-controller-working/441548#441548
	*
	* MAC: we assume the user is using the 360 Controller driver, specifically this one:
	* https://github.com/360Controller/360Controller/releases
 */
enum abstract XInputID(Int) to Int
{
	#if flash
	var A = 4;
	var B = 5;
	var X = 6;
	var Y = 7;
	var LB = 8;
	var RB = 9;

	var BACK = 12;
	var GUIDE = -1;
	var START = 13;

	var LEFT_STICK_CLICK = 14;
	var RIGHT_STICK_CLICK = 15;

	var DPAD_UP = 16;
	var DPAD_DOWN = 17;
	var DPAD_LEFT = 18;
	var DPAD_RIGHT = 19;

	var LEFT_TRIGGER = 10;
	var RIGHT_TRIGGER = 11;

	
	static final LEFT_X = 0;
	static final LEFT_Y = 1;
	static final RIGHT_X = 2;
	static final RIGHT_Y = 3;
	
	var LEFT_STICK_UP = 20;
	var LEFT_STICK_DOWN = 21;
	var LEFT_STICK_LEFT = 22;
	var LEFT_STICK_RIGHT = 23;
	
	var RIGHT_STICK_UP = 24;
	var RIGHT_STICK_DOWN = 25;
	var RIGHT_STICK_LEFT = 26;
	var RIGHT_STICK_RIGHT = 27;
	#elseif FLX_GAMEINPUT_API
	var A = 6;
	var B = 7;
	var X = 8;
	var Y = 9;

	var BACK = 10;
	var GUIDE = #if mac 11 #else - 1 #end;
	var START = 12;

	var LEFT_STICK_CLICK = 13;
	var RIGHT_STICK_CLICK = 14;

	var LB = 15;
	var RB = 16;

	var DPAD_UP = 17;
	var DPAD_DOWN = 18;
	var DPAD_LEFT = 19;
	var DPAD_RIGHT = 20;
	
	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 2;
	static inline final RIGHT_Y = 3;

	var LEFT_STICK_UP = 21;
	var LEFT_STICK_DOWN = 22;
	var LEFT_STICK_LEFT = 23;
	var LEFT_STICK_RIGHT = 24;
	
	var RIGHT_STICK_UP = 25;
	var RIGHT_STICK_DOWN = 26;
	var RIGHT_STICK_LEFT = 27;
	var RIGHT_STICK_RIGHT = 28;

	var LEFT_TRIGGER = 4;
	var RIGHT_TRIGGER = 5;
	#elseif FLX_JOYSTICK_API
	#if (windows || linux)
	var A = 0;
	var B = 1;
	var X = 2;
	var Y = 3;

	var LB = 4;
	var RB = 5;

	var BACK = 6;
	var START = 7;

	#if linux
	var LEFT_STICK_CLICK = 9;
	var RIGHT_STICK_CLICK = 10;
	var GUIDE = 8;
	#elseif windows
	var LEFT_STICK_CLICK = 8;
	var RIGHT_STICK_CLICK = 9;
	var GUIDE = 10;
	#end

	// "fake" IDs, we manually watch for hat axis changes and then send events using
	// these otherwise unused joystick button codes
	var DPAD_UP = 11;
	var DPAD_DOWN = 12;
	var DPAD_LEFT = 13;
	var DPAD_RIGHT = 14;

	var LEFT_TRIGGER = 2;
	var RIGHT_TRIGGER = 5;

	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 3;
	static inline final RIGHT_Y = 4;

	var LEFT_STICK_UP = 21;
	var LEFT_STICK_DOWN = 22;
	var LEFT_STICK_LEFT = 23;
	var LEFT_STICK_RIGHT = 24;
	
	var RIGHT_STICK_UP = 25;
	var RIGHT_STICK_DOWN = 26;
	var RIGHT_STICK_LEFT = 27;
	var RIGHT_STICK_RIGHT = 28;
	#else // mac
	var A = 0;
	var B = 1;
	var X = 2;
	var Y = 3;

	var LB = 4;
	var RB = 5;

	var LEFT_STICK_CLICK = 6;
	var RIGHT_STICK_CLICK = 7;

	var BACK = 9;
	var START = 8;

	var GUIDE = 10;

	var DPAD_UP = 11;
	var DPAD_DOWN = 12;
	var DPAD_LEFT = 13;
	var DPAD_RIGHT = 14;

	var LEFT_TRIGGER = 2;
	var RIGHT_TRIGGER = 5;

	static inline final LEFT_X = 0;
	static inline final LEFT_Y = 1;
	static inline final RIGHT_X = 3;
	static inline final RIGHT_Y = 4;

	var LEFT_STICK_UP = 21;
	var LEFT_STICK_DOWN = 22;
	var LEFT_STICK_LEFT = 23;
	var LEFT_STICK_RIGHT = 24;
	
	var RIGHT_STICK_UP = 25;
	var RIGHT_STICK_DOWN = 26;
	var RIGHT_STICK_LEFT = 27;
	var RIGHT_STICK_RIGHT = 28;
	#end
	#end
	
	public static final LEFT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<XInputID>(LEFT_X, LEFT_Y, {
		up: LEFT_STICK_UP,
		down: LEFT_STICK_DOWN,
		left: LEFT_STICK_LEFT,
		right: LEFT_STICK_RIGHT
	});
	
	public static var RIGHT_ANALOG_STICK = new FlxTypedGamepadAnalogStick<XInputID>(RIGHT_X, RIGHT_Y, {
		up: RIGHT_STICK_UP,
		down: RIGHT_STICK_DOWN,
		left: RIGHT_STICK_LEFT,
		right: RIGHT_STICK_RIGHT
	});
}
