package flixel.input.gamepad;

import flixel.system.macros.FlxMacroUtil;

/**
 * A high-level list of unique values for gamepad inputs.
 * These do NOT correspond to any actual hardware values but
 * are the basis for all hardware-specific lookups.
 *
 * Maps enum values and strings to unique integer codes
 */
enum abstract FlxGamepadInputID(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, FlxGamepadInputID> = FlxMacroUtil.buildMap("flixel.input.gamepad.FlxGamepadInputID");
	public static var toStringMap(default, null):Map<FlxGamepadInputID, String> = FlxMacroUtil.buildMap("flixel.input.gamepad.FlxGamepadInputID", true);
	// Button Indices
	var ANY = -2;
	var NONE = -1;

	/**BOTTOM face button*/
	var A = 0;

	/**RIGHT face button*/
	var B = 1;

	/**LEFT face button*/
	var X = 2;

	/**TOP face button*/
	var Y = 3;

	/**left digital "bumper"*/
	var LEFT_SHOULDER = 4;

	/**right digital "bumper"*/
	var RIGHT_SHOULDER = 5;

	/**also known as "select", the leftmost center button*/
	var BACK = 6;

	/**the rightmost center button*/
	var START = 7;

	/**digital click of the left analog stick*/
	var LEFT_STICK_CLICK = 8;

	/**digital click of the right analog stick*/
	var RIGHT_STICK_CLICK = 9;

	/**this is the "XBox" or "PS" or "home" button in the center*/
	var GUIDE = 10;

	var DPAD_UP = 11;
	var DPAD_DOWN = 12;
	var DPAD_LEFT = 13;
	var DPAD_RIGHT = 14;

	/**digital click at end of left analog trigger's squeeze (if available)*/
	var LEFT_TRIGGER_BUTTON = 15;

	/**digital click at end of right analog trigger's squeeze (if available)*/
	var RIGHT_TRIGGER_BUTTON = 16;

	var LEFT_TRIGGER = 17;
	var RIGHT_TRIGGER = 18;

	/**identifier for the entire LEFT_ANALOG_STICK itself, not just any particular direction**/
	var LEFT_ANALOG_STICK = 19;

	/**identifier for the entire RIGHT_ANALOG_STICK itself, not just any particular direction**/
	var RIGHT_ANALOG_STICK = 20;

	/**identifier for the entire DPAD itself, not just any particular button**/
	var DPAD = 21;

	#if FLX_JOYSTICK_API
	var LEFT_TRIGGER_FAKE = 22;
	var RIGHT_TRIGGER_FAKE = 23;
	var LEFT_STICK_FAKE = 24;
	var RIGHT_STICK_FAKE = 25;
	#end

	/**tilting towards or away from the ceiling (think "look up", "look down")**/
	var TILT_PITCH = 26;

	/**tilting side-to-side (think "twisting", or "do a barrel roll!")**/
	var TILT_ROLL = 27;

	/**for a mouse-like input such as touch or IR camera. Horizontal axis.**/
	var POINTER_X = 28;

	/**for a mouse-like input such as touch or IR camera. Vertical axis.**/
	var POINTER_Y = 29;

	/**an extra digital button that doesn't fit cleanly into the universal template**/
	var EXTRA_0 = 30;

	/**an extra digital button that doesn't fit cleanly into the universal template**/
	var EXTRA_1 = 31;

	/**an extra digital button that doesn't fit cleanly into the universal template**/
	var EXTRA_2 = 32;

	/**an extra digital button that doesn't fit cleanly into the universal template**/
	var EXTRA_3 = 33;

	/**left analog stick as a dpad, pushed up**/
	var LEFT_STICK_DIGITAL_UP = 34;

	/**left analog stick as a dpad, pushed right**/
	var LEFT_STICK_DIGITAL_RIGHT = 35;

	/**left analog stick as a dpad, pushed down**/
	var LEFT_STICK_DIGITAL_DOWN = 36;

	/**left analog stick as a dpad, pushed left**/
	var LEFT_STICK_DIGITAL_LEFT = 37;

	/**left analog stick as a dpad, pushed up**/
	var RIGHT_STICK_DIGITAL_UP = 38;

	/**left analog stick as a dpad, pushed right**/
	var RIGHT_STICK_DIGITAL_RIGHT = 39;

	/**left analog stick as a dpad, pushed down**/
	var RIGHT_STICK_DIGITAL_DOWN = 40;

	/**left analog stick as a dpad, pushed left**/
	var RIGHT_STICK_DIGITAL_LEFT = 41;

	@:from
	public static inline function fromString(s:String)
	{
		s = s.toUpperCase();
		return fromStringMap.exists(s) ? fromStringMap.get(s) : NONE;
	}

	@:to
	public inline function toString():String
	{
		return toStringMap.get(this);
	}
}
