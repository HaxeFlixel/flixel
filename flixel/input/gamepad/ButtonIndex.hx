package flixel.input.gamepad;
import flixel.input.gamepad.FlxGamepad.GamepadAxisID;
import flixel.input.gamepad.FlxGamepad.GamepadButtonID;
import flixel.input.gamepad.FlxGamepad.GamepadModel;
import flixel.input.gamepad.FlxGamepad.FlxAxes;

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
			case XInput: getXInput(button);
			default: -1;
		}
	}
	
	public function toButtonID(i:Int):GamepadButtonID
	{
		return switch(model)
		{
			case Logitech: toLogitech(i);
			case OUYA: toOUYA(i);
			case PS3: toPS3(i);
			case PS4: toPS4(i);
			case Xbox: toXbox(i);
			case XInput: toXInput(i);
			default: UNKNOWN;
		}
	}
	
	public function getAxis(button:GamepadAxisID):Int
	{
		return switch(model)
		{
			case Logitech: getAxisLogitech(button);
			case OUYA: getAxisOUYA(button);
			case PS3: getAxisPS3(button);
			case PS4: getAxisPS4(button);
			case Xbox: getAxisXbox(button);
			case XInput: getAxisXInput(button);
			default: -1;
		}
	}
	
	/****give GamepadButtonID, get int****/
	
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
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
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
			default: -1;
		}
	}
	
	public inline function getXInput(button:GamepadButtonID):Int
	{
		return switch(button)
		{
			case A: XInputButtonID.A;
			case B: XInputButtonID.B;
			case X: XInputButtonID.X;
			case Y: XInputButtonID.Y;
			case BACK: XInputButtonID.BACK;
			case GUIDE: XInputButtonID.GUIDE;
			case START: XInputButtonID.START;
			case LEFT_STICK: XInputButtonID.LEFT_ANALOG;
			case RIGHT_STICK: XInputButtonID.RIGHT_ANALOG;
			case LEFT_SHOULDER: XInputButtonID.LB;
			case RIGHT_SHOULDER: XInputButtonID.RB;
			case DPAD_UP: XInputButtonID.DPAD_UP;
			case DPAD_DOWN: XInputButtonID.DPAD_DOWN;
			case DPAD_LEFT: XInputButtonID.DPAD_LEFT;
			case DPAD_RIGHT: XInputButtonID.DPAD_RIGHT;
			default: -1;
		}
	}
	
	/****give Int, get GamepadButtonID****/
	
	public inline function toOUYA(button:Int):GamepadButtonID
	{
		return switch(button)
		{
			case OUYAButtonID.O: A;
			case OUYAButtonID.A: B;
			case OUYAButtonID.U: X;
			case OUYAButtonID.Y: Y;
			case OUYAButtonID.HOME: GUIDE;
			case OUYAButtonID.LEFT_ANALOG: LEFT_STICK;
			case OUYAButtonID.RIGHT_ANALOG: RIGHT_STICK;
			case OUYAButtonID.LB: LEFT_SHOULDER;
			case OUYAButtonID.RB: RIGHT_SHOULDER;
			//case BACK:
			//case START:
			//case DPAD_UP:
			//case DPAD_DOWN:
			//case DPAD_LEFT:
			//case DPAD_RIGHT:
			default: UNKNOWN;
		}
	}
	
	public inline function toLogitech(button:Int):GamepadButtonID
	{
		return switch(button)
		{
			case LogitechButtonID.TWO: A;
			case LogitechButtonID.THREE: B;
			case LogitechButtonID.ONE: X;
			case LogitechButtonID.FOUR: Y;
			case LogitechButtonID.NINE: BACK;
			case LogitechButtonID.TEN: START;
			case LogitechButtonID.LEFT_ANALOG: LEFT_STICK;
			case LogitechButtonID.RIGHT_ANALOG: RIGHT_STICK;
			case LogitechButtonID.FIVE: LEFT_SHOULDER;
			case LogitechButtonID.SIX: RIGHT_SHOULDER;
			case LogitechButtonID.SEVEN: LEFT_TRIGGER;
			case LogitechButtonID.EIGHT: RIGHT_TRIGGER;
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
			//case GUIDE:
			default: UNKNOWN;
		}
	}
	
	public inline function toPS4(button:Int):GamepadButtonID
	{
		return switch(button)
		{
			case PS4ButtonID.X: A;
			case PS4ButtonID.CIRCLE: B;
			case PS4ButtonID.SQUARE: X;
			case PS4ButtonID.TRIANGLE: Y;
			case PS4ButtonID.SELECT: BACK;
			case PS4ButtonID.PS: GUIDE;
			case PS4ButtonID.START: START;
			case PS4ButtonID.LEFT_ANALOG: LEFT_STICK;
			case PS4ButtonID.RIGHT_ANALOG: RIGHT_STICK;
			case PS4ButtonID.L1: LEFT_SHOULDER;
			case PS4ButtonID.R1: RIGHT_SHOULDER;
			case PS4ButtonID.L2: LEFT_TRIGGER;
			case PS4ButtonID.R2: RIGHT_TRIGGER;
			//case DPAD_UP: 
			//case DPAD_DOWN: 
			//case DPAD_LEFT: 
			//case DPAD_RIGHT: 
			default: UNKNOWN;
		}
	}
	
	public inline function toPS3(button:Int):GamepadButtonID
	{
		return switch(button)
		{
			case PS3ButtonID.X: A;
			case PS3ButtonID.CIRCLE: B;
			case PS3ButtonID.SQUARE: X;
			case PS3ButtonID.TRIANGLE: Y;
			case PS3ButtonID.SELECT: BACK;
			case PS3ButtonID.PS: GUIDE;
			case PS3ButtonID.START: START;
			case PS3ButtonID.LEFT_ANALOG: LEFT_STICK;
			case PS3ButtonID.RIGHT_ANALOG: RIGHT_STICK;
			case PS3ButtonID.L1: LEFT_SHOULDER;
			case PS3ButtonID.R1: RIGHT_SHOULDER;
			case PS3ButtonID.L2: LEFT_TRIGGER;
			case PS3ButtonID.R2: RIGHT_TRIGGER;
			case PS3ButtonID.DPAD_UP: DPAD_UP;
			case PS3ButtonID.DPAD_DOWN: DPAD_DOWN;
			case PS3ButtonID.DPAD_LEFT: DPAD_LEFT;
			case PS3ButtonID.DPAD_RIGHT: DPAD_RIGHT;
			default: UNKNOWN;
		}
	}
	
	public inline function toXbox(button:Int):GamepadButtonID
	{
		return switch(button)
		{
			case XboxButtonID.A: A;
			case XboxButtonID.B: B;
			case XboxButtonID.X: X;
			case XboxButtonID.Y: Y;
			case XboxButtonID.BACK: BACK;
			case XboxButtonID.XBOX: GUIDE;
			case XboxButtonID.START: START;
			case XboxButtonID.LEFT_ANALOG: LEFT_STICK;
			case XboxButtonID.RIGHT_ANALOG: RIGHT_STICK;
			case XboxButtonID.LB: LEFT_SHOULDER;
			case XboxButtonID.RB: RIGHT_SHOULDER;
			case XboxButtonID.DPAD_UP: DPAD_UP;
			case XboxButtonID.DPAD_DOWN: DPAD_DOWN;
			case XboxButtonID.DPAD_LEFT: DPAD_LEFT;
			case XboxButtonID.DPAD_RIGHT: DPAD_RIGHT;
			default: UNKNOWN;
		}
	}
	
	public inline function toXInput(button:Int):GamepadButtonID
	{
		return switch(button)
		{
			case XInputButtonID.A: A;
			case XInputButtonID.B: B;
			case XInputButtonID.X: X;
			case XInputButtonID.Y: Y;
			case XInputButtonID.BACK: BACK;
			case XInputButtonID.GUIDE: GUIDE;
			case XInputButtonID.START: START;
			case XInputButtonID.LEFT_ANALOG: LEFT_STICK;
			case XInputButtonID.RIGHT_ANALOG: RIGHT_STICK;
			case XInputButtonID.LB: LEFT_SHOULDER;
			case XInputButtonID.RB: RIGHT_SHOULDER;
			case XInputButtonID.DPAD_UP: DPAD_UP;
			case XInputButtonID.DPAD_DOWN: DPAD_DOWN;
			case XInputButtonID.DPAD_LEFT: DPAD_LEFT;
			case XInputButtonID.DPAD_RIGHT: DPAD_RIGHT;
			default: UNKNOWN;
		}
	}
	
	/***********/
	
	public inline function getAxisLogitech(button:GamepadAxisID):Int
	{
		return switch(button)
		{
			case LEFT_STICK_X: LogitechButtonID.LEFT_ANALOG_STICK[FlxAxes.X];
			case LEFT_STICK_Y: LogitechButtonID.LEFT_ANALOG_STICK[FlxAxes.Y];
			case RIGHT_STICK_X: LogitechButtonID.RIGHT_ANALOG_STICK[FlxAxes.X];
			case RIGHT_STICK_Y: LogitechButtonID.RIGHT_ANALOG_STICK[FlxAxes.Y];
			//case LEFT_TRIGGER:
			//case RIGHT_TRIGGER:
			default: -1;
		}
	}
	
	public inline function getAxisOUYA(button:GamepadAxisID):Int
	{
		return switch(button)
		{
			case LEFT_STICK_X: OUYAButtonID.LEFT_ANALOG_STICK[FlxAxes.X];
			case LEFT_STICK_Y: OUYAButtonID.LEFT_ANALOG_STICK[FlxAxes.Y];
			case RIGHT_STICK_X: OUYAButtonID.RIGHT_ANALOG_STICK[FlxAxes.X];
			case RIGHT_STICK_Y: OUYAButtonID.RIGHT_ANALOG_STICK[FlxAxes.Y];
			case LEFT_TRIGGER: OUYAButtonID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: OUYAButtonID.RIGHT_TRIGGER;
			default: -1;
		}
	}
	
	public inline function getAxisPS3(button:GamepadAxisID):Int
	{
		return switch(button)
		{
			case LEFT_STICK_X: PS3ButtonID.LEFT_ANALOG_STICK[FlxAxes.X];
			case LEFT_STICK_Y: PS3ButtonID.LEFT_ANALOG_STICK[FlxAxes.Y];
			case RIGHT_STICK_X: PS3ButtonID.RIGHT_ANALOG_STICK[FlxAxes.X];
			case RIGHT_STICK_Y: PS3ButtonID.RIGHT_ANALOG_STICK[FlxAxes.Y];
			//case LEFT_TRIGGER:
			//case RIGHT_TRIGGER:
			default: -1;
		}
	}
	
	public inline function getAxisPS4(button:GamepadAxisID):Int
	{
		return switch(button)
		{
			case LEFT_STICK_X: PS4ButtonID.LEFT_ANALOG_STICK[FlxAxes.X];
			case LEFT_STICK_Y: PS4ButtonID.LEFT_ANALOG_STICK[FlxAxes.Y];
			case RIGHT_STICK_X: PS4ButtonID.RIGHT_ANALOG_STICK[FlxAxes.X];
			case RIGHT_STICK_Y: PS4ButtonID.RIGHT_ANALOG_STICK[FlxAxes.Y];
			// case LEFT_TRIGGER:
			//case RIGHT_TRIGGER:
			default: -1;
		}
	}
	
	public inline function getAxisXbox(button:GamepadAxisID):Int
	{
		return switch(button)
		{
			case LEFT_STICK_X: XboxButtonID.LEFT_ANALOG_STICK[FlxAxes.X];
			case LEFT_STICK_Y: XboxButtonID.LEFT_ANALOG_STICK[FlxAxes.Y];
			case RIGHT_STICK_X: XboxButtonID.RIGHT_ANALOG_STICK[FlxAxes.X];
			case RIGHT_STICK_Y: XboxButtonID.RIGHT_ANALOG_STICK[FlxAxes.Y];
			case LEFT_TRIGGER: XboxButtonID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: XboxButtonID.RIGHT_TRIGGER;
			default: -1;
		}
	}
	
	public inline function getAxisXInput(button:GamepadAxisID):Int
	{
		return switch(button)
		{
			case LEFT_STICK_X: XInputButtonID.LEFT_ANALOG_STICK[FlxAxes.X];
			case LEFT_STICK_Y: XInputButtonID.LEFT_ANALOG_STICK[FlxAxes.Y];
			case RIGHT_STICK_X: XInputButtonID.RIGHT_ANALOG_STICK[FlxAxes.X];
			case RIGHT_STICK_Y: XInputButtonID.RIGHT_ANALOG_STICK[FlxAxes.Y];
			case LEFT_TRIGGER: XInputButtonID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: XInputButtonID.RIGHT_TRIGGER;
			default: -1;
		}
	}
}