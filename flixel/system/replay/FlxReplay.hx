package flixel.system.replay;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.util.FlxArrayUtil;
import flixel.system.FlxVersion;

/**
 * The replay object both records and replays game recordings,
 * as well as handle saving and loading replays to and from files.
 * Gameplay recordings are essentially a list of keyboard and mouse inputs,
 * but since Flixel is fairly deterministic, we can use these to play back
 * recordings of gameplay with a decent amount of fidelity.
 */
class FlxReplay
{
	static inline var VERSION = 1;
	
	/**
	 * The random number generator seed value for this recording.
	 */
	public var seed:Int;

	/**
	 * The current frame for this recording.
	 */
	public var frame:Int;

	/**
	 * The number of frames in this recording.
	 */
	public var frameCount(get, never):Int;

	/**
	 * Whether the replay has finished playing or not.
	 */
	public var finished:Bool;

	/**
	 * Internal container for all the frames in this replay.
	 */
	var frames:Array<FrameRecord>;

	/**
	 * Internal helper variable for keeping track of where we are in frames during recording or replay.
	 */
	var marker:Int;

	/**
	 * Instantiate a new replay object.  Doesn't actually do much until you call create() or load().
	 */
	public function new()
	{
		seed = 0;
		frame = 0;
		finished = false;
		frames = null;
		marker = 0;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		if (frames == null)
			return;
		
		for (frame in frames)
			frame.destroy();
		
		frames = null;
	}

	/**
	 * Create a new gameplay recording.  Requires the current random number generator seed.
	 *
	 * @param	Seed	The current seed from the random number generator.
	 */
	public function create(Seed:Int):Void
	{
		destroy();
		init();
		seed = Seed;
		rewind();
	}

	/**
	 * Load replay data from a String object.  Strings can come from embedded assets or external
	 * files loaded through the debugger overlay.
	 * 
	 * @param   data  A String object containing a gameplay recording.
	 */
	public function load(data:String):Void
	{
		init();
		
		var lines = data.split("\n");
		var headerData = lines.shift();
		var validator = ~/v(\d+)s(\d+)/;
		var version = 0;
		if (!validator.match(headerData))
			seed = Std.parseInt(headerData);
		else
		{
			version = Std.parseInt(validator.matched(1));
			seed = Std.parseInt(validator.matched(2));
		}
		
		if(version == 0)
			lines = FrameConvertor.convert(lines, version);
		
		for (line in lines)
			frames.push(new FrameRecord().load(line));
		
		rewind();
	}
	
	function convertLegacy0(lines:Array<String>)
	{
		
	}

	/**
	 * Save the current recording data off to a String object.
	 * Basically goes through and calls FrameRecord.save() on each frame in the replay.
	 * 
	 * @return  The gameplay recording in simple ASCII format.
	 */
	public function save():String
	{
		if (frameCount <= 0)
			return null;
		
		var output = 'v${VERSION}s$seed\n';
		for (frame in frames)
			output += frame.save() + "\n";
		
		// remove the final new line
		return output.substr(0, -1);
	}

	/**
	 * Get the current input data from the input managers and store it in a new frame record.
	 */
	public function recordFrame():Void
	{
		var continueFrame = true;

		#if FLX_KEYBOARD
		var keysRecord = FlxG.keys.record();
		if (keysRecord != null)
			continueFrame = false;
		#end

		#if FLX_MOUSE
		var mouseRecord = FlxG.mouse.record();
		if (mouseRecord != null)
			continueFrame = false;
		#end

		#if FLX_TOUCH
		var touchesRecord = FlxG.touches.record();
		if (touchesRecord != null)
			continueFrame = false;
		#end

		if (continueFrame)
		{
			frame++;
			return;
		}

		var record = new FrameRecord().create(frame++);
		
		#if FLX_MOUSE
		record.mouse = mouseRecord;
		#end
		
		#if FLX_KEYBOARD
		record.keys = keysRecord;
		#end
		
		#if FLX_KEYBOARD
		record.touches = touchesRecord;
		#end

		frames.push(record);
	}

	/**
	 * Get the current frame record data and load it into the input managers.
	 */
	public function playNextFrame():Void
	{
		FlxG.inputs.reset();

		if (marker >= frameCount)
		{
			finished = true;
			return;
		}
		
		if (frames[marker].frame != frame++)
			return;

		var record = frames[marker++];

		#if FLX_KEYBOARD
		if (record.keys != null)
		{
			FlxG.keys.playback(record.keys);
		}
		#end

		#if FLX_MOUSE
		if (record.mouse != null)
		{
			FlxG.mouse.playback(record.mouse);
		}
		#end

		#if FLX_TOUCH
		if (record.touches != null)
		{
			FlxG.touches.playback(record.touches);
		}
		#end
	}

	/**
	 * Reset the replay back to the first frame.
	 */
	public function rewind():Void
	{
		marker = 0;
		frame = 0;
		finished = false;
	}

	/**
	 * Common initialization terms used by both create() and load() to set up the replay object.
	 */
	function init():Void
	{
		frames = new Array<FrameRecord>();
	}
	
	public function get_frameCount()
	{
		return frames.length;
	}
}

@:access(flixel.system.replay.FlxReplay)
private class FrameConvertor
{
	public static function convert(lines:Array<String>, version:Int)
	{
		return switch (version)
		{
			case 0: convert0(lines);
			case FlxReplay.VERSION: lines;
			default: throw "Unexpected version: " + version;
		}
	}
	
	static var keysExtractor = ~/^(\d+)k(.+?)(m.+$)/;
	public static function convert0(lines:Array<String>)
	{
		var i = 0;
		
		var pressedKeys = new Map<String, Bool>();
		function wasPressed(key:String)
		{
			return pressedKeys.exists(key) && pressedKeys[key];
		}
		
		while (i < lines.length)
		{
			final line = lines[i];
			
			// check if the frame has key data
			if (keysExtractor.match(line))
			{
				final frame = Std.parseInt(keysExtractor.matched(1));
				final newKeys = new Array<String>();
				final keys = keysExtractor.matched(2).split(",");
				for (key in keys)
				{
					// remove all key data that hasn't changed from the previous
					final data = key.split(":");
					final isPressed = (cast data[1]:FlxInputState).pressed;
					if (wasPressed(data[0]) != isPressed)
					{
						newKeys.push(data[0] + ":" + (isPressed ? "1" : "0"));
					}
					pressedKeys[data[0]] = isPressed;
				}
				
				lines[i] = line;
				i++;
			}
		}
		
		return lines;
	}
}
