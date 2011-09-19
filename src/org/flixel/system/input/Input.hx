package org.flixel.system.input;

import org.flixel.FlxU;

/**
 * Basic input class that manages the fast-access Booleans and detailed key-state tracking.
 * Keyboard extends this with actual specific key data.
 */
class Input
{
	/**
	 * @private
	 */
	private var _lookup:Dynamic;
	/**
	 * @private
	 */
	private var _map:Array<Dynamic>;
	/**
	 * @private
	 */
	#if flash
	private var _total:UInt;
	#else
	private var _total:Int;
	#end
	
	/**
	 * Constructor
	 */
	public function new()
	{
		_total = 256;
		
		_lookup = {};
		_map = new Array<Dynamic>(/*_total*/);
		FlxU.SetArrayLength(_map, _total);
	}
	
	/**
	 * Updates the key states (for tracking just pressed, just released, etc).
	 */
	public function update():Void
	{
		#if flash
		var i:UInt = 0;
		#else
		var i:Int = 0;
		#end
		while(i < _total)
		{
			var o:Dynamic = _map[i++];
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
		for(i in 0..._total)
		{
			if(_map[i] == null) continue;
			var o:Dynamic = _map[i];
			Reflect.setField(this, o.name, false);
			o.current = 0;
			o.last = 0;
		}
		
	}
	
	/**
	 * Check to see if this key is pressed.
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key is pressed
	 */
	public function pressed(Key:String):Bool { return Reflect.field(this, Key); }
	
	/**
	 * Check to see if this key was just pressed.
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key was just pressed
	 */
	public function justPressed(Key:String):Bool { return _map[Reflect.field(_lookup, Key)].current == 2; }
	
	/**
	 * Check to see if this key is just released.
	 * @param	Key		One of the key constants listed above (e.g. "LEFT" or "A").
	 * @return	Whether the key is just released.
	 */
	public function justReleased(Key:String):Bool { return _map[Reflect.field(_lookup, Key)].current == -1; }
	
	/**
	 * If any keys are not "released" (0),
	 * this function will return an array indicating
	 * which keys are pressed and what state they are in.
	 * @return	An array of key state data.  Null if there is no data.
	 */
	public function record():Array<Dynamic>
	{
		var data:Array<Dynamic> = null;
		#if flash
		var i:UInt = 0;
		#else
		var i:Int = 0;
		#end
		while(i < _total)
		{
			var o:Dynamic = _map[i++];
			if ((o == null) || (o.current == 0))
			{
				continue;
			}
			if (data == null)
			{
				data = new Array<Dynamic>();
			}
			data.push( { code:i - 1, value:o.current } );
		}
		return data;
	}
	
	/**
	 * Part of the keystroke recording system.
	 * Takes data about key presses and sets it into array.
	 * 
	 * @param	Record	Array of data about key states.
	 */
	public function playback(Record:Array<Dynamic>):Void
	{
		var i:Int = 0;
		var l:Int = Record.length;
		var o:Dynamic;
		var o2:Dynamic;
		while(i < l)
		{
			o = Record[i++];
			o2 = _map[o.code];
			o2.current = o.value;
			if (o.value > 0)
			{
				//this[o2.name] = true;
				Reflect.setField(this, o2.name, true);
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
		//return _lookup[KeyName];
		return Reflect.field(_lookup, KeyName);
	}
	
	/**
	 * Check to see if any keys are pressed right now.
	 * @return	Whether any keys are currently pressed.
	 */
	public function any():Bool
	{
		#if flash
		var i:UInt = 0;
		#else
		var i:Int = 0;
		#end
		while(i < _total)
		{
			var o:Dynamic = _map[i++];
			if ((o != null) && (o.current > 0))
			{
				return true;
			}
		}
		return false;
	}
	
	/**
	 * An internal helper function used to build the key array.
	 * @param	KeyName		String name of the key (e.g. "LEFT" or "A")
	 * @param	KeyCode		The numeric Flash code for this key.
	 */
	#if flash
	private function addKey(KeyName:String, KeyCode:UInt):Void
	#else
	private function addKey(KeyName:String, KeyCode:Int):Void
	#end
	{
		//_lookup[KeyName] = KeyCode;
		Reflect.setField(_lookup, KeyName, KeyCode);
		_map[KeyCode] = { name: KeyName, current: 0, last: 0 };
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