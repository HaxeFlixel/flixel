package flixel.animation;
import flixel.FlxG;
import flixel.FlxSprite;

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
	 * Whether or not this animation is being played backwards.
	 */
	public var reversed:Bool = false;
	
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
	
	/**
	 * Starts this animation playback.
	 * 
	 * @param	Force			Whether to force this animation to restart.
	 * @param	Reversed		Whether to play animation backwards or not.
	 * @param	Frame			The frame number in this animation you want to start from (0 by default).
	 *                    	 	If you pass negative value then it will start from random frame.
	 * 							If you set Reverse to true then Frame value will be "reversed" (Frame = numFrames - 1 - Frame),
	 * 							so Frame value will mean frame index from the animation end in this case.
	 */
	public function play(Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!Force && (looped || !finished) && reversed == Reversed)
		{
			paused = false;
			finished = false;
			set_curFrame(curFrame);
			return;
		}
		
		reversed = Reversed;
		paused = false;
		_frameTimer = 0;
		
		var numFramesMinusOne:Int = numFrames - 1;
		
		if (Frame >= 0)
		{
			// bound frame value
			Frame = (Frame > numFramesMinusOne) ? numFramesMinusOne : Frame;
			// "reverse" frame value
			Frame = (reversed) ? (numFramesMinusOne - Frame) : Frame;
		}
		
		if ((delay <= 0) 									// non-positive fps
			|| (Frame > numFramesMinusOne && !reversed) 	// normal animation
			|| (Frame < 0 && reversed))						// reversed animation
		{
			finished = true;
			parent.fireFinishCallback(name);
		}
		else
		{
			finished = false;
		}
		
		if (Frame < 0)
		{
			curFrame = FlxG.random.int(0, numFramesMinusOne);
		}
		else
		{
			curFrame = Frame;
		}
	}
	
	public function restart():Void
	{
		play(true, reversed);
	}
	
	public function stop():Void
	{
		finished = true;
		paused = true;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (delay > 0 && (looped || !finished) && !paused)
		{
			_frameTimer += elapsed;
			while (_frameTimer > delay)
			{
				_frameTimer -= delay;
				
				if (looped)
				{
					var numFramesMinusOne:Int = numFrames - 1;
					var tempFrame:Int = (reversed) ? (numFramesMinusOne - curFrame) : curFrame;
					
					if (tempFrame == numFramesMinusOne)
					{
						curFrame = (reversed) ? numFramesMinusOne : 0;
					}
					else
					{
						curFrame = (reversed) ? (curFrame - 1) : (curFrame + 1);
					}
				}
				else
				{
					curFrame = (reversed) ? (curFrame - 1) : (curFrame + 1);
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
		var numFramesMinusOne:Int = numFrames - 1;
		// "reverse" frame value (if there is such need)
		var tempFrame:Int = (reversed) ? (numFramesMinusOne - Frame) : Frame;
		
		if (tempFrame >= 0)
		{
			if (!looped && tempFrame > numFramesMinusOne)
			{
				finished = true;
				curFrame = (reversed) ? 0 : numFramesMinusOne;
				parent.fireFinishCallback(name);
			}
			else
			{
				curFrame = Frame;
			}
		}
		else
		{
			curFrame = FlxG.random.int(0, numFramesMinusOne);
		}
		
		curIndex = _frames[curFrame];
		return Frame;
	}
	
	private inline function get_numFrames():Int
	{
		return _frames.length;
	}
}