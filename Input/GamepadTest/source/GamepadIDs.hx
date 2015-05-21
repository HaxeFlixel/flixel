package ;

import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.OUYAButtonID;

/**
 * NOTE: This should probably be inside FlxGamepad.
 * @author crazysam
 */
class GamepadIDs
{
	public static inline var A = #if (OUYA) OUYAButtonID.O #else XboxButtonID.A #end;
	public static inline var B = #if (OUYA) OUYAButtonID.A #else XboxButtonID.B #end;
	public static inline var X = #if (OUYA) OUYAButtonID.U #else XboxButtonID.X #end;
	public static inline var Y = #if (OUYA) OUYAButtonID.Y #else XboxButtonID.Y #end;
	public static inline var LB = #if (OUYA) OUYAButtonID.LB #else XboxButtonID.LB #end;
	public static inline var RB = #if (OUYA) OUYAButtonID.RB #else XboxButtonID.RB #end;
	public static inline var START = #if (OUYA) OUYAButtonID.RIGHT_ANALOG #else XboxButtonID.START #end; // hax: there's no start button on the OUYA
	public static inline var SELECT = #if (OUYA) OUYAButtonID.LEFT_ANALOG #else XboxButtonID.BACK #end;
	public static inline var LEFT_ANALOG = #if (OUYA) OUYAButtonID.LEFT_STICK_BTN #else XboxButtonID.LEFT_STICK_BTN #end;
	public static inline var RIGHT_ANALOG = #if (OUYA) OUYAButtonID.RIGHT_STICK_BTN #else XboxButtonID.RIGHT_STICK_BTN #end;
	public static inline var LEFT_TRIGGER = #if (OUYA) OUYAButtonID.LEFT_TRIGGER #else XboxButtonID.LEFT_TRIGGER #end;
	public static inline var RIGHT_TRIGGER = #if (OUYA) OUYAButtonID.RIGHT_TRIGGER #else XboxButtonID.RIGHT_TRIGGER #end;
	public static var LEFT_ANALOG_STICK = #if (OUYA) OUYAButtonID.LEFT_ANALOG_STICK #else XboxButtonID.LEFT_ANALOG_STICK #end;
	public static var RIGHT_ANALOG_STICK = #if (OUYA) OUYAButtonID.RIGHT_ANALOG_STICK #else XboxButtonID.RIGHT_ANALOG_STICK #end;
}