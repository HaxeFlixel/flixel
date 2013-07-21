package flixel.animation;

/**
 * Just a helper structure for the FlxSprite animation system.
 */
class FlxAnimation
{
	/**
	 * String name of the animation (e.g. "walk")
	 */
	public var name:String;
	/**
	 * Seconds between frames (basically the framerate)
	 */
	public var delay:Float;
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
	public var finished:Bool;
	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused(default, null):Bool;
	/**
	 * Internal, keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	private var _curFrame:Int;
	/**
	 * Internal, used to time each frame of animation.
	 */
	private var _frameTimer:Float;
	
	/**
	 * Constructor
	 * @param	Name		What this animation should be called (e.g. "run")
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3)
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40)
	 * @param	Looped		Whether or not the animation is looped or just plays once
	 */
	public function new(Name:String, Frames:Array<Int>, FrameRate:Float = 0, Looped:Bool = true)
	{
		name = Name;
		frameRate = FrameRate;
		frames = Frames;
		looped = Looped;
		finished = false;
		paused = true;
		_curFrame = 0;
		_frameTimer = 0;
	}
	
	/**
	 * Clean up memory.
	 */
	public function destroy():Void
	{
		frames = null;
		name = null;
	}
	
	/**
	 * Animation frameRate - the speed in frames per second that the animation should play at.
	 */
	public var frameRate(default, set_frameRate):Float;
	
	private function set_frameRate(value:Float):Float
	{
		delay = 0;
		frameRate = value;
		if (value > 0)
		{
			delay = 1.0 / value;
		}
		return value;
	}
}