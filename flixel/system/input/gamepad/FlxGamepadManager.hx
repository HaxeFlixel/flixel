package flixel.system.input.gamepad;

#if (cpp || neko)
import openfl.events.JoystickEvent;
#end
#if (cpp || neko || js)
import flash.Lib;
import flixel.system.input.gamepad.FlxGamepad;
import flixel.system.input.IFlxInput;

#if (android && openfl_ouya)
import openfl.utils.JNI;
import tv.ouya.console.api.OuyaController;
#end

/**
 * ...
 * @author Zaphod
 */
class FlxGamepadManager implements IFlxInput
{
	/**
	 * Storage for all connected joysticks
	 */
	private var _gamepads:Map<Int, FlxGamepad>;
	
	/**
	 * Constructor
	 */
	public function new() 
	{
		#if (android && openfl_ouya)
		var getContext = JNI.createStaticMethod ("org.haxe.nme.GameActivity", "getContext", "()Landroid/content/Context;", true);
		OuyaController.init(getContext());
		#end
		
		_gamepads = new Map<Int, FlxGamepad>();
		#if (cpp || neko)
		Lib.current.stage.addEventListener(JoystickEvent.AXIS_MOVE, handleAxisMove);
		Lib.current.stage.addEventListener(JoystickEvent.BALL_MOVE, handleBallMove);
		Lib.current.stage.addEventListener(JoystickEvent.BUTTON_DOWN, handleButtonDown);
		Lib.current.stage.addEventListener(JoystickEvent.BUTTON_UP, handleButtonUp);
		Lib.current.stage.addEventListener(JoystickEvent.HAT_MOVE, handleHatMove);
		#end
	}
	
	/**
	 * Get a particular Gamepad object
	 */
	public function get(GamepadID:Int):FlxGamepad
	{
		var gamepad:FlxGamepad = _gamepads.get(GamepadID);
		
		if (gamepad == null)
		{
			gamepad = new FlxGamepad(GamepadID, globalDeadZone);
			_gamepads.set(GamepadID, gamepad);
		}
		
		return gamepad;
	}
	
	/**
	 * Check to see if any button was pressed on any Gamepad
	 */
	public function anyButton():Bool
	{
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.anyButton())
			{
				return true;
			}
			
			gamepad = it.next();
		}
		
		return false;
	}

	/**
	 * Check to see if this button is pressed on any Gamepad.
	 * 
	 * @param 	ButtonID  The button id (from 0 to 7).
	 * @return 	Whether the button is pressed
	 */
	public function anyPressed(ButtonID:Int):Bool
	{
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.pressed(ButtonID))
			{
				return true;
			}
			
			gamepad = it.next();
		}
		
		return false;
	}

	/**
	 * Check to see if this button was just pressed on any Gamepad.
	 * 
	 * @param 	ButtonID 	The button id (from 0 to 7).
	 * @return 	Whether the button was just pressed
	*/
	public function anyJustPressed(ButtonID:Int):Bool
	{
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.justPressed(ButtonID))
			{
				return true;
			}
			
			gamepad = it.next();
		}
		return false;
	}

	/**
	 * Check to see if this button is just released on any Gamepad.
	 * 
	 * @param 	ButtonID 	The Button id (from 0 to 7).
	 * @return 	Whether the button is just released.
	*/
	public function anyJustReleased(ButtonID:Int):Bool
	{
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.justReleased(ButtonID))
			{
				return true;
			}
			
			gamepad = it.next();
		}
		return false;
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		for (gamepad in _gamepads)
		{
			gamepad.update();
		}
	}
	
	/**
	 * Resets all the keys on all joys.
	 */
	public function reset():Void
	{
		for (gamepad in _gamepads)
		{
			gamepad.reset();
		}
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		for (gamepad in _gamepads)
		{
			gamepad.destroy();
		}
		
		_gamepads = new Map<Int, FlxGamepad>();
		numActiveGamepads = 0;
	}
	
	#if (cpp || neko)
	/**
	 * Event handler so FlxGame can toggle buttons.
	 * 
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	private function handleButtonDown(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = get(FlashEvent.device);
		var o:FlxGamepadButton = gamepad.getButton(FlashEvent.id);
		
		if (o == null) 
		{
			return;
		}
		
		if (o.current > 0) 
		{
			o.current = 1;
		}
		else 
		{
			o.current = 2;
		}
	}
	
	/**
	 * Event handler so FlxGame can toggle buttons.
	 * 
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	private function handleButtonUp(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = get(FlashEvent.device);
		var object:FlxGamepadButton = gamepad.getButton(FlashEvent.id);
		
		if (object == null) 
		{
			return;
		}
		
		if (object.current > 0) 
		{
			object.current = -1;
		}
		else 
		{
			object.current = 0;
		}
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * 
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	private function handleAxisMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = get(FlashEvent.device);
		gamepad.axis = FlashEvent.axis;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * 
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	private function handleBallMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = get(FlashEvent.device);
		gamepad.ball.x = (Math.abs(FlashEvent.x) < gamepad.deadZone) ? 0 : FlashEvent.x;
		gamepad.ball.y = (Math.abs(FlashEvent.y) < gamepad.deadZone) ? 0 : FlashEvent.y;
	}
	
	/**
	 * Event handler so FlxGame can update joystick.
	 * 
	 * @param	FlashEvent	A <code>JoystickEvent</code> object.
	 */
	private function handleHatMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = get(FlashEvent.device);
		gamepad.hat.x = (Math.abs(FlashEvent.x) < gamepad.deadZone) ? 0 : FlashEvent.x;
		gamepad.hat.y = (Math.abs(FlashEvent.y) < gamepad.deadZone) ? 0 : FlashEvent.y;
	}
	#end
	
	inline public function onFocus():Void { }

	inline public function onFocusLost():Void
	{
		reset();
	}

	inline public function toString():String
	{
		return 'FlxGamepadManager';
	}
	
	/**
	 * A counter for the number of active Joysticks
	 */
	public var numActiveGamepads(get, null):Int;

	private function get_numActiveGamepads():Int
	{
		var count = 0;
		
		for (gamepad in _gamepads)
		{
			count++;
		}
		
		return count;
	}
	
	/**
	 * While you can have each joystick use a custom dead zone, setting this will 
	 * set every gamepad to use this deadzone.
	 */
	public var globalDeadZone(default, set):Float;
	
	/**
	 * Facility function to set the deadzone on every available gamepad.
	 * @param	DeadZone	Joystick deadzone. Sets the sensibility. 
	 * 						Less this number the more Joystick is sensible.
	 * 						Should be between 0.0 and 1.0.
	 */
	private function set_globalDeadZone(DeadZone:Float):Float
	{
		globalDeadZone = DeadZone;
		
		for (gamepad in _gamepads)
		{
			gamepad.deadZone = DeadZone;
		}
		
		return globalDeadZone;
	}
}
#end
