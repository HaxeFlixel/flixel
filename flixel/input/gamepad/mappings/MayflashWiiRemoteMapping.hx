package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepad.FlxGamepadAttachment;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.MayflashWiiRemoteID;

class MayflashWiiRemoteMapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	static inline var REMOTE_DPAD_X:Int = 16;
	static inline var REMOTE_DPAD_Y:Int = 17;

	static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 18;
	static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 19;
	static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 20;
	static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 21;
	#end

	override function initValues():Void
	{
		// but you'll only get non-zero values for it when the Nunchuk is attached
		supportsPointer = true;
	}

	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (attachment)
		{
			case WII_CLASSIC_CONTROLLER: getIDClassicController(rawID);
			case WII_NUNCHUCK: getIDNunchuk(rawID);
			case NONE: getIDDefault(rawID);
		}
	}

	function getIDClassicController(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case MayflashWiiRemoteID.CLASSIC_A: B;
			case MayflashWiiRemoteID.CLASSIC_B: A;
			case MayflashWiiRemoteID.CLASSIC_X: Y;
			case MayflashWiiRemoteID.CLASSIC_Y: X;
			case MayflashWiiRemoteID.CLASSIC_SELECT: BACK;
			case MayflashWiiRemoteID.CLASSIC_HOME: GUIDE;
			case MayflashWiiRemoteID.CLASSIC_START: START;
			case MayflashWiiRemoteID.CLASSIC_L: LEFT_TRIGGER;
			case MayflashWiiRemoteID.CLASSIC_R: RIGHT_TRIGGER;
			case MayflashWiiRemoteID.CLASSIC_ZL: LEFT_SHOULDER;
			case MayflashWiiRemoteID.CLASSIC_ZR: RIGHT_SHOULDER;
			case MayflashWiiRemoteID.CLASSIC_DPAD_UP: DPAD_UP;
			case MayflashWiiRemoteID.CLASSIC_DPAD_DOWN: DPAD_DOWN;
			case MayflashWiiRemoteID.CLASSIC_DPAD_LEFT: DPAD_LEFT;
			case MayflashWiiRemoteID.CLASSIC_DPAD_RIGHT: DPAD_RIGHT;
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

	function getIDNunchuk(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case MayflashWiiRemoteID.NUNCHUK_A: A;
			case MayflashWiiRemoteID.NUNCHUK_B: B;
			case MayflashWiiRemoteID.NUNCHUK_ONE: X;
			case MayflashWiiRemoteID.NUNCHUK_TWO: Y;
			case MayflashWiiRemoteID.NUNCHUK_MINUS: BACK;
			case MayflashWiiRemoteID.NUNCHUK_PLUS: START;
			case MayflashWiiRemoteID.NUNCHUK_HOME: GUIDE;
			case MayflashWiiRemoteID.NUNCHUK_C: LEFT_SHOULDER;
			case MayflashWiiRemoteID.NUNCHUK_Z: LEFT_TRIGGER;
			case MayflashWiiRemoteID.NUNCHUK_DPAD_UP: DPAD_UP;
			case MayflashWiiRemoteID.NUNCHUK_DPAD_DOWN: DPAD_DOWN;
			case MayflashWiiRemoteID.NUNCHUK_DPAD_LEFT: DPAD_LEFT;
			case MayflashWiiRemoteID.NUNCHUK_DPAD_RIGHT: DPAD_RIGHT;
			default:
				if (rawID == MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawUp) LEFT_STICK_DIGITAL_UP;
				if (rawID == MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawDown) LEFT_STICK_DIGITAL_DOWN;
				if (rawID == MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawLeft) LEFT_STICK_DIGITAL_LEFT;
				if (rawID == MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawRight) LEFT_STICK_DIGITAL_RIGHT;
				NONE;
		}
	}

	function getIDDefault(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case MayflashWiiRemoteID.REMOTE_A: A;
			case MayflashWiiRemoteID.REMOTE_B: B;
			case MayflashWiiRemoteID.REMOTE_ONE: X;
			case MayflashWiiRemoteID.REMOTE_TWO: Y;
			case MayflashWiiRemoteID.REMOTE_MINUS: BACK;
			case MayflashWiiRemoteID.REMOTE_HOME: GUIDE;
			case MayflashWiiRemoteID.REMOTE_PLUS: START;
			case MayflashWiiRemoteID.REMOTE_DPAD_UP: DPAD_UP;
			case MayflashWiiRemoteID.REMOTE_DPAD_DOWN: DPAD_DOWN;
			case MayflashWiiRemoteID.REMOTE_DPAD_LEFT: DPAD_LEFT;
			case MayflashWiiRemoteID.REMOTE_DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}

	override public function getRawID(ID:FlxGamepadInputID):Int
	{
		return switch (attachment)
		{
			case WII_CLASSIC_CONTROLLER: getRawClassicController(ID);
			case WII_NUNCHUCK: getRawNunchuk(ID);
			case NONE: getRawDefault(ID);
		}
	}

	function getRawClassicController(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: MayflashWiiRemoteID.CLASSIC_B;
			case B: MayflashWiiRemoteID.CLASSIC_A;
			case X: MayflashWiiRemoteID.CLASSIC_Y;
			case Y: MayflashWiiRemoteID.CLASSIC_X;
			case DPAD_UP: MayflashWiiRemoteID.CLASSIC_DPAD_UP;
			case DPAD_DOWN: MayflashWiiRemoteID.CLASSIC_DPAD_DOWN;
			case DPAD_LEFT: MayflashWiiRemoteID.CLASSIC_DPAD_LEFT;
			case DPAD_RIGHT: MayflashWiiRemoteID.CLASSIC_DPAD_RIGHT;
			case BACK: MayflashWiiRemoteID.CLASSIC_SELECT;
			case GUIDE: MayflashWiiRemoteID.CLASSIC_HOME;
			case START: MayflashWiiRemoteID.CLASSIC_START;
			case LEFT_SHOULDER: MayflashWiiRemoteID.CLASSIC_ZL;
			case RIGHT_SHOULDER: MayflashWiiRemoteID.CLASSIC_ZR;
			case LEFT_TRIGGER: MayflashWiiRemoteID.CLASSIC_L;
			case RIGHT_TRIGGER: MayflashWiiRemoteID.CLASSIC_R;
			case EXTRA_0: MayflashWiiRemoteID.CLASSIC_ONE;
			case EXTRA_1: MayflashWiiRemoteID.CLASSIC_TWO;
			case LEFT_STICK_DIGITAL_UP: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawRight;
			case RIGHT_STICK_DIGITAL_UP: MayflashWiiRemoteID.RIGHT_ANALOG_STICK.rawUp;
			case RIGHT_STICK_DIGITAL_DOWN: MayflashWiiRemoteID.RIGHT_ANALOG_STICK.rawDown;
			case RIGHT_STICK_DIGITAL_LEFT: MayflashWiiRemoteID.RIGHT_ANALOG_STICK.rawLeft;
			case RIGHT_STICK_DIGITAL_RIGHT: MayflashWiiRemoteID.RIGHT_ANALOG_STICK.rawRight;
			default: getRawDefault(ID);
		}
	}

	function getRawNunchuk(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: MayflashWiiRemoteID.NUNCHUK_A;
			case B: MayflashWiiRemoteID.NUNCHUK_B;
			case X: MayflashWiiRemoteID.NUNCHUK_ONE;
			case Y: MayflashWiiRemoteID.NUNCHUK_TWO;
			case BACK: MayflashWiiRemoteID.NUNCHUK_MINUS;
			case START: MayflashWiiRemoteID.NUNCHUK_PLUS;
			case GUIDE: MayflashWiiRemoteID.NUNCHUK_HOME;
			case LEFT_SHOULDER: MayflashWiiRemoteID.NUNCHUK_C;
			case LEFT_TRIGGER: MayflashWiiRemoteID.NUNCHUK_Z;
			case DPAD_UP: MayflashWiiRemoteID.NUNCHUK_DPAD_UP;
			case DPAD_DOWN: MayflashWiiRemoteID.NUNCHUK_DPAD_DOWN;
			case DPAD_LEFT: MayflashWiiRemoteID.NUNCHUK_DPAD_LEFT;
			case DPAD_RIGHT: MayflashWiiRemoteID.NUNCHUK_DPAD_RIGHT;
			case POINTER_X: MayflashWiiRemoteID.NUNCHUK_POINTER_X;
			case POINTER_Y: MayflashWiiRemoteID.NUNCHUK_POINTER_Y;
			case LEFT_STICK_DIGITAL_UP: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawUp;
			case LEFT_STICK_DIGITAL_DOWN: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawDown;
			case LEFT_STICK_DIGITAL_LEFT: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawLeft;
			case LEFT_STICK_DIGITAL_RIGHT: MayflashWiiRemoteID.LEFT_ANALOG_STICK.rawRight;
			default: -1;
		}
	}

	function getRawDefault(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: MayflashWiiRemoteID.REMOTE_A;
			case B: MayflashWiiRemoteID.REMOTE_B;
			case X: MayflashWiiRemoteID.REMOTE_ONE;
			case Y: MayflashWiiRemoteID.REMOTE_TWO;
			case DPAD_UP: MayflashWiiRemoteID.REMOTE_DPAD_UP;
			case DPAD_DOWN: MayflashWiiRemoteID.REMOTE_DPAD_DOWN;
			case DPAD_LEFT: MayflashWiiRemoteID.REMOTE_DPAD_LEFT;
			case DPAD_RIGHT: MayflashWiiRemoteID.REMOTE_DPAD_RIGHT;
			case BACK: MayflashWiiRemoteID.REMOTE_MINUS;
			case GUIDE: MayflashWiiRemoteID.REMOTE_HOME;
			case START: MayflashWiiRemoteID.REMOTE_PLUS;
			default: -1;
		}
	}

	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int
	{
		if (attachment == WII_NUNCHUCK || attachment == WII_CLASSIC_CONTROLLER)
		{
			if (axisID == leftStick.x)
				return LEFT_ANALOG_STICK_FAKE_X;
			else if (axisID == rightStick.y)
				return LEFT_ANALOG_STICK_FAKE_Y;
		}
		else
		{
			if (axisID == leftStick.x)
				return REMOTE_DPAD_X;
			else if (axisID == rightStick.y)
				return REMOTE_DPAD_Y;
		}

		if (axisID == leftStick.x)
			return RIGHT_ANALOG_STICK_FAKE_X;
		else if (axisID == rightStick.y)
			return RIGHT_ANALOG_STICK_FAKE_Y;

		return axisID;
	}

	override public function checkForFakeAxis(ID:FlxGamepadInputID):Int
	{
		if (attachment == WII_NUNCHUCK)
		{
			if (ID == LEFT_TRIGGER)
				return MayflashWiiRemoteID.NUNCHUK_Z;
		}
		else if (attachment == WII_CLASSIC_CONTROLLER)
		{
			if (ID == LEFT_TRIGGER)
				return LEFT_TRIGGER_FAKE;
			if (ID == RIGHT_TRIGGER)
				return RIGHT_TRIGGER_FAKE;
		}
		return -1;
	}
	#end

	override function set_attachment(attachment:FlxGamepadAttachment):FlxGamepadAttachment
	{
		leftStick = switch (attachment)
		{
			case WII_NUNCHUCK, WII_CLASSIC_CONTROLLER: MayflashWiiRemoteID.LEFT_ANALOG_STICK;
			case NONE: MayflashWiiRemoteID.REMOTE_DPAD;
		}

		rightStick = switch (attachment)
		{
			case WII_CLASSIC_CONTROLLER: MayflashWiiRemoteID.RIGHT_ANALOG_STICK;
			default: null;
		}

		return super.set_attachment(attachment);
	}
	
	override function getInputLabel(id:FlxGamepadInputID)
	{
		var label = WiiRemoteMapping.getWiiInputLabel(id, attachment);
		if (label == null)
			return super.getInputLabel(id);
		
		return label;
	}
}
