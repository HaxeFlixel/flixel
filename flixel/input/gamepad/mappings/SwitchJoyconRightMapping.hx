package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.SwitchJoyconRightID;

/**
 * @since 4.8.0
 */
class SwitchJoyconRightMapping extends FlxGamepadMapping
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
		leftStick = SwitchJoyconRightID.LEFT_ANALOG_STICK;
		supportsMotion = true;
		supportsPointer = false;
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case SwitchJoyconRightID.A: A;
			case SwitchJoyconRightID.B: X;
			case SwitchJoyconRightID.X: B;
			case SwitchJoyconRightID.Y: Y;
			case SwitchJoyconRightID.HOME: GUIDE;
			case SwitchJoyconRightID.PLUS: START;
			case SwitchJoyconRightID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case SwitchJoyconRightID.SL: LEFT_SHOULDER;
			case SwitchJoyconRightID.SR: RIGHT_SHOULDER;
			case SwitchJoyconRightID.ZR: RIGHT_TRIGGER;
			case SwitchJoyconRightID.R: EXTRA_0;
			case id if (id == leftStick.rawUp): LEFT_STICK_DIGITAL_UP;
			case id if (id == leftStick.rawDown): LEFT_STICK_DIGITAL_DOWN;
			case id if (id == leftStick.rawLeft): LEFT_STICK_DIGITAL_LEFT;
			case id if (id == leftStick.rawRight): LEFT_STICK_DIGITAL_RIGHT;
			case _: NONE;
		}
	}

	override public function getRawID(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: SwitchJoyconRightID.A;
			case B: SwitchJoyconRightID.X;
			case X: SwitchJoyconRightID.B;
			case Y: SwitchJoyconRightID.Y;
			case GUIDE: SwitchJoyconRightID.HOME;
			case START: SwitchJoyconRightID.PLUS;
			case LEFT_STICK_CLICK: SwitchJoyconRightID.LEFT_STICK_CLICK;
			case LEFT_SHOULDER: SwitchJoyconRightID.SL;
			case RIGHT_SHOULDER: SwitchJoyconRightID.SR;
			case EXTRA_0: SwitchJoyconRightID.R;
			case RIGHT_TRIGGER: SwitchJoyconRightID.ZR;
			case LEFT_STICK_DIGITAL_UP: SwitchJoyconRightID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: SwitchJoyconRightID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: SwitchJoyconRightID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: SwitchJoyconRightID.LEFT_ANALOG_STICK.rawRight;
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
			case A: "a";
			case B: "x";
			case X: "b";
			case Y: "y";
			case GUIDE: "home";
			case START: "plus";
			case LEFT_SHOULDER: "sl";
			case RIGHT_SHOULDER: "sr";
			case RIGHT_TRIGGER: "zr";
			case EXTRA_0: "r";
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
			else if (axisID == SwitchJoyconRightID.ZL)
				LEFT_TRIGGER_FAKE;
			else if (axisID == SwitchJoyconRightID.ZR)
				RIGHT_TRIGGER_FAKE;
			else
				axisID;
	}
	#end
}
