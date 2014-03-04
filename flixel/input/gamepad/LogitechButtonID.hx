package flixel.input.gamepad;

/**
 * Button IDs for Logitech controllers (key codes based on Cordless Rumblepad 2)
 */
class LogitechButtonID
{
	
#if flash
	/**
	 * Placement equivalent to 'X' button on the Xbox 360 controller.
	 */
	public static inline var ONE:Int = 8;
	/**
	 * Placement equivalent to 'A' button on the Xbox 360 controller.
	 */
	public static inline var TWO:Int = 9;
	/**
	 * Placement equivalent to 'B' button on the Xbox 360 controller.
	 */
	public static inline var THREE:Int = 10;
	/**
	 * Placement equivalent to 'Y' button on the Xbox 360 controller.
	 */
	public static inline var FOUR:Int = 11;
	
	/**
	 * Placement equivalent to the left bumper on the Xbox 360 controller.
	 */
	public static inline var FIVE:Int = 12;
	/**
	 * Placement equivalent to the right bumper on the Xbox 360 controller.
	 */
	public static inline var SIX:Int = 13;
	/**
	 * Placement equivalent to the left trigger on the Xbox 360 controller.
	 * (it is a bumper though)
	 */
	public static inline var SEVEN:Int = 14;
	/**
	 * Placement equivalent to the right trigger on the Xbox 360 controller.
	 * (it is a bumper though)
	 */
	public static inline var EIGHT:Int = 15;
	
	/**
	 * Placement equivalent to the 'Back' button on the Xbox 360 controller.
	 */
	public static inline var NINE:Int = 16;
	/**
	 * Placement equivalent to the 'Menu' button on the Xbox 360 controller.
	 */
	public static inline var TEN:Int = 17;
	
	/**
	 * Placement equivalent to the 'left analogue' button on the Xbox 360 controller.
	 */
	public static inline var LEFT_ANALOGUE:Int = 18;
	/**
	 * Placement equivalent to the 'right analogue' button on the Xbox 360 controller.
	 */
	public static inline var RIGHT_ANALOGUE:Int = 19;
	
	/**
	 * Axis array indicies
	 */
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	public static inline var RIGHT_ANALOGUE_X:Int = 2;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
	
	public static inline var DPAD_UP:Int = 4;
	public static inline var DPAD_DOWN:Int = 5;
	public static inline var DPAD_LEFT:Int = 6;
	public static inline var DPAD_RIGHT:Int = 7;
#else
	/**
	 * Placement equivalent to 'X' button on the Xbox 360 controller.
	 */
	public static inline var ONE:Int = 0;
	/**
	 * Placement equivalent to 'A' button on the Xbox 360 controller.
	 */
	public static inline var TWO:Int = 1;
	/**
	 * Placement equivalent to 'B' button on the Xbox 360 controller.
	 */
	public static inline var THREE:Int = 2;
	/**
	 * Placement equivalent to 'Y' button on the Xbox 360 controller.
	 */
	public static inline var FOUR:Int = 3;
	
	/**
	 * Placement equivalent to the left bumper on the Xbox 360 controller.
	 */
	public static inline var FIVE:Int = 4;
	/**
	 * Placement equivalent to the right bumper on the Xbox 360 controller.
	 */
	public static inline var SIX:Int = 5;
	/**
	 * Placement equivalent to the left trigger on the Xbox 360 controller.
	 * (it is a bumper though)
	 */
	public static inline var SEVEN:Int = 6;
	/**
	 * Placement equivalent to the right trigger on the Xbox 360 controller.
	 * (it is a bumper though)
	 */
	public static inline var EIGHT:Int = 7;
	
	/**
	 * Placement equivalent to the 'Back' button on the Xbox 360 controller.
	 */
	public static inline var NINE:Int = 8;
	/**
	 * Placement equivalent to the 'Menu' button on the Xbox 360 controller.
	 */
	public static inline var TEN:Int = 9;
	
	/**
	 * Placement equivalent to the 'left analogue' button on the Xbox 360 controller.
	 */
	public static inline var LEFT_ANALOGUE:Int = 10;
	/**
	 * Placement equivalent to the 'right analogue' button on the Xbox 360 controller.
	 */
	public static inline var RIGHT_ANALOGUE:Int = 11;
	
	/**
	 * Axis array indicies
	 */
	public static inline var LEFT_ANALOGUE_X:Int = 0;
	public static inline var LEFT_ANALOGUE_Y:Int = 1;
	
	public static inline var RIGHT_ANALOGUE_X:Int = 2;
	public static inline var RIGHT_ANALOGUE_Y:Int = 3;
#end
}