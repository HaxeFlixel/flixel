package flixel.input.actions;

import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.gamepad.FlxGamepadInputID;

#if steamwrap
import steamwrap.api.Steam;
import steamwrap.api.Controller;
#end

@:enum
abstract FlxAnalogState(Int) from Int
{
	var JUST_STOPPED =  cast FlxInputState.JUST_RELEASED;	// became 0 on this frame
	var STOPPED      =  cast FlxInputState.RELEASED;		// is 0
	var MOVED        =  cast FlxInputState.PRESSED;			// is !0
	var JUST_MOVED   =  cast FlxInputState.JUST_PRESSED;	// became !0 on this frame
}

class FlxActionInputAnalogMouse extends FlxActionInputAnalog
{
	/**
	 * Mouse movement action input
	 * @param	Trigger What state triggers this action (PRESSED, JUST_PRESSED, RELEASED, JUST_RELEASED)
	 * @param	Axis which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 */
	
	public function new(Trigger:FlxAnalogState, Axis:FlxAnalogAxis = EITHER)
	{
		super(FlxInputDevice.Mouse, -1, cast Trigger, Axis);
	}
	
	override public function update():Void 
	{
		updateVals(FlxG.mouse.x, FlxG.mouse.y);
	}
	
	override private function updateVals(X:Float, Y:Float):Void
	{
		if (X != x)
		{
			xMoved.press();
		}
		else
		{
			xMoved.release();
		}
		
		if (Y != y)
		{
			yMoved.press();
		}
		else
		{
			yMoved.release();
		}
		
		x = X;
		y = Y;
	}
}

class FlxActionInputAnalogGamepad extends FlxActionInputAnalog
{
	/**
	 * Gamepad action input for analog (trigger, joystick, touchpad, etc) events
	 * @param	InputID "universal" gamepad input ID (LEFT_TRIGGER, RIGHT_ANALOG_STICK, TILT_PITCH, etc)
	 * @param	Trigger What state triggers this action (MOVING, JUST_MOVED, STOPPED, JUST_STOPPED)
	 * @param	Axis which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 * @param	GamepadID specific gamepad ID, or FlxInputDeviceID.FIRST_ACTIVE / ALL
	 */
	
	public function new(InputID:FlxGamepadInputID, Trigger:FlxAnalogState, Axis:FlxAnalogAxis = EITHER, GamepadID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputDevice.Gamepad, InputID, cast Trigger, Axis, GamepadID);
	}
	
	override public function update():Void 
	{
		if (deviceID != FlxInputDeviceID.ALL)	//analog data is only meaningful on an individual device
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
				switch(inputID)
				{
					case FlxGamepadInputID.LEFT_ANALOG_STICK: 
						updateVals(gamepad.analog.value.LEFT_STICK_X, gamepad.analog.value.LEFT_STICK_Y);
						
					case FlxGamepadInputID.RIGHT_ANALOG_STICK:
						updateVals(gamepad.analog.value.RIGHT_STICK_X, gamepad.analog.value.RIGHT_STICK_Y);
						
					case FlxGamepadInputID.LEFT_TRIGGER:
						updateVals(gamepad.analog.value.LEFT_TRIGGER, 0);
						
					case FlxGamepadInputID.RIGHT_TRIGGER:
						updateVals(gamepad.analog.value.RIGHT_TRIGGER, 0);
						
					case FlxGamepadInputID.POINTER_X:
						updateVals(gamepad.analog.value.POINTER_X, 0);
						
					case FlxGamepadInputID.POINTER_Y:
						updateVals(gamepad.analog.value.POINTER_Y, 0);
				}
			}
			else
			{
				updateVals(0, 0);
			}
		}
	}
}

class FlxActionInputAnalogSteam extends FlxActionInputAnalog
{
	/**
	 * Steam Controller action input for analog (trigger, joystick, touchpad, etc) events
	 * @param	ActionHandle handle received from FlxSteamController.getAnalogActionHandle()
	 * @param	Trigger what state triggers this action (MOVING, JUST_MOVED, STOPPED, JUST_STOPPED)
	 * @param	Axis which axes to monitor for triggering: X, Y, EITHER, or BOTH
	 * @param	DeviceHandle handle received from FlxSteamController.getConnectedControllers(), or FlxInputDeviceID.ALL / FlxInputDeviceID.FIRST_ACTIVE
	 */
	
