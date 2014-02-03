package flixel.input.android;

#if android
import flash.events.KeyboardEvent;
import flash.Lib;
import flixel.FlxG;
import flixel.interfaces.IFlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.system.replay.CodeValuePair;
import flixel.util.FlxArrayUtil;
import haxe.ds.HashMap.HashMap;
import haxe.Log;

/**
 * Keeps track of Android system key presses (Back/Menu)
 */
class FlxAndroidKeys implements IFlxInput
{
	/**
	 * Whether or not android key input is currently enabled
	 */
	public var enabled:Bool = true;
	
	/**
	 * Total amount of keys.
	 */
	private static inline var TOTAL:Int = 2;
	
	/**
	 * A map for key lookup.
	 */
	private var _keyLookup:Map<String, Int>;
	
	/**
	 * And array of FlxKey objects.
	 */
	@:allow(flixel.input.keyboard.FlxAndroidKeyList.get_ANY) // Need to access the var there
	private var _keyList:Map<Int, FlxKey>;
	
	public var preventDefaultBackAction:Bool = false;
	
	/**
	 * An internal helper function used to build the key array.
	 *
	 * @param	KeyName		String name of the key (e.g. "BACK" or "MENU")
	 * @param	KeyCode		The numeric code for this key.
	 */
	private function addKey(KeyName:String, KeyCode:Int):Void
	{
		_keyLookup.set(KeyName, KeyCode);
		_keyList.set(KeyCode, new FlxKey(KeyName));
	}
	
	/**
	 * Check to see if a key, or one key from a list of mutliple keys is pressed. Pass them in as Strings.
	 * Example: .pressed("BACK", "MENU")
	 */
	public var pressed:Dynamic;
	
	/**
	 * Check to see if at least one key from an array of keys is pressed. Pass them in as Strings.
	 * Example: .anyPressed(["BACK", "MENU"])
	 * @param	KeyArray 	An array of keys as Strings
	 * @return	Whether at least one of the keys passed in is pressed.
	 */
	public inline function anyPressed(KeyArray:Array<Dynamic>):Bool
	{
		return checkKeyStatus(KeyArray, FlxKey.PRESSED);
	}
	
	/**
	 * Check to see if a key, or one key from a list of mutliple keys was just pressed. Pass them in as Strings.
	 * Example: .justPressed("BACK", "MENU")
	 */
	public var justPressed:Dynamic;
	
	/**
	 * Check to see if at least one key from an array of keys was just pressed. Pass them in as Strings.
	 * Example: .anyJustPressed(["BACK", "MENU"])
	 * @param	KeyArray 	An array of keys as Strings
	 * @return	Whether at least one of the keys passed was just pressed.
	 */
	public inline function anyJustPressed(KeyArray:Array<Dynamic>):Bool
	{
		return checkKeyStatus(KeyArray, FlxKey.JUST_PRESSED);
	}
	
	/**
	 * Check to see if a key, or one key from a list of mutliple keys was just released. Pass them in as Strings.
	 * Example: .justReleased("BACK", "MENU")
	 */
	public var justReleased:Dynamic;
	
	/**
	 * Check to see if at least one key from an array of keys was just released. Pass them in as Strings.
	 * Example: .anyJustReleased(["BACK", "MENU"])
	 * @param	KeyArray 	An array of keys as Strings
	 * @return	Whether at least one of the keys passed was just released.
	 */
	public inline function anyJustReleased(KeyArray:Array<Dynamic>):Bool
	{
		return checkKeyStatus(KeyArray, FlxKey.JUST_RELEASED);
	}
	
	
	/**
	 * Look up the key code for any given string name of the key or button.
	 *
	 * @param	KeyName		The String name of the key.
	 * @return	The key code for that key.
	 */
	public inline function getKeyCode(KeyName:String):Int
	{
		return _keyLookup.get(KeyName);
	}

