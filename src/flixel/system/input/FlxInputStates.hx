package flixel.system.input;

import flixel.FlxG;
import flixel.system.replay.CodeValuePair;
import flixel.util.FlxArray;

/**
 * Basic input class that manages the fast-access Booleans and detailed key-state tracking.
 * Keyboard extends this with actual specific key data.
 */
class FlxInputStates
{
	/**
	 * @private
	 */
	private var _keyLookup:Map<String, Int>;
	/**
	 * @private
	 */
	private var _keyBools:Map<String, Bool>;
	/**
	 * @private
	 */
	private var _keyMap:Array<FlxMapObject>;
	/**
	 * @private
	 */
	private var _total:Int;
	
	
	/**
	 * Constructor
	 */
	public function new()
	{
		_total = 256;
		
		_keyLookup = new Map<String, Int>();
		_keyBools = new Map<String, Bool>();
		
		_keyMap = new Array<FlxMapObject>(/*_total*/);
		FlxArray.setLength(_keyMap, _total);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		var i:Int = 0;
		while(i < _total)
		{
			var o:FlxMapObject = _keyMap[i++];
			if(o == null) continue;
			if((o.last == -1) && (o.current == -1)) o.current = 0;
			else if((o.last == 2) && (o.current == 2)) o.current = 1;
			o.last = o.current;
		}
	}
	
	/**
	 * Resets all the keys.
	 */
	public function reset():Void
	{
		for(i in 0...(_total))
		{
			if(_keyMap[i] == null) continue;
			var o:FlxMapObject = _keyMap[i];
			_keyBools.set(o.name, false);
			o.current = 0;
			o.last = 0;
		}
	}
	
	/**
	 * Check to see if this key is pressed.
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
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key was just pressed
	 */
	public function justPressed(Key:String):Bool 
	{ 
		if (_keyMap[_keyLookup.get(Key)] != null) 
		{
			return _keyMap[_keyLookup.get(Key)].current == 2;
		}
		else
		{
			FlxG.log.error("Invalid Key: `" + Key + "`. Note that function and numpad keys can only be used in flash and js.");
			return false;
		}
	}
	
	/**
	 * Check to see if this key is just released.
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key is just released.
	 */
	public function justReleased(Key:String):Bool 
	{ 
		if (_keyMap[_keyLookup.get(Key)] != null) 
		{
			return _keyMap[_keyLookup.get(Key)].current == -1;
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
	 * @return	An array of key state data.  Null if there is no data.
	 */
	public function record():Array<CodeValuePair>
	{
		var data:Array<CodeValuePair> = null;
		var i:Int = 0;
		while(i < _total)
		{
			var o:FlxMapObject = _keyMap[i++];
			if ((o == null) || (o.current == 0))
			{
				continue;
			}
			if (data == null)
			{
				data = new Array<CodeValuePair>();
			}
			data.push(new CodeValuePair(i - 1, o.current));
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
		var o2:FlxMapObject;
		while(i < l)
		{
			o = Record[i++];
			o2 = _keyMap[o.code];
			o2.current = o.value;
			if (o.value > 0)
			{
				_keyBools.set(o2.name, true);
			}
		}
	}
	
	/**
	 * Look up the key code for any given string name of the key or button.
	 * @param	KeyName		The <code>String</code> name of the key.
	 * @return	The key code for that key.
	 */
	public function getKeyCode(KeyName:String):Int
	{
		return _keyLookup.get(KeyName);
	}
	
	/**
	 * Check to see if any keys are pressed right now.
	 * @return	Whether any keys are currently pressed.
	 */
	public function any():Bool
	{
		var i:Int = 0;
		while(i < _total)
		{
			var o:FlxMapObject = _keyMap[i++];
			if ((o != null) && (o.current > 0))
			{
				return true;
			}
		}
		return false;
	}

	/**
	* Get an Array of FlxMapObjects that are in a pressed state
	* @return	Array<FlxMapObject> of keys that are currently pressed.
	*/
	public function getIsDown():Array<FlxMapObject>
	{
		var keysdown:Array<FlxMapObject> = new Array<FlxMapObject>();
		var i:Int = 0;
		while(i < _total)
		{
			var o:FlxMapObject = _keyMap[i++];
			if ((o != null) && (o.current > 0))
			{
				keysdown.push (o);
			}
		}
		return keysdown;
	}

	/**
	 * An internal helper function used to build the key array.
	 * @param	KeyName		String name of the key (e.g. "LEFT" or "A")
	 * @param	KeyCode		The numeric Flash code for this key.
	 */
	private function addKey(KeyName:String, KeyCode:Int):Void
	{
		_keyLookup.set(KeyName, KeyCode);
		_keyMap[KeyCode] = new FlxMapObject(KeyName, 0, 0);
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_keyMap = null;
		_keyBools = null;
		_keyLookup = null;
	}
}