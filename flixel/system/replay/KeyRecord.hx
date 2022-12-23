package flixel.system.replay;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.system.debug.log.LogStyle;

class KeyRecord
{
	public var code:Int;
	public var value:String;
	
	public function new(code:Int, value:String)
	{
		this.code = code;
		this.value = value;
	}
	
	function copy()
	{
		return new KeyRecord(code, value);
	}
	
	function copyTo(record:KeyRecord)
	{
		record.code = code;
		record.value = value;
		
		return record;
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
}

@:access(flixel.system.replay.KeyRecord)
@:forward(keys, keyValueIterator, iterator, get, set, exists, clear)
abstract KeyRecordList(Map<FlxKey, KeyRecord>)
{
	public inline function new()
	{
		this = [];
	}
	
	@:arrayAccess
	public inline function get(key:FlxKey)
	{
		return this.get(key);
	}
	
	@:arrayAccess
	public inline function arrayWrite(key:FlxKey, value:KeyRecord):KeyRecord
	{
		this.set(key, value);
		return value;
	}
	
	public function toString():String
	{
		var list = new Array<KeyRecord>();
		for (record in this)
			list.push(record);
		
		// Sort keys for deterministic output (for unit tests)
		list.sort(function (a, b)
			{
				if (a.value == b.value)
					return a.code - b.code;
				
				return a.value == "1" ? -1 : 1;
			}
		);
		
		var output = "";
		for (record in list)
			output += record.toString() + ",";
		
		// remove the last delimiter
		return output.substr(0, -1);
	}
	
	public static inline function fromString(data:String):Null<KeyRecordList>
	{
		var keys:KeyRecordList = null;
		var list = data.split(",");
		
		for (record in list)
		{
			var key = KeyRecord.fromString(record);
			if (key == null)
				FlxG.log.advanced('Invalid KeyRecords:"$data"', LogStyle.WARNING, true);
			else
			{
				if (keys == null)
					keys = new KeyRecordList();
				
				keys[key.code] = key;
			}
		}
		return keys;
	}
}