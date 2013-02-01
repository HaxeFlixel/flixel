package org.flixel.system.input;

#if (cpp || neko)
import org.flixel.FlxG;
import nme.Lib;
import nme.events.JoystickEvent;
import org.flixel.system.input.FlxJoystick;

/**
 * ...
 * @author Zaphod
 */

class FlxJoystickManager implements IFlxInput
{
	/**
	 * Storage for all connected joysticks
	 */
	public var joysticks:IntHash<FlxJoystick>;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
        joysticks  = new IntHash<FlxJoystick>();

		Lib.current.stage.addEventListener(JoystickEvent.AXIS_MOVE, handleAxisMove);
		Lib.current.stage.addEventListener(JoystickEvent.BALL_MOVE, handleBallMove);
		Lib.current.stage.addEventListener(JoystickEvent.BUTTON_DOWN, handleButtonDown);
		Lib.current.stage.addEventListener(JoystickEvent.BUTTON_UP, handleButtonUp);
		Lib.current.stage.addEventListener(JoystickEvent.HAT_MOVE, handleHatMove);
	}
	
	/**
	 * Get a particular Joystick object
	 */
	private function joystick(joystickID:Int):FlxJoystick
	{
		var joy:FlxJoystick = joysticks.get(joystickID);
		if (joy == null)
		{
			joy = new FlxJoystick(joystickID);
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
		
		joysticks = new IntHash<FlxJoystick>();
	}
	
	/**
	 * Event handler so FlxGame can toggle buttons.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleButtonDown(FlashEvent:JoystickEvent):Void
	{
		var joy:FlxJoystick = joystick(FlashEvent.device);
		joy.connected = true;
		
		var o:FlxJoyButton = joy.getButton(FlashEvent.id);
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
		var joy:FlxJoystick = joystick(FlashEvent.device);
		joy.connected = true;
		
		var object:FlxJoyButton = joy.getButton(FlashEvent.id);
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
		var joy:FlxJoystick = joystick(FlashEvent.device);
		joy.connected = true;
		joy.axis = FlashEvent.axis;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleBallMove(FlashEvent:JoystickEvent):Void
	{
		var joy:FlxJoystick = joystick(FlashEvent.device);
		joy.connected = true;
		joy.ball.x = (Math.abs(FlashEvent.x) < joy.deadZone) ? 0 : FlashEvent.x;
		joy.ball.y = (Math.abs(FlashEvent.y) < joy.deadZone) ? 0 : FlashEvent.y;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleHatMove(FlashEvent:JoystickEvent):Void
	{
		var joy:FlxJoystick = joystick(FlashEvent.device);
		joy.connected = true;
		joy.hat.x = (Math.abs(FlashEvent.x) < joy.deadZone) ? 0 : FlashEvent.x;
		joy.hat.y = (Math.abs(FlashEvent.y) < joy.deadZone) ? 0 : FlashEvent.y;
	}

	public function onFocus( ):Void
	{
		
	}

	public function onFocusLost( ):Void
	{
		reset();
	}

	public function toString( ):String
	{
		return 'FlxJoyStickManager';
	}
	
}
#end