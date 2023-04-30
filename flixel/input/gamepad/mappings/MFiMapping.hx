package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.MFiID;

class MFiMapping extends FlxGamepadMapping
{
	override function initValues():Void
	{
		leftStick = MFiID.LEFT_ANALOG_STICK;
		rightStick = MFiID.RIGHT_ANALOG_STICK;
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case MFiID.A: A;
			case MFiID.B: B;
			case MFiID.X: X;
			case MFiID.Y: Y;
			case MFiID.BACK: BACK;
			case MFiID.GUIDE: GUIDE;
			case MFiID.START: START;
			case MFiID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case MFiID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case MFiID.LB: LEFT_SHOULDER;
			case MFiID.RB: RIGHT_SHOULDER;
			case MFiID.DPAD_UP: DPAD_UP;
			case MFiID.DPAD_DOWN: DPAD_DOWN;
			case MFiID.DPAD_LEFT: DPAD_LEFT;
			case MFiID.DPAD_RIGHT: DPAD_RIGHT;
			case id if (id == leftStick.rawUp): LEFT_STICK_DIGITAL_UP;
			case id if (id == leftStick.rawDown): LEFT_STICK_DIGITAL_DOWN;
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
			case A: MFiID.A;
			case B: MFiID.B;
			case X: MFiID.X;
			case Y: MFiID.Y;
			case BACK: MFiID.BACK;
			case GUIDE: MFiID.GUIDE;
			case START: MFiID.START;
			case LEFT_STICK_CLICK: MFiID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: MFiID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: MFiID.LB;
			case RIGHT_SHOULDER: MFiID.RB;
			case DPAD_UP: MFiID.DPAD_UP;
			case DPAD_DOWN: MFiID.DPAD_DOWN;
			case DPAD_LEFT: MFiID.DPAD_LEFT;
			case DPAD_RIGHT: MFiID.DPAD_RIGHT;
			case LEFT_TRIGGER: MFiID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: MFiID.RIGHT_TRIGGER;
			case LEFT_STICK_DIGITAL_UP: MFiID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: MFiID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: MFiID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: MFiID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: MFiID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: MFiID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: MFiID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: MFiID.RIGHT_ANALOG_STICK.rawRight;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: MFiID.LEFT_TRIGGER;
			case RIGHT_TRIGGER_FAKE: MFiID.RIGHT_TRIGGER;
			#end
			default: -1;
		}
	}

	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int
	{
		// the axis index values for this don't overlap with anything so we can just return the original values!
		return axisID;
	}
	#end
}
