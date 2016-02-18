package flixel.input.actions;

import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.keyboard.FlxKey;
import flixel.input.mouse.FlxMouseButton.FlxMouseButtonID;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

#if steamwrap
import steamwrap.api.Steam;
import steamwrap.api.Controller;
#end

class FlxActionInputDigitalMouse extends FlxActionInputDigital
{
	/**
	 * Mouse button action input
	 * @param	ButtonID Button identifier (FlxMouseButtonID.LEFT / MIDDLE / RIGHT)
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	
	public function new(ButtonID:FlxMouseButtonID, Trigger:FlxInputState)
	{
		super(FlxInputDevice.Mouse, ButtonID, Trigger);
	}
	
	override public function check(Action:FlxAction):Bool 
	{
		return switch(inputID)
		{
			case FlxMouseButtonID.LEFT  : switch(trigger)
			{
				case PRESSED:        FlxG.mouse.pressed || FlxG.mouse.justPressed;
				case RELEASED:      !FlxG.mouse.pressed || FlxG.mouse.justReleased;
				case JUST_PRESSED:   FlxG.mouse.justPressed;
				case JUST_RELEASED:  FlxG.mouse.justReleased;
			}
			case FlxMouseButtonID.MIDDLE: switch(trigger)
			{
				case PRESSED:        FlxG.mouse.pressedMiddle || FlxG.mouse.justPressedMiddle;
				case RELEASED:      !FlxG.mouse.pressedMiddle || FlxG.mouse.justReleasedMiddle;
				case JUST_PRESSED:   FlxG.mouse.justPressedMiddle;
				case JUST_RELEASED:  FlxG.mouse.justReleasedMiddle;
			}
			case FlxMouseButtonID.RIGHT : switch(trigger)
			{
				case PRESSED:        FlxG.mouse.pressedRight || FlxG.mouse.justPressedRight;
				case RELEASED:      !FlxG.mouse.pressedRight || FlxG.mouse.justReleasedRight;
				case JUST_PRESSED:   FlxG.mouse.justPressedRight;
				case JUST_RELEASED:  FlxG.mouse.justReleasedRight;
			}
			default: false;
		}
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
		super(FlxInputDevice.Keyboard, Key, Trigger);
	}
	
	override public function check(Action:FlxAction):Bool 
	{
		return switch(trigger)
		{
			case PRESSED:       FlxG.keys.checkStatus(inputID, PRESSED ) || FlxG.keys.checkStatus(inputID, JUST_PRESSED);
			case RELEASED:      FlxG.keys.checkStatus(inputID, RELEASED) || FlxG.keys.checkStatus(inputID, JUST_RELEASED);
			case JUST_PRESSED:  FlxG.keys.checkStatus(inputID, JUST_PRESSED);
			case JUST_RELEASED: FlxG.keys.checkStatus(inputID, JUST_RELEASED);
			default: false;
		}
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
	
	public function new(InputID:FlxGamepadInputID, Trigger:FlxInputState, ?GamepadID:Int=FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.Gamepad, InputID, Trigger, GamepadID);
	}
	
	override public function check(Action:FlxAction):Bool 
	{
		if (deviceID == FlxInputDeviceID.ALL)
		{
			switch(trigger)
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
			else if(deviceID >= 0)
			{
				gamepad = FlxG.gamepads.getByID(deviceID);
			}
			
			if (gamepad != null)
			{
				switch(trigger)
				{
					case PRESSED:       return  gamepad.checkStatus(inputID, PRESSED) || gamepad.checkStatus(inputID, JUST_PRESSED);
					case RELEASED:      return !gamepad.checkStatus(inputID, PRESSED) || gamepad.checkStatus(inputID, JUST_RELEASED);
					case JUST_PRESSED:  return  gamepad.checkStatus(inputID, JUST_PRESSED);
					case JUST_RELEASED: return  gamepad.checkStatus(inputID, JUST_RELEASED);
				}
			}
		}
		return false;
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
	private function new(ActionHandle:Int, Trigger:FlxInputState, ?DeviceHandle:Int=FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.SteamController, ActionHandle, Trigger, DeviceHandle);
		#if steamwrap
			steamInput = new FlxInput<Int>(ActionHandle);
		#else
			FlxG.log.warn("steamwrap library not installed; steam inputs will be ignored.");
		#end
	}
	
	override public function check(Action:FlxAction):Bool 
	{
		return compareState(steamInput.current, trigger);
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

class FlxActionInputDigital extends FlxActionInput
{
	private function new(Device:FlxInputDevice, InputID:Int, Trigger:FlxInputState, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputType.Digital, Device, InputID, Trigger, DeviceID);
		inputID = InputID;
	}
}

