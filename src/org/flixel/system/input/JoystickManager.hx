package org.flixel.system.input;

#if (cpp || neko)
import nme.events.JoystickEvent;
import org.flixel.system.input.Joystick;

/**
 * ...
 * @author Zaphod
 */

class JoystickManager 
{

	/**
	 * Joystick deadzone. Sets the sensibility. 
	 * Less this number the more Joystick is sensible.
	 * Should be between 0.0 and 1.0.
	 */
	public static var deadZone:Float = 0.0;
	
	public static var joysticks:IntHash<Joystick> = new IntHash<Joystick>();
	
	public static function joystick(joystickID:Int):Joystick
	{
		var joy:Joystick = joysticks.get(joystickID);
		if (joy == null)
		{
			joy = new Joystick(joystickID);
			joysticks.set(joystickID, joy);
		}
		return joy;
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		for (joy in joysticks)
		{
			joy.update();
		}
	}
	
	/**
	 * Resets all the keys on all joys.
	 */
	public function reset():Void
	{
		for (joy in joysticks)
		{
			joy.reset();
		}
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		for (joy in joysticks)
		{
			joy.destroy();
		}
		
		joysticks = new IntHash<Joystick>();
	}
	
	/**
	 * Event handler so FlxGame can toggle buttons.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleButtonDown(FlashEvent:JoystickEvent):Void
	{
		var joy:Joystick = joystick(FlashEvent.device);
		joy.connected = true;
		
		var o:JoyButton = joy.buttons.get(FlashEvent.id);
		if (o == null) return;
		if(o.current > 0) o.current = 1;
		else o.current = 2;
	}
	
	/**
	 * Event handler so FlxGame can toggle buttons.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleButtonUp(FlashEvent:JoystickEvent):Void
	{
		var joy:Joystick = joystick(FlashEvent.device);
		joy.connected = true;
		
		var object:JoyButton = joy.buttons.get(FlashEvent.id);
		if(object == null) return;
		if(object.current > 0) object.current = -1;
		else object.current = 0;
	}
	
}
#end

// This code should be moved to FlxG and FlxGame classes

/*
#if (cpp || neko)
import nme.events.JoystickEvent;
#end
*/

/*
#if (cpp || neko)
FlxG.stage.addEventListener(JoystickEvent.AXIS_MOVE, onJoyAxisMove);
FlxG.stage.addEventListener(JoystickEvent.BALL_MOVE, onJoyBallMove);
FlxG.stage.addEventListener(JoystickEvent.BUTTON_DOWN, onJoyButtonDown);
FlxG.stage.addEventListener(JoystickEvent.BUTTON_UP, onJoyButtonUp);
FlxG.stage.addEventListener(JoystickEvent.HAT_MOVE, onJoyHatMove);
#end
*/

/*
#if (cpp || neko)
	private static function onJoyAxisMove(e:JoystickEvent):Void
	{
		var joy:Joystick = joystick(e.device);
		joy.connected = true;
		joy.axis.x = (Math.abs(e.x) < deadZone) ? 0 : e.x;
		joy.axis.y = (Math.abs(e.y) < deadZone) ? 0 : e.y;
	}

	private static function onJoyBallMove(e:JoystickEvent):Void
	{
		var joy:Joystick = joystick(e.device);
		joy.connected = true;
		joy.ball.x = (Math.abs(e.x) < deadZone) ? 0 : e.x;
		joy.ball.y = (Math.abs(e.y) < deadZone) ? 0 : e.y;
	}

	private static function onJoyButtonDown(e:JoystickEvent):Void
	{
		var joy:Joystick = joystick(e.device);
		joy.connected = true;
		if (e.id < 8)
		{
			joy.buttons[e.id] = true;
		}
	}

	private static function onJoyButtonUp(e:JoystickEvent):Void
	{
		var joy:Joystick = joystick(e.device);
		joy.connected = true;
		if (e.id < 8)
		{
			joy.buttons[e.id] = false;
		}
	}

	private static function onJoyHatMove(e:JoystickEvent):Void
	{
		var joy:Joystick = joystick(e.device);
		joy.connected = true;
		joy.hat.x = (Math.abs(e.x) < deadZone) ? 0 : e.x;
		joy.hat.y = (Math.abs(e.y) < deadZone) ? 0 : e.y;
	}
#end
*/