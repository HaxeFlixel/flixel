package flixel.animation;

import flixel.FlxG;

/**
 * Just a helper structure for the `FlxSprite` animation system.
 */
class FlxAnimation extends FlxBaseAnimation
{
	/**
	 * Animation frameRate - the speed in frames per second that the animation should play at.
	 */
	public var frameRate(default, set):Float;

	/**
	 * Keeps track of the current frame of animation.
	 * This is NOT an index into the tile sheet, but the frame number in the animation object.
	 */
	public var curFrame(default, set):Int = 0;

	/**
	 * Accessor for `frames.length`
	 */
	public var numFrames(get, never):Int;

	/**
	 * Seconds between frames (basically the framerate)
	 */
	public var delay(default, null):Float = 0;

	/**
	 * Whether the current animation has finished.
	 */
	public var finished(default, null):Bool = true;

	/**
	 * Whether the current animation gets updated or not.
	 */
	public var paused:Bool = true;

	/**
	 * Whether or not the animation is looped.
	 */
	public var looped(default, null):Bool = true;

	/**
	 * Whether or not this animation is being played backwards.
	 */
	public var reversed(default, null):Bool = false;

	/**
	 * Whether or not the frames of this animation are horizontally flipped
	 */
	public var flipX:Bool = false;

	/**
	 * Whether or not the frames of this animation are vertically flipped
	 */
	public var flipY:Bool = false;

	/**
	 * A list of frames stored as int indices
	 * @since 4.2.0
	 */
	public var frames:Array<Int>;

	/**
	 * Internal, used to time each frame of animation.
	 */
	var _frameTimer:Float = 0;

	/**
	 * @param   Name        What this animation should be called (e.g. `"run"`).
	 * @param   Frames      An array of numbers indicating what frames to play in what order (e.g. `[1, 2, 3]`).
	 * @param   FrameRate   The speed in frames per second that the animation should play at (e.g. `40`).
	 * @param   Looped      Whether or not the animation is looped or just plays once.
	 * @param   FlipX       Whether or not the frames of this animation are horizontally flipped.
	 * @param   FlipY       Whether or not the frames of this animation are vertically flipped.
	 */
	public function new(Parent:FlxAnimationController, Name:String, Frames:Array<Int>, FrameRate:Float = 0, Looped:Bool = true, FlipX:Bool = false,
			FlipY:Bool = false)
	{
		super(Parent, Name);

		frameRate = FrameRate;
		frames = Frames;
		looped = Looped;
		flipX = FlipX;
		flipY = FlipY;
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

	/**
	 * Starts this animation playback.
	 *
	 * @param   Force      Whether to force this animation to restart.
	 * @param   Reversed   Whether to play animation backwards or not.
	 * @param   Frame      The frame number in this animation you want to start from (`0` by default).
	 *                     If you pass a negative value then it will start from a random frame.
	 *                     If you `Reversed` is `true`, the frame value will be "reversed"
	 *                     (`Frame = numFrames - 1 - Frame`), so `Frame` value will mean frame index
	 *                     from the animation's end in this case.
	 */
	public function play(Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (!Force && !finished && reversed == Reversed)
		{
			paused = false;
			finished = false;
			return;
		}

		reversed = Reversed;
		paused = false;
		_frameTimer = 0;
		finished = delay == 0;

		var maxFrameIndex:Int = numFrames - 1;
		if (Frame < 0)
			curFrame = FlxG.random.int(0, maxFrameIndex);
		else
		{
			if (Frame > maxFrameIndex)
				Frame = maxFrameIndex;
			if (reversed)
				Frame = (maxFrameIndex - Frame);
			curFrame = Frame;
		}

		if (finished)
			parent.fireFinishCallback(name);
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

	public function reset():Void
	{
		stop();
		curFrame = reversed ? (numFrames - 1) : 0;
	}

	public function finish():Void
	{
		stop();
		curFrame = reversed ? 0 : (numFrames - 1);
	}

	public function pause():Void
	{
		paused = true;
	}

	public inline function resume():Void
	{
		paused = false;
	}

	public function reverse():Void
	{
		reversed = !reversed;
		if (finished)
			play(false, reversed);
	}

	override public function update(elapsed:Float):Void
	{
		if (delay == 0 || finished || paused)
			return;

		_frameTimer += elapsed;
		while (_frameTimer > delay && !finished)
		{
			_frameTimer -= delay;
			if (reversed)
			{
				if (looped && curFrame == 0)
					curFrame = numFrames - 1;
				else
					curFrame--;
			}
			else
			{
				if (looped && curFrame == numFrames - 1)
					curFrame = 0;
				else
					curFrame++;
			}
		}
	}

	override public function clone(Parent:FlxAnimationController):FlxAnimation
	{
		return new FlxAnimation(Parent, name, frames, frameRate, looped, flipX, flipY);
	}

	function set_frameRate(value:Float):Float
	{
		delay = 0;
		frameRate = value;
		if (value > 0)
			delay = 1.0 / value;
		return value;
	}

	function set_curFrame(Frame:Int):Int
	{
		var maxFrameIndex:Int = numFrames - 1;
		var tempFrame:Int = (reversed) ? (maxFrameIndex - Frame) : Frame;

		if (tempFrame >= 0)
		{
			if (!looped && Frame > maxFrameIndex)
			{
				finished = true;
				curFrame = reversed ? 0 : maxFrameIndex;
			}
			else
			{
				curFrame = Frame;
			}
		}
		else
			curFrame = FlxG.random.int(0, maxFrameIndex);

		curIndex = frames[curFrame];

		if (finished && parent != null)
			parent.fireFinishCallback(name);

		return Frame;
	}

	inline function get_numFrames():Int
	{
		return frames.length;
	}
}
