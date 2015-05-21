package flixel.input.gamepad;

import flixel.system.macros.FlxMacroUtil;

/**
 * Maps enum values and strings to integer keycodes.
 */
@:enum
abstract ButtonID(Int) from Int to Int
{
	public static var fromStringMap(default, null):Map<String, ButtonID>
		= FlxMacroUtil.buildMap("flixel.input.gamepad.ButtonID");
		
	public static var toStringMap(default, null):Map<ButtonID, String>
		= FlxMacroUtil.buildMap("flixel.input.gamepad.ButtonID", true);
	
	// Key Indicies
	var ANY             = -2;
	var NONE            = -1;
	var A               =  0;
	var B               =  1;
	var X               =  2;
	var Y               =  3;
	var LEFT_SHOULDER   =  4;
	var RIGHT_SHOULDER  =  5;
	var BACK            =  6;
	var START           =  7;
	var LEFT_STICK_BTN  =  8;
	var RIGHT_STICK_BTN =  9;
	var GUIDE           = 10;
	var DPAD_UP         = 11;
	var DPAD_DOWN       = 12;
	var DPAD_LEFT       = 13;
	var DPAD_RIGHT      = 14;
	var LEFT_TRIGGER    = 15;
	var RIGHT_TRIGGER   = 16;
	
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