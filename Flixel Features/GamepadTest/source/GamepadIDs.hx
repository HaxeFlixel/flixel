package ;

import flixel.system.input.gamepad.XboxButtonID;
import flixel.system.input.gamepad.OUYAButtonID;

/**
 * ...
 * @author ...
 */
class GamepadIDs
{
	inline static public var A:Int = #if (OUYA) OUYAButtonID.O #else XboxButtonID.A #end;
	inline static public var B:Int = #if (OUYA) OUYAButtonID.A #else XboxButtonID.B #end;
	inline static public var X:Int = #if (OUYA) OUYAButtonID.U #else XboxButtonID.X #end;
	inline static public var Y:Int = #if (OUYA) OUYAButtonID.Y #else XboxButtonID.Y #end;
	inline static public var LB:Int = #if (OUYA) OUYAButtonID.LB #else XboxButtonID.LB #end;
	inline static public var RB:Int = #if (OUYA) OUYAButtonID.RB #else XboxButtonID.RB #end;
	inline static public var LEFT_ANALOGUE:Int = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE #else XboxButtonID.LEFT_ANALOGUE #end;
	inline static public var RIGHT_ANALOGUE:Int = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE #else XboxButtonID.RIGHT_ANALOGUE #end;
	inline static public var LEFT_ANALOGUE_X:Int = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_X #else XboxButtonID.LEFT_ANALOGUE_X #end;
	inline static public var LEFT_ANALOGUE_Y:Int = #if (OUYA) OUYAButtonID.LEFT_ANALOGUE_Y #else XboxButtonID.LEFT_ANALOGUE_Y #end;
	inline static public var RIGHT_ANALOGUE_X:Int = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_X #else XboxButtonID.RIGHT_ANALOGUE_X #end;
	inline static public var RIGHT_ANALOGUE_Y:Int = #if (OUYA) OUYAButtonID.RIGHT_ANALOGUE_Y #else XboxButtonID.RIGHT_ANALOGUE_Y #end;
}