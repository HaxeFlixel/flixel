package flixel.input.gamepad;
import flixel.input.gamepad.buttons.LogitechButtonID;
import flixel.input.gamepad.buttons.OUYAButtonID;
import flixel.input.gamepad.buttons.PS3ButtonID;
import flixel.input.gamepad.buttons.PS4ButtonID;
import flixel.input.gamepad.buttons.XBox360ButtonID;
import flixel.input.gamepad.buttons.XInputButtonID;
import flixel.input.gamepad.FlxGamepadButtonID;
import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepad.GamepadModel;

/**
 * ...
 * @author larsiusprime
 */
class FlxGamepadMapping
{
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var model(default, null):GamepadModel;
	
	public function new(Model:GamepadModel) 
	{
		model = Model;
	}
	
	/**
	 * Given a ButtonID, return the raw hardware code
	 * @param	buttonID the "universal" ButtonID
	 * @return	the raw hardware code
	 */
	public function getRaw(buttonID:FlxGamepadButtonID):Int
	{
		return switch(model)
		{
			case Logitech: getRawLogitech(buttonID);
			case OUYA: getRawOUYA(buttonID);
			case PS3: getRawPS3(buttonID);
			case PS4: getRawPS4(buttonID);
			case XBox360: getRawXBox360(buttonID);
			case XInput: getRawXInput(buttonID);
			default: -1;
		}
	}
	
	/**
	 * Given a raw hardware code, return the "universal" ButtonID
	 * @param	RawID	the raw hardware code
	 * @return	the "universal" ButtonID
	 */
	public function getBtn(RawID:Int):FlxGamepadButtonID
	{
		return switch(model)
		{
			case Logitech: getBtnLogitech(RawID);
			case OUYA: getBtnOUYA(RawID);
			case PS3: getBtnPS3(RawID);
			case PS4: getBtnPS4(RawID);
			case XBox360: getBtnXBox360(RawID);
			case XInput: getBtnXInput(RawID);
			default: NONE;
		}
	}
	
	/**
	 * Given a ButtonID, return the raw AnalogStick axes data structure
	 * @param	buttonID	the "universal" ButtonID
	 * @return	structure containing raw analog stick axes integer codes
	 */
	public function getRawAnalogStick(buttonID:FlxGamepadButtonID):FlxGamepadAnalogStick
	{
		if (buttonID == FlxGamepadButtonID.LEFT_ANALOG_STICK)
		{
			return switch(model)
			{
				case Logitech: LogitechButtonID.LEFT_ANALOG_STICK;
				case OUYA: OUYAButtonID.LEFT_ANALOG_STICK;
				case PS3: PS3ButtonID.LEFT_ANALOG_STICK;
				case PS4: PS4ButtonID.LEFT_ANALOG_STICK;
				case XBox360: XBox360ButtonID.LEFT_ANALOG_STICK;
				case XInput: XInputButtonID.LEFT_ANALOG_STICK;
				default: null;
			}
		}
		if (buttonID == FlxGamepadButtonID.RIGHT_ANALOG_STICK)
		{
			return switch(model)
			{
				case Logitech: LogitechButtonID.RIGHT_ANALOG_STICK;
				case OUYA: OUYAButtonID.RIGHT_ANALOG_STICK;
				case PS3: PS3ButtonID.RIGHT_ANALOG_STICK;
				case PS4: PS4ButtonID.RIGHT_ANALOG_STICK;
				case XBox360: XBox360ButtonID.RIGHT_ANALOG_STICK;
				case XInput: XInputButtonID.RIGHT_ANALOG_STICK;
				default: null;
			}
		}
		return null;
	}
	
	public function getRawOUYA(buttonID:FlxGamepadButtonID):Int
	{
		return switch(buttonID)
		{
			case A: OUYAButtonID.O;
			case B: OUYAButtonID.A;
			case X: OUYAButtonID.U;
			case Y: OUYAButtonID.Y;
			case GUIDE: OUYAButtonID.HOME;
			case LEFT_STICK_CLICK: OUYAButtonID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: OUYAButtonID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: OUYAButtonID.LB;
			case RIGHT_SHOULDER: OUYAButtonID.RB;
			//case BACK:
			//case START:
			//case DPAD_UP:
			//case DPAD_DOWN:
			//case DPAD_LEFT:
			//case DPAD_RIGHT:
			default: -1;
		}
	}
	
	public function getRawLogitech(buttonID:FlxGamepadButtonID):Int
	{
		return switch(buttonID)
		{
			case A: LogitechButtonID.TWO;
			case B: LogitechButtonID.THREE;
			case X: LogitechButtonID.ONE;
			case Y: LogitechButtonID.FOUR;
			case BACK: LogitechButtonID.NINE;
			case START: LogitechButtonID.TEN;
			case LEFT_STICK_CLICK: LogitechButtonID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: LogitechButtonID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: LogitechButtonID.FIVE;
			case RIGHT_SHOULDER: LogitechButtonID.SIX;
			case LEFT_TRIGGER: LogitechButtonID.SEVEN;
			case RIGHT_TRIGGER: LogitechButtonID.EIGHT;
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
			//case GUIDE:
			default: -1;
		}
	}
	
