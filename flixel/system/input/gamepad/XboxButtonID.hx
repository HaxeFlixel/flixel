package flixel.system.input.gamepad;

/**
 * Button IDs for Xbox 360 controllers
 */
class XboxButtonID
{
#if mac
	static public var A:Int = 11;
	static public var B:Int = 12;
	static public var X:Int = 13;
	static public var Y:Int = 14;
	static public var LB:Int = 8;
	static public var RB:Int = 9;
	static public var BACK:Int = 5;
	static public var START:Int = 4;
	static public var LEFT_ANALOGUE:Int = 6;
	static public var RIGHT_ANALOGUE:Int = 7;
	static public var LEFT_ANALOGUE_X:Int = 0;
	static public var LEFT_ANALOGUE_Y:Int = 1;
	static public var RIGHT_ANALOGUE_X:Int = 2;
	static public var RIGHT_ANALOGUE_Y:Int = 3;
	static public var DPAD_UP:Int = 0;
	static public var DPAD_DOWN:Int = 1;
	static public var DPAD_LEFT:Int = 2;
	static public var DPAD_RIGHT:Int = 3;

	//public static var TRIGGER:Int = 3;
#else
	
	static public var A:Int = 0;
	static public var B:Int = 1;
	static public var X:Int = 2;
	static public var Y:Int = 3;
	static public var LB:Int = 4;
	static public var RB:Int = 5;
	static public var BACK:Int = 6;
	static public var START:Int = 7;
	static public var LEFT_ANALOGUE:Int = 8;
	static public var RIGHT_ANALOGUE:Int = 9;
	static public var LEFT_ANALOGUE_X:Int = 0;
	static public var LEFT_ANALOGUE_Y:Int = 1;
	static public var RIGHT_ANALOGUE_X:Int = 4;
	static public var RIGHT_ANALOGUE_Y:Int = 3;
	
	/**
	 * Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	static public var TRIGGER:Int = 2;
#end
}