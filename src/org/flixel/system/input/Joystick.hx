package org.flixel.system.input;

import org.flixel.FlxPoint;

class Joystick 
{
	
	public var buttons:IntHash<JoyButton>;
	public var axis:FlxPoint;
	public var hat:FlxPoint;
	public var ball:FlxPoint;
	public var connected:Bool;
	public var id:Int;
	
	public static inline var NUM_BUTTONS:Int = 8;
	
	public function new(id:Int) 
	{
		buttons = new IntHash<JoyButton>();
		for (i in 0...(Joystick.NUM_BUTTONS))
		{
			buttons.set(i, new JoyButton(i));
		}
		
		ball = new FlxPoint();
		axis = new FlxPoint();
		hat = new FlxPoint();
		connected = false;
		this.id = id;
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
		
		axis.x = axis.y = 0;
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
		
		if (axis.x != 0 || axis.y != 0)
		{
			return true;
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

class JoyButton
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