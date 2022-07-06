package flixel.system.replay;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.system.replay.KeyRecord;
import flixel.system.replay.MouseRecord;
import flixel.system.replay.TouchRecord;
import flixel.system.debug.log.LogStyle;

/**
 * Helper class for the new replay system.  Represents all the game inputs for one "frame" or "step" of the game loop.
 */
class FrameRecord
{
	/**
	 * Which frame of the game loop this record is from or for.
	 */
	public var frame:Int;

	/**
	 * An array of simple integer pairs referring to what key is pressed, and what state its in.
	 */
	public var keys:KeyRecordList;

	/**
	 * A container for the mouse state values.
	 */
	public var mouse:MouseRecord;

	/**
	 * An array of touch states.
	 */
	public var touches:TouchRecordList;

	/**
	 * Instantiate array new frame record.
	 */
	public function new()
	{
		frame = 0;
		keys = null;
		mouse = null;
	}

	/**
	 * Load this frame record with input data from the input managers.
	 * @param   frame  What frame it is.
	 * @param   keys   Keyboard data from the keyboard manager.
	 * @param   mouse  Mouse data from the mouse manager.
	 * @return  A reference to this FrameRecord object.
	 */
	public function create(frame:Float, ?keys:KeyRecordList, ?mouse:MouseRecord, ?touches:TouchRecordList):FrameRecord
	{
		this.frame = Math.floor(frame);
		this.keys = keys;
		this.mouse = mouse;
		this.touches = touches;

		return this;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		keys = null;
		mouse = null;
		touches = null;
	}

	/**
	 * Save the frame record data to array simple ASCII string.
	 * @return	A String object containing the relevant frame record data.
	 */
	public function save():String
	{
		var output:String = frame + "k";

		if (keys != null)
		{
			output += keys.toString();
		}

		output += "m";
		if (mouse != null)
		{
			output += mouse.toString();
		}

		output += "t";
		if (touches != null)
		{
			output += touches.toString();
		}
		return output; 
	}

	static var validRecord = ~/^(\d+)k(.*?)m(.*?)(?:t(.*?))?$/;
	
	/**
	 * Load the frame record data from array simple ASCII string.
	 * @param   data  A String object containing the relevant frame record data.
	 */
	public function load(data:String):FrameRecord
	{
		if (!validRecord.match(data))
		{
			FlxG.log.advanced('Invalid FrameRecord format:"$data"', LogStyle.WARNING, true);
			return this;
		}
		// get frame number
		frame = Std.parseInt(validRecord.matched(1));
		var keyData = validRecord.matched(2);
		var mouseData = validRecord.matched(3);
		var touchData = validRecord.matched(4);

		// parse keyboard data
		if (keyData.length > 0)
		{
			keys = KeyRecordList.fromString(keyData);
		}

		// parse mouse data
		if (mouseData.length > 0)
		{
			mouse = MouseRecord.fromString(mouseData);
		}
		
		// Parse touch data
		if (touchData.length > 0)
		{
			touches = TouchRecordList.fromString(touchData);
		}
		
		return this;
	}
}

@:forward
abstract FrameRecordIterator(FrameRecord) to FrameRecord
{
	var _keys(get, never):KeyRecordListIterator;
	var _mouse(get, never):MouseRecordIterator;
	var _touches(get, never):TouchRecordListIterator;
	
	public inline function new()
	{
		this = new FrameRecord();
		this.keys = new KeyRecordListIterator();
		this.mouse = new MouseRecordIterator();
		this.touches = new TouchRecordListIterator();
	}
	
	public function merge(record:FrameRecord)
	{
		this.frame = record.frame;
		_keys.merge(record.keys);
		_mouse.merge(record.mouse);
		_touches.merge(record.touches);
	}
	
	public function rewind()
	{
		_keys.rewind();
		_mouse.rewind();
		_touches.rewind();
	}
	
	inline function get__keys() return this.keys;
	inline function get__mouse() return this.mouse;
	inline function get__touches() return this.touches;
}

@:access(flixel.system.replay.KeyRecord)
private abstract KeyRecordListIterator(KeyRecordList) to KeyRecordList from KeyRecordList
{
	inline public function new()
	{
		this = new KeyRecordList();
	}
	
	inline public function rewind()
	{
		this.clear();
	}
	
	inline public function merge(record:KeyRecordList)
	{
		if (record == null)
			return;
		
		for (key in record.keys())
		{
			if (this.exists(key))
			{
				record[key].copyTo(this[key]);
			}
			else
			{
				this[key] = record[key].copy();
			}
		}
	}
}

@:access(flixel.system.replay.MouseRecord)
private abstract MouseRecordIterator(MouseRecord) to MouseRecord from MouseRecord
{
	inline public function new()
	{
		this = new MouseRecord();
	}
	
	inline public function rewind()
	{
		this.reset();
	}
	
	inline public function merge(record:MouseRecord)
	{
		if (record == null)
			return;
		
		record.copyTo(this);
	}
}

@:access(flixel.system.replay.TouchRecord)
private abstract TouchRecordListIterator(TouchRecordList) to TouchRecordList from TouchRecordList
{
	inline public function new()
	{
		this = new TouchRecordList();
	}
	
	inline public function rewind()
	{
		this.clear();
	}
	
	inline public function merge(record:TouchRecordList)
	{
		if (record == null)
			return;
		
		for (id in record.keys())
		{
			if (this.exists(id))
			{
				record[id].copyTo(this[id]);
			}
			else
			{
				this[id] = record[id].copy();
			}
		}
	}
}