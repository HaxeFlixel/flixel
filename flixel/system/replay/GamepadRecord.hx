package flixel.system.replay;

import flixel.input.gamepad.FlxGamepad;

/**
 * Helper class for the new replay system.  Represents all the game inputs for one "frame" or "step" of the game loop.
 */
class GamepadRecord
{
	/**
	 * Which frame of the game loop this record is from or for.
	 */
	public var id:Int;
	
	/**
	 * An array of simple integer pairs referring to what key is pressed, and what state its in.
	 */
	public var states:Null<Array<CodeValuePair>>;
	
	/**
	 * Usd to tell if a gamepad was removed from the FlxGamepadManager.
	 */
	public var active(default, null):Bool = true;
	
	/*
	 * The model of the gamepad, used to initiate a new gamepad, otherwise should be null.
	 */
	public var model:Null<FlxGamepadModel>;
	
	/*
	 * The attachment of the gamepad, used to initiate a new gamepad, otherwise should be null.
	 */
	public var attachment:Null<FlxGamepadAttachment>;
	
	/**
	 * Instantiate a new mouse input record.
	 * 
	 * @param   id     The id of gamepad.
	 * @param   active Whether the gamepad is active.
	 */
	public function new(id:Int, active = true)
	{
		this.id = id;
		this.active = active;
	}
	
	public function addDigital(code:Int, value:Bool)
	{
		states.push(CodeValuePair.createBool(code, value));
	}
	
	public function addAnalog(code:Int, value:Float)
	{
		states.push(CodeValuePair.createFloat(code, value));
	}
	
	public function toString():String
	{
		var string = Std.string(id);
		if (active)
		{
			if (model != null)
			{
				string += model == null ? "" : ";" + model.getIndex();
			}
			
			if (attachment != null)
			{
				string += ";" + attachment.getIndex();
			}
			
			if (states != null)
			{
				string += "; " + CodeValuePair.arrayToString(states);
			}
		}
		return string;
	}
	
	/**
	 * Creates a Gamepad record from a FlxReplay string
	 * 
	 * Possible Formats:
	 *     "id;model;attachment;code1:value1;code2:value2;...;codeN:valueN" Ex: 0;6;1;0:1
	 *     "id"
	 * @param data 
	 * @return GamepadRecord
	 */
	static function fromString(data:String):GamepadRecord
	{
		var record:GamepadRecord = null;
		var firstDelimiter = data.indexOf(";");
		if (firstDelimiter == -1 && ~/^\d+$/.match(data))
		{
			// No supplementary data means gamepad was removed
			record = new GamepadRecord(Std.parseInt(data));
			record.active = false;
		}
		else
		{
			
			record = new GamepadRecord(Std.parseInt(data.substring(0, firstDelimiter - 1)));
			data = data.substring(firstDelimiter + 1);
			firstDelimiter = data.indexOf(";");
			var firstPair = data.indexOf(":");
			var states:String = null;
			if (firstPair == -1)
			{
				states = null;
			}
			else if (firstPair > firstDelimiter)
			{
				firstPair = data.substring(0, firstPair).lastIndexOf(";");
				states = data.substring(firstPair + 1);
				data = data.substring(0, firstPair - 1);
			}
			else
			{
				states = data;
				data = null;
			}
			
			if (data != null)
			{
				var split = data.split(";");
				record.model = FlxGamepadModel.createByIndex(Std.parseInt(split[0]));
				if (split.length > 1)
					record.attachment = FlxGamepadAttachment.createByIndex(Std.parseInt(split[1]));
			}
			
			if (states != null)
				record.states = CodeValuePair.arrayFromString(states, ";");
		}
		return record;
	}
	
	public static function arrayFromString(data:String):Null<Array<GamepadRecord>>
	{
		var array = data.split(",");
		var list:Null<Array<GamepadRecord>> = null;
		var i = 0;
		var l = array.length;
		while (i < l)
		{
			var record = fromString(array[i++]);
			if (record != null)
			{
				if (list == null)
				{
					list = [];
				}
				list.push(record);
			}
		}
		return list;
	}
	
	public static function arrayToString(records:Array<GamepadRecord>):String
	{
		var output = "";
		var i:Int = 0;
		var l:Int = records.length;
		while (i < l)
		{
			if (i > 0)
			{
				output += ",";
			}
			output += records[i++].toString();
		}
		return output;
	}
}