	public function getRawPS4(buttonID:FlxGamepadButtonID):Int
	{
		return switch(buttonID)
		{
			case A: PS4ButtonID.X;
			case B: PS4ButtonID.CIRCLE;
			case X: PS4ButtonID.SQUARE;
			case Y: PS4ButtonID.TRIANGLE;
			case BACK: PS4ButtonID.SELECT;
			case GUIDE: PS4ButtonID.PS;
			case START: PS4ButtonID.START;
			case LEFT_STICK_CLICK: PS4ButtonID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: PS4ButtonID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: PS4ButtonID.L1;
			case RIGHT_SHOULDER: PS4ButtonID.R1;
			case LEFT_TRIGGER: PS4ButtonID.L2;
			case RIGHT_TRIGGER: PS4ButtonID.R2;
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
			default: -1;
		}
	}
	
	public function getRawPS3(buttonID:FlxGamepadButtonID):Int
	{
		return switch(buttonID)
		{
			case A: PS3ButtonID.X;
			case B: PS3ButtonID.CIRCLE;
			case X: PS3ButtonID.SQUARE;
			case Y: PS3ButtonID.TRIANGLE;
			case BACK: PS3ButtonID.SELECT;
			case GUIDE: PS3ButtonID.PS;
			case START: PS3ButtonID.START;
			case LEFT_STICK_CLICK: PS3ButtonID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: PS3ButtonID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: PS3ButtonID.L1;
			case RIGHT_SHOULDER: PS3ButtonID.R1;
			case LEFT_TRIGGER: PS3ButtonID.L2;
			case RIGHT_TRIGGER: PS3ButtonID.R2;
			case DPAD_UP: PS3ButtonID.DPAD_UP;
			case DPAD_DOWN: PS3ButtonID.DPAD_DOWN;
			case DPAD_LEFT: PS3ButtonID.DPAD_LEFT;
			case DPAD_RIGHT: PS3ButtonID.DPAD_RIGHT;
			default: -1;
		}
	}
	
	public function getRawXBox360(buttonID:FlxGamepadButtonID):Int
	{
		return switch(buttonID)
		{
			case A: XBox360ButtonID.A;
			case B: XBox360ButtonID.B;
			case X: XBox360ButtonID.X;
			case Y: XBox360ButtonID.Y;
			case BACK: XBox360ButtonID.BACK;
			case GUIDE: XBox360ButtonID.XBOX;
			case START: XBox360ButtonID.START;
			case LEFT_STICK_CLICK: XBox360ButtonID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: XBox360ButtonID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: XBox360ButtonID.LB;
			case RIGHT_SHOULDER: XBox360ButtonID.RB;
			case DPAD_UP: XBox360ButtonID.DPAD_UP;
			case DPAD_DOWN: XBox360ButtonID.DPAD_DOWN;
			case DPAD_LEFT: XBox360ButtonID.DPAD_LEFT;
			case DPAD_RIGHT: XBox360ButtonID.DPAD_RIGHT;
			
			case LEFT_TRIGGER:  XBox360ButtonID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: XBox360ButtonID.RIGHT_TRIGGER;
			
			default: -1;
		}
	}
	
	public function getRawXInput(buttonID:FlxGamepadButtonID):Int
	{
		return switch(buttonID)
		{
			case A: XInputButtonID.A;
			case B: XInputButtonID.B;
			case X: XInputButtonID.X;
			case Y: XInputButtonID.Y;
			case BACK: XInputButtonID.BACK;
			case GUIDE: XInputButtonID.GUIDE;
			case START: XInputButtonID.START;
			case LEFT_STICK_CLICK: XInputButtonID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: XInputButtonID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: XInputButtonID.LB;
			case RIGHT_SHOULDER: XInputButtonID.RB;
			case DPAD_UP: XInputButtonID.DPAD_UP;
			case DPAD_DOWN: XInputButtonID.DPAD_DOWN;
			case DPAD_LEFT: XInputButtonID.DPAD_LEFT;
			case DPAD_RIGHT: XInputButtonID.DPAD_RIGHT;
			
			case LEFT_TRIGGER: XInputButtonID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: XInputButtonID.RIGHT_TRIGGER;
			
			//case LEFT_TRIGGER: 
			//case RIGHT_TRIGGER: 
			default: -1;
		}
	}
	
	public function getBtnOUYA(rawID:Int):FlxGamepadButtonID
	{
		return switch(rawID)
		{
			case OUYAButtonID.O: A;
			case OUYAButtonID.A: B;
			case OUYAButtonID.U: X;
			case OUYAButtonID.Y: Y;
			case OUYAButtonID.HOME: GUIDE;
			case OUYAButtonID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case OUYAButtonID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case OUYAButtonID.LB: LEFT_SHOULDER;
			case OUYAButtonID.RB: RIGHT_SHOULDER;
			//case BACK:
			//case START:
			//case DPAD_UP:
			//case DPAD_DOWN:
			//case DPAD_LEFT:
			//case DPAD_RIGHT:
			default: NONE;
		}
	}
	
