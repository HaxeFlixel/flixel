package ;

import flixel.input.gamepad.XboxButtonID;
import flixel.input.gamepad.OUYAButtonID;

/**
 * NOTE: This should probably be inside FlxGamepad.
 * @author crazysam
 */
class GamepadIDs
{
	inline public static var A = #if (OUYA) OUYAButtonID.O #else XboxButtonID.A #end;
	inline public static var B = #if (OUYA) OUYAButtonID.A #else XboxButtonID.B #end;
	inline public static var X = #if (OUYA) OUYAButtonID.U #else XboxButtonID.X #end;
	inline public static var Y = #if (OUYA) OUYAButtonID.Y #else XboxButtonID.Y #end;
	inline public static var LB = #if (OUYA) OUYAButtonID.LB #else XboxButtonID.LB #end;
	inline public static var RB = #if (OUYA) OUYAButtonID.RB #else XboxButtonID.RB #end;
	inline public static var START = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.START #end; // hax: there's no start button on the OUYA
	inline public static var SELECT = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.BACK #end;
	inline public static var LEFT_ANALOGUE = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.LEFT_ANALOGUE #end;
	inline public static var RIGHT_ANALOGUE = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.RIGHT_ANALOGUE #end;
	inline public static var LEFT_ANALOGUE_X = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_X #else XboxButtonID.LEFT_ANALOGUE_X #end;
	inline public static var LEFT_ANALOGUE_Y = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_Y #else XboxButtonID.LEFT_ANALOGUE_Y #end;
	inline public static var RIGHT_ANALOGUE_X = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_X #else XboxButtonID.RIGHT_ANALOGUE_X #end;
	inline public static var RIGHT_ANALOGUE_Y = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_Y #else XboxButtonID.RIGHT_ANALOGUE_Y #end;
}