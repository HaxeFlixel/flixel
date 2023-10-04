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
	 * Seconds between frames (inverse of the framerate)
	 * 
	 * Note: `FlxFrameCollections` and `FlxAtlasFrames` may have their own duration set per-frame,
	 * those values will override this value.
	 */
	public var frameDuration:Float = 0;

	/**
	 * Seconds between frames (inverse of the framerate)
	 */
	@:deprecated('FlxAnimation.delay is deprecated, use `frameDuration`')
	public var delay(get, set):Float;

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
	public var looped:Bool = true;

	/**
	 * The custom loop point for this animation.
	 * This allows you to skip the first few frames of an animation when looping.
	 */
	public var loopPoint:Int = 0;

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
	 * How fast or slow time should pass for this animation.
	 * 
	 * Similar to `FlxAnimationController`'s `timeScale`, but won't effect other animations.
	 * @since 5.4.1
	 */
	public var timeScale:Float = 1.0;

	/**
	 * Internal, used to time each frame of animation.
	 */
	var _frameTimer:Float = 0;

	/**
	 * @param   name        What this animation should be called (e.g. `"run"`).
	 * @param   frames      An array of numbers indicating what frames to play in what order (e.g. `[1, 2, 3]`).
	 * @param   frameRate   The speed in frames per second that the animation should play at (e.g. `40`).
	 * @param   looped      Whether or not the animation is looped or just plays once.
	 * @param   flipX       Whether or not the frames of this animation are horizontally flipped.
	 * @param   flipY       Whether or not the frames of this animation are vertically flipped.
	 */
	public function new(parent:FlxAnimationController, name:String, frames:Array<Int>, frameRate = 0.0, looped = true, flipX = false, flipY = false)
	{
		super(parent, name);

		this.frameRate = frameRate;
		this.frames = frames;
		this.looped = looped;
		this.flipX = flipX;
		this.flipY = flipY;
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
			return;
		}

		reversed = Reversed;
		paused = false;
		_frameTimer = 0;
		finished = frameDuration == 0;

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
		var curFrameDuration = getCurrentFrameDuration();
		if (curFrameDuration == 0 || finished || paused)
			return;

		_frameTimer += elapsed * timeScale;
		while (_frameTimer > curFrameDuration && !finished)
		{
			_frameTimer -= curFrameDuration;
			if (reversed)
			{
				if (looped && curFrame == loopPoint)
					curFrame = numFrames - 1;
				else
					curFrame--;
			}
			else
			{
				if (looped && curFrame == numFrames - 1)
					curFrame = loopPoint;
				else
					curFrame++;
			}
			
			// prevents null ref when the sprite is destroyed on finishCallback (#2782)
			if (finished)
				break;
			
			curFrameDuration = getCurrentFrameDuration();
		}
	}

	function getCurrentFrameDuration()
	{
		final curframeDuration = parent.getFrameDuration(frames[curFrame]);
		return curframeDuration > 0 ? curframeDuration : frameDuration;
	}

	override public function clone(newParent:FlxAnimationController):FlxAnimation
	{
		return new FlxAnimation(newParent, name, frames, frameRate, looped, flipX, flipY);
	}

	function set_frameRate(value:Float):Float
	{
		frameRate = value;
		frameDuration = (value > 0 ? 1.0 / value : 0);
		return value;
	}

	function set_curFrame(frame:Int):Int
	{
		var maxFrameIndex:Int = numFrames - 1;
		var tempFrame:Int = (reversed) ? (maxFrameIndex - frame) : frame;

		if (tempFrame >= 0)
		{
			if (!looped && tempFrame > maxFrameIndex)
			{
				finished = true;
				curFrame = reversed ? 0 : maxFrameIndex;
			}
			else
			{
				curFrame = frame;
			}
		}
		else
			curFrame = FlxG.random.int(0, maxFrameIndex);

		curIndex = frames[curFrame];

		if (finished && parent != null)
			parent.fireFinishCallback(name);

		return frame;
	}

	inline function get_numFrames():Int
	{
		return frames.length;
	}

	inline function get_delay()
	{
		return frameDuration;
	}

	inline function set_delay(value:Float)
	{
		return frameDuration = value;
	}
}
