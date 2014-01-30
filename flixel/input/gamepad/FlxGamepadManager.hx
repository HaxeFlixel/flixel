package flixel.input.gamepad;

import flash.Lib;
import flixel.FlxG;
import flixel.input.gamepad.FlxGamepad;
import flixel.interfaces.IFlxInput;
#if (cpp || neko)
import openfl.events.JoystickEvent;
#end
#if (cpp || neko || js)

/**
 * Manages gamepad input
 * @author Zaphod
 */
class FlxGamepadManager implements IFlxInput
{
	/**
	 * First accessed gamepad
	 */
	public var firstActive:FlxGamepad;
	/**
	 * Last accessed gamepad
	 */
	public var lastActive:FlxGamepad;
	
	/**
	 * A counter for the number of active Joysticks
	 */
	public var numActiveGamepads(get, null):Int;
	
	/**
	 * While you can have each joystick use a custom dead zone, setting this will 
	 * set every gamepad to use this deadzone.
	 */
	public var globalDeadZone(default, set):Float;
	
	/**
	 * Storage for all connected joysticks
	 */
	private var _gamepads:Map<Int, FlxGamepad>;
	
	public function getByID(GamepadID:Int):FlxGamepad
	{
		var gamepad:FlxGamepad = _gamepads.get(GamepadID);
		
		if (gamepad == null)
		{
			gamepad = new FlxGamepad(GamepadID, globalDeadZone);
			_gamepads.set(GamepadID, gamepad);
			
			lastActive = gamepad;
			if (firstActive == null)
				firstActive = gamepad;
		}
		
		return gamepad;
	}
	
	/**
	 * Get array of ids for gamepads with any pressed buttons or moved Axis, Ball and Hat.
	 * @param	IDsArray	optional array to fill with ids
	 * @return	array filled with active gamepad ids
	 */
	public function getActiveGamepadIDs(IDsArray:Array<Int> = null):Array<Int>
	{
		if (IDsArray == null)
		{
			IDsArray = [];
		}
		
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.anyInput())
			{
				IDsArray.push(gamepad.id);
			}
			
			gamepad = it.next();
		}
		
		return IDsArray;
	}
	
	/**
	 * Get array of gamepads with any pressed buttons or moved Axis, Ball and Hat.
	 * @param	GamepadArray	optional array to fill with active gamepads
	 * @return	array filled with active gamepads
	 */
	public function getActiveGamepads(GamepadArray:Array<FlxGamepad> = null):Array<FlxGamepad>
	{
		if (GamepadArray == null)
		{
			GamepadArray = [];
		}
		
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.anyInput())
			{
				GamepadArray.push(gamepad);
			}
			
			gamepad = it.next();
		}
		
		return GamepadArray;
	}
	
	/**
	 * Get first found active gamepad id (with any pressed buttons or moved Axis, Ball and Hat).
	 * Returns "-1" if no active gamepad has been found.
	 */
	public function getFirstActiveGamepadID():Int
	{
		var it = _gamepads.iterator();
		var gamepad:FlxGamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.anyInput())
			{
				return gamepad.id;
			}
			
			gamepad = it.next();
		}
		
		return -1;
	}
	
	/**
	 * Get first found active gamepad (with any pressed buttons or moved Axis, Ball and Hat).
	 * Returns null if no active gamepad has been found.
	 */
	public function getFirstActiveGamepad():FlxGamepad
	{
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.anyInput())
			{
				return gamepad;
			}
			
			gamepad = it.next();
		}
		
		return null;
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
	 * Check to see if any buttons are pressed right or Axis, Ball and Hat Moved on any Gamepad
	 */
	public function anyInput():Bool
	{
		var it = _gamepads.iterator();
		var gamepad = it.next();
		
		while (gamepad != null)
		{
			if (gamepad.anyInput())
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
	 * Clean up memory. Internal use only.
	 */
	@:noCompletion public function destroy():Void
	{
		for (gamepad in _gamepads)
		{
			gamepad.destroy();
		}
		
		firstActive = FlxG.safeDestroy(firstActive);
		lastActive = FlxG.safeDestroy(lastActive);
		_gamepads = new Map<Int, FlxGamepad>();
		numActiveGamepads = 0;
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
	
	@:allow(flixel.FlxG)
	private function new() 
	{
		firstActive = null;
		lastActive = null;
		_gamepads = new Map<Int, FlxGamepad>();
		
		#if (cpp || neko)
		Lib.current.stage.addEventListener(JoystickEvent.AXIS_MOVE, handleAxisMove);
		Lib.current.stage.addEventListener(JoystickEvent.BALL_MOVE, handleBallMove);
		Lib.current.stage.addEventListener(JoystickEvent.BUTTON_DOWN, handleButtonDown);
		Lib.current.stage.addEventListener(JoystickEvent.BUTTON_UP, handleButtonUp);
		Lib.current.stage.addEventListener(JoystickEvent.HAT_MOVE, handleHatMove);
		#end
	}
	
	#if (cpp || neko)
	private function handleButtonDown(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = getByID(FlashEvent.device);
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
	
	private function handleButtonUp(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = getByID(FlashEvent.device);
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
	
	private function handleAxisMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = getByID(FlashEvent.device);
		gamepad.axis = FlashEvent.axis;
	}
	
	private function handleBallMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = getByID(FlashEvent.device);
		gamepad.ball.x = (Math.abs(FlashEvent.x) < gamepad.deadZone) ? 0 : FlashEvent.x;
		gamepad.ball.y = (Math.abs(FlashEvent.y) < gamepad.deadZone) ? 0 : FlashEvent.y;
	}
	
	private function handleHatMove(FlashEvent:JoystickEvent):Void
	{
		var gamepad:FlxGamepad = getByID(FlashEvent.device);
		gamepad.hat.x = (Math.abs(FlashEvent.x) < gamepad.deadZone) ? 0 : FlashEvent.x;
		gamepad.hat.y = (Math.abs(FlashEvent.y) < gamepad.deadZone) ? 0 : FlashEvent.y;
	}
	#end
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (gamepad in _gamepads)
		{
			gamepad.update();
		}
	}
	
	private inline function onFocus():Void { }

	private inline function onFocusLost():Void
	{
		reset();
	}

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
