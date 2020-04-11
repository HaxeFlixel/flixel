package flixel.system.replay;

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
	public var keys:Array<CodeValuePair>;

	/**
	 * A container for the 4 mouse state integers.
	 */
	public var mouse:MouseRecord;

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
	 * @param Frame		What frame it is.
	 * @param Keys		Keyboard data from the keyboard manager.
	 * @param Mouse		Mouse data from the mouse manager.
	 * @return A reference to this FrameRecord object.
	 */
	public function create(Frame:Float, ?Keys:Array<CodeValuePair>, ?Mouse:MouseRecord):FrameRecord
	{
		frame = Math.floor(Frame);
		keys = Keys;
		mouse = Mouse;

		return this;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		keys = null;
		mouse = null;
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
			output += CodeValuePair.arrayToString(keys);
		}

		output += "m";
		if (mouse != null)
		{
			output += mouse.toString();
		}

		return output;
	}

	/**
	 * Load the frame record data from array simple ASCII string.
	 * @param	Data	A String object containing the relevant frame record data.
	 */
	public function load(Data:String):FrameRecord
	{
		var i:Int;
		var l:Int;

		// get frame number
		var array:Array<String> = Data.split("k");
		frame = Std.parseInt(array.shift());

		// split up keyboard and mouse data
		array = array[0].split("m");
		var keyData:String = array.shift();
		array = array[0].split("t");
		var mouseData:String = array.shift();
		var touchData:String = array.shift();

		// parse keyboard data
		if (keyData.length > 0)
		{
			keys = CodeValuePair.arrayFromString(keyData);
		}

		// parse mouse data
		if (mouseData.length > 0)
		{
			mouse = MouseRecord.fromString(mouseData);
		}
		
		return this;
	}
}
