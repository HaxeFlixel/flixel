package flixel.system.replay;

import flixel.input.FlxInput.FlxInputState;

class CodeValuePair
{
	public var code:Int;
	public var value:Bool;
	
	public function new(code:Int, value:Bool)
	{
		this.code = code;
		this.value = value;
	}
	
	public function toString():String
	{
		return code + ":" + (value ? "1" : "0");
	}
	
	public static function fromString(data:String):Null<CodeValuePair>
	{
		var keyPair = data.split(":");
		if (keyPair.length == 2)
		{
			return new CodeValuePair(Std.parseInt(keyPair[0]), keyPair[1] == "1");
		}
		return null;
	}
	
	public static inline function arrayFromString(data:String):Null<Array<CodeValuePair>>
	{
		var keys:Null<Array<CodeValuePair>> = null;
		var list = data.split(",");
		
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
	
	public static function arrayToString(keys:Array<CodeValuePair>):String
	{
		var output = "";
		var i:Int = 0;
		var l:Int = keys.length;
		while (i < l)
		{
			if (i > 0)
			{
				output += ",";
			}
			output += keys[i++].toString();
		}
		
		return output;
	}
}