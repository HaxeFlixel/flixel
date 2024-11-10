package flixel.input.gamepad;

import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.id.LogitechID;
import flixel.input.gamepad.id.MayflashWiiRemoteID;
import flixel.input.gamepad.id.MFiID;
import flixel.input.gamepad.id.OUYAID;
import flixel.input.gamepad.id.PS4ID;
import flixel.input.gamepad.id.PSVitaID;
import flixel.input.gamepad.id.SwitchJoyconLeftID;
import flixel.input.gamepad.id.SwitchJoyconRightID;
import flixel.input.gamepad.id.SwitchProID;
import flixel.input.gamepad.id.WiiRemoteID;
import flixel.input.gamepad.id.XInputID;

/**
 * A list of every possible gamepad input from every known device
 * @since 5.9.0
 */
@:using(flixel.input.gamepad.FlxGamepadMappedInput.FlxGamepadMappedInputTools)
enum FlxGamepadMappedInput
{
	LOGITECH(id:LogitechID);
	MAYFLASH_WII(id:MayflashWiiRemoteID);
	MFI(id:MFiID);
	OUYA(id:OUYAID);
	PS4(id:PS4ID);
	PS_VITA(id:PSVitaID);
	SWITCH_JOYCON_LEFT(id:SwitchJoyconLeftID);
	SWITCH_JOYCON_RIGHT(id:SwitchJoyconRightID);
	SWITCH_PRO(id:SwitchProID);
	WII(id:WiiRemoteID);
	X_INPUT(id:XInputID);
	UNKNOWN(id:FlxGamepadInputID);
}

private class FlxGamepadMappedInputTools
{
	public static inline function toModel(input:FlxGamepadMappedInput):FlxGamepadModel
	{
		return switch input
		{
			case FlxGamepadMappedInput.OUYA(_): FlxGamepadModel.OUYA;
			case FlxGamepadMappedInput.PS4(_): FlxGamepadModel.PS4;
			case FlxGamepadMappedInput.PS_VITA(_): FlxGamepadModel.PSVITA;
			case FlxGamepadMappedInput.LOGITECH(_): FlxGamepadModel.LOGITECH;
			case FlxGamepadMappedInput.X_INPUT(_): FlxGamepadModel.XINPUT;
			case FlxGamepadMappedInput.WII(_): FlxGamepadModel.WII_REMOTE;
			case FlxGamepadMappedInput.MAYFLASH_WII(_): FlxGamepadModel.MAYFLASH_WII_REMOTE;
			case FlxGamepadMappedInput.SWITCH_PRO(_): FlxGamepadModel.SWITCH_PRO;
			case FlxGamepadMappedInput.SWITCH_JOYCON_LEFT(_): FlxGamepadModel.SWITCH_JOYCON_LEFT;
			case FlxGamepadMappedInput.SWITCH_JOYCON_RIGHT(_): FlxGamepadModel.SWITCH_JOYCON_RIGHT;
			case FlxGamepadMappedInput.MFI(_): FlxGamepadModel.MFI;
			case FlxGamepadMappedInput.UNKNOWN(_): FlxGamepadModel.UNKNOWN;
		}
	}
}