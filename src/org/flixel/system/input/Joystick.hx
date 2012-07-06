package org.flixel.system.input;

import org.flixel.FlxPoint;
import org.flixel.system.replay.JoystickRecord;

class Joystick 
{
	
	public var buttons:IntHash<JoyButton>;
	public var axis:FlxPoint;
	public var hat:FlxPoint;
	public var ball:FlxPoint;
	public var connected:Bool;
	public var id:Int;
	
	public function new(id:Int) 
	{
		buttons = new IntHash<JoyButton>();
		for (i in 0...8)
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
	public function any():Bool
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
	 * Useful for inpurt recording stuff.
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
	
	// TODO: implement recording and replaying joystick input functionality
	
	/**
	 * Records current state of this Joystick object.
	 * Returns null if there is no any input.
	 * @return	JoystickRecord object indicating current joystick status.
	 */
	public function record():JoystickRecord
	{
		// TODO: implement joystick record
		
		var data:JoystickRecord = null;
		/*var i:Int = 0;
		while(i < _total)
		{
			var o:MapObject = _map[i++];
			if ((o == null) || (o.current == 0))
			{
				continue;
			}
			if (data == null)
			{
				data = new Array<CodeValuePair>();
			}
			data.push(new CodeValuePair(i - 1, o.current));
		}*/
		return data;
	}
	
	/**
	 * Part of the joystick input recording system.
	 * Takes data about joystick state and sets it into this Joystick object.
	 * 
	 * @param	Record	data about joystick state.
	 */
	public function playback(Record:JoystickRecord):Void
	{
		// TODO: implement joystick playback
	
		/*var i:Int = 0;
		var l:Int = Record.length;
		var o:CodeValuePair;
		var o2:MapObject;
		while(i < l)
		{
			o = Record[i++];
			#if cpp
			o = CodeValuePair.convertFromFlashToCpp(o);
			#end
			o2 = _map[o.code];
			o2.current = o.value;
			if (o.value > 0)
			{
				//this[o2.name] = true;
				Reflect.setProperty(this, o2.name, true);
			}
		}*/
	}
	
}

class JoyButton
{
	public var id:Int;
	public var current:Int;
	public var last:Int;
	
	public function new(id:Int, ?current:Int = 0, ?last:Int = 0)
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