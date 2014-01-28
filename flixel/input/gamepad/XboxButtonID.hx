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
	public inline static var A:Int = 11;
	public inline static var B:Int = 12;
	public inline static var X:Int = 13;
	public inline static var Y:Int = 14;
	public inline static var LB:Int = 8;
	public inline static var RB:Int = 9;
	public inline static var BACK:Int = 5;
	public inline static var START:Int = 4;
	public inline static var LEFT_ANALOGUE:Int = 6;
	public inline static var RIGHT_ANALOGUE:Int = 7;

	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public inline static var TRIGGER:Int = 4;
	public inline static var LEFT_ANALOGUE_X:Int = 0;
	public inline static var LEFT_ANALOGUE_Y:Int = 1;
	public inline static var RIGHT_ANALOGUE_X:Int = 2;
	public inline static var RIGHT_ANALOGUE_Y:Int = 3;
#else
	/**
	 * Button IDs (DPAD values are obtained from FlxGamepad.hat)
	 */
	public inline static var A:Int = 0;
	public inline static var B:Int = 1;
	public inline static var X:Int = 2;
	public inline static var Y:Int = 3;
	public inline static var LB:Int = 4;
	public inline static var RB:Int = 5;
	public inline static var BACK:Int = 6;
	public inline static var START:Int = 7;
	public inline static var LEFT_ANALOGUE:Int = 8;
	public inline static var RIGHT_ANALOGUE:Int = 9;
	
	/**
	 * Axis array indicies
	 * 
	 * If TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public inline static var TRIGGER:Int = 2;
	public inline static var LEFT_ANALOGUE_X:Int = 0;
	public inline static var LEFT_ANALOGUE_Y:Int = 1;
	public inline static var RIGHT_ANALOGUE_X:Int = 4;
	public inline static var RIGHT_ANALOGUE_Y:Int = 3;
	
#end
}