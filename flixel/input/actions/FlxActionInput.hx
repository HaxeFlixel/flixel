package flixel.input.actions;

import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

@:allow(flixel.input.actions.FlxActionInputDigital, flixel.input.actions.FlxActionInputAnalog)
class FlxActionInput implements IFlxDestroyable
{
	/**
	 * Digital or Analog
	 */
	public var type:FlxInputType;
	
	/**
	 * Mouse, Keyboard, Gamepad, SteamController, etc.
	 */
	public var device:FlxInputDevice;
	
	/**
	 * Gamepad ID or Steam Controller handle (ignored for Mouse & Keyboard)
	 */
	public var deviceID:Int;
	
	public var destroyed(default, null):Bool = false;
	
	/**
	 * Input code (FlxMouseButtonID, FlxKey, FlxGamepadInputID, or Steam Controller action handle)
	 */
	public var inputID(default, null):Int;
	
	/**
	 * What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 */
	public var trigger(default, null):FlxInputState;
	
	private function new(InputType:FlxInputType, Device:FlxInputDevice, InputID:Int, Trigger:FlxInputState, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		type = InputType;
		device = Device;
		inputID = InputID;
		trigger = Trigger;
		deviceID = DeviceID;
	}
	
	public function update():Void {}
	
	public function destroy():Void
	{
		destroyed = true;
	}
	
	/**
	 * Check whether this action has just been triggered
	 * @param	action
	 * @return
	 */
	public function check(action:FlxAction):Bool
	{
		return false;
	}
	
	private inline function compareState(a:FlxInputState, b:FlxInputState):Bool
	{
		return switch (a)
		{
			case PRESSED:       b == PRESSED  || b == JUST_PRESSED;
			case RELEASED:      b == RELEASED || b == JUST_RELEASED;
			case JUST_PRESSED:  b == PRESSED;
			case JUST_RELEASED: b == RELEASED;
			default:            false;
		}
	}
}

enum FlxInputType
{
	DIGITAL;
	ANALOG;
}

enum FlxInputDevice
{
	UNKNOWN;
	MOUSE;
	MOUSE_WHEEL;
	KEYBOARD;
	GAMEPAD;
	STEAM_CONTROLLER;
	IFLXINPUT_OBJECT;
	ALL;
}

/**
 * Just a bucket for some handy sentinel values.
 */
class FlxInputDeviceID
{
	/**
	 * Means "every connected device of the given type" (ie all gamepads, all steam controllers, etc)
	 */
	public static inline var ALL:Int          = -1;
	
	/**
	 * Means "the first connected device that has an active input" (ie a pressed button or moved analog stick/trigger/etc)
	 */
	public static inline var FIRST_ACTIVE:Int = -2;
	
	/**
	 * Means "no device"
	 */
	public static inline var NONE:Int         = -3;
}