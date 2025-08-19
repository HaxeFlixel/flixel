package flixel.system.replay;

import flixel.FlxG;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;

/**
 * The replay object both records and replays game recordings,
 * as well as handle saving and loading replays to and from files.
 * Gameplay recordings are essentially a list of keyboard and mouse inputs,
 * but since Flixel is fairly deterministic, we can use these to play back
 * recordings of gameplay with a decent amount of fidelity.
 */
@:nullSafety(Strict)
class FlxReplay implements IFlxDestroyable
{
	/**
	 * The random number generator seed value for this recording.
	 */
	public var seed(default, null):Int = 0;
	
	/**
	 * The current frame for this recording.
	 */
	public var frame(default, null):Int = 0;
	
	/**
	 * The number of frames in this recording.
	 * **Note:** This doesn't include empty records, unlike `getDuration()`
	 */
	public var frameCount(get, never):Int;
	inline function get_frameCount() return _frames.length;
	
	/**
	 * Whether the replay has finished playing or not.
	 */
	public var finished(default, null):Bool = false;
	
	/**
	 * Internal container for all the frames in this replay.
	 */
	final _frames:Array<FrameRecord> = [];
	
	/**
	 * Internal helper variable for keeping track of where we are in _frames during recording or replay.
	 */
	var _marker:Int = 0;
	
	/**
	 * Instantiate a new replay object.  Doesn't actually do much until you call create() or load().
	 */
	public function new() {}
	
	/**
	 * Common initialization terms used by both create() and load() to set up the replay object.
	 */
	function init():Void
	{
		destroy();
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		FlxDestroyUtil.destroyArray(_frames);
	}
	
	/**
	 * Create a new gameplay recording.  Requires the current random number generator seed.
	 *
	 * @param   seed  The current seed from the random number generator.
	 */
	public function create(seed:Int):Void
	{
		init();
		this.seed = seed;
		rewind();
	}
	
	/**
	 * Load replay data from a String object. Strings can come from embedded assets or external
	 * files loaded through the debugger overlay.
	 * 
	 * @param   fileContents  A String object containing a gameplay recording.
	 */
	public function load(fileContents:String):Void
	{
		init();
		
		final lines = fileContents.split("\n");
		final seedStr = lines.shift();
		final parsedSeed:Null<Int> = seedStr == null ? null : Std.parseInt(seedStr);
		if (parsedSeed == null)
			throw 'Invalid replay: $fileContents';
		
		seed = parsedSeed;
		for (line in lines)
		{
			if (line.length > 3)
				_frames.push(new FrameRecord().load(line));
		}
		
		rewind();
	}
	
	/**
	 * Save the current recording data off to a String object. Basically goes through and
	 * calls FrameRecord.save() on each frame in the replay.
	 * 
	 * @return  The gameplay recording in simple ASCII format.
	 */
	public function save():Null<String>
	{
		return Lambda.fold(_frames, (frame, result)->'${result}${frame.save()}\n', '$seed\n');
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
		
		_frames.push(frameRecorded);
	}
	
	/**
	 * Get the current frame record data and load it into the input managers.
	 */
	public function playNextFrame():Void
	{
		FlxG.inputs.reset();
		
		if (_marker >= _frames.length)
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
	 * The duration of this replay, in frames. **Note:** this is different from `frameCount`, which
	 * is the number of unique records, which doesn't count frames with no input
	 * 
	 * @since 5.9.0
	 */
	public function getDuration()
	{
		if (_frames != null)
		{
			// Add 1 to the last frame index, because they are zero-based
			return _frames[_frames.length - 1].frame + 1;
		}
		
		return 0;
	}
}
