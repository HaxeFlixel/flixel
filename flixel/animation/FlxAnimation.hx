package flixel.animation;
import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Just a helper structure for the FlxSprite animation system.
 */
class FlxAnimation extends FlxBaseAnimation
{
	/**
	 * String name of the animation (e.g. "walk")
	 */
	public var name:String;
	/**
	 * Seconds between frames (basically the framerate)
	 */
	private var _delay:Float;
	/**
	 * A list of frames stored as <code>int</code> objects
	 */
	public var frames:Array<Int>;
	/**
	 * Whether or not the animation is looped
	 */
	public var looped:Bool;
	/**
	 * Whether the current animation has finished its first (or only) loop.
	 */
	public var finished(default, null):Bool;
	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused:Bool;
	
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float;
	
	private var _curFrame:Int;
	
	/**
	 * Constructor
	 * @param	Name		What this animation should be called (e.g. "run")
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40)
	 * @param	Looped		Whether or not the animation is looped or just plays once
	 */
	public function new(Sprite:FlxSprite, Name:String, Frames:Array<Int>, FrameRate:Int = 0, Looped:Bool = true)
	{
		super(Sprite);
		
		name = Name;
		frameRate = FrameRate;
		frames = Frames;
		looped = Looped;
		finished = false;
		paused = true;
		_curFrame = 0;
		_curIndex = 0;
		_frameTimer = 0;
	}
	
	/**
	 * Clean up memory.
	 */
	override public function destroy():Void
	{
		frames = null;
		name = null;
		super.destroy();
	}
	
	public function play(Force:Bool = false, Frame:Int = 0):Void
	{
		if (!Force && (looped || !finished))
		{
			paused = false;
			return;
		}
		
		paused = false;
		finished = false;
		_frameTimer = 0;
		
		if (Frame < 0)
		{
			curFrame = Std.int(Math.random() * frames.length);
		}
		else if (frames.length > Frame)
		{
			curFrame = Frame;
		}
		else
		{
			curFrame = 0;
		}
		
		if (_delay <= 0)
		{
			finished = true;
		}
		else
		{
			finished = false;
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
	
	override public function update():Bool
	{
		var dirty:Bool = false;
		
		if (_delay > 0 && (looped || !finished) && !paused)
		{
			_frameTimer += FlxG.elapsed;
			while (_frameTimer > _delay)
			{
				_frameTimer = _frameTimer - _delay;
				if (curFrame == frames.length - 1)
				{
					if (looped)
					{
						_curFrame = 0;
					}
					else
					{
						finished = true;
					}
				}
				else
				{
					_curFrame++;
				}
				_curIndex = frames[curFrame];
				dirty = true;
			}
		}
		
		return dirty;
	}
	
	/**
	 * Animation frameRate - the speed in frames per second that the animation should play at.
	 */
	public var frameRate(default, set_frameRate):Int;
	
	private function set_frameRate(value:Int):Int
	{
		_delay = 0;
		frameRate = value;
		if (value > 0)
		{
			_delay = 1.0 / value;
		}
		return value;
	}
	
	public var numFrames(get, null):Int;
	
	private function get_numFrames():Int
	{
		return frames.length;
	}
	
	public var delay(get_delay, null):Float;
	
	function get_delay():Float 
	{
		return _delay;
	}
	
	/**
	 * Keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	public var curFrame(get, set):Int;
	
	private function get_curFrame():Int
	{
		return _curFrame;
	}
	
	private function set_curFrame(Frame:Int):Int
	{
		if (Frame >= 0 && Frame < frames.length)
		{
			_curFrame = Frame;
		}
		else if (Frame < 0)
		{
			_curFrame = Std.int(Math.random() * frames.length);
		}
		
		_curIndex = frames[_curFrame];
		return Frame;
	}
	
	override public function clone(Sprite:FlxSprite):FlxAnimation
	{
		return new FlxAnimation(Sprite, name, frames, frameRate, looped);
	}
}