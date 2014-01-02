package flixel.system.input.gamepad;

import flixel.util.FlxPoint;

class FlxGamepad 
{
	public var buttons:Map<Int, FlxGamepadButton>;
	
	@:allow(flixel.system.input.gamepad)
	public var axis(default, null):Array<Float>;
	/**
	 * DPAD on Xbox Gamepad
	 */
	public var hat:FlxPoint;
	public var ball:FlxPoint;
	public var id:Int;
	
	/**
	 * Gamepad deadzone. Sets the sensibility. 
	 * Less this number the more gamepad is sensible.
	 * Should be between 0.0 and 1.0.
	 */
	public var deadZone:Float = 0.15;
	
	public function new(ID:Int, GlobalDeadZone:Float = 0) 
	{
		buttons = new Map<Int, FlxGamepadButton>();
		ball = new FlxPoint();
		axis = new Array<Float>();
		axis = [for (i in 0...4) 0];
		hat = new FlxPoint();
		id = ID;
		
		if (GlobalDeadZone != 0)
		{
			deadZone = GlobalDeadZone;
		}
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
		
		hat.set();
		ball.set();
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
	 * 
	 * @param	ButtonID	The button id (from 0 to 7).
	 * @return	Whether the button is pressed
	 */
	public function pressed(ButtonID:Int):Bool 
	{
		#if (cpp || neko)
		if (buttons.exists(ButtonID))
		{
			return (buttons.get(ButtonID).current > 0);
		}
		#elseif js
			var v = untyped navigator.webkitGetGamepads().item(id).buttons[ButtonID];
			return if (Math.round(v) == 1) true else false;
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
			return (buttons.get(ButtonID).current == 2);
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
			return (buttons.get(ButtonID).current == -1);
		}
		
		return false;
	}
	
	public function getAxis(AxisID:Int):Float
	{
		if (AxisID < 0 || AxisID >= axis.length)
		{
			return 0;
		}
		
		#if (cpp || neko)
		if (Math.abs(axis[AxisID]) > deadZone)
		{
			return axis[AxisID];
		}
		#elseif js
		var v:Float = untyped navigator.webkitGetGamepads().item(id).axes[AxisID];
		if (Math.abs(v) > deadZone)
		{
			return Math.round(v);
		}
		#end
		return 0;
	}
	
	/**
	 * Check to see if any buttons are pressed right now.
	 * 
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
	 * 
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
