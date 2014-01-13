package flixel.input.gamepad;

/**
 * Button IDs for OUYA controllers
 */
class OUYAButtonID
{
	/**
	 * Button IDs (DPAD values are obtained from FlxGamepad.hat)
	 */
	public static inline var O:Int = 0;
	public static inline var U:Int = 3;
	public static inline var Y:Int = 4;
	public static inline var A:Int = 1;
	public static inline var LB:Int = 6;
	public static inline var RB:Int = 7;
	public static inline var LEFT_ANALOGUE:Int = 10;
	public static inline var RIGHT_ANALOGUE:Int = 11;
	public static inline var HOME:Int = 2;
	public static inline var LEFT_TRIGGER:Int = 8;
	public static inline var RIGHT_TRIGGER:Int = 9;
	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 11;
	public static inline var RIGHT_ANALOGUE_Y:Int = 14;
	public static inline var LEFT_TRIGGER_ANALOG:Int = 17;
	public static inline var RIGHT_TRIGGER_ANALOG:Int = 18;
} 