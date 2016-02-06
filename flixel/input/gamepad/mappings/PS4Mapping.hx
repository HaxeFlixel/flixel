package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.PS4ID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;

class PS4Mapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	private static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 21;
	private static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 22;

	private static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 23;
	private static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 24;

	private static inline var LEFT_TRIGGER_FAKE:Int = 25;
	private static inline var RIGHT_TRIGGER_FAKE:Int = 26;
	#end
	
	override function initValues():Void 
	{
		leftStick = PS4ID.LEFT_ANALOG_STICK;
		rightStick = PS4ID.RIGHT_ANALOG_STICK;
	}
	
	override public function getID(rawID:Int):FlxGamepadInputID 
	{
		return switch (rawID)
		{
			case PS4ID.X: A;
			case PS4ID.CIRCLE: B;
			case PS4ID.SQUARE: X;
			case PS4ID.TRIANGLE: Y;
			case PS4ID.SHARE: BACK;
			case PS4ID.PS: GUIDE;
			case PS4ID.OPTIONS: START;
			case PS4ID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case PS4ID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case PS4ID.L1: LEFT_SHOULDER;
			case PS4ID.R1: RIGHT_SHOULDER;
			case PS4ID.DPAD_DOWN: DPAD_DOWN;
			case PS4ID.DPAD_UP: DPAD_UP;
			case PS4ID.DPAD_LEFT: DPAD_LEFT;
			case PS4ID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	override public function getRawID(ID:FlxGamepadInputID):Int 
	{
		return switch (ID)
		{
			case A: PS4ID.X;
			case B: PS4ID.CIRCLE;
			case X: PS4ID.SQUARE;
			case Y: PS4ID.TRIANGLE;
			case BACK: PS4ID.SHARE;
			case GUIDE: PS4ID.PS;
			case START: PS4ID.OPTIONS;
			case LEFT_STICK_CLICK: PS4ID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: PS4ID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: PS4ID.L1;
			case RIGHT_SHOULDER: PS4ID.R1;
			case DPAD_UP: PS4ID.DPAD_UP;
			case DPAD_DOWN: PS4ID.DPAD_DOWN;
			case DPAD_LEFT: PS4ID.DPAD_LEFT;
			case DPAD_RIGHT: PS4ID.DPAD_RIGHT;
			case LEFT_TRIGGER: PS4ID.L2;
			case RIGHT_TRIGGER: PS4ID.R2;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int 
	{
		//Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
		return if (axisID == leftStick.x) LEFT_ANALOG_STICK_FAKE_X;
			else if (axisID == leftStick.y) LEFT_ANALOG_STICK_FAKE_Y;
			else if (axisID == rightStick.x) RIGHT_ANALOG_STICK_FAKE_X;
			else if (axisID == rightStick.y) RIGHT_ANALOG_STICK_FAKE_Y;
			else if (axisID == PS4ID.L2) LEFT_TRIGGER_FAKE;
			else if (axisID == PS4ID.R2) RIGHT_TRIGGER_FAKE;
			else axisID;
	}
	#end
}