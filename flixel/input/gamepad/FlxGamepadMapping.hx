package flixel.input.gamepad;

import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.LogitechID;
import flixel.input.gamepad.id.OUYAID;
import flixel.input.gamepad.id.PS3ID;
import flixel.input.gamepad.id.PS4ID;
import flixel.input.gamepad.id.XBox360ID;
import flixel.input.gamepad.id.XInputID;

/**
 * ...
 * @author larsiusprime
 */
class FlxGamepadMapping
{
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var model(default, null):FlxGamepadModel;
	
	public function new(Model:FlxGamepadModel) 
	{
		model = Model;
	}
	
	/**
	 * Given a ID, return the raw hardware code
	 * @param	ID the "universal" ID
	 * @return	the raw hardware code
	 */
	public function getRaw(ID:FlxGamepadInputID):Int
	{
		return switch (model)
		{
			case Logitech: getRawLogitech(ID);
			case OUYA: getRawOUYA(ID);
			case PS3: getRawPS3(ID);
			case PS4: getRawPS4(ID);
			case XBox360: getRawXBox360(ID);
			case XInput: getRawXInput(ID);
			default: -1;
		}
	}
	
	/**
	 * Given a raw hardware code, return the "universal" ID
	 * @param	RawID	the raw hardware code
	 * @return	the "universal" ID
	 */
	public function getID(RawID:Int):FlxGamepadInputID
	{
		return switch (model)
		{
			case Logitech: getIDLogitech(RawID);
			case OUYA: getIDOUYA(RawID);
			case PS3: getIDPS3(RawID);
			case PS4: getIDPS4(RawID);
			case XBox360: getIDXBox360(RawID);
			case XInput: getIDXInput(RawID);
			default: NONE;
		}
	}
	
	/**
	 * Given a ID, return the raw AnalogStick axes data structure
	 * @param	ID	the "universal" ID
	 * @return	structure containing raw analog stick axes integer codes
	 */
	public function getRawAnalogStick(ID:FlxGamepadInputID):FlxGamepadAnalogStick
	{
		if (ID == FlxGamepadInputID.LEFT_ANALOG_STICK)
		{
			return switch (model)
			{
				case Logitech: LogitechID.LEFT_ANALOG_STICK;
				case OUYA: OUYAID.LEFT_ANALOG_STICK;
				case PS3: PS3ID.LEFT_ANALOG_STICK;
				case PS4: PS4ID.LEFT_ANALOG_STICK;
				case XBox360: XBox360ID.LEFT_ANALOG_STICK;
				case XInput: XInputID.LEFT_ANALOG_STICK;
				default: null;
			}
		}
		else if (ID == FlxGamepadInputID.RIGHT_ANALOG_STICK)
		{
			return switch (model)
			{
				case Logitech: LogitechID.RIGHT_ANALOG_STICK;
				case OUYA: OUYAID.RIGHT_ANALOG_STICK;
				case PS3: PS3ID.RIGHT_ANALOG_STICK;
				case PS4: PS4ID.RIGHT_ANALOG_STICK;
				case XBox360: XBox360ID.RIGHT_ANALOG_STICK;
				case XInput: XInputID.RIGHT_ANALOG_STICK;
				default: null;
			}
		}
		return null;
	}
	
	#if FLX_JOYSTICK_API
	/**
	 * Given an axis index value like 0-6, figures out which input that corresponds to and returns a "fake" ButtonID for that input
	 */
	public function axisIndexToRawID(AxisID:Int):Int
	{
		return switch (model)
		{
			case Logitech: LogitechID.axisIndexToRawID(AxisID);
			case OUYA: OUYAID.axisIndexToRawID(AxisID);
			case PS3: PS3ID.axisIndexToRawID(AxisID);
			case PS4: PS4ID.axisIndexToRawID(AxisID);
			case XBox360: XBox360ID.axisIndexToRawID(AxisID);
			case XInput: XInputID.axisIndexToRawID(AxisID);
			default: -1;
		}
	}
	#end
	
