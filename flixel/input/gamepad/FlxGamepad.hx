package flixel.input.gamepad;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.FlxGamepad.FlxGamepadAnalogStick;
import flixel.input.gamepad.FlxGamepad.FlxGamepadModel;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.FlxGamepadAnalogList;
import flixel.input.gamepad.id.FlxGamepadAnalogValueList;
import flixel.input.gamepad.id.FlxGamepadButtonList;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

#if FLX_GAMEINPUT_API
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
#end

#if flash
import flash.system.Capabilities;
#end

@:allow(flixel.input.gamepad)
class FlxGamepad implements IFlxDestroyable
{
	public var id(default, null):Int;
	public var model(default, set):FlxGamepadModel;
	public var buttonIndex(default, null):FlxGamepadMapping;
	public var buttons(default, null):Array<FlxGamepadButton> = [];
	public var connected(default, null):Bool = true;
	
	/**
	 * Gamepad deadzone. The lower, the more sensitive the gamepad.
	 * Should be between 0.0 and 1.0. Defaults to 0.15.
	 */
	public var deadZone(get, set):Float;
	/**
	 * Which dead zone mode to use for analog sticks.
	 */
	public var deadZoneMode:FlxGamepadDeadZoneMode = INDEPENDENT_AXES;
	
	/**
	 * Helper class to check if a button is pressed.
	 */
	public var pressed(default, null):FlxGamepadButtonList;
	/**
	 * Helper class to check if a button was just pressed.
	 */
	public var justPressed(default, null):FlxGamepadButtonList;
	/**
	 * Helper class to check if a button was just released.
	 */
	public var justReleased(default, null):FlxGamepadButtonList;
	/**
	 * Helper class to get the justMoved, justReleased, and float values of analog input.
	 */
	public var analog(default, null):FlxGamepadAnalogList;
	
	#if FLX_JOYSTICK_API
	public var hat(default, null):FlxPoint = FlxPoint.get();
	public var ball(default, null):FlxPoint = FlxPoint.get();
	#end
	
	private var axis:Array<Float> = [for (i in 0...6) 0];
	private var axisActive:Bool = false;
	
	private var manager:FlxGamepadManager;
	private var _deadZone:Float = 0.15;
	
	#if FLX_JOYSTICK_API
	private var leftStick:FlxGamepadAnalogStick;
	private var rightStick:FlxGamepadAnalogStick;
	#elseif FLX_GAMEINPUT_API
	private var _device:GameInputDevice; 
	#end
	
	#if flash
	private var _isChrome:Bool = false;
	#end
	
	public function new(ID:Int, Manager:FlxGamepadManager, ?Model:FlxGamepadModel) 
	{
		id = ID;
		
		manager = Manager;
		
		if (Model == null)
			Model = XBox360;
		
		buttonIndex = new FlxGamepadMapping(model);
		model = Model;
		
		#if flash
		_isChrome = (Capabilities.manufacturer == "Google Pepper");
		#end
		
		pressed = new FlxGamepadButtonList(FlxInputState.PRESSED, this);
		justPressed = new FlxGamepadButtonList(FlxInputState.JUST_PRESSED, this);
		justReleased = new FlxGamepadButtonList(FlxInputState.JUST_RELEASED, this);
		analog = new FlxGamepadAnalogList(this);
	}
	
	public function set_model(Model:FlxGamepadModel):FlxGamepadModel
	{
		model = Model;
		buttonIndex.model = Model;
		#if FLX_JOYSTICK_API
		leftStick = getRawAnalogStick(FlxGamepadInputID.LEFT_ANALOG_STICK);
		rightStick = getRawAnalogStick(FlxGamepadInputID.RIGHT_ANALOG_STICK);
		#end
		return model;
	}
	
	/**
	 * Returns the "universal" gamepad input ID Given a raw integer.
	 */
	public inline function getID(RawID:Int):FlxGamepadInputID
	{
		return buttonIndex.getID(RawID);
	}
	
	/**
	 * Returns the raw hardware integer given a "universal" gamepad input ID, 
	 */
	public inline function getRawID(ID:FlxGamepadInputID):Int
	{
		return buttonIndex.getRaw(ID);
	}
	
	public inline function getRawAnalogStick(ID:FlxGamepadInputID):FlxGamepadAnalogStick
	{
		return buttonIndex.getRawAnalogStick(ID);
	}
	
