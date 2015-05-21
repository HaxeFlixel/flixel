package flixel.input.gamepad;

import flixel.input.FlxInput.FlxInputState;
import flixel.input.gamepad.id.FlxGamepadAnalogList;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.gamepad.id.FlxGamepadButtonList;
import flixel.input.gamepad.FlxGamepad.GamepadModel;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxDestroyUtil;

#if (flash || next)
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flash.system.Capabilities;
#end

@:allow(flixel.input.gamepad)
class FlxGamepad implements IFlxDestroyable
{
	public var id(default, null):Int;
	public var model(default, set):GamepadModel;
	public var buttonIndex(default, null):FlxGamepadMapping;
	public var buttons(default, null):Array<FlxGamepadButton> = [];
	public var connected(default, null):Bool = true;
	
	/**
	 * Gamepad deadzone. Sets the sensibility. 
	 * Less this number the more sensitive the gamepad is. Should be between 0.0 and 1.0.
	 */
	public var deadZone:Float = 0.15;
	/**
	 * Which dead zone mode to use for analog sticks.
	 */
	public var deadZoneMode:FlxGamepadDeadZoneMode = INDEPENDANT_AXES;
	
	#if !flash
	public var hat(default, null):FlxPoint = FlxPoint.get();
	public var ball(default, null):FlxPoint = FlxPoint.get();
	#end
	
	/**
	 * Axis array is read-only, use "getAxis" function for deadZone checking.
	 */
	private var axis:Array<Float> = [for (i in 0...6) 0];
	
	#if (flash || next)
	private var _device:GameInputDevice; 
	#end
	
	#if (flash)
	private var _isChrome:Bool = false;
	#end
	
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
	 * Helper class to get the float value of analog input.
	 */
	public var analog(default, null):FlxGamepadAnalogList;
	
	public function new(ID:Int, GlobalDeadZone:Float = 0, ?Model:GamepadModel) 
	{
		id = ID;
		
		if (Model == null) Model = XBox360;
		
		buttonIndex = new FlxGamepadMapping(model);
		model = Model;
		
		#if flash
		_isChrome = (Capabilities.manufacturer == "Google Pepper");
		#end
		
		if (GlobalDeadZone != 0)
		{
			deadZone = GlobalDeadZone;
		}
		
		pressed = new FlxGamepadButtonList(FlxInputState.PRESSED, this);
		justPressed = new FlxGamepadButtonList(FlxInputState.JUST_PRESSED, this);
		justReleased = new FlxGamepadButtonList(FlxInputState.JUST_RELEASED, this);
		analog = new FlxGamepadAnalogList(this);
	}
	
	public function set_model(Model:GamepadModel):GamepadModel
	{
		model = Model;
		buttonIndex.model = Model;
		return model;
	}
	
	/**
	 * Given a raw integer, return the "universal" gamepad input ID
	 * @param	RawID
	 * @return
	 */
	public inline function getID(RawID:Int):FlxGamepadInputID
	{
		return buttonIndex.getID(RawID);
	}
	
	/**
	 * Given a "universal" gamepad input ID, return the raw hardware integer
	 * @param	ID
	 * @return
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
		#if (flash || next)
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
			button = getButton(i);
			
			if (value == 0)
			{
				button.release();
			}
			else if (value > deadZone)
			{
				button.press();
			}
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
		
		#if !flash
		hat.set();
		ball.set();
		#end
	}
	
	public function destroy():Void
	{
		connected = false;
		
		buttons = null;
		axis = null;
		
		#if !flash
		hat = FlxDestroyUtil.put(hat);
		ball = FlxDestroyUtil.put(ball);
		
		hat = null;
		ball = null;
		#end
	}
	
	/**
	 * Check the status of a "universal" button ID, auto-mapped to this gamepad (something like FlxGamepadID.A)
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
	 * Check the status of a raw button ID (ie, something like XBox360ID.A)
	 * 
	 * @param	RawID	Index into _keyList array.
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
	 * use this only for things like <code>ButtonID.LEFT_TRIGGER</code>, 
	 * use getXAxis() / getYAxis() for analog sticks!
	 */
	public inline function getAxis(AxisButtonID:FlxGamepadInputID):Float
	{
		return getAxisRaw(getRawID(AxisButtonID));
	}
	
