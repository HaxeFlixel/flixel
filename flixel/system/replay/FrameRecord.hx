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
	 * An array containing all the gamepad inputs.
	 */
	public var gamepad:Array<GamepadRecord>;

	/**
	 * Instantiate array new frame record.
	 */
	public function new()
	{
		frame = 0;
		keys = null;
		mouse = null;
		gamepad = null;
	}

	/**
	 * Load this frame record with input data from the input managers.
	 * @param Frame		What frame it is.
	 * @param Keys		Keyboard data from the keyboard manager.
	 * @param Mouse		Mouse data from the mouse manager.
	 * @return A reference to this FrameRecord object.
	 */
	public function create(Frame:Float, ?Keys:Array<CodeValuePair>, ?Mouse:MouseRecord, ?Gamepad:Array<GamepadRecord>):FrameRecord
	{
		frame = Math.floor(Frame);
		keys = Keys;
		mouse = Mouse;
		gamepad = Gamepad;

		return this;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		keys = null;
		mouse = null;
		gamepad = null;
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
			var object:CodeValuePair;
			var i:Int = 0;
			var l:Int = keys.length;
			while (i < l)
			{
				if (i > 0)
				{
					output += ",";
				}
				object = keys[i++];
				output += object.code + ":" + object.value;
			}
		}

		output += "m";
		if (mouse != null)
		{
			output += mouse.x + "," + mouse.y + "," + mouse.button + "," + mouse.wheel;
		}

		if (gamepad != null)
		{
			for (record in gamepad)
			{
				output += "g";
				if (record != null)
				{
					output += record.gamepadID + ",";
					var object:CodeValuePair;
					var i:Int = 0;
					var l:Int = record.buttons.length;
					while (i < l)
					{
						if (i > 0)
						{
							output += ",";
						}
						object = record.buttons[i++];
						output += object.code + ":" + object.value;
					}
					output += "/";
					var object:IntegerFloatPair;
					var i:Int = 0;
					var l:Int = record.analog.length;
					while (i < l)
					{
						if (i > 0)
						{
							output += ",";
						}
						object = record.analog[i++];
						output += object.code + ":" + object.value;
					}
				}
			}
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
		frame = Std.parseInt(array[0]);

		// split up keyboard and mouse data
		array = array[1].split("m");
		var gamepadArray:Array<String> = array[1].split("g");

		var keyData:String = array[0];
		var mouseData:String = gamepadArray.splice(0, 1)[0];

		// parse keyboard data
		if (keyData.length > 0)
		{
			// get keystroke data pairs
			array = keyData.split(",");

			// go through each data pair and enter it into this frame's key state
			var keyPair:Array<String>;
			i = 0;
			l = array.length;
			while (i < l)
			{
				keyPair = array[i++].split(":");
				if (keyPair.length == 2)
				{
					if (keys == null)
					{
						keys = new Array<CodeValuePair>();
					}
					keys.push(new CodeValuePair(Std.parseInt(keyPair[0]), Std.parseInt(keyPair[1])));
				}
			}
		}

		// mouse data is just 4 integers, easy peezy
		if (mouseData.length > 0)
		{
			array = mouseData.split(",");
			if (array.length >= 4)
			{
				mouse = new MouseRecord(Std.parseInt(array[0]), Std.parseInt(array[1]), Std.parseInt(array[2]), Std.parseInt(array[3]));
			}
		}

		if (gamepadArray.length > 0)
		{
			for (gamepadString in gamepadArray)
			{
				array = gamepadString.split(",");
				var currentGamepad:GamepadRecord = new GamepadRecord(Std.parseInt(array[0]), [], []);
				
				var inputsArray:Array<String> = gamepadString.substring(array[0].length + 1).split("/");
				var buttonsArray:Array<String> = inputsArray[0].split(",");
				var analogArray:Array<String> = inputsArray[1].split(",");
				
				// go through each data pair and enter it into this frame's button state
				var buttonPair:Array<String>;
				i = 0;
				l = inputsArray[0].length;
				while (i < l)
				{
					var pairString = buttonsArray[i++];
					if (pairString != null)
					{
						buttonPair = pairString.split(":");
						if (buttonPair.length == 2)
						{
							if (gamepad == null)
							{
								gamepad = new Array<GamepadRecord>();
							}
							currentGamepad.buttons.push(new CodeValuePair(Std.parseInt(buttonPair[0]), Std.parseInt(buttonPair[1])));
						}
					}
				}
				
				// go through each data pair and enter it into this frame's analog state
				if (analogArray.length > 0)
				{
					var analogPair:Array<String>;
					i = 0;
					l = inputsArray[0].length;
					while (i < l)
					{
						var pairString = analogArray[i++];
						if (pairString != null)
						{
							analogPair = pairString.split(":");
							if (analogPair.length == 2)
							{
								if (gamepad == null)
								{
									gamepad = new Array<GamepadRecord>();
								}
								currentGamepad.analog.push(new IntegerFloatPair(Std.parseInt(analogPair[0]), Std.parseFloat(analogPair[1])));
							}
						}
					}
				}
				
				this.gamepad.push(currentGamepad);
			}
		}

		return this;
	}
}
