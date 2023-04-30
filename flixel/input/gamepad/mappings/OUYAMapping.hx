package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.OUYAID;

class OUYAMapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 19;
	static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 20;

	static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 21;
	static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 22;
	#end

	override function initValues():Void
	{
		leftStick = OUYAID.LEFT_ANALOG_STICK;
		rightStick = OUYAID.RIGHT_ANALOG_STICK;
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case OUYAID.O: A;
			case OUYAID.A: B;
			case OUYAID.U: X;
			case OUYAID.Y: Y;
			case OUYAID.HOME: GUIDE;
			case OUYAID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case OUYAID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case OUYAID.LB: LEFT_SHOULDER;
			case OUYAID.RB: RIGHT_SHOULDER;
			case OUYAID.LEFT_TRIGGER: LEFT_TRIGGER;
			case OUYAID.RIGHT_TRIGGER: RIGHT_TRIGGER;
			case OUYAID.DPAD_UP: DPAD_UP;
			case OUYAID.DPAD_DOWN: DPAD_DOWN;
			case OUYAID.DPAD_LEFT: DPAD_LEFT;
			case OUYAID.DPAD_RIGHT: DPAD_RIGHT;
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
			case A: OUYAID.O;
			case B: OUYAID.A;
			case X: OUYAID.U;
			case Y: OUYAID.Y;
			case GUIDE: OUYAID.HOME;
			case LEFT_STICK_CLICK: OUYAID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: OUYAID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: OUYAID.LB;
			case RIGHT_SHOULDER: OUYAID.RB;
			case DPAD_UP: OUYAID.DPAD_UP;
			case DPAD_DOWN: OUYAID.DPAD_DOWN;
			case DPAD_LEFT: OUYAID.DPAD_LEFT;
			case DPAD_RIGHT: OUYAID.DPAD_RIGHT;
			case LEFT_TRIGGER: OUYAID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: OUYAID.RIGHT_TRIGGER;
			case LEFT_STICK_DIGITAL_UP: OUYAID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: OUYAID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: OUYAID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: OUYAID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: OUYAID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: OUYAID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: OUYAID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: OUYAID.RIGHT_ANALOG_STICK.rawRight;
			default: -1;
		}
	}
	
	override function getInputLabel(id:FlxGamepadInputID)
	{
		return switch (id)
		{
			case A: "o";
			case B: "a";
			case X: "u";
			case Y: "y";
			case GUIDE: "home";
			case _: super.getInputLabel(id);
		}
	}

	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int
	{
		return if (axisID == leftStick.x) LEFT_ANALOG_STICK_FAKE_X; else if (axisID == leftStick.y) LEFT_ANALOG_STICK_FAKE_Y; else if (axisID == rightStick.x)
			RIGHT_ANALOG_STICK_FAKE_X;
		else if (axisID == rightStick.y)
			RIGHT_ANALOG_STICK_FAKE_Y;
		else
			axisID;
	}
	#end
}
