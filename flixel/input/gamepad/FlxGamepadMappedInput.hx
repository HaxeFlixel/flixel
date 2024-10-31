package flixel.input.gamepad;

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
