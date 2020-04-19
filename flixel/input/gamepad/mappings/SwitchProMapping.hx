package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.SWProID;

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
		leftStick = SWProID.LEFT_ANALOG_STICK;
		rightStick = SWProID.RIGHT_ANALOG_STICK;
		supportsMotion = true;
		supportsPointer = false;
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case SWProID.A: B;
			case SWProID.B: A;
			case SWProID.X: Y;
			case SWProID.Y: X;
			case SWProID.MINUS: BACK;
			case SWProID.CAPTURE: EXTRA_0;//TODO: Define common Capture inputID?
			case SWProID.HOME: GUIDE;
			case SWProID.PLUS: START;
			case SWProID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case SWProID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case SWProID.L: LEFT_SHOULDER;
			case SWProID.R: RIGHT_SHOULDER;
			case SWProID.ZL: LEFT_TRIGGER;
			case SWProID.ZR: RIGHT_TRIGGER;
			case SWProID.DPAD_DOWN: DPAD_DOWN;
			case SWProID.DPAD_UP: DPAD_UP;
			case SWProID.DPAD_LEFT: DPAD_LEFT;
			case SWProID.DPAD_RIGHT: DPAD_RIGHT;
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
			case A: SWProID.B;
			case B: SWProID.A;
			case X: SWProID.Y;
			case Y: SWProID.X;
			case BACK: SWProID.MINUS;
			case EXTRA_0: SWProID.CAPTURE;
			case GUIDE: SWProID.HOME;
			case START: SWProID.PLUS;
			case LEFT_STICK_CLICK: SWProID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: SWProID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: SWProID.L;
			case RIGHT_SHOULDER: SWProID.R;
			case LEFT_TRIGGER: SWProID.ZL;
			case RIGHT_TRIGGER: SWProID.ZR;
			case DPAD_UP: SWProID.DPAD_UP;
			case DPAD_DOWN: SWProID.DPAD_DOWN;
			case DPAD_LEFT: SWProID.DPAD_LEFT;
			case DPAD_RIGHT: SWProID.DPAD_RIGHT;
			case LEFT_STICK_DIGITAL_UP: SWProID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: SWProID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: SWProID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: SWProID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: SWProID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: SWProID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: SWProID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: SWProID.RIGHT_ANALOG_STICK.rawRight;
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
			else if (axisID == SWProID.ZL)
				LEFT_TRIGGER_FAKE;
			else if (axisID == SWProID.ZR)
				RIGHT_TRIGGER_FAKE;
			else
				axisID;
	}
	#end
}