	public function getBtnLogitech(rawID:Int):FlxGamepadButtonID
	{
		return switch(rawID)
		{
			case LogitechButtonID.TWO: A;
			case LogitechButtonID.THREE: B;
			case LogitechButtonID.ONE: X;
			case LogitechButtonID.FOUR: Y;
			case LogitechButtonID.NINE: BACK;
			case LogitechButtonID.TEN: START;
			case LogitechButtonID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case LogitechButtonID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case LogitechButtonID.FIVE: LEFT_SHOULDER;
			case LogitechButtonID.SIX: RIGHT_SHOULDER;
			case LogitechButtonID.SEVEN: LEFT_TRIGGER;
			case LogitechButtonID.EIGHT: RIGHT_TRIGGER;
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
			//case GUIDE:
			default: NONE;
		}
	}
	
	public function getBtnPS4(rawID:Int):FlxGamepadButtonID
	{
		return switch(rawID)
		{
			case PS4ButtonID.X: A;
			case PS4ButtonID.CIRCLE: B;
			case PS4ButtonID.SQUARE: X;
			case PS4ButtonID.TRIANGLE: Y;
			case PS4ButtonID.SELECT: BACK;
			case PS4ButtonID.PS: GUIDE;
			case PS4ButtonID.START: START;
			case PS4ButtonID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case PS4ButtonID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case PS4ButtonID.L1: LEFT_SHOULDER;
			case PS4ButtonID.R1: RIGHT_SHOULDER;
			case PS4ButtonID.L2: LEFT_TRIGGER;
			case PS4ButtonID.R2: RIGHT_TRIGGER;
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
			default: NONE;
		}
	}
	
	public function getBtnPS3(rawID:Int):FlxGamepadButtonID
	{
		return switch(rawID)
		{
			case PS3ButtonID.X: A;
			case PS3ButtonID.CIRCLE: B;
			case PS3ButtonID.SQUARE: X;
			case PS3ButtonID.TRIANGLE: Y;
			case PS3ButtonID.SELECT: BACK;
			case PS3ButtonID.PS: GUIDE;
			case PS3ButtonID.START: START;
			case PS3ButtonID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case PS3ButtonID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case PS3ButtonID.L1: LEFT_SHOULDER;
			case PS3ButtonID.R1: RIGHT_SHOULDER;
			case PS3ButtonID.L2: LEFT_TRIGGER;
			case PS3ButtonID.R2: RIGHT_TRIGGER;
			case PS3ButtonID.DPAD_UP: DPAD_UP;
			case PS3ButtonID.DPAD_DOWN: DPAD_DOWN;
			case PS3ButtonID.DPAD_LEFT: DPAD_LEFT;
			case PS3ButtonID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	public function getBtnXBox360(rawID:Int):FlxGamepadButtonID
	{
		return switch(rawID)
		{
			case XBox360ButtonID.A: A;
			case XBox360ButtonID.B: B;
			case XBox360ButtonID.X: X;
			case XBox360ButtonID.Y: Y;
			case XBox360ButtonID.BACK: BACK;
			case XBox360ButtonID.XBOX: GUIDE;
			case XBox360ButtonID.START: START;
			case XBox360ButtonID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case XBox360ButtonID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case XBox360ButtonID.LB: LEFT_SHOULDER;
			case XBox360ButtonID.RB: RIGHT_SHOULDER;
			case XBox360ButtonID.DPAD_UP: DPAD_UP;
			case XBox360ButtonID.DPAD_DOWN: DPAD_DOWN;
			case XBox360ButtonID.DPAD_LEFT: DPAD_LEFT;
			case XBox360ButtonID.DPAD_RIGHT: DPAD_RIGHT;
			
			//case XBox360ButtonID.LEFT_TRIGGER: LEFT_TRIGGER;
			//case XBox360ButtonID.RIGHT_TRIGGER: RIGHT_TRIGGER;
			//case LEFT_TRIGGER: 
			//case RIGHT_TRIGGER: 
			default: NONE;
		}
	}
	
	public function getBtnXInput(rawID:Int):FlxGamepadButtonID
	{
		return switch(rawID)
		{
			case XInputButtonID.A: A;
			case XInputButtonID.B: B;
			case XInputButtonID.X: X;
			case XInputButtonID.Y: Y;
			case XInputButtonID.BACK: BACK;
			case XInputButtonID.GUIDE: GUIDE;
			case XInputButtonID.START: START;
			case XInputButtonID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case XInputButtonID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case XInputButtonID.LB: LEFT_SHOULDER;
			case XInputButtonID.RB: RIGHT_SHOULDER;
			case XInputButtonID.DPAD_UP: DPAD_UP;
			case XInputButtonID.DPAD_DOWN: DPAD_DOWN;
			case XInputButtonID.DPAD_LEFT: DPAD_LEFT;
			case XInputButtonID.DPAD_RIGHT: DPAD_RIGHT;
			
			case XInputButtonID.LEFT_TRIGGER: LEFT_TRIGGER;
			case XInputButtonID.RIGHT_TRIGGER: RIGHT_TRIGGER;
			default: NONE;
		}
	}
}