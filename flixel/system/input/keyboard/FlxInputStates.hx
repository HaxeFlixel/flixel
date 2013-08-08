package flixel.system.input.keyboard;

import flixel.FlxG;
import flixel.system.replay.CodeValuePair;
import flixel.util.FlxArrayUtil;

/**
 * Basic input class that manages the fast-access Booleans and detailed key-state tracking.
 * Keyboard extends this with actual specific key data.
 */
class FlxInputStates
{
	/**
	 * Total amount of keys.
	 */
	inline static private var TOTAL:Int = 256;
	
	/**
	 * A map for key lookup.
	 */
	private var _keyLookup:Map<String, Int>;
	/**
	 * A map that stores a Boolean for each key, 
	 * indicating whether it has been pressed or not.
	 */
	private var _keyBools:Map<String, Bool>;
	/**
	 * An array of FlxKey objects.
	 */
	private var _keyList:Array<FlxKey>;
	
	public function new()
	{
		_keyLookup = new Map<String, Int>();
		_keyBools = new Map<String, Bool>();
		
		_keyList = new Array<FlxKey>();
		FlxArrayUtil.setLength(_keyList, TOTAL);
	}
	
	/**
	 * An internal helper function used to build the key array.
	 * 
	 * @param	KeyName		String name of the key (e.g. "LEFT" or "A")
	 * @param	KeyCode		The numeric Flash code for this key.
	 */
	private function addKey(KeyName:String, KeyCode:Int):Void
	{
		_keyLookup.set(KeyName, KeyCode);
		_keyList[KeyCode] = new FlxKey(KeyName);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
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
	
	/**
	 * Resets all the keys.
	 */
	public function reset():Void
	{
		for (key in _keyList)
		{
			if (key != null)
			{
				_keyBools.set(key.name, false);
				key.current = FlxKey.RELEASED;
				key.last = FlxKey.RELEASED;
			}
		}
	}
	
	/**
	 * Check to see if this key is pressed.
	 * 
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key is pressed
	 */
	public function pressed(Key:String):Bool 
	{ 
		if (_keyBools.exists(Key))
		{
			return _keyBools.get(Key);
		}
		
		FlxG.log.error("Invalid Key: `" + Key + "`. Note that function and numpad keys can only be used in flash and js.");
		return false; 
	}
	
	/**
	 * Check to see if this key was just pressed.
	 * 
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key was just pressed
	 */
	public function justPressed(Key:String):Bool 
	{ 
		if (_keyList[_keyLookup.get(Key)] != null) 
		{
			return _keyList[_keyLookup.get(Key)].current == FlxKey.JUST_PRESSED;
		}
		else
		{
			FlxG.log.error("Invalid Key: `" + Key + "`. Note that function and numpad keys can only be used in flash and js.");
			return false;
		}
	}
	
	/**
	 * Check to see if this key is just released.
	 * 
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key is just released.
	 */
	public function justReleased(Key:String):Bool 
	{ 
		if (_keyList[_keyLookup.get(Key)] != null) 
		{
			return _keyList[_keyLookup.get(Key)].current == FlxKey.JUST_RELEASED;
		}
		else
		{
			FlxG.log.error("Invalid Key: `" + Key + "`. Note that function and numpad keys can only be used in flash and js.");
			return false;
		}
	}
	
	/**
	 * If any keys are not "released" (0),
	 * this function will return an array indicating
	 * which keys are pressed and what state they are in.
	 * 
	 * @return	An array of key state data.  Null if there is no data.
	 */
	public function record():Array<CodeValuePair>
	{
		var data:Array<CodeValuePair> = null;
		var i:Int = 0;
		
		while (i < TOTAL)
		{
			var key:FlxKey = _keyList[i++];
			
			if (key == null || key.current == FlxKey.RELEASED)
			{
				continue;
			}
			
			if (data == null)
			{
				data = new Array<CodeValuePair>();
			}
			
			data.push(new CodeValuePair(i - 1, key.current));
		}
		return data;
	}
	
	/**
	 * Part of the keystroke recording system.
	 * Takes data about key presses and sets it into array.
	 * 
	 * @param	Record	Array of data about key states.
	 */
	public function playback(Record:Array<CodeValuePair>):Void
	{
		var i:Int = 0;
		var l:Int = Record.length;
		var o:CodeValuePair;
		var o2:FlxKey;
		
		while (i < l)
		{
			o = Record[i++];
			o2 = _keyList[o.code];
			o2.current = o.value;
			
			if (o.value > FlxKey.RELEASED)
			{
				_keyBools.set(o2.name, true);
			}
		}
	}
	
	/**
	 * Look up the key code for any given string name of the key or button.
	 * 
	 * @param	KeyName		The <code>String</code> name of the key.
	 * @return	The key code for that key.
	 */
	inline public function getKeyCode(KeyName:String):Int
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
		_keyBools = null;
		_keyLookup = null;
	}
}