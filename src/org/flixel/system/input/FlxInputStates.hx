package org.flixel.system.input;

import org.flixel.FlxU;
import org.flixel.system.replay.CodeValuePair;

/**
 * Basic input class that manages the fast-access Booleans and detailed key-state tracking.
 * Keyboard extends this with actual specific key data.
 */
class FlxInputStates implements Dynamic
{
	/**
	 * @private
	 */
	private var _lookup:Hash<Int>;
	/**
	 * @private
	 */
	private var _map:Array<FlxMapObject>;
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
		
		_lookup = new Hash<Int>();
		_map = new Array<FlxMapObject>(/*_total*/);
		FlxU.SetArrayLength(_map, _total);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		var i:Int = 0;
		while(i < _total)
		{
			var o:FlxMapObject = _map[i++];
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
			if(_map[i] == null) continue;
			var o:FlxMapObject = _map[i];
			Reflect.setProperty(this, o.name, false);
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
		return Reflect.getProperty(this, Key); 
	}
	
	/**
	 * Check to see if this key was just pressed.
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key was just pressed
	 */
	public function justPressed(Key:String):Bool 
	{ 
		return _map[_lookup.get(Key)].current == 2;
	}
	
	/**
	 * Check to see if this key is just released.
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key is just released.
	 */
	public function justReleased(Key:String):Bool 
	{ 
		return _map[_lookup.get(Key)].current == -1; 
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
			var o:FlxMapObject = _map[i++];
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
			o2 = _map[o.code];
			o2.current = o.value;
			if (o.value > 0)
			{
				Reflect.setProperty(this, o2.name, true);
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
		return _lookup.get(KeyName);
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
			var o:FlxMapObject = _map[i++];
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
            var o:FlxMapObject = _map[i++];
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
		_lookup.set(KeyName, KeyCode);
		_map[KeyCode] = new FlxMapObject(KeyName, 0, 0);
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		_lookup = null;
		_map = null;
	}
}