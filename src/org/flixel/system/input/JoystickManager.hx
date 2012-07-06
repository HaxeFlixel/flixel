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
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleAxisMove(FlashEvent:JoystickEvent):Void
	{
		var joy:Joystick = joystick(FlashEvent.device);
		joy.connected = true;
		joy.axis.x = (Math.abs(FlashEvent.x) < deadZone) ? 0 : FlashEvent.x;
		joy.axis.y = (Math.abs(FlashEvent.y) < deadZone) ? 0 : FlashEvent.y;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleBallMove(FlashEvent:JoystickEvent):Void
	{
		var joy:Joystick = joystick(FlashEvent.device);
		joy.connected = true;
		joy.ball.x = (Math.abs(FlashEvent.x) < deadZone) ? 0 : FlashEvent.x;
		joy.ball.y = (Math.abs(FlashEvent.y) < deadZone) ? 0 : FlashEvent.y;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleHatMove(FlashEvent:JoystickEvent):Void
	{
		var joy:Joystick = joystick(FlashEvent.device);
		joy.connected = true;
		joy.hat.x = (Math.abs(FlashEvent.x) < deadZone) ? 0 : FlashEvent.x;
		joy.hat.y = (Math.abs(FlashEvent.y) < deadZone) ? 0 : FlashEvent.y;
	}
	
}
#end