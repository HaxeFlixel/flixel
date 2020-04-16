package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

class CodeValuePair
{
	public var code:Int;
	public var value:String;
	
	public function new(code:Int, value:String)
	{
		this.code = code;
		this.value = value;
	}
	
	public inline function getBool():Bool
	{
		return value == "1";
	}
	
	public static inline function createBool(code:Int, value:Bool):CodeValuePair
	{
		return new CodeValuePair(code, value ? "1" : "0");
	}
	
	public inline function getInt():Int
	{
		return Std.parseInt(value);
	}
	
	public static inline function createInt(code:Int, value:Int):CodeValuePair
	{
		return new CodeValuePair(code, Std.string(value));
	}
	
	public inline function getFloat():Float
	{
		return Std.parseFloat(value);
	}
	
	public static inline function createFloat(code:Int, value:Float):CodeValuePair
	{
		return new CodeValuePair(code, Std.string(value));
	}
	
	public function toString():String
	{
		return code + ":" + value;
	}
	
	public static function fromString(data:String):Null<CodeValuePair>
	{
		var keyPair = data.split(":");
		if (keyPair.length == 2)
		{
			return new CodeValuePair(Std.parseInt(keyPair[0]), keyPair[1]);
		}
		return null;
	}
	
	public static inline function arrayFromString(data:String, delimiter:String = ","):Null<Array<CodeValuePair>>
	{
		var keys:Null<Array<CodeValuePair>> = null;
		var list = data.split(delimiter);
		
		var i = 0;
		var l = list.length;
		while (i < l)
		{
			var key = CodeValuePair.fromString(list[i++]);
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
	
	public static function arrayToString(states:Array<CodeValuePair>, delimiter:String = ","):String
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