package flixel.input.gamepad;

/**
 * Button IDs for Xbox 360 controllers
 */
class XboxButtonID
{
#if mac
	/**
	 * Button IDs (DPAD values are obtained from FlxGamepad.hat)
	 */
	inline public static var A:Int = 11;
	inline public static var B:Int = 12;
	inline public static var X:Int = 13;
	inline public static var Y:Int = 14;
	inline public static var LB:Int = 8;
	inline public static var RB:Int = 9;
	inline public static var BACK:Int = 5;
	inline public static var START:Int = 4;
	inline public static var LEFT_ANALOGUE:Int = 6;
	inline public static var RIGHT_ANALOGUE:Int = 7;

	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	inline public static var TRIGGER:Int = 4;
	inline public static var LEFT_ANALOGUE_X:Int = 0;
	inline public static var LEFT_ANALOGUE_Y:Int = 1;
	inline public static var RIGHT_ANALOGUE_X:Int = 2;
	inline public static var RIGHT_ANALOGUE_Y:Int = 3;
#else
	/**
	 * Button IDs (DPAD values are obtained from FlxGamepad.hat)
	 */
	inline public static var A:Int = 0;
	inline public static var B:Int = 1;
	inline public static var X:Int = 2;
	inline public static var Y:Int = 3;
	inline public static var LB:Int = 4;
	inline public static var RB:Int = 5;
	inline public static var BACK:Int = 6;
	inline public static var START:Int = 7;
	inline public static var LEFT_ANALOGUE:Int = 8;
	inline public static var RIGHT_ANALOGUE:Int = 9;
	
	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	inline public static var TRIGGER:Int = 2;
	inline public static var LEFT_ANALOGUE_X:Int = 0;
	inline public static var LEFT_ANALOGUE_Y:Int = 1;
	inline public static var RIGHT_ANALOGUE_X:Int = 4;
	inline public static var RIGHT_ANALOGUE_Y:Int = 3;
	
#end
}