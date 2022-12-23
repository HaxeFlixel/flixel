package flixel.system.replay;

import flixel.input.FlxInput;
import flixel.input.touch.FlxTouch;
import flixel.system.debug.log.LogStyle;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
@:allow(flixel.input.touch.FlxTouch)
class TouchRecord
{
	public var id:Int;
	public var x:Null<Int>;
	public var y:Null<Int>;
	public var pressure:Null<Float>;
	
	/**
	 * The state of the touch.
	 */
	public var pressed:Null<Bool>;
	
	/**
	 * Usd to tell if a touch was removed from the FlxTouchManager
	 */
	public var active:Bool = true;
	
	/**
	 * Instantiate a new mouse input record.
	 * 
	 * @param   id    The id of touch.
	 */
	public function new(id:Int, active = true)
	{
		this.id = id;
		this.active = active;
	}
	
	function copy()
	{
		return copyTo(new TouchRecord(id, active));
	}
	
	function copyTo(record:TouchRecord)
	{
		record.id = id;
		record.active = active;
		
		if (x        != null) record.x        = x;
		if (y        != null) record.y        = y;
		if (pressure != null) record.pressure = pressure;
		if (pressed  != null) record.pressed  = pressed;
		
		return record;
	}
	
	public function toString():String
	{
		if (!active)
		{
			// Mark removal
			return Std.string(id);
		}
		
		return id + ";" + numToString(x) + ";" + numToString(y) + ";" + boolToString(pressed) + ";" + numToString(pressure);
	}
	
	static inline function numToString(value:Null<Float>):String
	{
		return value == null ? "" : Std.string(value);
	}
	
	static inline function boolToString(value:Null<Bool>):String
	{
		
		return value == null ? "" : (value ? "1" : "0");
	}
	
	static function fromString(data:String):Null<TouchRecord>
	{
		var record:TouchRecord = null;
		var touch = data.split(";");
		if (touch.length == 1 && ~/^\d+$/.match(data))
		{
			record = new TouchRecord(Std.parseInt(data));
			record.active = false;
		}
		else if (touch.length == 5)
		{
			record = new TouchRecord(parseInt(touch[0]));
			record.x = parseInt(touch[1]);
			record.y = parseInt(touch[2]);
			record.pressed = parseBool(touch[3]);
			record.pressure = parseFloat(touch[4]);
		}
		return record;
	}
	
	static inline function parseInt(data:String):Null<Int>
	{
		return data == "" ? null : Std.parseInt(data);
	}
	
	static inline function parseFloat(data:String):Null<Float>
	{
		return data == "" ? null : Std.parseFloat(data);
	}
	
	static inline function parseBool(data:String):Null<Bool>
	{
		return data == "" ? null : data == "1";
	}
}

@:access(flixel.system.replay.TouchRecord)
@:forward(keys, keyValueIterator, iterator, get, set, exists, clear)
abstract TouchRecordList(Map<Int, TouchRecord>)
{
	public inline function new ()
	{
		this = [];
	}
	
	@:arrayAccess
	public inline function get(key:Int)
	{
		return this.get(key);
	}
	
	@:arrayAccess
	public inline function arrayWrite(key:Int, value:TouchRecord):TouchRecord
	{
		this.set(key, value);
		return value;
	}
	
	public function toString():String
	{
		var output = "";
		
		for (touch in this)
			output += touch.toString() + ",";
		
		return output.substr(0, -1);
	}
	
	public static function fromString(data:String):Null<TouchRecordList>
	{
		var array = data.split(",");
		var list:TouchRecordList = null;
		
		for (record in array)
		{
			var touch = TouchRecord.fromString(record);
			if (touch == null)
			{
				FlxG.log.advanced('Invalid TouchRecords:"$data"', LogStyle.WARNING, true);
			}
			else
			{
				if (list == null)
					list = new TouchRecordList();
				
				list[touch.id] = touch;
			}
		}
		return list;
	}
}