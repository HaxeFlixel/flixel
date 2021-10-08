package flixel.input.actions;

import flixel.input.FlxInput;
import flixel.input.IFlxInput;
import flixel.input.actions.FlxActionInput.FlxInputType;
import flixel.input.actions.FlxActionInput.FlxInputDevice;
import flixel.input.actions.FlxActionInput.FlxInputDeviceID;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.android.FlxAndroidKey;

/**
 * @since 4.6.0
 */
class FlxActionInputDigital extends FlxActionInput
{
	function new(Device:FlxInputDevice, InputID:Int, Trigger:FlxInputState, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputType.DIGITAL, Device, InputID, Trigger, DeviceID);
		inputID = InputID;
	}
}

/**
 * @since 4.6.0
 */
class FlxActionInputDigitalMouseWheel extends FlxActionInputDigital
{
	var input:FlxInput<Int>;
	var sign:Int = 0;

	/**
	 * Action for mouse wheel events
	 * @param	Positive	True: respond to mouse wheel values > 0; False: respond to mouse wheel values < 0
	 * @param	Trigger		What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public function new(Positive:Bool, Trigger:FlxInputState)
	{
		super(FlxInputDevice.MOUSE_WHEEL, 0, Trigger);
		input = new FlxInput<Int>(0);
		sign = Positive ? 1 : -1;
	}

	override public function check(Action:FlxAction):Bool
	{
		return switch (trigger)
		{
			#if !FLX_NO_MOUSE
			case PRESSED: return input.pressed || input.justPressed;
			case RELEASED: return input.released || input.justReleased;
			case JUST_PRESSED: return input.justPressed;
			case JUST_RELEASED: return input.justReleased;
			#end
			default: false;
		}
	}

	override public function update():Void
	{
		super.update();
		#if !FLX_NO_MOUSE
		if (FlxG.mouse.wheel * sign > 0)
		{
			input.press();
		}
		else
		{
			input.release();
		}
		#end
	}
}

/**
 * @since 4.6.0
 */
class FlxActionInputDigitalGamepad extends FlxActionInputDigital
{
	var input:FlxInput<Int>;

	/**
	 * Gamepad action input for digital (button-like) events
	 * @param	InputID "universal" gamepad input ID (A, X, DPAD_LEFT, etc)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @param	GamepadID specific gamepad ID, or FlxInputDeviceID.ALL / FIRST_ACTIVE
	 */
	public function new(InputID:FlxGamepadInputID, Trigger:FlxInputState, GamepadID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.GAMEPAD, InputID, Trigger, GamepadID);
		input = new FlxInput<Int>(InputID);
	}

	public function toString():String
	{
		return "FlxActionInputDigitalGamepad{inputID:" + inputID + ",trigger:" + trigger + ",deviceID:" + deviceID + ",device:" + device + ",type:" + type
			+ "}";
	}

	override public function update():Void
	{
		super.update();
		#if !FLX_NO_GAMEPAD
		if (deviceID == FlxInputDeviceID.ALL)
		{
			if (FlxG.gamepads.anyPressed(inputID) || FlxG.gamepads.anyJustPressed(inputID))
			{
				input.press();
			}
			else
			{
				input.release();
			}
		}
		else
		{
			var gamepad:FlxGamepad = null;

			if (deviceID == FlxInputDeviceID.FIRST_ACTIVE)
			{
				gamepad = FlxG.gamepads.getFirstActiveGamepad();
			}
			else if (deviceID >= 0)
			{
				gamepad = FlxG.gamepads.getByID(deviceID);
			}

			if (gamepad != null)
			{
				if (inputID == ANY && trigger == RELEASED)
				{
					if (gamepad.released.ANY)
					{
						input.release();
					}
					else
					{
						input.press();
					}
				}
				else
				{
					if (gamepad.checkStatus(inputID, PRESSED) || gamepad.checkStatus(inputID, JUST_PRESSED))
					{
						input.press();
					}
					else
					{
						input.release();
					}
				}
			}
			else
			{
				if (deviceID == FlxInputDeviceID.FIRST_ACTIVE)
				{
					input.release();
				}
			}
		}
		#end
	}

