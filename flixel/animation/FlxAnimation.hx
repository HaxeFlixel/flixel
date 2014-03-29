package flixel.animation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxRandom;

/**
 * Just a helper structure for the FlxSprite animation system.
 */
class FlxAnimation extends FlxBaseAnimation
{
	/**
	 * Animation frameRate - the speed in frames per second that the animation should play at.
	 */
	public var frameRate(default, set):Int;
	
	/**
	 * Keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	public var curFrame(default, set):Int = 0;
	
	/**
	 * Accesor for frames.length
	 */
	public var numFrames(get, null):Int;
	
	/**
	 * Seconds between frames (basically the framerate)
	 */
	public var delay(default, null):Float = 0;
	
	/**
	 * Whether the current animation has finished.
	 */
	public var finished:Bool = true;
	
	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused:Bool = true;
	
	/**
	 * Whether or not the animation is looped
	 */
	public var looped:Bool = true;
	
	
	/**
	 * A list of frames stored as int objects
	 */
	@:allow(flixel.animation)
	private var _frames:Array<Int>;
	
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float = 0;
	
	/**
	 * @param	Name		What this animation should be called (e.g. "run")
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40)
	 * @param	Looped		Whether or not the animation is looped or just plays once
	 */
	public function new(Parent:FlxAnimationController, Name:String, Frames:Array<Int>, FrameRate:Int = 0, Looped:Bool = true)
	{
		super(Parent, Name);
		
		frameRate = FrameRate;
		_frames = Frames;
		looped = Looped;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		_frames = null;
		name = null;
		super.destroy();
	}
	
	public function play(Force:Bool = false, Frame:Int = 0):Void
	{
		if (!Force && (looped || !finished))
		{
			paused = false;
			finished = false;
			set_curFrame(curFrame);
			return;
		}
		
		paused = false;
		_frameTimer = 0;
		
		if ((delay <= 0) || (Frame == (numFrames - 1)))
		{
			finished = true;
		}
		else
		{
			finished = false;
		}
		
		if (Frame < 0)
		{
			curFrame = FlxRandom.intRanged(0, numFrames - 1);
		}
		else if (numFrames > Frame)
		{
			curFrame = Frame;
		}
		else
		{
			curFrame = 0;
		}
	}
	
	public function restart():Void
	{
		play(true);
	}
	
	public function stop():Void
	{
		finished = true;
		paused = true;
	}
	
	override public function update():Void
	{
		if (delay > 0 && (looped || !finished) && !paused)
		{
			_frameTimer += FlxG.elapsed;
			while (_frameTimer > delay)
			{
				_frameTimer = _frameTimer - delay;
				if (looped && (curFrame == numFrames - 1))
				{
					curFrame = 0;
				}
				else
				{
					curFrame++;
				}
			}
		}
	}
	
	override public function clone(Parent:FlxAnimationController):FlxAnimation
	{
		return new FlxAnimation(Parent, name, _frames, frameRate, looped);
	}
	
	private function set_frameRate(value:Int):Int
	{
		delay = 0;
		frameRate = value;
		if (value > 0)
		{
			delay = 1.0 / value;
		}
		return value;
	}
	
	private function set_curFrame(Frame:Int):Int
	{
		if (Frame >= 0)
		{
			if (!looped && Frame >= numFrames)
			{
				finished = true;
				curFrame = numFrames - 1;
			}
			else
			{
				curFrame = Frame;
			}
		}
		else
		{
			curFrame = FlxRandom.intRanged(0, numFrames - 1);
		}
		
		curIndex = _frames[curFrame];
		return Frame;
	}
	
	private inline function get_numFrames():Int
	{
		return _frames.length;
	}
}