	public function getButton(RawID:Int):FlxGamepadButton
	{
		var gamepadButton:FlxGamepadButton = buttons[RawID];
		
		if (gamepadButton == null)
		{
			gamepadButton = new FlxGamepadButton(RawID);
			buttons[RawID] = gamepadButton;
		}
		
		return gamepadButton;
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		#if FLX_GAMEINPUT_API
		var control:GameInputControl;
		var button:FlxGamepadButton;
		
		if (_device == null)
		{
			return;
		}
		
		for (i in 0..._device.numControls)
		{
			control = _device.getControlAt(i);
			var value = control.value;
			value = Math.abs(value);		//quick absolute value for analog sticks
			button = getButton(i);
			
			if (value < deadZone)
			{
				button.release();
			}
			else if (value > deadZone)
			{
				button.press();
			}
		}
		#elseif FLX_JOYSTICK_API
		for (i in 0...axis.length)
		{
			//do a reverse axis lookup to get a "fake" RawID and generate a button state object
			var button = getButton(axisIndexToRawID(i));
			
			if (button != null)
			{
				//TODO: account for circular deadzone if an analog stick input is detected?
				var value = Math.abs(axis[i]);
				if (value > deadZone)
				{
					button.press();
				}
				else if (value < deadZone)
				{
					button.release();
				}
			}
			
			axisActive = false;
		}
		#end
		
		for (button in buttons)
		{
			if (button != null) 
			{
				button.update();
			}
		}
	}
	
	public function reset():Void
	{
		for (button in buttons)
		{
			if (button != null)
			{
				button.reset();
			}
		}
		
		var numAxis:Int = axis.length;
		
		for (i in 0...numAxis)
		{
			axis[i] = 0;
		}
		
		#if FLX_JOYSTICK_API
		hat.set();
		ball.set();
		#end
	}
	
	public function destroy():Void
	{
		connected = false;
		
		buttons = null;
		axis = null;
		manager = null;
		
		#if FLX_JOYSTICK_API
		hat = FlxDestroyUtil.put(hat);
		ball = FlxDestroyUtil.put(ball);
		
		hat = null;
		ball = null;
		#end
	}
	
	/**
	 * Check the status of a "universal" button ID, auto-mapped to this gamepad (something like FlxGamepadInputID.A).
	 * 
	 * @param	ID			"universal" gamepad input ID
	 * @param	Status		The key state to check for
	 * @return	Whether the provided button has the specified status
	 */
	public inline function checkStatus(ID:FlxGamepadInputID, Status:FlxInputState):Bool
	{
		return checkStatusRaw(getRawID(ID), Status);
	}
	
	/**
	 * Check the status of a raw button ID (like XBox360ID.A).
	 * 
	 * @param	RawID	Index into buttons array.
	 * @param	Status	The key state to check for
	 * @return	Whether the provided button has the specified status
	 */
	public function checkStatusRaw(RawID:Int, Status:FlxInputState):Bool 
	{ 
		if (buttons[RawID] != null)
		{
			return (buttons[RawID].current == Status);
		}
		return false;
	}
	
