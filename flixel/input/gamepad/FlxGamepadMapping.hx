package flixel.input.gamepad;

import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModelAttachment;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.LogitechID;
import flixel.input.gamepad.id.OUYAID;
import flixel.input.gamepad.id.PS4ID;
import flixel.input.gamepad.id.MayflashWiiRemoteID;
import flixel.input.gamepad.id.WiiRemoteID;
import flixel.input.gamepad.id.XBox360ID;
import flixel.input.gamepad.id.XInputID;
import flixel.input.gamepad.id.MFiID;

#if flash
import openfl.system.Capabilities;
#end

/**
 * ...
 * @author larsiusprime
 */
class FlxGamepadMapping
{
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var model(default, null):FlxGamepadModel;
	
	@:allow(flixel.input.gamepad.FlxGamepad)
	public var attachment(default, null):FlxGamepadModelAttachment = None;
	
	private var _manufacturer:Manufacturer = Unknown;
	
	public function new(Model:FlxGamepadModel, attachment:FlxGamepadModelAttachment=null) 
	{
		model = Model;
		#if flash
		_manufacturer = switch (Capabilities.manufacturer)
		{
			case "Google Pepper": GooglePepper;
			case "Adobe Windows": AdobeWindows;
			default: Unknown;
		}
		#end
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
			case PS4: getRawPS4(ID);
			case XBox360: getRawXBox360(ID);
			case XInput: getRawXInput(ID);
			case MayflashWiiRemote: 
				switch (attachment)
				{
					case WiiClassicController: getRawMayflashWiiClassicController(ID);
					case WiiNunchuk: getRawMayflashWiiNunchuk(ID);
					case None: getRawMayflashWiiRemote(ID);
				}
			case WiiRemote:
				switch (attachment)
				{
					case WiiClassicController: getRawWiiClassicController(ID);
					case WiiNunchuk: getRawWiiNunchuk(ID);
					case None: getRawWiiRemote(ID);
				}
			case MFi: getRawMFi(ID);
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
			case PS4: getIDPS4(RawID);
			case XBox360: getIDXBox360(RawID);
			case XInput: getIDXInput(RawID);
			case MayflashWiiRemote: 
				switch (attachment)
				{
					case WiiClassicController: getIDMayflashWiiClassicController(RawID);
					case WiiNunchuk: getIDMayflashWiiNunchuk(RawID);
					case None: getIDMayflashWiiRemote(RawID);
				}
			case WiiRemote:
				switch (attachment)
				{
					case WiiClassicController: getIDWiiClassicController(RawID);
					case WiiNunchuk: getIDWiiNunchuk(RawID);
					case None: getIDWiiRemote(RawID);
				}
			case MFi: getIDMFi(RawID);
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
				case PS4: PS4ID.LEFT_ANALOG_STICK;
				case XBox360: XBox360ID.LEFT_ANALOG_STICK;
				case XInput: XInputID.LEFT_ANALOG_STICK;
				case MayflashWiiRemote:
					switch (attachment)
					{
						case WiiNunchuk, WiiClassicController: MayflashWiiRemoteID.LEFT_ANALOG_STICK;
						case None: MayflashWiiRemoteID.REMOTE_DPAD;
					}
				case WiiRemote:
					switch (attachment)
					{
						case WiiNunchuk, WiiClassicController: WiiRemoteID.LEFT_ANALOG_STICK;
						case None: WiiRemoteID.REMOTE_DPAD;
					}
				case MFi: MFiID.LEFT_ANALOG_STICK;
				default: null;
			}
		}
		else if (ID == FlxGamepadInputID.RIGHT_ANALOG_STICK)
		{
			return switch (model)
			{
				case Logitech: LogitechID.RIGHT_ANALOG_STICK;
				case OUYA: OUYAID.RIGHT_ANALOG_STICK;
				case PS4: PS4ID.RIGHT_ANALOG_STICK;
				case XBox360: XBox360ID.RIGHT_ANALOG_STICK;
				case XInput: XInputID.RIGHT_ANALOG_STICK;
				case MayflashWiiRemote: 
					switch (attachment)
					{
						case WiiClassicController: MayflashWiiRemoteID.RIGHT_ANALOG_STICK;
						default: null;
					}
				case WiiRemote: 
					switch (attachment)
					{
						case WiiClassicController: WiiRemoteID.RIGHT_ANALOG_STICK;
						default: null;
					}
				case MFi: MFiID.RIGHT_ANALOG_STICK;
				default: null;
			}
		}
		return null;
	}
	
	/**
	 * Returns 1 or -1 depending on whether this axis needs to be flipped
	 */
	public function getFlipAxis(AxisID:Int):Int
	{
		return switch (model)
		{
			case Logitech: LogitechID.getFlipAxis(AxisID);
			case OUYA: OUYAID.getFlipAxis(AxisID);
			case PS4: PS4ID.getFlipAxis(AxisID);
			case XBox360: XBox360ID.getFlipAxis(AxisID, _manufacturer);
			case XInput: XInputID.getFlipAxis(AxisID);
			case MayflashWiiRemote: MayflashWiiRemoteID.getFlipAxis(AxisID, attachment);
			case WiiRemote: WiiRemoteID.getFlipAxis(AxisID, attachment);
			case MFi: MFiID.getFlipAxis(AxisID);
			default: -1;
		}
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
			case PS4: PS4ID.axisIndexToRawID(AxisID);
			case XBox360: XBox360ID.axisIndexToRawID(AxisID);
			case XInput: XInputID.axisIndexToRawID(AxisID);
			case MayflashWiiRemote: MayflashWiiRemoteID.axisIndexToRawID(AxisID, attachment);
			case WiiRemote: WiiRemoteID.axisIndexToRawID(AxisID, attachment);
			case MFi: MFiID.axisIndexToRawID(AxisID);
			default: -1;
		}
	}
	
	public function checkForFakeAxis(ID:FlxGamepadInputID):Int
	{
		return switch (model)
		{
			case MayflashWiiRemote: MayflashWiiRemoteID.checkForFakeAxis(ID, attachment);
			case WiiRemote: WiiRemoteID.checkForFakeAxis(ID, attachment);
			default: -1;
		}
	}
	
	#end
	
	public function isAxisForMotion(ID:FlxGamepadInputID):Bool
	{
		return switch (model)
		{
			case Logitech: LogitechID.isAxisForMotion(ID);
			case OUYA: OUYAID.isAxisForMotion(ID);
			case PS4: PS4ID.isAxisForMotion(ID);
			case XBox360: XBox360ID.isAxisForMotion(ID);
			case XInput: XInputID.isAxisForMotion(ID);
			case MayflashWiiRemote: MayflashWiiRemoteID.isAxisForMotion(ID, attachment);
			case WiiRemote: WiiRemoteID.isAxisForMotion(ID, attachment);
			case MFi: MFiID.isAxisForMotion(ID);
			default: false;
		}
	}
	
	public function supportsMotion():Bool
	{
		return switch (model)
		{
			case Logitech: LogitechID.SUPPORTS_MOTION;
			case OUYA: OUYAID.SUPPORTS_MOTION;
			case PS4: PS4ID.SUPPORTS_MOTION;
			case XBox360: XBox360ID.SUPPORTS_MOTION;
			case XInput: XInputID.SUPPORTS_MOTION;
			case MayflashWiiRemote: MayflashWiiRemoteID.SUPPORTS_MOTION;
			case WiiRemote: WiiRemoteID.SUPPORTS_MOTION;
			case MFi: MFiID.SUPPORTS_MOTION;
			default: false;
		}
	}
	
	public function supportsPointer():Bool
	{
		return switch (model)
		{
			case Logitech: LogitechID.SUPPORTS_POINTER;
			case OUYA: OUYAID.SUPPORTS_POINTER;
			case PS4: PS4ID.SUPPORTS_POINTER;
			case XBox360: XBox360ID.SUPPORTS_POINTER;
			case XInput: XInputID.SUPPORTS_POINTER;
			case MayflashWiiRemote: MayflashWiiRemoteID.SUPPORTS_POINTER;
			case WiiRemote: WiiRemoteID.SUPPORTS_POINTER;
			case MFi: MFiID.SUPPORTS_POINTER;
			default: false;
		}
	}
	
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
	
	public function getRawMayflashWiiClassicController(ID:FlxGamepadInputID):Int
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
			default: getRawMayflashWiiRemote(ID);
		}
	}
	
	public function getRawMayflashWiiNunchuk(ID:FlxGamepadInputID):Int
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
	
	public function getRawMayflashWiiRemote(ID:FlxGamepadInputID):Int
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
	
	public function getRawWiiClassicController(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: WiiRemoteID.CLASSIC_B;
			case B: WiiRemoteID.CLASSIC_A;
			case X: WiiRemoteID.CLASSIC_Y;
			case Y: WiiRemoteID.CLASSIC_X;
			case DPAD_UP: WiiRemoteID.CLASSIC_DPAD_UP;
			case DPAD_DOWN: WiiRemoteID.CLASSIC_DPAD_DOWN;
			case DPAD_LEFT: WiiRemoteID.CLASSIC_DPAD_LEFT;
			case DPAD_RIGHT: WiiRemoteID.CLASSIC_DPAD_RIGHT;
			case BACK: WiiRemoteID.CLASSIC_SELECT;
			case GUIDE: WiiRemoteID.CLASSIC_HOME;
			case START: WiiRemoteID.CLASSIC_START;
			case LEFT_SHOULDER: WiiRemoteID.CLASSIC_ZL;
			case RIGHT_SHOULDER: WiiRemoteID.CLASSIC_ZR;
			case LEFT_TRIGGER: WiiRemoteID.CLASSIC_L;
			case RIGHT_TRIGGER: WiiRemoteID.CLASSIC_R;
			case EXTRA_0: WiiRemoteID.CLASSIC_ONE;
			case EXTRA_1: WiiRemoteID.CLASSIC_TWO;
			default: -1;
		}
	}
	
	public function getRawWiiNunchuk(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: WiiRemoteID.NUNCHUK_A;
			case B: WiiRemoteID.NUNCHUK_B;
			case LEFT_SHOULDER: WiiRemoteID.NUNCHUK_C;
			case LEFT_TRIGGER: WiiRemoteID.NUNCHUK_Z;
			case X: WiiRemoteID.NUNCHUK_ONE;
			case Y: WiiRemoteID.NUNCHUK_TWO;
			case BACK: WiiRemoteID.NUNCHUK_MINUS;
			case START: WiiRemoteID.NUNCHUK_PLUS;
			case GUIDE: WiiRemoteID.NUNCHUK_HOME;
			case DPAD_UP: WiiRemoteID.NUNCHUK_DPAD_UP;
			case DPAD_DOWN: WiiRemoteID.NUNCHUK_DPAD_DOWN;
			case DPAD_LEFT: WiiRemoteID.NUNCHUK_DPAD_LEFT;
			case DPAD_RIGHT: WiiRemoteID.NUNCHUK_DPAD_RIGHT;
			case TILT_PITCH: WiiRemoteID.NUNCHUK_TILT_PITCH;
			case TILT_ROLL: WiiRemoteID.NUNCHUK_TILT_ROLL;
			default: -1;
		}
	}
	
	public function getRawWiiRemote(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: WiiRemoteID.REMOTE_A;
			case B: WiiRemoteID.REMOTE_B;
			case X: WiiRemoteID.REMOTE_ONE;
			case Y: WiiRemoteID.REMOTE_TWO;
			case DPAD_UP: WiiRemoteID.REMOTE_DPAD_UP;
			case DPAD_DOWN: WiiRemoteID.REMOTE_DPAD_DOWN;
			case DPAD_LEFT: WiiRemoteID.REMOTE_DPAD_LEFT;
			case DPAD_RIGHT: WiiRemoteID.REMOTE_DPAD_RIGHT;
			case BACK: WiiRemoteID.REMOTE_MINUS;
			case GUIDE: WiiRemoteID.REMOTE_HOME;
			case START: WiiRemoteID.REMOTE_PLUS;
			case TILT_PITCH: WiiRemoteID.REMOTE_TILT_PITCH;
			case TILT_ROLL: WiiRemoteID.REMOTE_TILT_ROLL;
			default: -1;
		}
	}

	public function getRawMFi(ID:FlxGamepadInputID):Int
	{
		return switch (ID)
		{
			case A: MFiID.A;
			case B: MFiID.B;
			case X: MFiID.X;
			case Y: MFiID.Y;
			case BACK: MFiID.BACK;
			case GUIDE: MFiID.GUIDE;
			case START: MFiID.START;
			case LEFT_STICK_CLICK: MFiID.LEFT_STICK_CLICK;
			case RIGHT_STICK_CLICK: MFiID.RIGHT_STICK_CLICK;
			case LEFT_SHOULDER: MFiID.LB;
			case RIGHT_SHOULDER: MFiID.RB;
			case DPAD_UP: MFiID.DPAD_UP;
			case DPAD_DOWN: MFiID.DPAD_DOWN;
			case DPAD_LEFT: MFiID.DPAD_LEFT;
			case DPAD_RIGHT: MFiID.DPAD_RIGHT;
			case LEFT_TRIGGER:  MFiID.LEFT_TRIGGER;
			case RIGHT_TRIGGER: MFiID.RIGHT_TRIGGER;
			#if FLX_JOYSTICK_API
			case LEFT_TRIGGER_FAKE: MFiID.LEFT_TRIGGER_FAKE;
			case RIGHT_TRIGGER_FAKE: MFiID.RIGHT_TRIGGER_FAKE;
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
			case OUYAID.LEFT_TRIGGER: LEFT_TRIGGER;
			case OUYAID.RIGHT_TRIGGER: RIGHT_TRIGGER;
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
			case XInputID.LEFT_TRIGGER: LEFT_TRIGGER;
			case XInputID.RIGHT_TRIGGER: RIGHT_TRIGGER;
			case XInputID.DPAD_UP: DPAD_UP;
			case XInputID.DPAD_DOWN: DPAD_DOWN;
			case XInputID.DPAD_LEFT: DPAD_LEFT;
			case XInputID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	public function getIDMayflashWiiClassicController(rawID:Int):FlxGamepadInputID
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
	
	public function getIDMayflashWiiNunchuk(rawID:Int):FlxGamepadInputID
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
	
	public function getIDMayflashWiiRemote(rawID:Int):FlxGamepadInputID
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
	
	public function getIDWiiClassicController(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case WiiRemoteID.CLASSIC_A: B;
			case WiiRemoteID.CLASSIC_B: A;
			case WiiRemoteID.CLASSIC_X: Y;
			case WiiRemoteID.CLASSIC_Y: X;
			case WiiRemoteID.CLASSIC_SELECT: BACK;
			case WiiRemoteID.CLASSIC_HOME: GUIDE;
			case WiiRemoteID.CLASSIC_START: START;
			case WiiRemoteID.CLASSIC_ZL: LEFT_SHOULDER;
			case WiiRemoteID.CLASSIC_ZR: RIGHT_SHOULDER;
			case WiiRemoteID.CLASSIC_L: LEFT_TRIGGER;
			case WiiRemoteID.CLASSIC_R: RIGHT_TRIGGER;
			case WiiRemoteID.CLASSIC_DPAD_UP: DPAD_UP;
			case WiiRemoteID.CLASSIC_DPAD_DOWN: DPAD_DOWN;
			case WiiRemoteID.CLASSIC_DPAD_LEFT: DPAD_LEFT;
			case WiiRemoteID.CLASSIC_DPAD_RIGHT: DPAD_RIGHT;
			case WiiRemoteID.CLASSIC_ONE: EXTRA_0;
			case WiiRemoteID.CLASSIC_TWO: EXTRA_1;
			default: NONE;
		}
	}
	
	public function getIDWiiNunchuk(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case WiiRemoteID.NUNCHUK_A: A;
			case WiiRemoteID.NUNCHUK_B: B;
			case WiiRemoteID.NUNCHUK_C: LEFT_SHOULDER;
			case WiiRemoteID.NUNCHUK_Z: LEFT_TRIGGER;
			case WiiRemoteID.NUNCHUK_ONE: X;
			case WiiRemoteID.NUNCHUK_TWO: Y;
			case WiiRemoteID.NUNCHUK_MINUS: BACK;
			case WiiRemoteID.NUNCHUK_PLUS: START;
			case WiiRemoteID.NUNCHUK_HOME: GUIDE;
			case WiiRemoteID.NUNCHUK_DPAD_UP: DPAD_UP;
			case WiiRemoteID.NUNCHUK_DPAD_DOWN: DPAD_DOWN;
			case WiiRemoteID.NUNCHUK_DPAD_LEFT: DPAD_LEFT;
			case WiiRemoteID.NUNCHUK_DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}
	
	public function getIDWiiRemote(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case WiiRemoteID.REMOTE_A: A;
			case WiiRemoteID.REMOTE_B: B;
			case WiiRemoteID.REMOTE_ONE: X;
			case WiiRemoteID.REMOTE_TWO: Y;
			case WiiRemoteID.REMOTE_MINUS: BACK;
			case WiiRemoteID.REMOTE_HOME: GUIDE;
			case WiiRemoteID.REMOTE_PLUS: START;
			case WiiRemoteID.REMOTE_DPAD_UP: DPAD_UP;
			case WiiRemoteID.REMOTE_DPAD_DOWN: DPAD_DOWN;
			case WiiRemoteID.REMOTE_DPAD_LEFT: DPAD_LEFT;
			case WiiRemoteID.REMOTE_DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}

	public function getIDMFi(rawID:Int):FlxGamepadInputID
	{
		return switch (rawID)
		{
			case MFiID.A: A;
			case MFiID.B: B;
			case MFiID.X: X;
			case MFiID.Y: Y;
			case MFiID.BACK: BACK;
			case MFiID.GUIDE: GUIDE;
			case MFiID.START: START;
			case MFiID.LEFT_STICK_CLICK: LEFT_STICK_CLICK;
			case MFiID.RIGHT_STICK_CLICK: RIGHT_STICK_CLICK;
			case MFiID.LB: LEFT_SHOULDER;
			case MFiID.RB: RIGHT_SHOULDER;
			case MFiID.DPAD_UP: DPAD_UP;
			case MFiID.DPAD_DOWN: DPAD_DOWN;
			case MFiID.DPAD_LEFT: DPAD_LEFT;
			case MFiID.DPAD_RIGHT: DPAD_RIGHT;
			default: NONE;
		}
	}

}

enum Manufacturer
{
	GooglePepper;
	AdobeWindows;
	Unknown;
}