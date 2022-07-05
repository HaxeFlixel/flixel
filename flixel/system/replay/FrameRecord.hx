package flixel.system.replay;

import flixel.FlxG;
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
	public var keys:Array<KeyRecord>;

	/**
	 * A container for the mouse state values.
	 */
	public var mouse:MouseRecord;

	/**
	 * An array of touch states.
	 */
	public var touches:Array<TouchRecord>;

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
	public function create(frame:Float, ?keys:Array<KeyRecord>, ?mouse:MouseRecord, ?touches:Array<TouchRecord>):FrameRecord
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
			output += KeyRecord.arrayToString(keys);
		}

		output += "m";
		if (mouse != null)
		{
			output += mouse.toString();
		}

		output += "t";
		if (touches != null)
		{
			output += TouchRecord.arrayToString(touches);
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
			trace(data);
			FlxG.log.advanced('Invalid FrameRecord format:$data', LogStyle.WARNING, true);
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
			keys = KeyRecord.arrayFromString(keyData);
		}

		// parse mouse data
		if (mouseData.length > 0)
		{
			mouse = MouseRecord.fromString(mouseData);
		}
		
		// Parse touch data
		if (touchData.length > 0)
		{
			touches = TouchRecord.arrayFromString(touchData);
		}
		
		return this;
	}
	
	public function merge(record:FrameRecord)
	{
		if (record.keys != null)
		{
			if (keys == null)
				keys = [];
			
			for (key in record.keys)
			{
			}
		}
		
	}
}