	/**
	 * Gets the value of the specified axis using the raw ID - 
	 * use this only for things like <code>XboxButtonID.LEFT_TRIGGER</code>,
	 * use getXAxis() / getYAxis() for analog sticks!
	 */
	public inline function getAxisRaw(RawAxisID:Int):Float
	{
		var axisValue = getAxisValue(RawAxisID);
		if (Math.abs(axisValue) > deadZone)
		{
			#if (!flash && !next)
				//in legacy this returns a (-1,1) range, but in flash/next it returns (0,1) so we normalize to (0,1) for legacy target only
				axisValue = (axisValue+1) / 2;
			#end
			return axisValue;
		}
		return 0;
	}
	
	/**
	 * Given a ButtonID for an analog stick, gets the value of its X axis
	 * @param	AxesButtonID an analog stick, ie <code>ButtonID.LEFT_STICK</code> or <code>ButtonID.RIGHT_STICK</code>
	 * @return	
	 */
	public inline function getXAxis(AxesButtonID:FlxGamepadInputID):Float
	{
		var axesValue = getRawAnalogStick(AxesButtonID);
		return getAnalogueAxisValue(FlxAxes.X, axesValue);
	}
	
	/**
	 * Given both raw ID's for the axes of an analog stick, gets the value of its X axis
	 * @param	Axes a FlxGamepadAnalogStick value
	 */
	public inline function getXAxisRaw(Axes:FlxGamepadAnalogStick):Float
	{
		return getAnalogueAxisValue(FlxAxes.X, Axes);
	}
	
	/**
	 * Given a ButtonID for an analog stick, gets the value of its Y axis
	 * @param	AxesButtonID an analog stick, ie <code>ButtonID.LEFT_STICK</code> or <code>ButtonID.RIGHT_STICK</code>
	 * @return	
	 */
	public inline function getYAxis(AxesButtonID:FlxGamepadInputID):Float
	{
		var axesValue = getRawAnalogStick(AxesButtonID);
		return getYAxisRaw(axesValue);
	}
	
	/**
	 * Given both raw ID's for the axes of an analog stick, gets the value of its Y axis
	 * (should be used in flash to correct the inverted y axis)
	 * @param	Axes a FlxGamepadAnalogStick value
	 */
	public function getYAxisRaw(Axes:FlxGamepadAnalogStick):Float
	{
		var axisValue = getAnalogueAxisValue(FlxAxes.Y, Axes);
		
		// the y axis is inverted on the Xbox gamepad in flash for some reason - but not in Chrome!
		#if (flash)
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
	 * Check to see if any buttons are pressed right or Axis, Ball and Hat Moved now.
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
		
		#if !flash
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
		
		#if (flash || next)
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
	
	private function getAnalogueAxisValue(Axis:FlxAxes, Axes:FlxGamepadAnalogStick):Float
	{
		if (deadZoneMode == CIRCULAR)
		{
			var xAxis = getAxisValue(Axes.get(FlxAxes.X));
			var yAxis = getAxisValue(Axes.get(FlxAxes.Y));
			
			var vector = FlxVector.get(xAxis, yAxis);
			var length = vector.length;
			vector.put();
			
			if (length > deadZone)
			{
				return (Axis == FlxAxes.X) ? xAxis : yAxis;
			}
		}
		else
		{
			var axisValue = getAxisValue(Axes.get(Axis));
			if (Math.abs(axisValue) > deadZone)
			{
				return axisValue;
			}
		}
		
		return 0;
	}
}

enum FlxGamepadDeadZoneMode
{
	/**
	 * The value of each axis is compared to the deadzone individually.
	 * Works better when an analog stick is used like arrow keys for 4-directional-input.
	 */
	INDEPENDANT_AXES;
	/**
	 * X and y are combined against the deadzone combined.
	 * Works better when an analog stick is used as a two-dimensional control surface.
	 */
	CIRCULAR;
}

typedef FlxGamepadAnalogStick = Map<FlxAxes, Int>;

enum FlxAxes
{
	X;
	Y;
}

enum GamepadModel
{
	Logitech;
	OUYA;
	PS3;
	PS4;
	XBox360;
	XInput;
}