	public function getRawOUYA(ID:FlxGamepadInputID):Int
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
			default: -1;
		}
	}
	
	public function getRawLogitech(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: LogitechID.TWO;
			case B: LogitechID.THREE;
			case X: LogitechID.ONE;
			case Y: LogitechID.FOUR;
			case BACK: LogitechID.NINE;
			case GUIDE: LogitechID.LOGITECH;
			case START: LogitechID.TEN;
			case LEFT_STICK_CLICK: LogitechID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: LogitechID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: LogitechID.FIVE;
			case RIGHT_SHOULDER: LogitechID.SIX;
			case DPAD_UP: LogitechID.DPAD_UP;
			case DPAD_DOWN: LogitechID.DPAD_DOWN;
			case DPAD_LEFT: LogitechID.DPAD_LEFT;
			case DPAD_RIGHT: LogitechID.DPAD_RIGHT;
			case LEFT_TRIGGER: LogitechID.SEVEN;
			case RIGHT_TRIGGER: LogitechID.EIGHT;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: LogitechID.LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: LogitechID.RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	public function getRawPS4(ID:FlxGamepadInputID):Int
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
			case LEFT_TRIGGER_FAKE: PS4ID.LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: PS4ID.RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	public function getRawPS3(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: PS3ID.X;
			case B: PS3ID.CIRCLE;
			case X: PS3ID.SQUARE;
			case Y: PS3ID.TRIANGLE;
			case BACK: PS3ID.SELECT;
			case GUIDE: PS3ID.PS;
			case START: PS3ID.START;
			case LEFT_STICK_CLICK: PS3ID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: PS3ID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: PS3ID.L1;
			case RIGHT_SHOULDER: PS3ID.R1;
			case DPAD_UP: PS3ID.DPAD_UP;
			case DPAD_DOWN: PS3ID.DPAD_DOWN;
			case DPAD_LEFT: PS3ID.DPAD_LEFT;
			case DPAD_RIGHT: PS3ID.DPAD_RIGHT;
			case LEFT_TRIGGER: PS3ID.L2;
			case RIGHT_TRIGGER: PS3ID.R2;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: PS3ID.LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: PS3ID.RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	public function getRawXBox360(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: XBox360ID.A;
			case B: XBox360ID.B;
			case X: XBox360ID.X;
			case Y: XBox360ID.Y;
			case BACK: XBox360ID.BACK;
			case GUIDE: XBox360ID.XBOX;
			case START: XBox360ID.START;
			case LEFT_STICK_CLICK: XBox360ID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: XBox360ID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: XBox360ID.LB;
			case RIGHT_SHOULDER: XBox360ID.RB;
			case DPAD_UP: XBox360ID.DPAD_UP;
			case DPAD_DOWN: XBox360ID.DPAD_DOWN;
			case DPAD_LEFT: XBox360ID.DPAD_LEFT;
			case DPAD_RIGHT: XBox360ID.DPAD_RIGHT;
			case LEFT_TRIGGER:  XBox360ID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: XBox360ID.RIGHT_TRIGGER;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: XBox360ID.LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: XBox360ID.RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	public function getRawXInput(ID:FlxGamepadInputID):Int
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
			case LEFT_TRIGGER_FAKE: XInputID.LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: XInputID.RIGHT_TRIGGER_FAKE;
			#end
			default: -1;
		}
	}
	
	public function getIDOUYA(rawID:Int):FlxGamepadInputID
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
			case OUYAID.DPAD_UP: DPAD_UP;
			case OUYAID.DPAD_DOWN: DPAD_DOWN;
			case OUYAID.DPAD_LEFT: DPAD_LEFT;
			case OUYAID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	public function getIDLogitech(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case LogitechID.TWO: A;
			case LogitechID.THREE: B;
			case LogitechID.ONE: X;
			case LogitechID.FOUR: Y;
			case LogitechID.NINE: BACK;
			case LogitechID.TEN: START;
			case LogitechID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case LogitechID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case LogitechID.FIVE: LEFT_SHOULDER;
			case LogitechID.SIX: RIGHT_SHOULDER;
			case LogitechID.SEVEN: LEFT_TRIGGER;
			case LogitechID.EIGHT: RIGHT_TRIGGER;
			case LogitechID.DPAD_DOWN: DPAD_DOWN;
			case LogitechID.DPAD_LEFT: DPAD_LEFT;
			case LogitechID.DPAD_RIGHT: DPAD_RIGHT;
			case LogitechID.DPAD_UP: DPAD_UP;
			case LogitechID.LOGITECH: GUIDE;
			default: NONE;
		}
	}
	
	public function getIDPS4(rawID:Int):FlxGamepadInputID
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
	
	public function getIDPS3(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case PS3ID.X: A;
			case PS3ID.CIRCLE: B;
			case PS3ID.SQUARE: X;
			case PS3ID.TRIANGLE: Y;
			case PS3ID.SELECT: BACK;
			case PS3ID.PS: GUIDE;
			case PS3ID.START: START;
			case PS3ID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case PS3ID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case PS3ID.L1: LEFT_SHOULDER;
			case PS3ID.R1: RIGHT_SHOULDER;
			case PS3ID.DPAD_UP: DPAD_UP;
			case PS3ID.DPAD_DOWN: DPAD_DOWN;
			case PS3ID.DPAD_LEFT: DPAD_LEFT;
			case PS3ID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	public function getIDXBox360(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case XBox360ID.A: A;
			case XBox360ID.B: B;
			case XBox360ID.X: X;
			case XBox360ID.Y: Y;
			case XBox360ID.BACK: BACK;
			case XBox360ID.XBOX: GUIDE;
			case XBox360ID.START: START;
			case XBox360ID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case XBox360ID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case XBox360ID.LB: LEFT_SHOULDER;
			case XBox360ID.RB: RIGHT_SHOULDER;
			case XBox360ID.DPAD_UP: DPAD_UP;
			case XBox360ID.DPAD_DOWN: DPAD_DOWN;
			case XBox360ID.DPAD_LEFT: DPAD_LEFT;
			case XBox360ID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	public function getIDXInput(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case XInputID.A: A;
			case XInputID.B: B;
			case XInputID.X: X;
			case XInputID.Y: Y;
			case XInputID.BACK: BACK;
			case XInputID.GUIDE: GUIDE;
			case XInputID.START: START;
			case XInputID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case XInputID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case XInputID.LB: LEFT_SHOULDER;
			case XInputID.RB: RIGHT_SHOULDER;
			case XInputID.DPAD_UP: DPAD_UP;
			case XInputID.DPAD_DOWN: DPAD_DOWN;
			case XInputID.DPAD_LEFT: DPAD_LEFT;
			case XInputID.DPAD_RIGHT: DPAD_RIGHT;
			case XInputID.LEFT_TRIGGER: LEFT_TRIGGER;
			case XInputID.RIGHT_TRIGGER: RIGHT_TRIGGER;
			default: NONE;
		}
	}
}