package ;

import flixel.system.input.gamepad.XboxButtonID;
import flixel.system.input.gamepad.OUYAButtonID;

/**
 * NOTE: This should probably be inside FlxGamepad.
 * @author crazysam
 */
class GamepadIDs
{
	inline static public var A = #if (OUYA) OUYAButtonID.O #else XboxButtonID.A #end;
	inline static public var B = #if (OUYA) OUYAButtonID.A #else XboxButtonID.B #end;
	inline static public var X = #if (OUYA) OUYAButtonID.U #else XboxButtonID.X #end;
	inline static public var Y = #if (OUYA) OUYAButtonID.Y #else XboxButtonID.Y #end;
	inline static public var LB = #if (OUYA) OUYAButtonID.LB #else XboxButtonID.LB #end;
	inline static public var RB = #if (OUYA) OUYAButtonID.RB #else XboxButtonID.RB #end;
	inline static public var START = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.START #end; // hax: there's no start button on the OUYA
	inline static public var SELECT = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.BACK #end;
	inline static public var LEFT_ANALOGUE = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.LEFT_ANALOGUE #end;
	inline static public var RIGHT_ANALOGUE = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.RIGHT_ANALOGUE #end;
	inline static public var LEFT_ANALOGUE_X = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_X #else XboxButtonID.LEFT_ANALOGUE_X #end;
	inline static public var LEFT_ANALOGUE_Y = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_Y #else XboxButtonID.LEFT_ANALOGUE_Y #end;
	inline static public var RIGHT_ANALOGUE_X = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_X #else XboxButtonID.RIGHT_ANALOGUE_X #end;
	inline static public var RIGHT_ANALOGUE_Y = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_Y #else XboxButtonID.RIGHT_ANALOGUE_Y #end;
}