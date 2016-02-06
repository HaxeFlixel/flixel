package flixel.input.gamepad.mappings;

import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.XInputID;
import flixel.input.gamepad.mappings.FlxGamepadMapping;

class XInputMapping extends FlxGamepadMapping
{
	#if FLX_JOYSTICK_API
	private static inline var LEFT_ANALOG_STICK_FAKE_X:Int = 15;
	private static inline var LEFT_ANALOG_STICK_FAKE_Y:Int = 16;

	private static inline var RIGHT_ANALOG_STICK_FAKE_X:Int = 17;
	private static inline var RIGHT_ANALOG_STICK_FAKE_Y:Int = 18;

	private static inline var LEFT_TRIGGER_FAKE:Int = 19;
	private static inline var RIGHT_TRIGGER_FAKE:Int = 20;
	#end
	
	override function initValues():Void 
	{
		leftStick = XInputID.LEFT_ANALOG_STICK;
		rightStick = XInputID.RIGHT_ANALOG_STICK;
	}
	
	override public function getID(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case XInputID.A: B;
			case XInputID.B: A;
			case XInputID.X: Y;
			case XInputID.Y: X;
			case XInputID.BACK: BACK;
			case XInputID.GUIDE: GUIDE;
			case XInputID.START: START;
			case XInputID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case XInputID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case XInputID.LB: LEFT_SHOULDER;
			case XInputID.RB: RIGHT_SHOULDER;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: LEFT_TRIGGER;
			case RIGHT_TRIGGER_FAKE: RIGHT_TRIGGER;
			#else
			case XInputID.LEFT_TRIGGER: LEFT_TRIGGER;
			case XInputID.RIGHT_TRIGGER: RIGHT_TRIGGER;
			#end
			case XInputID.DPAD_UP: DPAD_UP;
			case XInputID.DPAD_DOWN: DPAD_DOWN;
			case XInputID.DPAD_LEFT: DPAD_LEFT;
			case XInputID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	override public function getRawID(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: XInputID.A;
			case B: XInputID.B;
			case X: XInputID.X;
			case Y: XInputID.Y;
			case BACK: XInputID.BACK;
			case GUIDE: XInputID.GUIDE;
			case START: XInputID.START;
			case LEFT_STICK_CLICK: XInputID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: XInputID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: XInputID.LB;
			case RIGHT_SHOULDER: XInputID.RB;
			case DPAD_UP: XInputID.DPAD_UP;
			case DPAD_DOWN: XInputID.DPAD_DOWN;
			case DPAD_LEFT: XInputID.DPAD_LEFT;
			case DPAD_RIGHT: XInputID.DPAD_RIGHT;
			case LEFT_TRIGGER: XInputID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: XInputID.RIGHT_TRIGGER;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	#if flash
	override public function isAxisFlipped(axisID:Int):Bool
	{ 
		if (manufacturer == GooglePepper)
			return false;
		
		return axisID == XInputID.LEFT_ANALOG_STICK.y ||
			axisID == XInputID.RIGHT_ANALOG_STICK.y;
	}
	#end
	
	#if FLX_JOYSTICK_API
	override public function axisIndexToRawID(axisID:Int):Int 
	{
		// Analog stick and trigger values overlap with regular buttons so we remap to "fake" button ID's
		return if (axisID == leftStick.x) LEFT_ANALOG_STICK_FAKE_X;
			else if (axisID == leftStick.y) LEFT_ANALOG_STICK_FAKE_Y;
			else if (axisID == rightStick.x) RIGHT_ANALOG_STICK_FAKE_X;
			else if (axisID == rightStick.y) RIGHT_ANALOG_STICK_FAKE_Y;
			else if (axisID == XInputID.LEFT_TRIGGER) LEFT_TRIGGER_FAKE;
			else if (axisID == XInputID.RIGHT_TRIGGER) RIGHT_TRIGGER_FAKE;
			else axisID;
	}
	#end
}