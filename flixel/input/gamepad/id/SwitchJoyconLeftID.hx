package flixel.input.gamepad.id;

import flixel.input.gamepad.FlxGamepadAnalogStick;

/**
 * IDs for Switch's Left JoyCon controllers
 *
 *-------
 * NOTES
 *-------
 *
 * WINDOWS: untested.
 *
 * LINUX: untested.
 *
 * MAC: Worked on html out of box for me when connected via microUSB cable or Bluetooth.
 * Flash and neko couldn't detect the controller via bluetooth,
 * which is weird because The pro worked wirelessly.
 * 
 * @since 4.8.0
 */
class SwitchJoyconLeftID
{
	#if flash
	public static inline var UP:Int = 8;
	public static inline var LEFT:Int = 9;
	public static inline var DOWN:Int = 10;
	public static inline var RIGHT:Int = 11;
	public static inline var SL:Int = 12;
	public static inline var SR:Int = 13;
	public static inline var ZL:Int = 14;
	public static inline var L:Int = 15;
	public static inline var MINUS:Int = 17;
	public static inline var CAPTURE:Int = 21;
	public static inline var LEFT_STICK_CLICK:Int = 22;
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 24,
		down: 25,
		left: 26,
		right: 27
	});
	#else
	public static inline var ZL:Int = 4;
	public static inline var DOWN:Int = 6;
	public static inline var RIGHT:Int = 7;
	public static inline var LEFT:Int = 8;
	public static inline var UP:Int = 9;
	public static inline var L:Int = 10;
	public static inline var MINUS:Int = 12;
	public static inline var LEFT_STICK_CLICK:Int = 13;
	public static inline var SL:Int = 15;
	public static inline var SR:Int = 16;
	public static inline var CAPTURE:Int = 21;
	public static var LEFT_ANALOG_STICK(default, null) = new FlxGamepadAnalogStick(0, 1, {
		up: 22,
		down: 23,
		left: 24,
		right: 25
	});
	#end
	
}
