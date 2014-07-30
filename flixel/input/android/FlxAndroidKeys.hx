package flixel.input.android;
import flixel.util.FlxArrayUtil;

#if android
import flash.events.KeyboardEvent;
import flash.Lib;
import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.util.FlxDestroyUtil;

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
	 * Whether or not the back button is allowed to perform its default back action.
	 */
	public var preventDefaultBackAction:Bool = false;
	/**
	 * Helper class to check if a key is pressed.
	 */
	public var pressed:FlxAndroidKeyList;
	/**
	 * Helper class to check if a key was just pressed.
	 */
	public var justPressed:FlxAndroidKeyList;
	/**
	 * Helper class to check if a key was just released.
	 */
	public var justReleased:FlxAndroidKeyList;
	/**
	 * Internal storage of input keys as an array, for efficient iteration.
	 */
	private var _keyListArray:Array<FlxAndroidKeyInput>;
	/**
	 * Internal storage of input keys as a map, for efficient indexing.
	 */
	private var _keyListMap:Map<Int, FlxAndroidKeyInput>;
	
	/**
	 * Check to see if at least one key from an array of keys is pressed.
	 * Example: FlxG.android.anyPressed([BACK, MENU]) - having them in an array is handy for configurable keys!
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
	 * Example: FlxG.android.anyJustPressed([BACK, MENU]) - having them in an array is handy for configurable keys!
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
	 * Example: FlxG.android.anyJustReleased([BACK, MENU]) - having them in an array is handy for configurable keys!
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
		for (key in _keyListArray)
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
		for (key in _keyListArray)
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
		for (key in _keyListArray)
		{
			if (key != null && key.justReleased)
			{
				return key.ID;
			}
		}
		return "";
	}
	
	/**
	 * Check the status of a single key.
	 * 
	 * @param	KeyCode		KeyCode to be checked.
	 * @param	Status		The key state to check for.
	 * @return	Whether the provided key has the specified status.
	 */
	public function checkStatus(KeyCode:FlxAndroidKey, Status:FlxInputState):Bool
	{
		var key:FlxAndroidKeyInput = getKey(KeyCode);
		
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
	 * Get an Array of FlxAndroidKeyInputs that are in a pressed state
	 * 
	 * @return	Array of keys that are currently pressed.
	 */
	public function getIsDown():Array<FlxAndroidKeyInput>
	{
		var keysDown = new Array<FlxAndroidKeyInput>();
		
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
	
	@:allow(flixel.FlxG)
	private function new()
	{
		_keyListArray = new Array<FlxAndroidKeyInput>();
		_keyListMap = new Map<Int, FlxAndroidKeyInput>();
		
		// BACK button
		var back:FlxAndroidKeyInput = new FlxAndroidKeyInput(27);
		_keyListArray.push(back);
		_keyListMap.set(back.ID, back);
		// MENU button
		var menu:FlxAndroidKeyInput = new FlxAndroidKeyInput(16777234);
		_keyListArray.push(menu);
		_keyListMap.set(menu.ID, menu);
		
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
	private function checkKeyArrayState(KeyArray:Array<FlxAndroidKey>, State:FlxInputState):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		
		var key:FlxAndroidKeyInput = null;
		
		for (checkKey in KeyArray)
		{
			key = getKey(checkKey);
			
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
		if (preventDefaultBackAction && event.keyCode == FlxAndroidKey.BACK)
		{
			event.stopImmediatePropagation();
			event.stopPropagation();
		}
		
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
		var key:FlxAndroidKeyInput = getKey(KeyCode);
		
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
	
	/**
	 * Return a key from the key list, if found. Will return null if not found.
	 */
	@:allow(flixel.input.android.FlxAndroidKeyList.get_ANY())
	private inline function getKey(KeyCode:Int):FlxAndroidKeyInput
	{
		return _keyListMap.get(KeyCode);
	}
	
	private inline function onFocus():Void {}

	private inline function onFocusLost():Void
	{
		reset();
	}
}

typedef FlxAndroidKeyInput = FlxInput<Int>;
#end