	/**
	 * Get an Array of FlxMapObjects that are in a pressed state
	 *
	 * @return	Array<FlxMapObject> of keys that are currently pressed.
	 */
	public function getIsDown():Array<FlxKey>
	{
		var keysDown:Array<FlxKey> = new Array<FlxKey>();
		
		for (key in _keyList)
		{
			if (key != null && key.current > FlxKey.RELEASED)
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
		_keyLookup = null;
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
				key.current = FlxKey.RELEASED;
				key.last = FlxKey.RELEASED;
			}
		}
	}
	
	@:allow(flixel.FlxG)
	private function new()
	{
		_keyLookup = new Map<String, Int>();
		
		_keyList = new Map<Int, FlxKey>();
		
		addKey("BACK", 27);
		addKey("MENU", 16777234); // wow, really?
		
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		Lib.current.stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		
		pressed = Reflect.makeVarArgs(anyPressed);
		justPressed = Reflect.makeVarArgs(anyJustPressed);
		justReleased = Reflect.makeVarArgs(anyJustReleased);
	}
	
	/**
	 * Helper function to check the status of an array of keys
	 * 
	 * @param	KeyArray	An array of keys as Strings
	 * @param	Status		The key state to check for
	 * @return	Whether at least one of the keys has the specified status
	 */
	private function checkKeyStatus(KeyArray:Array<Dynamic>, Status:Int):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		
		for (key in KeyArray)
		{
			// Also make lowercase keys work, like "space" or "sPaCe"
			key = Std.string(key).toUpperCase();
			
			var k:FlxKey = _keyList.get(_keyLookup.get(key));
			if (k != null)
			{
				if (k.current == Status)
				{
					return true;
				}
				else if (Status == FlxKey.PRESSED && k.current == FlxKey.JUST_PRESSED)
				{
					return true;
				}
				else if (Status == FlxKey.RELEASED && k.current == FlxKey.JUST_RELEASED)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Event handler so FlxGame can toggle keys.
	 *
	 * @param	FlashEvent	A KeyboardEvent object.
	 */
	private function onKeyUp(FlashEvent:KeyboardEvent):Void
	{
		var c:Int = FlashEvent.keyCode;
		
		if (preventDefaultBackAction && c == getKeyCode("BACK"))
		{
			
			FlashEvent.stopImmediatePropagation();
			FlashEvent.stopPropagation();
		}

		// Everything from on here is only updated if input is enabled
		if (!enabled)
		{
			return;
		}
		
		updateKeyStates(c, false);
	}
	
	/**
	 * Internal event handler for input and focus.
	 *
	 * @param	FlashEvent	Flash keyboard event.
	 */
	private function onKeyDown(FlashEvent:KeyboardEvent):Void
	{
		var c:Int = FlashEvent.keyCode;
		
		if (preventDefaultBackAction && c == getKeyCode("BACK"))
		{
			FlashEvent.stopImmediatePropagation();
			FlashEvent.stopPropagation();
		}
		
		if (enabled)
		{
			updateKeyStates(c, true);
		}
	}
	
	/**
	 * A Helper function to check whether an array of keycodes contains
	 * a certain key safely (returns false if the array is null).
	 */
	private function inKeyArray(KeyArray:Array<String>, KeyCode:Int):Bool
	{
		if (KeyArray == null)
		{
			return false;
		}
		else
		{
			for (keyString in KeyArray)
			{
				if (keyString == "ANY" || getKeyCode(keyString) == KeyCode)
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
		var obj:FlxKey = _keyList[KeyCode];
		
		if (obj != null)
		{
			if (obj.current > FlxKey.RELEASED)
			{
				if (Down)
				{
					obj.current = FlxKey.PRESSED;
				}
				else
				{
					obj.current = FlxKey.JUST_RELEASED;
				}
			}
			else
			{
				if (Down)
				{
					obj.current = FlxKey.JUST_PRESSED;
				}
				else
				{
					obj.current = FlxKey.RELEASED;
				}
			}
		}
	}
	
	private inline function onFocus():Void {}

	private inline function onFocusLost():Void
	{
		reset();
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	private function update():Void
	{
		for (key in _keyList)
		{
			if (key == null)
			{
				continue;
			}
			
			if (key.last == FlxKey.JUST_RELEASED && key.current == FlxKey.JUST_RELEASED)
			{
				key.current = FlxKey.RELEASED;
			}
			else if (key.last == FlxKey.JUST_PRESSED && key.current == FlxKey.JUST_PRESSED)
			{
				key.current = FlxKey.PRESSED;
			}
			
			key.last = key.current;
		}
	}
}
#end
