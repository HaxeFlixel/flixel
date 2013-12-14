package flixel.system.input.gamepad;

/**
 * Button IDs for Xbox 360 controllers
 */
class XboxButtonID
{
#if mac
	inline static public var A:Int = 11;
	inline static public var B:Int = 12;
	inline static public var X:Int = 13;
	inline static public var Y:Int = 14;
	inline static public var LB:Int = 8;
	inline static public var RB:Int = 9;
	inline static public var BACK:Int = 5;
	inline static public var START:Int = 4;
	inline static public var LEFT_ANALOGUE:Int = 6;
	inline static public var RIGHT_ANALOGUE:Int = 7;
	inline static public var LEFT_ANALOGUE_X:Int = 0;
	inline static public var LEFT_ANALOGUE_Y:Int = 1;
	inline static public var RIGHT_ANALOGUE_X:Int = 2;
	inline static public var RIGHT_ANALOGUE_Y:Int = 3;
	inline static public var DPAD_UP:Int = 0;
	inline static public var DPAD_DOWN:Int = 1;
	inline static public var DPAD_LEFT:Int = 2;
	inline static public var DPAD_RIGHT:Int = 3;

	/**
	 * Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	inline static public var TRIGGER:Int = 3;
#else
	
	inline static public var A:Int = 0;
	inline static public var B:Int = 1;
	inline static public var X:Int = 2;
	inline static public var Y:Int = 3;
	inline static public var LB:Int = 4;
	inline static public var RB:Int = 5;
	inline static public var BACK:Int = 6;
	inline static public var START:Int = 7;
	inline static public var LEFT_ANALOGUE:Int = 8;
	inline static public var RIGHT_ANALOGUE:Int = 9;
	inline static public var LEFT_ANALOGUE_X:Int = 0;
	inline static public var LEFT_ANALOGUE_Y:Int = 1;
	inline static public var RIGHT_ANALOGUE_X:Int = 4;
	inline static public var RIGHT_ANALOGUE_Y:Int = 3;
	
	/**
	 * Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	inline static public var TRIGGER:Int = 2;
#end
}