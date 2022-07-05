package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

class KeyRecord
{
	public var code:Int;
	public var value:String;
	
	public function new(code:Int, value:String)
	{
		this.code = code;
		this.value = value;
	}
	
	public inline function getBool()
	{
		return value == "1";
	}
	
	public function toString():String
	{
		return code + ":" + value;
	}
	
	public static inline function fromBool(code:Int, value:Bool)
	{
		return new KeyRecord(code, value ? "1" : "0");
	}
	
	static var valid = ~/^(\d+):([01])$/;
	public static function fromString(data:String):Null<KeyRecord>
	{
		if (valid.match(data))
			return new KeyRecord(Std.parseInt(valid.matched(1)), valid.matched(2));
		
		return null;
	}
	
	public static inline function arrayFromString(data:String, delimiter:String = ","):Null<Array<KeyRecord>>
	{
		var keys:Null<Array<KeyRecord>> = null;
		var list = data.split(delimiter);
		
		var i = 0;
		var l = list.length;
		while (i < l)
		{
			var key = KeyRecord.fromString(list[i++]);
			if (key != null)
			{
				if (keys == null)
				{
					keys = [];
				}
				keys.push(key);
			}
		}
		return keys;
	}
	
	public static function arrayToString(states:Array<KeyRecord>, delimiter:String = ","):String
	{
		var output = "";
		var i:Int = 0;
		var l:Int = states.length;
		while (i < l)
		{
			if (i > 0)
			{
				output += delimiter;
			}
			output += states[i++].toString();
		}
		
		return output;
	}
}