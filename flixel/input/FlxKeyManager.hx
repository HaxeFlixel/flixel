package flixel.input;

import flash.events.KeyboardEvent;
import flixel.FlxG;
import flixel.input.FlxInput.FlxInputState;
import flixel.input.keyboard.FlxKey;

/**
 * Keeps track of what keys are pressed and how with handy Bools or strings.
 * Automatically instatiated by flixel as a `FlxKeyboard` and accessed via `FlxG.keys`
 * or `FlxAndroidKeys` with `FlxG.android`.
 * Example: `FlxG.keys.justPressed.A`
 */
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
	 * Helper class to check if a key is pressed.
	 */
	public var pressed(default, null):KeyList;

	/**
	 * Helper class to check if a key was just pressed.
	 */
	public var justPressed(default, null):KeyList;

	/**
	 * Helper class to check if a key is released.
	 * @since 4.8.0
	 */
	public var released(default, null):KeyList;

	/**
	 * Helper class to check if a key was just released.
	 */
	public var justReleased(default, null):KeyList;

	/**
	 * Internal storage of input keys as an array, for efficient iteration.
	 */
	@:allow(flixel.input.FlxBaseKeyList)
	var _keyListArray:Array<FlxInput<Key>> = [];

	/**
	 * Internal storage of input keys as a map, for efficient indexing.
	 */
	var _keyListMap:Map<Int, FlxInput<Key>> = new Map<Int, FlxInput<Key>>();

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
	 * Get the ID of the first key which is currently pressed.
	 *
	 * @return	The ID of the first pressed key or -1 if none are pressed.
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
	 * Get the ID of the first key which has just been pressed.
	 *
	 * @return	The ID of the key or -1 if none were just pressed.
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
	 * Get the ID of the first key which has just been released.
	 *
	 * @return	The ID of the key or -1 if none were just released.
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
		/*
		Note: switch(KeyCode) { case ANY: } causes seg faults with
		hashlink on linux. This should use ifs, until it is fixed.
		See: https://github.com/HaxeFlixel/flixel/issues/2318
		*/
		
		if (KeyCode == FlxKey.ANY)
		{
			return switch (Status)
			{
				case PRESSED: pressed.ANY;
				case JUST_PRESSED: justPressed.ANY;
				case RELEASED: released.ANY;
				case JUST_RELEASED: justReleased.ANY;
			}
		}
		
		if (KeyCode == FlxKey.NONE)
		{
			return switch (Status)
			{
				case PRESSED: pressed.NONE;
				case JUST_PRESSED: justPressed.NONE;
				case RELEASED: released.NONE;
				case JUST_RELEASED: justReleased.NONE;
			}
		}
		
		if (_keyListMap.exists(KeyCode))
		{
			return checkStatusUnsafe(KeyCode, Status);
		}
		
		#if debug
		throw 'Invalid key code: $KeyCode.';
		#end
		return false;
	}

	/**
	 * Check the status of a single of key.
	 * Throws errors on ANY, NONE or invalid keys.
	 * Use `checkStatus`, for most cases.
	 * 
	 * @param KeyCode KeyCode to be checked.
	 * @param Status  The key state to check for.
	 * @return Whether the provided key has the specified status.
	 */
	@:allow(flixel.input.FlxBaseKeyList)
	function checkStatusUnsafe(KeyCode:Key, Status:FlxInputState)
	{
		return getKey(KeyCode).hasState(Status);
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

	function new(createKeyList:FlxInputState->FlxKeyManager<Dynamic, Dynamic>->KeyList)
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);

		pressed = createKeyList(FlxInputState.PRESSED, this);
		released = createKeyList(FlxInputState.RELEASED, this);
		justPressed = createKeyList(FlxInputState.JUST_PRESSED, this);
		justReleased = createKeyList(FlxInputState.JUST_RELEASED, this);
	}

	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	function update():Void
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
	function checkKeyArrayState(KeyArray:Array<Key>, State:FlxInputState):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}

		for (code in KeyArray)
		{
			if (checkStatus(code, State))
				return true;
		}

		return false;
	}

	/**
	 * Event handler so FlxGame can toggle keys.
	 */
	function onKeyUp(event:KeyboardEvent):Void
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
	function onKeyDown(event:KeyboardEvent):Void
	{
		var c:Int = resolveKeyCode(event);
		handlePreventDefaultKeys(c, event);

		if (enabled)
		{
			updateKeyStates(c, true);
		}
	}

	function handlePreventDefaultKeys(keyCode:Int, event:KeyboardEvent):Void
	{
		var key:FlxInput<Key> = getKey(keyCode);
		if (key != null && preventDefaultKeys != null && preventDefaultKeys.indexOf(key.ID) != -1)
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
			#if (html5 || android)
			event.preventDefault();
			#end
		}
	}

	/**
	 * A Helper function to check whether an array of keycodes contains
	 * a certain key safely (returns false if the array is null).
	 */
	function inKeyArray(KeyArray:Array<Key>, Event:KeyboardEvent):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		else
		{
			var code = resolveKeyCode(Event);
			for (key in KeyArray)
			{
				if (key == code || key == -2)
				{
					return true;
				}
			}
		}
		return false;
	}

	function resolveKeyCode(e:KeyboardEvent):Int
	{
		return e.keyCode;
	}

	/**
	 * A helper function to update the key states based on a keycode provided.
	 */
	inline function updateKeyStates(KeyCode:Int, Down:Bool):Void
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

	inline function onFocus():Void {}

	inline function onFocusLost():Void
	{
		reset();
	}

	/**
	 * Return a key from the key list, if found. Will return null if not found.
	 */
	inline function getKey(KeyCode:Int):FlxInput<Key>
	{
		return _keyListMap.get(KeyCode);
	}
}
