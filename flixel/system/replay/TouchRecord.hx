package flixel.system.replay;

import flixel.input.FlxInput;
import flixel.input.touch.FlxTouch;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
@:allow(flixel.input.touch.FlxTouch)
class TouchRecord
{
	public var id(default, null):Int;
	public var x(default, null):Null<Int>;
	public var y(default, null):Null<Int>;
	public var pressure(default, null):Null<Float>;
	/**
	 * The state of the touch.
	 */
	public var pressed(default, null):Null<Bool>;
	/**
	 * Usd to tell if a touch was removed from the FlxTouchManager
	 */
	public var active(default, null):Bool = true;
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
	
	public function toString():String
	{
		if (!active)
		{
			// Mark removal
			return Std.string(id);
		}
		
		return id + ";" + numToString(x) + ";" + numToString(y) + ";" + boolToString(pressed) + ";" + numToString(pressure);
	}
	
	inline static function numToString(value:Null<Float>):String
	{
		return value == null ? "" : Std.string(value);
	}
	
	inline static function boolToString(value:Null<Bool>):String
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
		else if (touch.length == 4)
		{
			record = new TouchRecord(parseInt(touch[0]));
			record.x = parseInt(touch[1]);
			record.y = parseInt(touch[2]);
			record.pressed = parseBool(touch[3]);
			record.pressure = parseFloat(touch[4]);
		}
		return record;
	}
	
	inline static function parseInt(data:String):Null<Int>
	{
		return data == "" ? null : Std.parseInt(data);
	}
	
	inline static function parseFloat(data:String):Null<Float>
	{
		return data == "" ? null : Std.parseFloat(data);
	}
	
	inline static function parseBool(data:String):Null<Bool>
	{
		return data == "" ? null : data == "1";
	}
	
	public static function arrayFromString(data:String):Null<Array<TouchRecord>>
	{
		var array = data.split(",");
		var list:Null<Array<TouchRecord>> = null;
		var i = 0;
		var l = array.length;
		while (i < l)
		{
			var touch = fromString(array[i++]);
			if (touch != null)
			{
				if (list == null)
				{
					list = [];
				}
				list.push(touch);
			}
		}
		return list;
	}
	
	public static function arrayToString(touches:Array<TouchRecord>):String
	{
		var output = "";
		var i:Int = 0;
		var l:Int = touches.length;
		while (i < l)
		{
			if (i > 0)
			{
				output += ",";
			}
			output += touches[i++].toString();
		}
		return output;
	}
}