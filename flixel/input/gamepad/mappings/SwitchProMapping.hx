package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.SwitchProID;

/**
 * @since 4.8.0
 */
class SwitchProMapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 32;
	static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 33;

	static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 34;
	static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 35;

	static inline var LEFT_TRIGGER_FAKE:Int = 36;
	static inline var RIGHT_TRIGGER_FAKE:Int = 37;
	#end

	override function initValues():Void
	{
		leftStick = SwitchProID.LEFT_ANALOG_STICK;
		rightStick = SwitchProID.RIGHT_ANALOG_STICK;
		supportsMotion = true;
		supportsPointer = false;
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case SwitchProID.A: B;
			case SwitchProID.B: A;
			case SwitchProID.X: Y;
			case SwitchProID.Y: X;
			case SwitchProID.MINUS: BACK;
			case SwitchProID.CAPTURE: EXTRA_0;//TODO: Define common Capture inputID?
			case SwitchProID.HOME: GUIDE;
			case SwitchProID.PLUS: START;
			case SwitchProID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case SwitchProID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case SwitchProID.L: LEFT_SHOULDER;
			case SwitchProID.R: RIGHT_SHOULDER;
			case SwitchProID.ZL: LEFT_TRIGGER;
			case SwitchProID.ZR: RIGHT_TRIGGER;
			case SwitchProID.DPAD_DOWN: DPAD_DOWN;
			case SwitchProID.DPAD_UP: DPAD_UP;
			case SwitchProID.DPAD_LEFT: DPAD_LEFT;
			case SwitchProID.DPAD_RIGHT: DPAD_RIGHT;
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
			case A: SwitchProID.B;
			case B: SwitchProID.A;
			case X: SwitchProID.Y;
			case Y: SwitchProID.X;
			case BACK: SwitchProID.MINUS;
			case EXTRA_0: SwitchProID.CAPTURE;
			case GUIDE: SwitchProID.HOME;
			case START: SwitchProID.PLUS;
			case LEFT_STICK_CLICK: SwitchProID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: SwitchProID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: SwitchProID.L;
			case RIGHT_SHOULDER: SwitchProID.R;
			case LEFT_TRIGGER: SwitchProID.ZL;
			case RIGHT_TRIGGER: SwitchProID.ZR;
			case DPAD_UP: SwitchProID.DPAD_UP;
			case DPAD_DOWN: SwitchProID.DPAD_DOWN;
			case DPAD_LEFT: SwitchProID.DPAD_LEFT;
			case DPAD_RIGHT: SwitchProID.DPAD_RIGHT;
			case LEFT_STICK_DIGITAL_UP: SwitchProID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: SwitchProID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: SwitchProID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: SwitchProID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: SwitchProID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: SwitchProID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: SwitchProID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: SwitchProID.RIGHT_ANALOG_STICK.rawRight;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}

	override function getInputLabel(id:FlxGamepadInputID)
	{
		return switch (id)
		{
			case A: "b";
			case B: "a";
			case X: "y";
			case Y: "x";
			case BACK: "minus";
			case GUIDE: "home";
			case START: "plus";
			case EXTRA_0: "capture";
			case LEFT_SHOULDER: "l";
			case RIGHT_SHOULDER: "r";
			case LEFT_TRIGGER: "zl";
			case RIGHT_TRIGGER: "zr";
			case _: super.getInputLabel(id);
		}
	}
	
	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int
	{
		// Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
		return if (axisID == leftStick.x)
				LEFT_ANALOG_STICK_FAKE_X;
			else if (axisID == leftStick.y)
				LEFT_ANALOG_STICK_FAKE_Y;
			else if (axisID == rightStick.x)
				RIGHT_ANALOG_STICK_FAKE_X;
			else if (axisID == rightStick.y)
				RIGHT_ANALOG_STICK_FAKE_Y;
			else if (axisID == SwitchProID.ZL)
				LEFT_TRIGGER_FAKE;
			else if (axisID == SwitchProID.ZR)
				RIGHT_TRIGGER_FAKE;
			else
				axisID;
	}
	#end
}
