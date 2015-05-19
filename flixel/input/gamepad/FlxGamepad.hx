package flixel.input.gamepad;

import flixel.input.FlxInput.FlxInputState;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxDestroyUtil;

#if flash
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flash.system.Capabilities;
#end

@:allow(flixel.input.gamepad)
class FlxGamepad implements IFlxDestroyable
{
	public var id(default, null):Int;
	public var buttons(default, null):Array<FlxGamepadButton> = [];
	public var connected(default, null):Bool = true;
	
	/**
	 * Gamepad deadzone. Sets the sensibility. 
	 * Less this number the more gamepad is sensible. Should be between 0.0 and 1.0.
	 */
	public var deadZone:Float = 0.15;
	/**
	 * Which dead zone mode to use for analog sticks.
	 */
	public var deadZoneMode:FlxGamepadDeadZoneMode = INDEPENDANT_AXES;
	
	#if !flash
	public var hat(default, null):FlxPoint = FlxPoint.get();
	public var ball(default, null):FlxPoint = FlxPoint.get();
	
	public var dpadUp(get, null):Bool = false;
	public var dpadDown(get, null):Bool = false;
	public var dpadLeft(get, null):Bool = false;
	public var dpadRight(get, null):Bool = false;
	#end
	
	/**
	 * Axis array is read-only, use "getAxis" function for deadZone checking.
	 */
	private var axis:Array<Float> = [for (i in 0...6) 0];
	
	#if flash
	private var _device:GameInputDevice; 
	#end
	
	public function new(ID:Int, GlobalDeadZone:Float = 0) 
	{
		id = ID;
		
		if (GlobalDeadZone != 0)
		{
			deadZone = GlobalDeadZone;
		}
	}
	
	public function getButton(ButtonID:Int):FlxGamepadButton
	{
		var gamepadButton:FlxGamepadButton = buttons[ButtonID];
		
		if (gamepadButton == null)
		{
			gamepadButton = new FlxGamepadButton(ButtonID);
			buttons[ButtonID] = gamepadButton;
		}
		
		return gamepadButton;
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		#if flash
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
	 * Check the status of a button
	 * 
	 * @param	ButtonID	Index into _keyList array.
	 * @param	Status		The key state to check for
	 * @return	Whether the provided button has the specified status
	 */
	public function checkStatus(ButtonID:Int, Status:FlxInputState):Bool 
	{ 
		if (buttons[ButtonID] != null)
		{
			return (buttons[ButtonID].current == Status);
		}
		return false;
	}
	
	/**
	 * Check if at least one button from an array of button IDs is pressed.
	 * 
	 * @param	ButtonIDArray	An array of button IDs
	 * @return	Whether at least one of the buttons is pressed
	 */
	public function anyPressed(ButtonIDArray:Array<Int>):Bool
	{
		for (b in ButtonIDArray)
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
	 * Check if at least one button from an array of button IDs was just pressed.
	 * 
	 * @param	ButtonArray	An array of button IDs
	 * @return	Whether at least one of the buttons was just pressed
	 */
	public function anyJustPressed(ButtonIDArray:Array<Int>):Bool
	{
		for (b in ButtonIDArray)
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
	 * Check if at least one button from an array of button IDs was just released.
	 * 
	 * @param	ButtonArray	An array of button IDs
	 * @return	Whether at least one of the buttons was just released
	 */
	public function anyJustReleased(ButtonIDArray:Array<Int>):Bool
	{
		for (b in ButtonIDArray)
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
	 * Check to see if this button is pressed.
	 * 
	 * @param	ButtonID	The button ID.
	 * @return	Whether the button is pressed
	 */
	public function pressed(ButtonID:Int):Bool 
	{
		if (buttons[ButtonID] != null)
		{
			return buttons[ButtonID].pressed;
		}
		return false;
	}
	
	/**
	 * Check to see if this button was just pressed.
	 * 
	 * @param	ButtonID	The button ID.
	 * @return	Whether the button was just pressed
	 */
	public function justPressed(ButtonID:Int):Bool 
	{ 
		if (buttons[ButtonID] != null)
		{
			return buttons[ButtonID].justPressed;
		}
		return false;
	}
	
	/**
	 * Check to see if this button was just released.
	 * 
	 * @param	ButtonID	The button ID.
	 * @return	Whether the button was just released.
	 */
	public function justReleased(ButtonID:Int):Bool 
	{ 
		if (buttons[ButtonID] != null)
		{
			return (buttons[ButtonID].justReleased);
		}
		return false;
	}
	
	/**
	 * Get the first found ID of the button which is currently pressed.
	 * Returns -1 if no button is pressed.
	 */
	public function firstPressedButtonID():Int
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
	 * Get the first found ID of the button which has been just pressed.
	 * Returns -1 if no button was just pressed.
	 */
	public function firstJustPressedButtonID():Int
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
	 * Get the first found ID of the button which has been just released.
	 * Returns -1 if no button was just released.
	 */
	public function firstJustReleasedButtonID():Int
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
	 * Gets the value of the specified axis - use this only for things like
	 * XboxButtonID.LEFT_TRIGGER, use getXAxis() / getYAxis() for analog sticks!
	 */
	public inline function getAxis(AxisID:Int):Float
	{
		var axisValue = getAxisValue(AxisID);
		if (Math.abs(axisValue) > deadZone)
		{
			return axisValue;
		}
		return 0;
	}
	
	/**
	 * Gets the value of the specified X axis.
	 */
	public inline function getXAxis(Axes:FlxGamepadAnalogStick):Float
	{
		return getAnalogueAxisValue(FlxAxes.X, Axes);
	}
	
	/**
	 * Gets the value of the specified Y axis - 
	 * should be used in flash to correct the inverted y axis.
	 */
	public function getYAxis(Axes:FlxGamepadAnalogStick):Float
	{
		var axisValue = getAnalogueAxisValue(FlxAxes.Y, Axes);
		
		// the y axis is inverted on the Xbox gamepad in flash for some reason - but not in Chrome!
		// WARNING: this causes unnecessary string allocations - we should remove this hack when possible.
		#if flash
		if ((_device != null) && _device.enabled && (_device.name.indexOf("Xbox") != -1) && 
		   (Capabilities.manufacturer != "Google Pepper"))
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
		
		#if flash
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
	
	#if !flash
	private inline function get_dpadUp():Bool    { return hat.y < 0; }
	private inline function get_dpadDown():Bool  { return hat.y > 0; }
	private inline function get_dpadLeft():Bool  { return hat.x < 0; }
	private inline function get_dpadRight():Bool { return hat.x > 0; }
	#end
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