	override public function check(Action:FlxAction):Bool
	{
		return switch (trigger)
		{
			case PRESSED: return input.pressed || input.justPressed;
			case RELEASED: return input.released || input.justReleased;
			case JUST_PRESSED: return input.justPressed;
			case JUST_RELEASED: return input.justReleased;
			default: false;
		}
	}
}

/**
 * @since 4.6.0
 */
class FlxActionInputDigitalKeyboard extends FlxActionInputDigital
{
	/**
	 * Keyboard action input
	 * @param	Key Key identifier (FlxKey.SPACE, FlxKey.Z, etc)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public function new(Key:FlxKey, Trigger:FlxInputState)
	{
		super(FlxInputDevice.KEYBOARD, Key, Trigger);
	}

	override public function check(Action:FlxAction):Bool
	{
		return switch (trigger)
		{
			#if !FLX_NO_KEYBOARD
			case PRESSED: FlxG.keys.checkStatus(inputID, PRESSED) || FlxG.keys.checkStatus(inputID, JUST_PRESSED);
			case RELEASED: FlxG.keys.checkStatus(inputID, RELEASED) || FlxG.keys.checkStatus(inputID, JUST_RELEASED);
			case JUST_PRESSED: FlxG.keys.checkStatus(inputID, JUST_PRESSED);
			case JUST_RELEASED: FlxG.keys.checkStatus(inputID, JUST_RELEASED);
			#end
			default: false;
		}
	}
}

/**
 * @since 4.6.0
 */
class FlxActionInputDigitalMouse extends FlxActionInputDigital
{
	/**
	 * Mouse button action input
	 * @param	ButtonID Button identifier (FlxMouseButtonID.LEFT / MIDDLE / RIGHT)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public function new(ButtonID:FlxMouseButtonID, Trigger:FlxInputState)
	{
		super(FlxInputDevice.MOUSE, ButtonID, Trigger);
	}

	override public function check(Action:FlxAction):Bool
	{
		return switch (inputID)
		{
			#if !FLX_NO_MOUSE
			case FlxMouseButtonID.LEFT: switch (trigger)
				{
					case PRESSED: FlxG.mouse.pressed || FlxG.mouse.justPressed;
					case RELEASED: !FlxG.mouse.pressed || FlxG.mouse.justReleased;
					case JUST_PRESSED: FlxG.mouse.justPressed;
					case JUST_RELEASED: FlxG.mouse.justReleased;
				}
			case FlxMouseButtonID.MIDDLE: switch (trigger)
				{
					case PRESSED: FlxG.mouse.pressedMiddle || FlxG.mouse.justPressedMiddle;
					case RELEASED: !FlxG.mouse.pressedMiddle || FlxG.mouse.justReleasedMiddle;
					case JUST_PRESSED: FlxG.mouse.justPressedMiddle;
					case JUST_RELEASED: FlxG.mouse.justReleasedMiddle;
				}
			case FlxMouseButtonID.RIGHT: switch (trigger)
				{
					case PRESSED: FlxG.mouse.pressedRight || FlxG.mouse.justPressedRight;
					case RELEASED: !FlxG.mouse.pressedRight || FlxG.mouse.justReleasedRight;
					case JUST_PRESSED: FlxG.mouse.justPressedRight;
					case JUST_RELEASED: FlxG.mouse.justReleasedRight;
				}
			#end
			default: false;
		}
	}
}

/**
 * @since 4.6.0
 */
class FlxActionInputDigitalSteam extends FlxActionInputDigital
{
	var steamInput:FlxInput<Int>;