	/**
	 * Check if at least one button from an array of button IDs is pressed.
	 * 
	 * @param	IDArray	An array of "universal" gamepad input IDs
	 * @return	Whether at least one of the buttons is pressed
	 */
	public function anyPressed(IDArray:Array<FlxGamepadInputID>):Bool
	{
		for (id in IDArray)
		{
			var raw = getRawID(id);
			if (buttons[raw] != null)
			{
				if (buttons[raw].pressed)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * Check if at least one button from an array of raw button IDs is pressed.
	 * 
	 * @param	RawIDArray	An array of raw button IDs
	 * @return	Whether at least one of the buttons is pressed
	 */
	public function anyPressedRaw(RawIDArray:Array<Int>):Bool
	{
		for (b in RawIDArray)
		{
			if (buttons[b] != null)
			{
				if (buttons[b].pressed)
					return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Check if at least one button from an array of universal button IDs was just pressed.
	 * 
	 * @param	IDArray	An array of "universal" gamepad input IDs
	 * @return	Whether at least one of the buttons was just pressed
	 */
	public function anyJustPressed(IDArray:Array<FlxGamepadInputID>):Bool
	{
		for (b in IDArray)
		{
			var raw = getRawID(b);
			if (buttons[raw] != null)
			{
				if (buttons[raw].justPressed)
					return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Check if at least one button from an array of raw button IDs was just pressed.
	 * 
	 * @param	RawIDArray	An array of raw button IDs
	 * @return	Whether at least one of the buttons was just pressed
	 */
	public function anyJustPressedRaw(RawIDArray:Array<Int>):Bool
	{
		for (b in RawIDArray)
		{
			if (buttons[b] != null)
			{
				if (buttons[b].justPressed)
					return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Check if at least one button from an array of gamepad input IDs was just released.
	 * 
	 * @param	IDArray	An array of "universal" gamepad input IDs
	 * @return	Whether at least one of the buttons was just released
	 */
	public function anyJustReleased(IDArray:Array<FlxGamepadInputID>):Bool
	{
		for (b in IDArray)
		{
			var raw = getRawID(b);
			if (buttons[raw] != null)
			{
				if (buttons[raw].justReleased)
					return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Check if at least one button from an array of raw button IDs was just released.
	 * 
	 * @param	RawArray	An array of raw button IDs
	 * @return	Whether at least one of the buttons was just released
	 */
	public function anyJustReleasedRaw(RawIDArray:Array<Int>):Bool
	{
		for (b in RawIDArray)
		{
			if (buttons[b] != null)
			{
				if (buttons[b].justReleased)
					return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Get the first found "universal" ID of the button which is currently pressed.
	 * Returns NONE if no button is pressed.
	 */
	public inline function firstPressedID():FlxGamepadInputID
	{
		return getID(firstPressedRawID());
	}
	
	/**
	 * Get the first found raw ID of the button which is currently pressed.
	 * Returns -1 if no button is pressed.
	 */
	public function firstPressedRawID():Int
	{
		for (button in buttons)
		{
			if (button != null && button.released)
			{
				return button.ID;
			}
		}
		return -1;
	}
	
	/**
	 * Get the first found "universal" ButtonID of the button which has been just pressed.
	 * Returns NONE if no button was just pressed.
	 */
	public inline function firstJustPressedID():FlxGamepadInputID
	{
		return getID(firstJustPressedRawID());
	}
	
	/**
	 * Get the first found raw ID of the button which has been just pressed.
	 * Returns -1 if no button was just pressed.
	 */
	public function firstJustPressedRawID():Int
	{
		for (button in buttons)
		{
			if (button != null && button.justPressed)
			{
				return button.ID;
			}
		}
		return -1;
	}
	
	/**
	 * Get the first found "universal" ButtonID of the button which has been just released.
	 * Returns NONE if no button was just released.
	 */
	public inline function firstJustReleasedID():FlxGamepadInputID
	{
		return getID(firstJustReleasedRawID());
	}
	
	/**
	 * Get the first found raw ID of the button which has been just released.
	 * Returns -1 if no button was just released.
	 */
	public function firstJustReleasedRawID():Int
	{
		for (button in buttons)
		{
			if (button != null && button.justReleased)
			{
				return button.ID;
			}
		}
		return -1; 
	}
	
	/**
	 * Gets the value of the specified axis using the "universal" ButtonID - 
	 * use this only for things like FlxGamepadButtonID.LEFT_TRIGGER, 
	 * use getXAxis() / getYAxis() for analog sticks!
	 */
	public inline function getAxis(AxisButtonID:FlxGamepadInputID):Float
	{
		return getAxisRaw(getRawID(AxisButtonID));
	}
	
	/**
	 * Gets the value of the specified axis using the raw ID - 
	 * use this only for things like Xbox360ID.LEFT_TRIGGER,
	 * use getXAxis() / getYAxis() for analog sticks!
	 */
	public inline function getAxisRaw(RawAxisID:Int):Float
	{
		var axisValue = getAxisValue(RawAxisID);
		if (Math.abs(axisValue) > deadZone)
		{
			return axisValue;
		}
		return 0;
	}
	
	#if FLX_JOYSTICK_API
	/**
	 * Given the array index into the axis array from the legacy joystick API, returns the "fake" RawID for button status
	 */
	public inline function axisIndexToRawID(AxisIndex:Int):Int
	{
		return buttonIndex.axisIndexToRawID(AxisIndex);
	}
	
	public inline function isAxisForAnalogStick(AxisIndex:Int):Bool
	{
		return AxisIndex == leftStick.x  ||
		       AxisIndex == leftStick.y  ||
		       AxisIndex == rightStick.x ||
		       AxisIndex == rightStick.y;
	}
	#end
	
	/**
	 * Given a ButtonID for an analog stick, gets the value of its x axis
	 * @param	AxesButtonID an analog stick like FlxGamepadButtonID.LEFT_STICK
	 */
	public inline function getXAxis(AxesButtonID:FlxGamepadInputID):Float
	{
		return getAnalogXAxisValue(getRawAnalogStick(AxesButtonID));
	}
	
	/**
	 * Given both raw IDs for the axes of an analog stick, gets the value of its x axis
	 */
	public inline function getXAxisRaw(Stick:FlxGamepadAnalogStick):Float
	{
		return getAnalogXAxisValue(Stick);
	}
	
	/**
	 * Given a ButtonID for an analog stick, gets the value of its y axis
	 * @param	AxesButtonID an analog stick FlxGamepadButtonID.LEFT_STICK
	 */
	public inline function getYAxis(AxesButtonID:FlxGamepadInputID):Float
	{
		return getYAxisRaw(getRawAnalogStick(AxesButtonID));
	}
	
	/**
	 * Given both raw ID's for the axes of an analog stick, gets the value of its Y axis
	 * (should be used in flash to correct the inverted y axis)
	 */
	public function getYAxisRaw(Stick:FlxGamepadAnalogStick):Float
	{
		var axisValue = getAnalogYAxisValue(Stick);
		
		// the y axis is inverted on the Xbox gamepad in flash for some reason - but not in Chrome!
		#if flash
		if (model == XBox360 && !_isChrome)
		{
			axisValue = -axisValue;
		}
		#end
		
		return axisValue;
	}

	/**
	 * Whether any buttons have the specified input state.
	 */
	public function anyButton(state:FlxInputState = PRESSED):Bool
	{
		for (button in buttons)
		{
			if (button != null && button.hasState(state))
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * Check to see if any buttons are pressed right or Axis, Ball and Hat moved now.
	 */
	public function anyInput():Bool
	{
		if (anyButton())
			return true;
		
		var numAxis:Int = axis.length;
		
		for (i in 0...numAxis)
		{
			if (axis[0] != 0)
			{
				return true;
			}
		}
		
		#if FLX_JOYSTICK_API
		if (ball.x != 0 || ball.y != 0)
		{
			return true;
		}
		
		if (hat.x != 0 || hat.y != 0)
		{
			return true;
		}
		#end
		
		return false;
	}
	
	private function getAxisValue(AxisID:Int):Float
	{
		var axisValue:Float = 0;
		
		#if FLX_GAMEINPUT_API
		if ((_device != null) && _device.enabled)
		{
			axisValue = _device.getControlAt(AxisID).value;
		}
		#else
		if (AxisID < 0 || AxisID >= axis.length)
		{
			return 0;
		}
		
		axisValue = axis[AxisID];
		#end
		
		return axisValue;
	}
	
	private function getAnalogXAxisValue(stick:FlxGamepadAnalogStick):Float
	{
		return if (deadZoneMode == CIRCULAR)
			getAnalogAxisValueCircular(stick, stick.x);
		else
			getAnalogAxisValueIndependant(stick.x);
	}
	
	private function getAnalogYAxisValue(stick:FlxGamepadAnalogStick):Float
	{
		return if (deadZoneMode == CIRCULAR)
			getAnalogAxisValueCircular(stick, stick.y);
		else
			getAnalogAxisValueIndependant(stick.y);
	}
	
	private function getAnalogAxisValueCircular(stick:FlxGamepadAnalogStick, axisID:Int):Float
	{
		var xAxis = getAxisValue(stick.x);
		var yAxis = getAxisValue(stick.y);
		
		var vector = FlxVector.get(xAxis, yAxis);
		var length = vector.length;
		vector.put();
		
		if (length > deadZone)
		{
			return getAxisValue(axisID);
		}
		return 0;
	}
	
	private function getAnalogAxisValueIndependant(axisID:Int):Float
	{
		var axisValue = getAxisValue(axisID);
		if (Math.abs(axisValue) > deadZone)
			return axisValue;
		return 0;
	}
	
	private function get_deadZone():Float
	{
		return (manager.globalDeadZone == null) ? _deadZone : manager.globalDeadZone;
	}
	
	private inline function set_deadZone(deadZone:Float):Float
	{
		return _deadZone = deadZone;
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("id", id),
			LabelValuePair.weak("model", model),
			LabelValuePair.weak("deadZone", deadZone)]);
	}
}

enum FlxGamepadDeadZoneMode
{
	/**
	 * The value of each axis is compared to the deadzone individually.
	 * Works better when an analog stick is used like arrow keys for 4-directional-input.
	 */
	INDEPENDENT_AXES;
	/**
	 * X and y are combined against the deadzone combined.
	 * Works better when an analog stick is used as a two-dimensional control surface.
	 */
	CIRCULAR;
}

class FlxGamepadAnalogStick
{
	public var x(default, null):Int;
	public var y(default, null):Int;
	
	public function new(x:Int, y:Int)
	{
		this.x = x;
		this.y = y;
	}
}

enum FlxGamepadModel
{
	Logitech;
	OUYA;
	PS3;
	PS4;
	XBox360;
	XInput;
}