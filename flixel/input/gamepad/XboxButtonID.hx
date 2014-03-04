package flixel.input.gamepad;

/**
 * Button IDs for Xbox 360 controllers
 */
class XboxButtonID
{
#if flash
	public static inline var A:Int = 4;
	public static inline var B:Int = 5;
	public static inline var X:Int = 6;
	public static inline var Y:Int = 7;
	public static inline var LB:Int = 8;
	public static inline var RB:Int = 9;
	public static inline var BACK:Int = 12;
	public static inline var START:Int = 13;
	
	public static inline var LEFT_TRIGGER:Int = 10;
	public static inline var RIGHT_TRIGGER:Int = 11;
	
	public static inline var LEFT_ANALOGUE:Int = 14;
	public static inline var RIGHT_ANALOGUE:Int = 15;
	
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 2;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
	
	public static inline var DPAD_UP:Int = 16;
	public static inline var DPAD_DOWN:Int = 17;
	public static inline var DPAD_LEFT:Int = 18;
	public static inline var DPAD_RIGHT:Int = 19;
#elseif mac
	/**
	 * Button IDs (DPAD values are obtained from FlxGamepad.hat)
	 */
	public static inline var A:Int = 11;
	public static inline var B:Int = 12;
	public static inline var X:Int = 13;
	public static inline var Y:Int = 14;
	public static inline var LB:Int = 8;
	public static inline var RB:Int = 9;
	public static inline var BACK:Int = 5;
	public static inline var START:Int = 4;
	public static inline var LEFT_ANALOGUE:Int = 6;
	public static inline var RIGHT_ANALOGUE:Int = 7;

	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public static inline var TRIGGER:Int = 4;
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 2;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
#else
	/**
	 * Button IDs (DPAD values are obtained from FlxGamepad.hat)
	 */
	public static inline var A:Int = 0;
	public static inline var B:Int = 1;
	public static inline var X:Int = 2;
	public static inline var Y:Int = 3;
	public static inline var LB:Int = 4;
	public static inline var RB:Int = 5;
	public static inline var BACK:Int = 6;
	public static inline var START:Int = 7;
	public static inline var LEFT_ANALOGUE:Int = 8;
	public static inline var RIGHT_ANALOGUE:Int = 9;
	
	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public static inline var TRIGGER:Int = 2;
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 4;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
#end
}