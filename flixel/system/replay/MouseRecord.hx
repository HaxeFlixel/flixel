package flixel.system.replay;

import flixel.input.FlxInput;

/**
 * A helper class for the frame records, part of the replay/demo/recording system.
 */
class MouseRecord
{
	public var x(default, null):Null<Int>;
	public var y(default, null):Null<Int>;
	
	/** The state of the left mouse button. */
	public var leftButton(default, null):Null<Bool>;
	
	#if FLX_MOUSE_ADVANCED
	/** The state of the middle mouse button. */
	public var middleButton(default, null):Null<Bool>;
	/** The state of the right mouse button. */
	public var rightButton(default, null):Null<Bool>;
	#end
	/** The state of the mouse wheel. */
	public var wheel(default, null):Null<Int>;
	
	public function new() {}
	
	public function toString():String
	{
		return intToString(x)
			+ "," + intToString(y)
			+ "," + boolToString(leftButton)
			#if FLX_MOUSE_ADVANCED
			+ "," + boolToString(middleButton)
			+ "," + boolToString(rightButton)
			#end
			+ "," + intToString(wheel)
			;
	}
	
	inline static function intToString(value:Null<Int>):String
	{
		return value == null ? "" : Std.string(value);
	}
	
	inline static function boolToString(value:Null<Bool>):String
	{
		
		return value == null ? "" : (value ? "1" : "0");
	}
	
	public static function fromString(data:String):Null<MouseRecord>
	{
		var record:MouseRecord = null;
		var mouse = data.split(",");
		if (mouse.length == 6)
		{
			record = new MouseRecord();
			record.x = parseInt(mouse[0]);
			record.y = parseInt(mouse[1]);
			record.leftButton = parseBool(mouse[2]);
			#if FLX_MOUSE_ADVANCED
			record.middleButton = parseBool(mouse[3]);
			record.rightButton = parseBool(mouse[4]);
			#end
			record.wheel = parseInt(mouse[5]);
		}
		if (mouse.length == 4)
		{
			record = new MouseRecord();
			record.x = parseInt(mouse[0]);
			record.y = parseInt(mouse[1]);
			record.leftButton = parseBool(mouse[2]);
			record.wheel = parseInt(mouse[3]);
		}
		return record;
	}
	
	inline static function parseInt(data:String):Null<Int> 
	{
		return data == "" ? null : Std.parseInt(data);
	}
	
	inline static function parseBool(data:String):Null<Bool> 
	{
		return data == "" ? null : data == "1";
	}
}