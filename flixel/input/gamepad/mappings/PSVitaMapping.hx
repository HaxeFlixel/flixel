package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.PSVitaID;

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
			case id if (id == leftStick.rawUp): LEFT_STICK_DIGITAL_UP;
			case id if (id == leftStick.rawDown): LEFT_STICK_DIGITAL_UP;
			case id if (id == leftStick.rawLeft): LEFT_STICK_DIGITAL_LEFT;
			case id if (id == leftStick.rawRight): LEFT_STICK_DIGITAL_RIGHT;
			case id if (id == rightStick.rawUp): RIGHT_STICK_DIGITAL_UP;
			case id if (id == rightStick.rawDown): RIGHT_STICK_DIGITAL_DOWN;
			case id if (id == rightStick.rawLeft): RIGHT_STICK_DIGITAL_LEFT;
			case id if (id == rightStick.rawRight): RIGHT_STICK_DIGITAL_RIGHT;
			case _: NONE;
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
			case LEFT_STICK_DIGITAL_UP: PSVitaID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: PSVitaID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: PSVitaID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: PSVitaID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: PSVitaID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: PSVitaID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: PSVitaID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: PSVitaID.RIGHT_ANALOG_STICK.rawRight;
			default: -1;
		}
	}
	
	override function getInputLabel(id:FlxGamepadInputID)
	{
		return switch (id)
		{
			case A: "x";
			case B: "circle";
			case X: "square";
			case Y: "triangle";
			case BACK: "select";
			case LEFT_SHOULDER: "l1";
			case RIGHT_SHOULDER: "r1";
			case LEFT_TRIGGER: "l2";
			case RIGHT_TRIGGER: "r2";
			case _: super.getInputLabel(id);
		}
	}

	override public function isAxisFlipped(axisID:Int):Bool
	{
		return axisID == PSVitaID.LEFT_ANALOG_STICK.y || axisID == PSVitaID.RIGHT_ANALOG_STICK.y;
	}
}
