package flixel.input.gamepad;

import flixel.system.macros.FlxMacroUtil;

/**
 * A high-level list of unique values for gamepad inputs.
 * These do NOT correspond to any actual hardware values but
 * are the basis for all hardware-specific lookups.
 * 
 * Maps enum values and strings to unique integer codes
 */
@:enum
abstract FlxGamepadInputID(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, FlxGamepadInputID>
		= FlxMacroUtil.buildMap("flixel.input.gamepad.FlxGamepadInputID");
		
	public static var toStringMap(default, null):Map<FlxGamepadInputID, String>
		= FlxMacroUtil.buildMap("flixel.input.gamepad.FlxGamepadInputID", true);
	
	// Button Indices
	var ANY               = -2;
	var NONE              = -1;
	
	/**BOTTOM face button*/ 
	var A                 =  0;
	/**RIGHT face button*/  
	var B                 =  1;
	/**LEFT face button*/
	var X                 =  2;
	/**TOP face button*/
	var Y                 =  3;
	/**left digital "bumper"*/
	var LEFT_SHOULDER     =  4;
	/**right digital "bumper"*/
	var RIGHT_SHOULDER    =  5;
	/**also known as "select", the leftmost center button*/
	var BACK              =  6;
	/**the rightmost center button*/
	var START             =  7;
	/**digital click of the left analog stick*/
	var LEFT_STICK_CLICK  =  8;
	/**digital click of the right analog stick*/
	var RIGHT_STICK_CLICK =  9;
	/**this is the "XBox" or "PS" or "home" button in the center*/
	var GUIDE             = 10;
	var DPAD_UP           = 11;
	var DPAD_DOWN         = 12;
	var DPAD_LEFT         = 13;
	var DPAD_RIGHT        = 14;
	/**digital click at end of left analog trigger's squeeze (if available)*/
	var LEFT_TRIGGER_BTN  = 15;
	/**digital click at end of right analog trigger's squeeze (if available)*/
	var RIGHT_TRIGGER_BTN = 16;
	
	var LEFT_TRIGGER       = 17;
	var RIGHT_TRIGGER      = 18;
	
	var LEFT_ANALOG_STICK  = 19;
	var RIGHT_ANALOG_STICK = 20;
	
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