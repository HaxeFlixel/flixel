package flixel.input.gamepad;

import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;

#if flash
import flash.ui.GameInputControl;
import flash.ui.GameInputDevice;
import flash.system.Capabilities;
#end

@:allow(flixel.input.gamepad)
class FlxGamepad implements IFlxDestroyable
{
	// Button States (mirrors Key States in FlxKey.hx)
	public static inline var JUST_RELEASED:Int = -1;
	public static inline var RELEASED:Int = 0;
	public static inline var PRESSED:Int = 1;
	public static inline var JUST_PRESSED:Int = 2;
	
	public var id:Int;
	public var buttons:Map<Int, FlxGamepadButton>;
	
	/**
	 * Gamepad deadzone. Sets the sensibility. 
	 * Less this number the more gamepad is sensible. Should be between 0.0 and 1.0.
	 */
	public var deadZone:Float = 0.15;
	
	/**
	 * DPAD
	 */
	#if !flash
	public var hat:FlxPoint;
	public var ball:FlxPoint;
	
	public var dpadUp(get, null):Bool = false;
	public var dpadDown(get, null):Bool = false;
	public var dpadLeft(get, null):Bool = false;
	public var dpadRight(get, null):Bool = false;
	#end
	
	/**
	 * Axis array is read-only, use "getAxis" function for deadZone checking.
	 */
	private var axis:Array<Float>;
	
	#if flash
	private var _device:GameInputDevice; 
	#end
	
	public function new(ID:Int, GlobalDeadZone:Float = 0) 
	{
		buttons = new Map<Int, FlxGamepadButton>();
		axis = [for (i in 0...6) 0];
		id = ID;
		
		if (GlobalDeadZone != 0)
		{
			deadZone = GlobalDeadZone;
		}
		
		#if !flash
		ball = FlxPoint.get();
		hat = FlxPoint.get();
		#end
	}
	
	public function getButton(ButtonID:Int):FlxGamepadButton
	{
		var gamepadButton:FlxGamepadButton = buttons.get(ButtonID);
		
		if (gamepadButton == null)
		{
			gamepadButton = new FlxGamepadButton(ButtonID);
			buttons.set(ButtonID, gamepadButton);
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
			if ((button.last == -1) && (button.current == -1)) 
			{
				button.current = 0;
			}
			else if ((button.last == 2) && (button.current == 2)) 
			{
				button.current = 1;
			}
			
			button.last = button.current;
		}
	}
	