	@:allow(flixel.input.actions.FlxActionSet)
	private function new(ActionHandle:Int, Trigger:FlxAnalogState, Axis:FlxAnalogAxis = EITHER, DeviceID:Int = FlxInputDeviceID.ALL)
	{
		super(FlxInputDevice.SteamController, ActionHandle, cast Trigger, Axis, DeviceID);
		#if !steamwrap
			FlxG.log.warn("steamwrap library not installed; steam inputs will be ignored.");
		#end
	}
	
	override public function update():Void 
	{
		//TODO: implement DEVICE_ID_FIRST_ACTIVE
		var handle = deviceID;
		if (handle == FlxInputDeviceID.NONE)
		{
			return;
		}
		else if (deviceID == FlxInputDeviceID.FIRST_ACTIVE)
		{
			handle = FlxSteamController.getFirstActiveHandle();
		}
		
		analogActionData = FlxSteamController.getAnalogActionData(handle, inputID, analogActionData);
		updateVals(analogActionData.x, analogActionData.y);
	}
	
	private static var analogActionData:ControllerAnalogActionData = new ControllerAnalogActionData();
}

@:access(flixel.input.actions.FlxAction)
class FlxActionInputAnalog extends FlxActionInput
{
	public var axis(default, null):FlxAnalogAxis;
	
	public var x(default, null):Float;
	public var y(default, null):Float;
	public var xMoved(default, null):FlxInput<Int>;
	public var yMoved(default, null):FlxInput<Int>;
	
	private function new (Device:FlxInputDevice, InputID:Int, Trigger:FlxInputState, Axis:FlxAnalogAxis = EITHER, DeviceID:Int = FlxInputDeviceID.FIRST_ACTIVE)
	{
		super(FlxInputType.Analog, Device, InputID, Trigger, DeviceID);
		axis = Axis;
		xMoved = new FlxInput<Int>(0);
		yMoved = new FlxInput<Int>(1);
	}
	
	public override function check(Action:FlxAction):Bool 
	{
		var returnVal = switch(axis)
		{
			case X:      compareState(xMoved.current, trigger);
			case Y:      compareState(yMoved.current, trigger);
			case BOTH:   compareState(xMoved.current, trigger) && compareState(yMoved.current, trigger);
			             //in practice, "both pressed" and "both released" could be useful, whereas 
			             //"both just pressed" and "both just released" seem like very unlikely real-world events
			case EITHER: 
				switch(trigger)
				{
					case PRESSED:        checkAxis(aX, PRESSED)       || checkAxis(aY, PRESSED);         //either one pressed
					case RELEASED:       checkAxis(aX, RELEASED)      || checkAxis(aY, RELEASED);        //either one NOT pressed
					
					case JUST_PRESSED:  (checkAxis(aX, JUST_PRESSED)  && checkAxis(aY, JUST_PRESSED)) || //both just pressed == whole stick just pressed
					                    (checkAxis(aX, JUST_PRESSED)  && checkAxis(aY, RELEASED))     || //one just pressed & other NOT pressed == whole stick just pressed
					                    (checkAxis(aX, RELEASED)      && checkAxis(aY, JUST_PRESSED));
					                    
					case JUST_RELEASED: (checkAxis(aX, JUST_RELEASED) && checkAxis(aY, RELEASED)) ||
					                    (checkAxis(aX, RELEASED)      && checkAxis(aY, JUST_RELEASED));  //one just released & other NOT pressed = whole stick just released
				}
		}
		if (returnVal)
		{
			Action._x = x;
			Action._y = y;
		}
		return returnVal;
	}
	
	private static inline var aX = true;
	private static inline var aY = false;
	
	private function checkAxis(isX:Bool, state:FlxInputState):Bool
	{
		var input = isX ? xMoved : yMoved;
		return compareState(input.current, state);
	}
	
	private function updateVals(X:Float, Y:Float):Void
	{
		if (X != 0)
		{
			xMoved.press();
		}
		else
		{
			xMoved.release();
		}
		
		if (Y != 0)
		{
			yMoved.press();
		}
		else
		{
			yMoved.release();
		}
		
		x = X;
		y = Y;
	}
}

@:enum
abstract FlxAnalogAxis(Int) from Int
{
	var X = 0;
	var Y = 1;
	var BOTH = 2;
	var EITHER = 3;
}