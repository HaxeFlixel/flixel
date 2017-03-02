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

class FlxActionInputDigital extends FlxActionInput
{
	private function new(Device:FlxInputDevice, InputID:Int, Trigger:FlxInputState, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputType.DIGITAL, Device, InputID, Trigger, DeviceID);
		inputID = InputID;
	}
}

class FlxActionInputDigitalMouseWheel extends FlxActionInputDigital
{
	private var input:FlxInput<Int>;
	private var sign:Int = 0;
	
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
				case PRESSED:       return  input.pressed  || input.justPressed;
				case RELEASED:      return  input.released || input.justReleased;
				case JUST_PRESSED:  return  input.justPressed;
				case JUST_RELEASED: return  input.justReleased;
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

class FlxActionInputDigitalGamepad extends FlxActionInputDigital
{
	/**
	 * Gamepad action input for digital (button-like) events
	 * @param	InputID "universal" gamepad input ID (A, X, DPAD_LEFT, etc)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @param	GamepadID specific gamepad ID, or FlxInputDeviceID.ALL / FIRST_ACTIVE
	 */
	public function new(InputID:FlxGamepadInputID, Trigger:FlxInputState, ?GamepadID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.GAMEPAD, InputID, Trigger, GamepadID);
	}
	
	override public function check(Action:FlxAction):Bool 
	{
		#if !FLX_NO_GAMEPAD
		if (deviceID == FlxInputDeviceID.ALL)
		{
			switch (trigger)
			{
				case PRESSED:       return  FlxG.gamepads.anyPressed(inputID)  || FlxG.gamepads.anyJustPressed (inputID);
				case RELEASED:      return !FlxG.gamepads.anyPressed(inputID)  || FlxG.gamepads.anyJustReleased(inputID);
				case JUST_PRESSED:  return  FlxG.gamepads.anyJustPressed (inputID);
				case JUST_RELEASED: return  FlxG.gamepads.anyJustReleased(inputID);
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
				if (inputID == FlxGamepadInputID.ANY)
				{
					switch(trigger)
					{
						case PRESSED:       return  gamepad.pressed.ANY || gamepad.justPressed.ANY;
						case RELEASED:      return !gamepad.pressed.ALL && !gamepad.justPressed.ALL;
						case JUST_PRESSED:  return  gamepad.justPressed.ANY;
						case JUST_RELEASED: return  gamepad.justReleased.ANY;
					}
				}
				else
				{
					switch (trigger)
					{
						case PRESSED:       return  gamepad.checkStatus(inputID, PRESSED)  || gamepad.checkStatus(inputID, JUST_PRESSED);
						case RELEASED:      return  gamepad.checkStatus(inputID, RELEASED) || gamepad.checkStatus(inputID, JUST_RELEASED);
						case JUST_PRESSED:  return  gamepad.checkStatus(inputID, JUST_PRESSED);
						case JUST_RELEASED: return  gamepad.checkStatus(inputID, JUST_RELEASED);
					}
				}
			}
		}
		#end
		return false;
	}
}

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
			case PRESSED:       FlxG.keys.checkStatus(inputID, PRESSED ) || FlxG.keys.checkStatus(inputID, JUST_PRESSED);
			case RELEASED:      FlxG.keys.checkStatus(inputID, RELEASED) || FlxG.keys.checkStatus(inputID, JUST_RELEASED);
			case JUST_PRESSED:  FlxG.keys.checkStatus(inputID, JUST_PRESSED);
			case JUST_RELEASED: FlxG.keys.checkStatus(inputID, JUST_RELEASED);
			#end
			default: false;
		}
	}
}

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
			case FlxMouseButtonID.LEFT  : switch (trigger)
			{
				case PRESSED:        FlxG.mouse.pressed || FlxG.mouse.justPressed;
				case RELEASED:      !FlxG.mouse.pressed || FlxG.mouse.justReleased;
				case JUST_PRESSED:   FlxG.mouse.justPressed;
				case JUST_RELEASED:  FlxG.mouse.justReleased;
			}
			case FlxMouseButtonID.MIDDLE: switch (trigger)
			{
				case PRESSED:        FlxG.mouse.pressedMiddle || FlxG.mouse.justPressedMiddle;
				case RELEASED:      !FlxG.mouse.pressedMiddle || FlxG.mouse.justReleasedMiddle;
				case JUST_PRESSED:   FlxG.mouse.justPressedMiddle;
				case JUST_RELEASED:  FlxG.mouse.justReleasedMiddle;
			}
			case FlxMouseButtonID.RIGHT : switch (trigger)
			{
				case PRESSED:        FlxG.mouse.pressedRight || FlxG.mouse.justPressedRight;
				case RELEASED:      !FlxG.mouse.pressedRight || FlxG.mouse.justReleasedRight;
				case JUST_PRESSED:   FlxG.mouse.justPressedRight;
				case JUST_RELEASED:  FlxG.mouse.justReleasedRight;
			}
			#end
			default: false;
		}
	}
}

class FlxActionInputDigitalSteam extends FlxActionInputDigital
{
	/**
	 * Steam Controller action input for digital (button-like) events
	 * @param	ActionHandle handle received from FlxSteamController.getDigitalActionHandle()
	 * @param	Trigger what state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @param	DeviceHandle handle received from FlxSteamController.getConnectedControllers(), or FlxInputDeviceID.ALL / FIRST_ACTIVE
	 */
	@:allow(flixel.input.actions.FlxActionSet)
	private function new(ActionHandle:Int, Trigger:FlxInputState, ?DeviceHandle:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.STEAM_CONTROLLER, ActionHandle, Trigger, DeviceHandle);
		#if steamwrap
			steamInput = new FlxInput<Int>(ActionHandle);
		#else
			FlxG.log.warn("steamwrap library not installed; steam inputs will be ignored.");
		#end
	}
	
	override public function check(Action:FlxAction):Bool 
	{
		return switch (trigger)
		{
			case PRESSED:        steamInput.pressed  || steamInput.justPressed;
			case RELEASED:      !steamInput.released || steamInput.justReleased;
			case JUST_PRESSED:   steamInput.justPressed;
			case JUST_RELEASED:  steamInput.justReleased;
		}
	}
	
	override public function update():Void 
	{
		if (getSteamControllerData(deviceID))
			steamInput.press();
		else
			steamInput.release();
	}
	
	private var steamInput:FlxInput<Int>;
	
	private inline function getSteamControllerData(controllerHandle:Int):Bool
	{
		if (controllerHandle == FlxInputDeviceID.FIRST_ACTIVE)
		{
			controllerHandle = FlxSteamController.getFirstActiveHandle();
		}
		
		var data = FlxSteamController.getDigitalActionData(controllerHandle, inputID);
		
		return (data.bActive && data.bState);
	}
}

class FlxActionInputDigitalIFlxInput extends FlxActionInputDigital
{
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
			case PRESSED:        input.pressed || input.justPressed;
			case RELEASED:      !input.pressed || input.justReleased;
			case JUST_PRESSED:   input.justPressed;
			case JUST_RELEASED:  input.justReleased;
			default: false;
		}
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		input = null;
	}
	
	private var input:IFlxInput;
	
}