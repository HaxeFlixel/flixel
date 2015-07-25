package flixel.input;

import flash.events.KeyboardEvent;
import flixel.FlxG;
import flixel.input.FlxInput;

@:allow(flixel)
class FlxKeyManager<Key:Int, KeyList:FlxBaseKeyList> implements IFlxInputManager
{
	/**
	 * Whether or not keyboard input is currently enabled.
	 */
	public var enabled:Bool = true;
	/**
	 * List of keys on which preventDefault() is called, useful on HTML5 to stop 
	 * the browser from scrolling when pressing the up or down key for example, or
	 * on android to prevent the default back key action.
	 */
	public var preventDefaultKeys:Array<Key> = [];
	
	/**
	 * Helper class to check if a keys is pressed.
	 */
	public var pressed(default, null):KeyList;
	/**
	 * Helper class to check if a keys was just pressed.
	 */
	public var justPressed(default, null):KeyList;
	/**
	 * Helper class to check if a keys was just released.
	 */
	public var justReleased(default, null):KeyList;
	/**
	 * Internal storage of input keys as an array, for efficient iteration.
	 */
	private var _keyListArray:Array<FlxInput<Key>> = [];
	/**
	 * Internal storage of input keys as a map, for efficient indexing.
	 */
	private var _keyListMap:Map<Int, FlxInput<Key>> = new Map<Int, FlxInput<Key>>();
	
	/**
	 * Check to see if at least one key from an array of keys is pressed.
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed in is pressed.
	 */
	public inline function anyPressed(KeyArray:Array<Key>):Bool
	{ 
		return checkKeyArrayState(KeyArray, PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just pressed.
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed was just pressed.
	 */
	public inline function anyJustPressed(KeyArray:Array<Key>):Bool
	{ 
		return checkKeyArrayState(KeyArray, JUST_PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just released.
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed was just released.
	 */
	public inline function anyJustReleased(KeyArray:Array<Key>):Bool
	{ 
		return checkKeyArrayState(KeyArray, JUST_RELEASED);
	}
	
	/**
	 * Get the first key which is currently pressed.
	 * 
	 * @return	The the first pressed Key
	 */
	public function firstPressed():Int
	{
		for (key in _keyListArray)
		{
			if (key != null && key.pressed)
			{
				return key.ID;
			}
		}
		return -1;
	}
	
	/**
	 * Get the name of the first key which has just been pressed.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustPressed():Int
	{
		for (key in _keyListArray)
		{
			if (key != null && key.justPressed)
			{
				return key.ID;
			}
		}
		return -1;
	}
	
	/**
	 * Get the name of the first key which has just been released.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustReleased():Int
	{
		for (key in _keyListArray)
		{
			if (key != null && key.justReleased)
			{
				return key.ID;
			}
		}
		return -1;
	}
	
	/**
	 * Check the status of a single of key
	 * 
	 * @param	KeyCode		KeyCode to be checked.
	 * @param	Status		The key state to check for.
	 * @return	Whether the provided key has the specified status.
	 */
	public function checkStatus(KeyCode:Key, Status:FlxInputState):Bool
	{
		var key:FlxInput<Key> = getKey(KeyCode);
		
		if (key != null)
		{
			if (key.hasState(Status))
			{
				return true;
			}
		}
		#if !FLX_NO_DEBUG
			else
			{
				throw 'Invalid key code: $KeyCode.';
			}
		#end
		
		return false;
	}

	/**
	 * Get an Array of Key that are in a pressed state
	 * 
	 * @return	Array of keys that are currently pressed.
	 */
	public function getIsDown():Array<FlxInput<Key>>
	{
		var keysDown = new Array<FlxInput<Key>>();
		
		for (key in _keyListArray)
		{
			if (key != null && key.pressed)
			{
				keysDown.push(key);
			}
		}
		return keysDown;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_keyListArray = null;
		_keyListMap = null;
	}
	
	/**
	 * Resets all the keys.
	 */
	public function reset():Void
	{
		for (key in _keyListArray)
		{
			if (key != null)
			{
				key.release();
			}
		}
	}
	
	private function new(keyListClass:Class<FlxBaseKeyList>)
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		pressed = cast Type.createInstance(keyListClass, [FlxInputState.PRESSED, this]);
		justPressed = cast Type.createInstance(keyListClass, [FlxInputState.JUST_PRESSED, this]);
		justReleased = cast Type.createInstance(keyListClass, [FlxInputState.JUST_RELEASED, this]);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (key in _keyListArray)
		{
			if (key != null) 
			{
				key.update();
			}
		}
	}
	
	/**
	 * Helper function to check the status of an array of keys
	 * 
	 * @param	KeyArray	An array of keys as Strings
	 * @param	State		The key state to check for
	 * @return	Whether at least one of the keys has the specified status
	 */
	private function checkKeyArrayState(KeyArray:Array<Key>, State:FlxInputState):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		
		for (code in KeyArray)
		{
			var key:FlxInput<Key> = getKey(code);
			
			if (key != null)
			{
				if (key.hasState(State))
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Event handler so FlxGame can toggle keys.
	 */
	private function onKeyUp(event:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(event);
		handlePreventDefaultKeys(c, event);
		
		if (enabled) 
		{
			updateKeyStates(c, false);
		}
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	private function onKeyDown(event:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(event);
		handlePreventDefaultKeys(c, event);
		
		if (enabled) 
		{
			updateKeyStates(c, true);
		}
	}
	
	private function handlePreventDefaultKeys(keyCode:Int, event:KeyboardEvent):Void
	{
		var key:FlxInput<Key> = getKey(keyCode);
		if (key != null && preventDefaultKeys != null && preventDefaultKeys.indexOf(key.ID) != -1)
		{
			#if bitfive
				event.preventDefault();
			#else
				event.stopImmediatePropagation();
				event.stopPropagation();
			#end
		}
	}
	
	/**
	 * A Helper function to check whether an array of keycodes contains 
	 * a certain key safely (returns false if the array is null).
	 */ 
	private function inKeyArray(KeyArray:Array<Key>, Key:Key):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		else
		{
			for (key in KeyArray)
			{
				if (key == Key || key == -2)
				{
					return true;
				}
			}
		}
		return false;
	}
	
	private function resolveKeyCode(e:KeyboardEvent):Int
	{
		return e.keyCode;
	}
	
	/**
	 * A helper function to update the key states based on a keycode provided.
	 */
	private inline function updateKeyStates(KeyCode:Int, Down:Bool):Void
	{
		var key:FlxInput<Key> = getKey(KeyCode);
		
		if (key != null) 
		{
			if (Down)
			{
				key.press();
			}
			else
			{
				key.release();
			}
		}
	}
	
	private inline function onFocus():Void {}

	private inline function onFocusLost():Void
	{
		reset();
	}
	
	/**
	 * Return a key from the key list, if found. Will return null if not found.
	 */
	private inline function getKey(KeyCode:Int):FlxInput<Key>
	{
		return _keyListMap.get(KeyCode);
	}
}