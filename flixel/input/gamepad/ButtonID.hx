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
	
	// Button Indices
	var ANY               = -2;		
	var NONE              = -1;		
	var A                 =  0;		//BOTTOM face button
	var B                 =  1;		//RIGHT  face button
	var X                 =  2;		//LEFT   face button
	var Y                 =  3;		//TOP    face button
	var LEFT_SHOULDER     =  4;		//left "bumper"
	var RIGHT_SHOULDER    =  5;		//right "bumper"
	var BACK              =  6;		//a.k.a "select", left center button
	var START             =  7;		//right center button
	var LEFT_STICK_BTN    =  8;		//Click left stick
	var RIGHT_STICK_BTN   =  9;		//Click right stick
	var GUIDE             = 10;		//a.k.a "xbox" or "PS" or "home" button in center
	var DPAD_UP           = 11;
	var DPAD_DOWN         = 12;
	var DPAD_LEFT         = 13;
	var DPAD_RIGHT        = 14;
	var LEFT_TRIGGER_BTN  = 15;		//digital button at end of left analog trigger full squeeze (if available)
	var RIGHT_TRIGGER_BTN = 16;		//digital button at end of right analog trigger full squeeze (if available)
	
	var LEFT_TRIGGER       = 17;
	var RIGHT_TRIGGER      = 18;
	
	// FlxGamepadAnalogSticks (wraps up the _X/_Y into a structure)
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