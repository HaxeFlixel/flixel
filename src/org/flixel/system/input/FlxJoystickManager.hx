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
	 * While you can have each joystick use a custom dead zone, setting this will 
	 * set every gamepad to use this deadzone.
	 */
	public var globalDeadZone(default, set_deadZone):Float;
	
	/**
	 * A counter for the number of active Joysticks
	 */
	public var numActiveJoysticks(getNumActiveJoysticks,null):Int;
	
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
	public function joystick(joystickID:Int):FlxJoystick
	{
		var joy:FlxJoystick = joysticks.get(joystickID);
		if (joy == null)
		{
			joy = new FlxJoystick(joystickID, globalDeadZone);
			joysticks.set(joystickID, joy);
		}
		return joy;
	}
	
	/**
	 * Gets the number of active joysticks
	 */
	function getNumActiveJoysticks():Int
	{
		var count = 0;
		for (joy in joysticks)
			count++;
		return count;
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
		numActiveJoysticks = 0;
	}
	
	/**
	 * Event handler so FlxGame can toggle buttons.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleButtonDown(FlashEvent:JoystickEvent):Void
	{
		var joy:FlxJoystick = joystick(FlashEvent.device);
		
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
		joy.axis = FlashEvent.axis;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	public function handleBallMove(FlashEvent:JoystickEvent):Void
	{
		var joy:FlxJoystick = joystick(FlashEvent.device);
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
		joy.hat.x = (Math.abs(FlashEvent.x) < joy.deadZone) ? 0 : FlashEvent.x;
		joy.hat.y = (Math.abs(FlashEvent.y) < joy.deadZone) ? 0 : FlashEvent.y;
	}
	
	/**
	 * Facility function to set the deadzone on every available gamepad.
	 * @param	DeadZone	Joystick deadzone. Sets the sensibility. 
	 * 						Less this number the more Joystick is sensible.
	 * 						Should be between 0.0 and 1.0.
	 */
	private function set_deadZone(DeadZone:Float):Float
	{
		globalDeadZone = DeadZone;
		for (joy in joysticks)
		{
			joy.deadZone = DeadZone;
		}
		return globalDeadZone;
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