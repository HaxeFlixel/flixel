package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepad.FlxGamepadAttachment;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.MayflashWiiRemoteID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;

class MayflashWiiRemoteMapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	private static inline var REMOTE_DPAD_X:Int = 16;
	private static inline var REMOTE_DPAD_Y:Int = 17;

	private static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 18;
	private static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 19;
	private static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 20;
	private static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 21;
	#end
	
	override function initValues():Void 
	{
		//But you'll only get non-zero values for it when the Nunchuk is attached
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
	
	private function getIDClassicController(rawID:Int):FlxGamepadInputID
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
			default: NONE;
		}
	}
	
	private function getIDNunchuk(rawID:Int):FlxGamepadInputID
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
			default: NONE;
		}
	}
	
	private function getIDDefault(rawID:Int):FlxGamepadInputID
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
	
	private function getRawClassicController(ID:FlxGamepadInputID):Int
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
			default: getRawDefault(ID);
		}
	}
	
	private function getRawNunchuk(ID:FlxGamepadInputID):Int
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
			default: -1;
		}
	}
	
	private function getRawDefault(ID:FlxGamepadInputID):Int
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
}