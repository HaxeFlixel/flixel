package flixel.input.android;

#if android
import flash.events.KeyboardEvent;
import flash.Lib;
import flixel.FlxG;
import flixel.input.FlxInput;

/**
 * Keeps track of Android system key presses (Back/Menu)
 */
@:allow(flixel.input.android.FlxAndroidKeyList)
class FlxAndroidKeys implements IFlxInputManager
{
	/**
	 * Total amount of keys.
	 */
	private static inline var TOTAL:Int = 2;
	
	/**
	 * Whether or not android key input is currently enabled
	 */
	public var enabled:Bool = true;
	
	/**
	 * Helper class to check if a keys is pressed.
	 */
	public var pressed:FlxAndroidKeyList;
	/**
	 * Helper class to check if a keys was just pressed.
	 */
	public var justPressed:FlxAndroidKeyList;
	/**
	 * Helper class to check if a keys was just released.
	 */
	public var justReleased:FlxAndroidKeyList;
	
	@:allow(flixel.input.android.FlxAndroidKeyList.get_ANY)
	private var _keyList:Array<FlxAndroidKeyInput>;
	
	/**
	 * Check to see if at least one key from an array of keys is pressed.
	 * Example: FlxG.keys.anyPressed([UP, W, SPACE]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed in is pressed.
	 */
	public inline function anyPressed(KeyArray:Array<FlxAndroidKey>):Bool
	{ 
		return checkKeyArrayState(KeyArray, PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just pressed.
	 * Example: FlxG.keys.anyJustPressed([UP, W, SPACE]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed was just pressed.
	 */
	public inline function anyJustPressed(KeyArray:Array<FlxAndroidKey>):Bool
	{ 
		return checkKeyArrayState(KeyArray, JUST_PRESSED);
	}
	
	/**
	 * Check to see if at least one key from an array of keys was just released.
	 * Example: FlxG.keys.anyJustReleased([UP, W, SPACE]) - having them in an array is handy for configurable keys!
	 * 
	 * @param	KeyArray 	An array of key names
	 * @return	Whether at least one of the keys passed was just released.
	 */
	public inline function anyJustReleased(KeyArray:Array<FlxAndroidKey>):Bool
	{ 
		return checkKeyArrayState(KeyArray, JUST_RELEASED);
	}
	
	/**
	 * Get the first key which is currently pressed.
	 * 
	 * @return	The first pressed FlxAndroidKey
	 */
	public function firstPressed():FlxAndroidKey
	{
		for (key in _keyList)
		{
			if (key != null && key.pressed)
			{
				return key.ID;
			}
		}
		return FlxAndroidKey.NONE;
	}
	
	/**
	 * Get the name of the first key which has just been pressed.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustPressed():FlxAndroidKey
	{
		for (key in _keyList)
		{
			if (key != null && key.justPressed)
			{
				return key.ID;
			}
		}
		return "";
	}
	
	/**
	 * Get the name of the first key which has just been released.
	 * 
	 * @return	The name of the key or "" if none could be found.
	 */
	public function firstJustReleased():FlxAndroidKey
	{
		for (key in _keyList)
		{
			if (key != null && key.justReleased)
			{
				return key.ID;
			}
		}
		return "";
	}
	
	/**
	 * Check the status of a single of key
	 * 
	 * @param	KeyCode		Index into _keyList array.
	 * @param	Status		The key state to check for
	 * @return	Whether the provided key has the specified status
	 */
	public function checkStatus(KeyCode:FlxAndroidKey, Status:FlxInputState):Bool
	{
		var key:FlxAndroidKeyInput = _keyList[KeyCode];
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
	 * Get an Array of FlxAndroidKey that are in a pressed state
	 * 
	 * @return	Array of keys that are currently pressed.
	 */
	public function getIsDown():Array<FlxAndroidKeyInput>
	{
		var keysDown = new Array<FlxAndroidKeyInput>();
		
		for (key in _keyList)
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
		_keyList = null;
	}
	
	/**
	 * Resets all the keys.
	 */
	public function reset():Void
	{
		for (key in _keyList)
		{
			if (key != null)
			{
				key.release();
			}
		}
	}
	
	@:allow(flixel.FlxG)
	private function new()
	{
		_keyList = new Array<FlxAndroidKeyInput>();
		
		// BACK button
		_keyList[27] = new FlxAndroidKeyInput(27);
		// MENU button
		_keyList[16777234] = new FlxAndroidKeyInput(16777234);
		
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		pressed = new FlxAndroidKeyList(PRESSED);
		justPressed = new FlxAndroidKeyList(JUST_PRESSED);
		justReleased = new FlxAndroidKeyList(JUST_RELEASED);
	}
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (key in _keyList)
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
	private function checkKeyArrayState(KeyArray:Array<FlxAndroidKey>, State:FlxInputState):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		
		for (code in KeyArray)
		{
			var key:FlxAndroidKeyInput = _keyList[code];
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
		if (enabled) 
		{
			updateKeyStates(event.keyCode, false);
		}
	}
	
	/**
	 * Internal event handler for input and focus.
	 */
	private function onKeyDown(event:KeyboardEvent):Void
	{
		if (enabled) 
		{
			updateKeyStates(event.keyCode, true);
		}
	}
	
	/**
	 * A Helper function to check whether an array of keycodes contains 
	 * a certain key safely (returns false if the array is null).
	 */ 
	private function inKeyArray(KeyArray:Array<FlxAndroidKey>, Key:FlxAndroidKey):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		else
		{
			for (key in KeyArray)
			{
				if (key == Key || key == "ANY")
				{
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * A helper function to update the key states based on a keycode provided.
	 */
	private inline function updateKeyStates(KeyCode:Int, Down:Bool):Void
	{
		var key:FlxAndroidKeyInput = _keyList[KeyCode];
		
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
}

typedef FlxAndroidKeyInput = FlxInput<Int>;
#end