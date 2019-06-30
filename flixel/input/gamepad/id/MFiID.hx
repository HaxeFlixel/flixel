package flixel.input.gamepad.id;

/**
 * IDs for MFi controllers
 */
class MFiID
{
	public static inline var A:Int = 6;
	public static inline var B:Int = 7;
	public static inline var X:Int = 8;
	public static inline var Y:Int = 9;
	public static inline var LB:Int = 15;
	public static inline var RB:Int = 16;
	public static inline var BACK:Int = 10;
	public static inline var START:Int = 12;
	public static inline var LEFT_STICK_CLICK:Int = 13;
	public static inline var RIGHT_STICK_CLICK:Int = 14;

	public static inline var GUIDE:Int = 11;

	public static inline var DPAD_UP:Int = 17;
	public static inline var DPAD_DOWN:Int = 18;
	public static inline var DPAD_LEFT:Int = 19;
	public static inline var DPAD_RIGHT:Int = 20;

	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 21,
		down: 22,
		left: 23,
		right: 24
	});
	public static var RIGHT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(2, 3, {
		up: 25,
		down: 26,
		left: 27,
		right: 28
	});

	public static inline var LEFT_TRIGGER:Int = 4;
	public static inline var RIGHT_TRIGGER:Int = 5;
}
