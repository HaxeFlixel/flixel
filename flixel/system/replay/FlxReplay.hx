package flixel.system.replay;

import flixel.FlxG;
import flixel.util.FlxArrayUtil;

/**
 * The replay object both records and replays game recordings,
 * as well as handle saving and loading replays to and from files.
 * Gameplay recordings are essentially a list of keyboard and mouse inputs,
 * but since Flixel is fairly deterministic, we can use these to play back
 * recordings of gameplay with a decent amount of fidelity.
 */
class FlxReplay
{
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
	public var frameCount:Int;

	/**
	 * Whether the replay has finished playing or not.
	 */
	public var finished:Bool;

	/**
	 * Internal container for all the frames in this replay.
	 */
	var _frames:Array<FrameRecord>;

	/**
	 * Internal tracker for max number of frames we can fit before growing the _frames again.
	 */
	var _capacity:Int;

	/**
	 * Internal helper variable for keeping track of where we are in _frames during recording or replay.
	 */
	var _marker:Int;

	/**
	 * Instantiate a new replay object.  Doesn't actually do much until you call create() or load().
	 */
	public function new()
	{
		seed = 0;
		frame = 0;
		frameCount = 0;
		finished = false;
		_frames = null;
		_capacity = 0;
		_marker = 0;
	}

	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		if (_frames == null)
		{
			return;
		}
		var i:Int = frameCount - 1;
		while (i >= 0)
		{
			_frames[i--].destroy();
		}
		_frames = null;
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
	 * Load replay data from a String object.
	 * Strings can come from embedded assets or external
	 * files loaded through the debugger overlay.
	 * @param	FileContents	A String object containing a gameplay recording.
	 */
	public function load(FileContents:String):Void
	{
		init();

		var lines:Array<String> = FileContents.split("\n");

		seed = Std.parseInt(lines[0]);

		var line:String;
		var i:Int = 1;
		var l:Int = lines.length;
		while (i < l)
		{
			line = lines[i++];
			if (line.length > 3)
			{
				_frames[frameCount++] = new FrameRecord().load(line);
				if (frameCount >= _capacity)
				{
					_capacity *= 2;
					FlxArrayUtil.setLength(_frames, _capacity);
				}
			}
		}

		rewind();
	}

	/**
	 * Save the current recording data off to a String object.
	 * Basically goes through and calls FrameRecord.save() on each frame in the replay.
	 * return	The gameplay recording in simple ASCII format.
	 */
	public function save():String
	{
		if (frameCount <= 0)
		{
			return null;
		}
		var output:String = seed + "\n";
		var i:Int = 0;
		while (i < frameCount)
		{
			output += _frames[i++].save() + "\n";
		}
		return output;
	}

	/**
	 * Get the current input data from the input managers and store it in a new frame record.
	 */
	public function recordFrame():Void
	{
		var continueFrame = true;

		#if FLX_KEYBOARD
		var keysRecord:Array<CodeValuePair> = FlxG.keys.record();
		if (keysRecord != null)
			continueFrame = false;
		#end

		#if FLX_MOUSE
		var mouseRecord:MouseRecord = FlxG.mouse.record();
		if (mouseRecord != null)
			continueFrame = false;
		#end

		if (continueFrame)
		{
			frame++;
			return;
		}

		var frameRecorded = new FrameRecord().create(frame++);
		#if FLX_MOUSE
		frameRecorded.mouse = mouseRecord;
		#end
		#if FLX_KEYBOARD
		frameRecorded.keys = keysRecord;
		#end

		_frames[frameCount++] = frameRecorded;

		if (frameCount >= _capacity)
		{
			_capacity *= 2;
			FlxArrayUtil.setLength(_frames, _capacity);
		}
	}

	/**
	 * Get the current frame record data and load it into the input managers.
	 */
	public function playNextFrame():Void
	{
		FlxG.inputs.reset();

		if (_marker >= frameCount)
		{
			finished = true;
			return;
		}
		if (_frames[_marker].frame != frame++)
		{
			return;
		}

		var fr:FrameRecord = _frames[_marker++];

		#if FLX_KEYBOARD
		if (fr.keys != null)
		{
			FlxG.keys.playback(fr.keys);
		}
		#end

		#if FLX_MOUSE
		if (fr.mouse != null)
		{
			FlxG.mouse.playback(fr.mouse);
		}
		#end
	}

	/**
	 * Reset the replay back to the first frame.
	 */
	public function rewind():Void
	{
		_marker = 0;
		frame = 0;
		finished = false;
	}

	/**
	 * Common initialization terms used by both create() and load() to set up the replay object.
	 */
	function init():Void
	{
		_capacity = 100;
		_frames = new Array<FrameRecord>( /*_capacity*/);
		FlxArrayUtil.setLength(_frames, _capacity);
		frameCount = 0;
	}
}
