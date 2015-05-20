package flixel.input.gamepad;
import flixel.input.gamepad.FlxGamepad.GamepadButtonID;
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
	
	public function get(button:GamepadButtonID):Int
	{
		return switch(model)
		{
			case Logitech: getLogitech(button);
			case OUYA: getOUYA(button);
			case PS3: getPS3(button);
			case PS4: getPS4(button);
			case Xbox: getXbox(button);
			default: -1;
		}
	}
	
	public inline function getOUYA(button:GamepadButtonID):Int
	{
		return switch(button)
		{
			case A: OUYAButtonID.O;
			case B: OUYAButtonID.A;
			case X: OUYAButtonID.U;
			case Y: OUYAButtonID.Y;
			case GUIDE: OUYAButtonID.HOME;
			case LEFT_STICK: OUYAButtonID.LEFT_ANALOG;
			case RIGHT_STICK: OUYAButtonID.RIGHT_ANALOG;
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
	
	public inline function getLogitech(button:GamepadButtonID):Int
	{
		return switch(button)
		{
			case A: LogitechButtonID.TWO;
			case B: LogitechButtonID.THREE;
			case X: LogitechButtonID.ONE;
			case Y: LogitechButtonID.FOUR;
			case BACK: LogitechButtonID.NINE;
			case START: LogitechButtonID.TEN;
			case LEFT_STICK: LogitechButtonID.LEFT_ANALOG;
			case RIGHT_STICK: LogitechButtonID.RIGHT_ANALOG;
			case LEFT_SHOULDER: LogitechButtonID.FIVE;
			case RIGHT_SHOULDER: LogitechButtonID.SIX;
			case LEFT_TRIGGER: LogitechButtonID.SEVEN;
			case RIGHT_TRIGGER: LogitechButtonID.EIGHT;
			case DPAD_UP: LogitechButtonID.DPAD_UP;
			case DPAD_DOWN: LogitechButtonID.DPAD_DOWN;
			case DPAD_LEFT: LogitechButtonID.DPAD_LEFT;
			case DPAD_RIGHT: LogitechButtonID.DPAD_RIGHT;
			//case GUIDE:
			default: -1;
		}
	}
	
	public inline function getPS4(button:GamepadButtonID):Int
	{
		return switch(button)
		{
			case A: PS4ButtonID.X;
			case B: PS4ButtonID.CIRCLE;
			case X: PS4ButtonID.SQUARE;
			case Y: PS4ButtonID.TRIANGLE;
			case BACK: PS4ButtonID.SELECT;
			case GUIDE: PS4ButtonID.PS;
			case START: PS4ButtonID.START;
			case LEFT_STICK: PS4ButtonID.LEFT_ANALOG;
			case RIGHT_STICK: PS4ButtonID.RIGHT_ANALOG;
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
	
	public inline function getPS3(button:GamepadButtonID):Int
	{
		return switch(button)
		{
			case A: PS3ButtonID.X;
			case B: PS3ButtonID.CIRCLE;
			case X: PS3ButtonID.SQUARE;
			case Y: PS3ButtonID.TRIANGLE;
			case BACK: PS3ButtonID.SELECT;
			case GUIDE: PS3ButtonID.PS;
			case START: PS3ButtonID.START;
			case LEFT_STICK: PS3ButtonID.LEFT_ANALOG;
			case RIGHT_STICK: PS3ButtonID.RIGHT_ANALOG;
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
	
	public inline function getXbox(button:GamepadButtonID):Int
	{
		return switch(button)
		{
			case A: XboxButtonID.A;
			case B: XboxButtonID.B;
			case X: XboxButtonID.X;
			case Y: XboxButtonID.Y;
			case BACK: XboxButtonID.BACK;
			case GUIDE: XboxButtonID.XBOX;
			case START: XboxButtonID.START;
			case LEFT_STICK: XboxButtonID.LEFT_ANALOG;
			case RIGHT_STICK: XboxButtonID.RIGHT_ANALOG;
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
}