	/**
	 * Steam Controller action input for digital (button-like) events
	 * @param	ActionHandle handle received from FlxSteamController.getDigitalActionHandle()
	 * @param	Trigger what state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @param	DeviceHandle handle received from FlxSteamController.getConnectedControllers(), or FlxInputDeviceID.ALL / FIRST_ACTIVE
	 */
	@:allow(flixel.input.actions.FlxActionSet)
	function new(ActionHandle:Int, Trigger:FlxInputState, ?DeviceHandle:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.STEAM_CONTROLLER, ActionHandle, Trigger, DeviceHandle);
		#if FLX_STEAMWRAP
		steamInput = new FlxInput<Int>(ActionHandle);
		#else
		FlxG.log.warn("steamwrap library not installed; steam inputs will be ignored.");
		#end
	}

	override public function check(Action:FlxAction):Bool
	{
		return switch (trigger)
		{
			case PRESSED: steamInput.pressed || steamInput.justPressed;
			case RELEASED: !steamInput.released || steamInput.justReleased;
			case JUST_PRESSED: steamInput.justPressed;
			case JUST_RELEASED: steamInput.justReleased;
		}
	}

	override public function update():Void
	{
		if (getSteamControllerData(deviceID))
			steamInput.press();
		else
			steamInput.release();
	}

	inline function getSteamControllerData(controllerHandle:Int):Bool
	{
		if (controllerHandle == FlxInputDeviceID.FIRST_ACTIVE)
		{
			controllerHandle = FlxSteamController.getFirstActiveHandle();
		}

		var data = FlxSteamController.getDigitalActionData(controllerHandle, inputID);

		return (data.bActive && data.bState);
	}
}

#if android
/**
 * @since 4.10.0
 */
class FlxActionInputDigitalAndroid extends FlxActionInputDigital
{
	/**
	 * Android buttons action input for the BACK and MENU buttons on Android
	 * @param	androidKeyID Key identifier (FlxAndroidKey.BACK, FlxAndroidKey.MENU... those are the only 2 android specific ones)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public function new(androidKeyID:FlxAndroidKey, Trigger:FlxInputState)
	{
		super(ANDROID, androidKeyID, Trigger);
	}

	override public function check(Action:FlxAction):Bool
	{
		return switch (trigger)
		{
			case PRESSED: FlxG.android.checkStatus(inputID, PRESSED) || FlxG.android.checkStatus(inputID, JUST_PRESSED);
			case RELEASED: FlxG.android.checkStatus(inputID, RELEASED) || FlxG.android.checkStatus(inputID, JUST_RELEASED);
			case JUST_PRESSED: FlxG.android.checkStatus(inputID, JUST_PRESSED);
			case JUST_RELEASED: FlxG.android.checkStatus(inputID, JUST_RELEASED);

			default: false;
		}
	}
}
#end

/**
 * @since 4.6.0
 */
class FlxActionInputDigitalIFlxInput extends FlxActionInputDigital
{
	var input:IFlxInput;

	/**
	 * Generic IFlxInput action input
	 *
	 * WARNING: IFlxInput objects are often member variables of some other
	 * object that is often destructed at the end of a state. If you don't
	 * destroy() this input (or the action you assign it to), the IFlxInput
	 * reference will persist forever even after its parent object has been
	 * destroyed!
	 *
	 * @param	Input	A generic IFlxInput object (ex: FlxButton.input)
	 * @param	Trigger	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public function new(Input:IFlxInput, Trigger:FlxInputState)
	{
		super(FlxInputDevice.IFLXINPUT_OBJECT, 0, Trigger);
		input = Input;
	}

	override public function check(action:FlxAction):Bool
	{
		return switch (trigger)
		{
			case PRESSED: input.pressed || input.justPressed;
			case RELEASED: !input.pressed || input.justReleased;
			case JUST_PRESSED: input.justPressed;
			case JUST_RELEASED: input.justReleased;
			default: false;
		}
	}

	override public function destroy():Void
	{
		super.destroy();
		input = null;
	}
}
