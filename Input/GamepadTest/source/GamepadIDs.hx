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
	public static inline var START = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.START #end; // hax: there's no start button on the OUYA
	public static inline var SELECT = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.BACK #end;
	public static inline var LEFT_ANALOGUE = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.LEFT_ANALOGUE #end;
	public static inline var RIGHT_ANALOGUE = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.RIGHT_ANALOGUE #end;
	public static var LEFT_ANALOGUE_STICK = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_STICK #else XboxButtonID.LEFT_ANALOGUE_STICK #end;
	public static var RIGHT_ANALOGUE_STICK = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_STICK #else XboxButtonID.RIGHT_ANALOGUE_STICK #end;
}