	public function reset():Void
	{
		for (button in buttons)
		{
			button.current = 0;
			button.last = 0;
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
	public function checkStatus(ButtonID:Int, Status:Int):Bool 
	{ 
		if (buttons.exists(ButtonID))
		{
			return (buttons.get(ButtonID).current == Status);
		}
		return false;
	}
	
	/**
	 * Check if at least one button from an array of keys is pressed.
	 * 
	 * @param	ButtonArray	An array of button IDs as Int
	 * @return	Whether at least one of the keys passed in is pressed
	 */
	public function anyPressed(ButtonArray:Array<Int>):Bool
	{
		for (b in ButtonArray)
		{
			if (buttons.get(b).current == PRESSED)
				return true;
		}
		
		return false;
	}
	
	/**
	 * Check if at least one button from an array of keys is justPressed.
	 * 
	 * @param	ButtonArray	An array of button IDs as Int
	 * @return	Whether at least one of the keys passed in is justRressed
	 */
	public function anyJustPressed(ButtonArray:Array<Int>):Bool
	{
		for (b in ButtonArray)
		{
			if (buttons.get(b).current == JUST_PRESSED)
				return true;
		}
		
		return false;
	}
	/**
	 * Check if at least one button from an array of keys is justReleased.
	 * 
	 * @param	ButtonArray	An array of button IDs as Int
	 * @return	Whether at least one of the keys passed in is justReleased
	 */
	public function anyJustReleased(ButtonArray:Array<Int>):Bool
	{
		for (b in ButtonArray)
		{
			if (buttons.get(b).current == JUST_RELEASED)
				return true;
		}
		
		return false;
	}
	
	/**
	 * Check to see if this button is pressed.
	 * 
	 * @param	ButtonID	The button id (from 0 to 7).
	 * @return	Whether the button is pressed
	 */
	public function pressed(ButtonID:Int):Bool 
	{
		#if js
		var pad:js.html.Gamepad = null,
			nav:js.html.Navigator = untyped navigator;
		if (untyped nav.webkitGetGamepads != null) { // if browser has webkit gamepads as such
			pad = untyped nav.webkitGetGamepads().item(id);
		}
		return (pad != null) && (Math.round(pad.buttons[ButtonID]) == 1);
		#else
		if (buttons.exists(ButtonID))
		{
			return (buttons.get(ButtonID).current > RELEASED);
		}
		#end
		
		return false;
	}
	
	/**
	 * Check to see if this button was just pressed.
	 * 
	 * @param	ButtonID	The button id (from 0 to 7).
	 * @return	Whether the button was just pressed
	 */
	public function justPressed(ButtonID:Int):Bool 
	{ 
		if (buttons.exists(ButtonID))
		{
			return (buttons.get(ButtonID).current == JUST_PRESSED);
		}
		
		return false;
	}
	
	/**
	 * Check to see if this button is just released.
	 * 
	 * @param	buttonID	The button id (from 0 to 7).
	 * @return	Whether the button is just released.
	 */
	public function justReleased(ButtonID:Int):Bool 
	{ 
		if (buttons.exists(ButtonID))
		{
			return (buttons.get(ButtonID).current == JUST_RELEASED);
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
			if (button.current > RELEASED)
			{
				return button.id;
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
			if (button.current == JUST_PRESSED)
			{
				return button.id;
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
			if (button.current == JUST_RELEASED)
			{
				return button.id;
			}
		}
		
		return -1; 
	}
	
	/**
	 * Gets the value of the specified axis - DOES NOT WORK WELL ON 
	 * THE FLASH TARGET, use getXAxis() and getYAxis() instead.
	 */
	public inline function getAxis(AxisID:Int):Float
	{
		return getAxisValue(AxisID);
	}
	
	/**
	 * Gets the value of the specified X axis.
	 */
	public inline function getXAxis(AxisID:Int):Float
	{
		return getAxisValue(AxisID);
	}
	
	/**
	 * Gets the value of the specified Y axis - 
	 * should be used in flash to correct the inverted y axis.
	 */
	public function getYAxis(AxisID:Int):Float
	{
		var axisValue = getAxisValue(AxisID);
		
		// the y axis is inverted on the Xbox gamepad in flash for some reason - but not in Chrome!
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
	 * Check to see if any buttons are pressed right now.
	 */
	public function anyButton():Bool
	{
		for (button in buttons)
		{
			if (button.current > RELEASED)
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
		if (AxisID < 0 || AxisID >= axis.length)
		{
			return 0;
		}
		
		var axisValue:Float = 0;
		
		#if flash
		if ((_device != null) && _device.enabled)
		{
			axisValue = _device.getControlAt(AxisID).value;
		}
		#elseif js
		// TODO: fix this for html5
		//axisValue = untyped navigator.webkitGetGamepads().item(id).axes[AxisID];
		#else
		axisValue = axis[AxisID];
		#end
		
		if (Math.abs(axisValue) > deadZone)
		{
			return axisValue;
		}
		
		return 0;
	}
	
	/**
	 * DPAD accessor properties
	 */
	#if !flash
	private inline function get_dpadUp():Bool    { return hat.y < 0; }
	private inline function get_dpadDown():Bool  { return hat.y > 0; }
	private inline function get_dpadLeft():Bool  { return hat.x < 0; }
	private inline function get_dpadRight():Bool { return hat.x > 0; }
	#end
}
