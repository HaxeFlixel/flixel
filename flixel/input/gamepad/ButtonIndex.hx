package flixel.input.gamepad;
import flixel.input.gamepad.ButtonID;
import flixel.input.gamepad.FlxGamepad.GamepadModel;

/**
 * ...
 * @author larsiusprime
 */
class ButtonIndex
{
	public var model:GamepadModel;
	
	public function new(Model:GamepadModel) 
	{
		model = Model;
	}
	
	/**
	 * Given a ButtonID, return the raw hardware code
	 * @param	buttonID the "universal" ButtonID
	 * @return	the raw hardware code
	 */
	
	public inline function getRaw(buttonID:ButtonID):Int
	{
		return switch(model)
		{
			case Logitech: getRawLogitech(buttonID);
			case OUYA: getRawOUYA(buttonID);
			case PS3: getRawPS3(buttonID);
			case PS4: getRawPS4(buttonID);
			case Xbox: getRawXbox(buttonID);
			default: -1;
		}
	}
	
	/**
	 * Given a raw hardware code, return the "universal" ButtonID
	 * @param	RawID	the raw hardware code
	 * @return	the "universal" ButtonID
	 */
	
	public inline function getBtn(RawID:Int):ButtonID
	{
		return switch(model)
		{
			case Logitech: getBtnLogitech(RawID);
			case OUYA: getBtnOUYA(RawID);
			case PS3: getBtnPS3(RawID);
			case PS4: getBtnPS4(RawID);
			case Xbox: getBtnXbox(RawID);
			default: NONE;
		}
	}
	
	public inline function getRawOUYA(buttonID:ButtonID):Int
	{
		return switch(buttonID)
		{
			case A: OUYAButtonID.O;
			case B: OUYAButtonID.A;
			case X: OUYAButtonID.U;
			case Y: OUYAButtonID.Y;
			case GUIDE: OUYAButtonID.HOME;
			case LEFT_STICK_BTN: OUYAButtonID.LEFT_STICK_BTN;
			case RIGHT_STICK_BTN: OUYAButtonID.RIGHT_STICK_BTN;
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
	
	public inline function getRawLogitech(buttonID:ButtonID):Int
	{
		return switch(buttonID)
		{
			case A: LogitechButtonID.TWO;
			case B: LogitechButtonID.THREE;
			case X: LogitechButtonID.ONE;
			case Y: LogitechButtonID.FOUR;
			case BACK: LogitechButtonID.NINE;
			case START: LogitechButtonID.TEN;
			case LEFT_STICK_BTN: LogitechButtonID.LEFT_STICK_BTN;
			case RIGHT_STICK_BTN: LogitechButtonID.RIGHT_STICK_BTN;
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
	
	public inline function getRawPS4(buttonID:ButtonID):Int
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
			case LEFT_STICK_BTN: PS4ButtonID.LEFT_STICK_BTN;
			case RIGHT_STICK_BTN: PS4ButtonID.RIGHT_STICK_BTN;
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
	
	public inline function getRawPS3(buttonID:ButtonID):Int
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
			case LEFT_STICK_BTN: PS3ButtonID.LEFT_STICK_BTN;
			case RIGHT_STICK_BTN: PS3ButtonID.RIGHT_STICK_BTN;
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
	
	public inline function getRawXbox(buttonID:ButtonID):Int
	{
		return switch(buttonID)
		{
			case A: XboxButtonID.A;
			case B: XboxButtonID.B;
			case X: XboxButtonID.X;
			case Y: XboxButtonID.Y;
			case BACK: XboxButtonID.BACK;
			case GUIDE: XboxButtonID.XBOX;
			case START: XboxButtonID.START;
			case LEFT_STICK_BTN: XboxButtonID.LEFT_STICK_BTN;
			case RIGHT_STICK_BTN: XboxButtonID.RIGHT_STICK_BTN;
			case LEFT_SHOULDER: XboxButtonID.LB;
			case RIGHT_SHOULDER: XboxButtonID.RB;
			case DPAD_UP: XboxButtonID.DPAD_UP;
			case DPAD_DOWN: XboxButtonID.DPAD_DOWN;
			case DPAD_LEFT: XboxButtonID.DPAD_LEFT;
			case DPAD_RIGHT: XboxButtonID.DPAD_RIGHT;
			//case LEFT_TRIGGER: 
			//case RIGHT_TRIGGER: 
			default: -1;
		}
	}
	
	/**************/
	
	public inline function getBtnOUYA(rawID:Int):ButtonID
	{
		return switch(rawID)
		{
			case OUYAButtonID.O: A;
			case OUYAButtonID.A: B;
			case OUYAButtonID.U: X;
			case OUYAButtonID.Y: Y;
			case OUYAButtonID.HOME: GUIDE;
			case OUYAButtonID.LEFT_STICK_BTN: LEFT_STICK_BTN;
			case OUYAButtonID.RIGHT_STICK_BTN: RIGHT_STICK_BTN;
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
	
	public inline function getBtnLogitech(rawID:Int):ButtonID
	{
		return switch(rawID)
		{
			case LogitechButtonID.TWO: A;
			case LogitechButtonID.THREE: B;
			case LogitechButtonID.ONE: X;
			case LogitechButtonID.FOUR: Y;
			case LogitechButtonID.NINE: BACK;
			case LogitechButtonID.TEN: START;
			case LogitechButtonID.LEFT_STICK_BTN: LEFT_STICK_BTN;
			case LogitechButtonID.RIGHT_STICK_BTN: RIGHT_STICK_BTN;
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
	
	public inline function getBtnPS4(rawID:Int):ButtonID
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
			case PS4ButtonID.LEFT_STICK_BTN: LEFT_STICK_BTN;
			case PS4ButtonID.RIGHT_STICK_BTN: RIGHT_STICK_BTN;
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
	
	public inline function getBtnPS3(rawID:Int):ButtonID
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
			case PS3ButtonID.LEFT_STICK_BTN: LEFT_STICK_BTN;
			case PS3ButtonID.RIGHT_STICK_BTN: RIGHT_STICK_BTN;
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
	
	public inline function getBtnXbox(rawID:Int):ButtonID
	{
		return switch(rawID)
		{
			case XboxButtonID.A: A;
			case XboxButtonID.B: B;
			case XboxButtonID.X: X;
			case XboxButtonID.Y: Y;
			case XboxButtonID.BACK: BACK;
			case XboxButtonID.XBOX: GUIDE;
			case XboxButtonID.START: START;
			case XboxButtonID.LEFT_STICK_BTN: LEFT_STICK_BTN;
			case XboxButtonID.RIGHT_STICK_BTN: RIGHT_STICK_BTN;
			case XboxButtonID.LB: LEFT_SHOULDER;
			case XboxButtonID.RB: RIGHT_SHOULDER;
			case XboxButtonID.DPAD_UP: DPAD_UP;
			case XboxButtonID.DPAD_DOWN: DPAD_DOWN;
			case XboxButtonID.DPAD_LEFT: DPAD_LEFT;
			case XboxButtonID.DPAD_RIGHT: DPAD_RIGHT;
			//case LEFT_TRIGGER: 
			//case RIGHT_TRIGGER: 
			default: ButtonID.NONE;
		}
	}
}