package org.flixel.system.input;

import org.flixel.FlxU;
import org.flixel.FlxPoint;

class FlxJoystick 
{
	
	public var buttons:IntHash<FlxJoyButton>;
	public var axis(null, default):Array<Float>;
	public var hat:FlxPoint;	// DPAD on Xbox Gamepad
	public var ball:FlxPoint;
	public var id:Int;
	
	/**
	 * Joystick deadzone. Sets the sensibility. 
	 * Less this number the more Joystick is sensible.
	 * Should be between 0.0 and 1.0.
	 */
	public var deadZone:Float = 0.15;
	
	public function new(id:Int, globalDeadZone:Float = 0) 
	{
		buttons = new IntHash<FlxJoyButton>();
		ball = new FlxPoint();
		axis = new Array<Float>();
		hat = new FlxPoint();
		this.id = id;
		
		if (globalDeadZone != 0)
			deadZone = globalDeadZone;
	}
	
	public function getButton(buttonID:Int):FlxJoyButton
	{
		var joyButton:FlxJoyButton = buttons.get(buttonID);
		if (joyButton == null)
		{
			joyButton = new FlxJoyButton(buttonID);
			buttons.set(buttonID, joyButton);
		}
		return joyButton;
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
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
		
		hat.x = hat.y = 0;
		ball.x = ball.y = 0;
	}
	
	public function destroy():Void
	{
		buttons = null;
		axis = null;
		hat = null;
		ball = null;
	}
	
	/**
	 * Check to see if this button is pressed.
	 * @param	buttonID		button id (from 0 to 7).
	 * @return	Whether the button is pressed
	 */
	public function pressed(buttonID:Int):Bool 
	{ 
		if (buttons.exists(buttonID))
		{
			return (buttons.get(buttonID).current > 0);
		}
		
		return false;
	}
	
	/**
	 * Check to see if this button was just pressed.
	 * @param	buttonID		button id (from 0 to 7).
	 * @return	Whether the button was just pressed
	 */
	public function justPressed(buttonID:Int):Bool 
	{ 
		if (buttons.exists(buttonID))
		{
			return (buttons.get(buttonID).current == 2);
		}
		
		return false;
	}
	
	/**
	 * Check to see if this button is just released.
	 * @param	buttonID		button id (from 0 to 7).
	 * @return	Whether the button is just released.
	 */
	public function justReleased(buttonID:Int):Bool 
	{ 
		if (buttons.exists(buttonID))
		{
			return (buttons.get(buttonID).current == -1);
		}
		
		return false;
	}
	
	public function getAxis(axeID:Int):Float
	{
		if (axeID < 0 || axeID >= axis.length)
			return 0;
			
		if (FlxU.abs(axis[axeID]) > deadZone)
			return axis[axeID];
		
		return 0;
	}
	
	/**
	 * Check to see if any buttons are pressed right now.
	 * @return	Whether any buttons are currently pressed.
	 */
	public function anyButton():Bool
	{
		for (button in buttons)
		{
			if (button.current > 0)
			{
				return true;
			}
		}
		
		return false;
	}
	
	/**
	 * Check to see if any buttons are pressed right or Axis, Ball and Hat Moved now.
	 * @return	Whether any buttons are currently pressed.
	 */
	public function anyInput():Bool
	{
		for (button in buttons)
		{
			if (button.current > 0)
			{
				return true;
			}
		}
		
		var numAxis:Int = axis.length;
		for (i in 0...numAxis)
		{
			if (axis[0] != 0)
			{
				return true;
			}
		}
		
		if (ball.x != 0 || ball.y != 0)
		{
			return true;
		}
		
		if (hat.x != 0 || hat.y != 0)
		{
			return true;
		}
		
		return false;
	}
	
}

class FlxJoyButton
{
	public var id:Int;
	public var current:Int;
	public var last:Int;
	
	public function new(id:Int, current:Int = 0, last:Int = 0)
	{
		this.id = id;
		this.current = current;
		this.last = last;
	}
	
	public function reset():Void
	{
		this.current = 0;
		this.last = 0;
	}
}


// Button IDs for commonly used gamepads:
class XBOX_BUTTON_IDS
{
	public static var A_BUTTON:Int = 0;
	public static var B_BUTTON:Int = 1;
	public static var X_BUTTON:Int = 2;
	public static var Y_BUTTON:Int = 3;
	public static var LB_BUTTON:Int = 4;
	public static var RB_BUTTON:Int = 5;
	public static var BACK_BUTTON:Int = 6;
	public static var START_BUTTON:Int = 7;
	public static var LEFT_ANALOGUE_X:Int = 0;
	public static var LEFT_ANALOGUE_Y:Int = 1;
	public static var RIGHT_ANALOGUE_X:Int = 4;
	public static var RIGHT_ANALOGUE_Y:Int = 3;
	
	/**
	 * Keep in mind that if TRIGGER axis returns value > 0 then LT is being pressed, and if it's < 0 then RT is being pressed
	 */
	public static var TRIGGER:Int = 2;
}