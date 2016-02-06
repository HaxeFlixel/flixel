package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.PSVitaID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;

class PSVitaMapping extends FlxGamepadMapping
{
	override function initValues():Void 
	{
		leftStick = PSVitaID.LEFT_ANALOG_STICK;
		rightStick = PSVitaID.RIGHT_ANALOG_STICK;
	}
	
	override public function getID(rawID:Int):FlxGamepadInputID 
	{
		return switch (rawID)
		{
			case PSVitaID.X: A;
			case PSVitaID.CIRCLE: B;
			case PSVitaID.SQUARE: X;
			case PSVitaID.TRIANGLE: Y;
			case PSVitaID.SELECT: BACK;
			case PSVitaID.START: START;
			case PSVitaID.L: LEFT_SHOULDER;
			case PSVitaID.R: RIGHT_SHOULDER;
			case PSVitaID.DPAD_DOWN: DPAD_DOWN;
			case PSVitaID.DPAD_UP: DPAD_UP;
			case PSVitaID.DPAD_LEFT: DPAD_LEFT;
			case PSVitaID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	override public function getRawID(ID:FlxGamepadInputID):Int 
	{
		return switch (ID)
		{
			case A: PSVitaID.X;
			case B: PSVitaID.CIRCLE;
			case X: PSVitaID.SQUARE;
			case Y: PSVitaID.TRIANGLE;
			case BACK: PSVitaID.SELECT;
			case START: PSVitaID.START;
			case LEFT_SHOULDER: PSVitaID.L;
			case RIGHT_SHOULDER: PSVitaID.R;
			case DPAD_UP: PSVitaID.DPAD_UP;
			case DPAD_DOWN: PSVitaID.DPAD_DOWN;
			case DPAD_LEFT: PSVitaID.DPAD_LEFT;
			case DPAD_RIGHT: PSVitaID.DPAD_RIGHT;
			default: -1;
		}
	}
	
	override public function isAxisFlipped(axisID:Int):Bool 
	{
		return axisID == PSVitaID.LEFT_ANALOG_STICK.y ||
			axisID == PSVitaID.RIGHT_ANALOG_STICK.y;
	}
}