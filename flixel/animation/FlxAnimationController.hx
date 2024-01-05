package flixel.animation;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

using StringTools;

class FlxAnimationController implements IFlxDestroyable
{
	/**
	 * Property access for currently playing animation (warning: can be `null`).
	 */
	public var curAnim(get, set):FlxAnimation;

	/**
	 * The frame index of the current animation. Can be changed manually.
	 */
	public var frameIndex(default, set):Int = -1;

	/**
	 * Tell the sprite to change to a frame with specific name.
	 * Useful for sprites with loaded TexturePacker atlas.
	 */
	public var frameName(get, set):String;

	/**
	 * Gets or sets the currently playing animation (warning: can be `null`).
	 */
	public var name(get, set):String;

	/**
	 * Pause or resume the current animation.
	 */
	public var paused(get, set):Bool;

	/**
	 * Whether the current animation has finished playing.
	 */
	public var finished(get, set):Bool;

	/**
	 * The total number of frames in this image.
	 * WARNING: assumes each row in the sprite sheet is full!
	 */
	public var numFrames(get, never):Int;

	/**
	 * The total number of frames in this image.
	 * WARNING: assumes each row in the sprite sheet is full!
	 */
	@:deprecated("frames is deprecated, use numFrames")
	public var frames(get, never):Int;

	/**
	 * If assigned, will be called each time the current animation's frame changes.
	 * A function that has 3 parameters: a string name, a frame number, and a frame index.
	 */
	public var callback:(name:String, frameNumber:Int, frameIndex:Int) -> Void;

	/**
	 * If assigned, will be called each time the current animation finishes.
	 * A function that has 1 parameter: a string name - animation name.
	 */
	public var finishCallback:(name:String) -> Void;

	/**
	 * How fast or slow time should pass for this animation controller
	 */
	public var timeScale:Float = 1.0;

	/**
	 * Internal, reference to owner sprite.
	 */
	var _sprite:FlxSprite;

	/**
	 * Internal, currently playing animation.
	 */
	@:allow(flixel.animation)
	var _curAnim:FlxAnimation;

	/**
	 * Internal, stores all the animation that were added to this sprite.
	 */
	var _animations(default, null):Map<String, FlxAnimation> = [];

	var _prerotated:FlxPrerotatedAnimation;

	public function new(sprite:FlxSprite)
	{
		_sprite = sprite;
	}

	public function update(elapsed:Float):Void
	{
		if (_curAnim != null)
		{
			_curAnim.update(elapsed * (timeScale * FlxG.animationTimeScale));
		}
		else if (_prerotated != null)
		{
			_prerotated.angle = _sprite.angle;
		}
	}

	public function copyFrom(controller:FlxAnimationController):FlxAnimationController
	{
		destroyAnimations();

		for (anim in controller._animations)
		{
			add(anim.name, anim.frames, anim.frameRate, anim.looped, anim.flipX, anim.flipY);
		}

		if (controller._prerotated != null)
		{
			createPrerotated();
		}

		if (controller.name != null)
		{
			name = controller.name;
		}

		frameIndex = controller.frameIndex;

		return this;
	}

	public function createPrerotated(?Controller:FlxAnimationController):Void
	{
		destroyAnimations();
		Controller = (Controller != null) ? Controller : this;
		_prerotated = new FlxPrerotatedAnimation(Controller, Controller._sprite.bakedRotationAngle);
		_prerotated.angle = _sprite.angle;
	}

	public function destroyAnimations():Void
	{
		clearAnimations();
		clearPrerotated();
	}

	public function destroy():Void
	{
		destroyAnimations();
		_animations = null;
		callback = null;
		_sprite = null;
	}

	@:allow(flixel.animation.FlxAnimation)
	function getFrameDuration(index:Int)
	{
		return _sprite.frames.frames[index].duration;
	}

	function clearPrerotated():Void
	{
		if (_prerotated != null)
		{
			_prerotated.destroy();
		}
		_prerotated = null;
	}

	function clearAnimations():Void
	{
		if (_animations != null)
		{
			var anim:FlxAnimation;
			for (key in _animations.keys())
			{
				anim = _animations.get(key);
				if (anim != null)
				{
					anim.destroy();
				}
			}
		}

		_animations = new Map<String, FlxAnimation>();
		_curAnim = null;
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param   name        What this animation should be called (e.g. `"run"`).
	 * @param   frames      An array of indices indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param   frameRate   The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   looped      Whether or not the animation is looped or just plays once.
	 * @param   flipX       Whether the frames should be flipped horizontally.
	 * @param   flipY       Whether the frames should be flipped vertically.
	 */
	public function add(name:String, frames:Array<Int>, frameRate = 30.0, looped = true, flipX = false, flipY = false):Void
	{
		if (numFrames == 0)
		{
			FlxG.log.warn('Could not create animation: "$name", this sprite has no frames');
			return;
		}
		
		// Check _animations frames
		var framesToAdd:Array<Int> = frames;
		var hasInvalidFrames = false;
		var i = framesToAdd.length;
		while (i-- >= 0)
		{
			final frame = framesToAdd[i];
			if (frame >= numFrames)
			{
				// log if frames are excluded
				hasInvalidFrames = true;
				
				// Splicing original Frames array could lead to unexpected results
				// So we are cloning it (only once) and will use its copy
				if (framesToAdd == frames)
					framesToAdd = frames.copy();

				framesToAdd.splice(i, 1);
			}
		}
		
		if (framesToAdd.length > 0)
		{
			var anim = new FlxAnimation(this, name, framesToAdd, frameRate, looped, flipX, flipY);
			_animations.set(name, anim);
			
			if (hasInvalidFrames)
				FlxG.log.warn('Could not add frames above ${numFrames - 1} to animation: "$name"');
		}
		else
			FlxG.log.warn('Could not create animation: "$name", no valid frames were given');
	}

	/**
	 * Removes (and destroys) an animation.
	 *
	 * @param   Name   The name of animation to remove.
	 */
	public function remove(Name:String):Void
	{
		var anim:FlxAnimation = _animations.get(Name);
		if (anim != null)
		{
			_animations.remove(Name);
			anim.destroy();
		}
	}

	/**
	 * Adds to an existing animation in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the indices of the frames in the atlas are already known.
	 * The animation must already exist in order to append frames to it.
	 *
	 * @param   name     What the existing animation is called (e.g. `"run"`).
	 * @param   frames   An array of indices indicating what frames to append (e.g. `[0, 1, 2]`).
	 */
	public function append(name:String, frames:Array<Int>):Void
	{
		final anim:FlxAnimation = _animations.get(name);
		if (anim == null)
		{
			// anim must already exist
			FlxG.log.warn('No animation called "$name"');
			return;
		}
		
		var hasInvalidFrames = false;

		// Check _animations frames
		for (frame in frames)
		{
			if (frame < numFrames)
				anim.frames.push(frame);
			else
				hasInvalidFrames = true;
		}
		
		if (hasInvalidFrames)
			FlxG.log.warn('Could not append frames above ${numFrames - 1} to animation: "$name"');
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param   Name         What this animation should be called (e.g. `"run"`).
	 * @param   FrameNames   An array of image names from the atlas indicating what frames to play in what order.
	 * @param   FrameRate    The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   Looped       Whether or not the animation is looped or just plays once.
	 * @param   FlipX        Whether the frames should be flipped horizontally.
	 * @param   FlipY        Whether the frames should be flipped vertically.
	 */
	public function addByNames(Name:String, FrameNames:Array<String>, FrameRate:Float = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void
	{
		if (_sprite.frames != null)
		{
			var indices:Array<Int> = new Array<Int>();
			byNamesHelper(indices, FrameNames); // finds frames and appends them to the blank array

			if (indices.length > 0)
			{
				var anim = new FlxAnimation(this, Name, indices, FrameRate, Looped, FlipX, FlipY);
				_animations.set(Name, anim);
			}
		}
	}

	/**
	 * Adds to an existing animation in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the exact name of each frame from the atlas is known (e.g. `"walk00.png"`, `"walk01.png"`).
	 * The animation must already exist in order to append frames to it.
	 *
	 * @param   Name         What the existing animation is called (e.g. `"run"`).
	 * @param   FrameNames   An array of image names from atlas indicating what frames to append.
	 */
	public function appendByNames(name:String, frameNames:Array<String>):Void
	{
		final anim:FlxAnimation = _animations.get(name);
		if (anim == null)
		{
			FlxG.log.warn('No animation called "$name"');
			return;
		}

		if (_sprite.frames != null)
		{
			byNamesHelper(anim.frames, frameNames); // finds frames and appends them to the existing array
		}
	}

	/**
	 * Adds a new animation to the sprite. Should be slightly faster than `addByIndices()`.
	 *
	 * @param   Name        What this animation should be called (e.g. `"run"`).
	 * @param   Prefix      Common beginning of image names in the atlas (e.g. `"tiles-"`).
	 * @param   Indices     An array of strings indicating what frames to play in what order
	 *                      (e.g. `["01", "02", "03"]`).
	 * @param   Postfix     Common ending of image names in atlas (e.g. `".png"`).
	 * @param   FrameRate   The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   Looped      Whether or not the animation is looped or just plays once.
	 * @param   FlipX       Whether the frames should be flipped horizontally.
	 * @param   FlipY       Whether the frames should be flipped vertically.
	 */
	public function addByStringIndices(Name:String, Prefix:String, Indices:Array<String>, Postfix:String, FrameRate:Float = 30, Looped:Bool = true,
			FlipX:Bool = false, FlipY:Bool = false):Void
	{
		if (_sprite.frames != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			// finds frames and appends them to the blank array
			byStringIndicesHelper(frameIndices, Prefix, Indices, Postfix);

			if (frameIndices.length > 0)
			{
				var anim:FlxAnimation = new FlxAnimation(this, Name, frameIndices, FrameRate, Looped, FlipX, FlipY);
				_animations.set(Name, anim);
			}
		}
	}

	/**
	 * Adds to an existing animation in the sprite by appending the specified frames to the existing frames.
	 * Should be slightly faster than `appendByIndices()`. Use this method when the names of each frame from
	 * the atlas share a common prefix and postfix (e.g. `"walk00.png"`, `"walk01.png"`).
	 * The animation must already exist in order to append frames to it. FrameRate and Looped are unchanged.
	 *
	 * @param   name     What the existing animation is called (e.g. `"run"`).
	 * @param   prefix   Common beginning of image names in the atlas (e.g. `"tiles-"`).
	 * @param   indices  An array of strings indicating what frames to append (e.g. `["01", "02", "03"]`).
	 * @param   suffix   Common ending of image names in atlas (e.g. `".png"`).
	 */
	public function appendByStringIndices(name:String, prefix:String, indices:Array<String>, suffix:String):Void
	{
		final anim:FlxAnimation = _animations.get(name);
		if (anim == null)
		{
			FlxG.log.warn('No animation called "$name"');
			return;
		}

		if (_sprite.frames != null)
		{
			// finds frames and appends them to the existing array
			byStringIndicesHelper(anim.frames, prefix, indices, suffix);
		}
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param   Name        What this animation should be called (e.g. `"run"`).
	 * @param   Prefix      Common beginning of image names in the atlas (e.g. "tiles-").
	 * @param   Indices     An array of numbers indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param   Postfix     Common ending of image names in the atlas (e.g. `".png"`).
	 * @param   FrameRate   The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   Looped      Whether or not the animation is looped or just plays once.
	 * @param   FlipX       Whether the frames should be flipped horizontally.
	 * @param   FlipY       Whether the frames should be flipped vertically.
	 */
	public function addByIndices(Name:String, Prefix:String, Indices:Array<Int>, Postfix:String, FrameRate:Float = 30, Looped:Bool = true, FlipX:Bool = false,
			FlipY:Bool = false):Void
	{
		if (_sprite.frames != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			// finds frames and appends them to the blank array
			byIndicesHelper(frameIndices, Prefix, Indices, Postfix);

			if (frameIndices.length > 0)
			{
				var anim:FlxAnimation = new FlxAnimation(this, Name, frameIndices, FrameRate, Looped, FlipX, FlipY);
				_animations.set(Name, anim);
			}
		}
	}

	/**
	 * Adds to an existing animation in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the names of each frame from the atlas share a common prefix
	 * and postfix (e.g. `"walk00.png"`, `"walk01.png"`).
	 * Leading zeroes are ignored for matching indices (`5` will match `"5"` and `"005"`).
	 * The animation must already exist in order to append frames to it.
	 *
	 * @param   name     What the existing animation is called (e.g. `"run"`).
	 * @param   prefix   Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @param   indices  An array of numbers indicating what frames to append (e.g. `[0, 1, 2]`).
	 * @param   suffix   Common ending of image names in atlas (e.g. `".png"`).
	 */
	public function appendByIndices(name:String, prefix:String, indices:Array<Int>, suffix:String):Void
	{
		final anim:FlxAnimation = _animations.get(name);
		if (anim == null)
		{
			FlxG.log.warn('No animation called "$name"');
			return;
		}

		if (_sprite.frames != null)
		{
			// finds frames and appends them to the existing array
			byIndicesHelper(anim.frames, prefix, indices, suffix);
		}
	}

	/**
	 * Find a sprite frame so that for `Prefix = "file"; Index = 5; Postfix = ".png"`
	 * It will find frame with name `"file5.png"`. If it doesn't exist it will try
	 * to find `"file05.png"`, allowing 99 frames per animation.
	 * Returns the found frame or `-1` on failure.
	 */
	function findSpriteFrame(prefix:String, index:Int, postfix:String):Int
	{
		final frames = _sprite.frames.frames;
		for (i in 0...frames.length)
		{
			final frame = frames[i];
			final name = frame.name;
			if (name.startsWith(prefix) && name.endsWith(postfix))
			{
				final frameIndex:Null<Int> = Std.parseInt(name.substring(prefix.length, name.length - postfix.length));
				if (frameIndex == index)
					return i;
			}
		}

		return -1;
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param   name        What this animation should be called (e.g. `"run"`).
	 * @param   prefix      Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @param   frameRate   The animation speed in frames per second.
	 *                      Note: individual frames have their own duration, which overrides this value.
	 * @param   looped      Whether or not the animation is looped or just plays once.
	 * @param   flipX       Whether the frames should be flipped horizontally.
	 * @param   flipY       Whether the frames should be flipped vertically.
	 */
	public function addByPrefix(name:String, prefix:String, frameRate = 30.0, looped = true, flipX = false, flipY = false):Void
	{
		if (_sprite.frames != null)
		{
			final animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			findByPrefix(animFrames, prefix); // adds valid frames to animFrames
			
			if (animFrames.length > 0)
			{
				final frameIndices:Array<Int> = [];
				byPrefixHelper(frameIndices, animFrames, prefix); // finds frames and appends them to the blank array
				final anim = new FlxAnimation(this, name, frameIndices, frameRate, looped, flipX, flipY);
				_animations.set(name, anim);
			}
			else
				FlxG.log.warn('Could not create animation: "$name", no frames were found with the prefix "$prefix" ');
		}
	}

	/**
	 * Adds to an existing animation in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the names of each frame from the atlas share a common prefix
	 * (e.g. `"walk00.png"`, `"walk01.png"`).
	 * Frames are sorted numerically while ignoring postfixes (e.g. `".png"`, `".gif"`).
	 * The animation must already exist in order to append frames to it.
	 *
	 * @param   name     What the existing animation is called (e.g. `"run"`).
	 * @param   prefix   Common beginning of image names in atlas (e.g. `"tiles-"`)
	 */
	public function appendByPrefix(name:String, prefix:String):Void
	{
		final anim:FlxAnimation = _animations.get(name);
		if (anim == null)
		{
			FlxG.log.warn('No animation called "$name"');
			return;
		}

		if (_sprite.frames != null)
		{
			final animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			findByPrefix(animFrames, prefix); // adds valid frames to animFrames
			
			if (animFrames.length > 0)
			{
				// finds frames and appends them to the existing array
				byPrefixHelper(anim.frames, animFrames, prefix);
			}
			else
				FlxG.log.warn('Could not append to animation: "$name", no frames were found with the prefix: "$prefix"');
		}
	}

	/**
	 * Plays an existing animation (e.g. `"run"`).
	 * If you call an animation that is already playing, it will be ignored.
	 *
	 * @param   animName   The string name of the animation you want to play.
	 * @param   force      Whether to force the animation to restart.
	 * @param   reversed   Whether to play animation backwards or not.
	 * @param   frame      The frame number in the animation you want to start from.
	 *                     If a negative value is passed, a random frame is used.
	 */
	public function play(animName:String, force = false, reversed = false, frame = 0):Void
	{
		if (animName == null)
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
			}
			_curAnim = null;
		}

		if (animName == null || _animations.get(animName) == null)
		{
			FlxG.log.warn('No animation called "$animName"');
			return;
		}

		var oldFlipX:Bool = false;
		var oldFlipY:Bool = false;

		if (_curAnim != null && animName != _curAnim.name)
		{
			oldFlipX = _curAnim.flipX;
			oldFlipY = _curAnim.flipY;
			_curAnim.stop();
		}
		_curAnim = _animations.get(animName);
		_curAnim.play(force, reversed, frame);

		if (oldFlipX != _curAnim.flipX || oldFlipY != _curAnim.flipY)
		{
			_sprite.dirty = true;
		}
	}

	/**
	 * Stops current animation and resets its frame index to zero.
	 */
	public inline function reset():Void
	{
		if (_curAnim != null)
		{
			_curAnim.reset();
		}
	}

	/**
	 * Stops current animation and sets its frame to the last one.
	 */
	public function finish():Void
	{
		if (_curAnim != null)
		{
			_curAnim.finish();
		}
	}

	/**
	 * Just stops current animation.
	 */
	public function stop():Void
	{
		if (_curAnim != null)
		{
			_curAnim.stop();
		}
	}

	/**
	 * Pauses the current animation.
	 */
	public inline function pause():Void
	{
		if (_curAnim != null)
		{
			_curAnim.pause();
		}
	}

	/**
	 * Resumes the current animation if it exists.
	 */
	public inline function resume():Void
	{
		if (_curAnim != null)
		{
			_curAnim.resume();
		}
	}

	/**
	 * Reverses current animation if it exists.
	 */
	public inline function reverse():Void
	{
		if (_curAnim != null)
		{
			_curAnim.reverse();
		}
	}

	/**
	 * Gets the FlxAnimation object with the specified name.
	 */
	public inline function getByName(name:String):FlxAnimation
	{
		return _animations.get(name);
	}

	/**
	 * Changes to a random animation frame.
	 * Useful for instantiating particles or other weird things.
	 */
	public function randomFrame():Void
	{
		if (_curAnim != null)
		{
			_curAnim.stop();
			_curAnim = null;
		}
		frameIndex = FlxG.random.int(0, numFrames - 1);
	}

	inline function fireCallback():Void
	{
		if (callback != null)
		{
			var name:String = (_curAnim != null) ? (_curAnim.name) : null;
			var number:Int = (_curAnim != null) ? (_curAnim.curFrame) : frameIndex;
			callback(name, number, frameIndex);
		}
	}

	@:allow(flixel.animation)
	inline function fireFinishCallback(?name:String):Void
	{
		if (finishCallback != null)
		{
			finishCallback(name);
		}
	}

	function byNamesHelper(addTo:Array<Int>, frameNames:Array<String>):Void
	{
		for (frameName in frameNames)
		{
			if (_sprite.frames.exists(frameName))
			{
				var frameToAdd = _sprite.frames.getByName(frameName);
				addTo.push(getFrameIndex(frameToAdd));
			}
		}
	}

	function byStringIndicesHelper(addTo:Array<Int>, prefix:String, indices:Array<String>, suffix:String):Void
	{
		for (index in indices)
		{
			final name = prefix + index + suffix;
			if (_sprite.frames.exists(name))
			{
				final frameToAdd = _sprite.frames.getByName(name);
				addTo.push(getFrameIndex(frameToAdd));
			}
		}
	}

	function byIndicesHelper(addTo:Array<Int>, prefix:String, indices:Array<Int>, suffix:String):Void
	{
		for (index in indices)
		{
			final indexToAdd = findSpriteFrame(prefix, index, suffix);
			if (indexToAdd != -1)
				addTo.push(indexToAdd);
		}
	}

	function byPrefixHelper(addTo:Array<Int>, frames:Array<FlxFrame>, prefix:String):Void
	{
		final name = frames[0].name;
		final postIndex = name.indexOf(".", prefix.length);
		final postFix = name.substring(postIndex == -1 ? name.length : postIndex, name.length);
		FlxFrame.sort(frames, prefix.length, postFix.length);
		
		for (frame in frames)
		{
			addTo.push(getFrameIndex(frame));
		}
	}

	function findByPrefix(animFrames:Array<FlxFrame>, prefix:String, logError = true):Void
	{
		for (frame in _sprite.frames.frames)
		{
			if (frame.name != null && frame.name.startsWith(prefix))
			{
				animFrames.push(frame);
			}
		}
		
		// prevent and log errors for invalid frames
		final invalidFrames = removeInvalidFrames(animFrames);
		#if FLX_DEBUG
		if (invalidFrames.length == 0 || !logError)
			return;
		
		final names = invalidFrames.map((f)->'"${f.name}"').join(", ");
		FlxG.log.error('Attempting to use frames that belong to a destroyed graphic, frame names: $names');
		#end
	}
	
	function removeInvalidFrames(frames:Array<FlxFrame>)
	{
		final invalid:Array<FlxFrame> = [];
		var i = frames.length;
		while (i-- > 0)
		{
			final frame = frames[i];
			if (frame.parent.shader == null)
				invalid.unshift(frames.splice(i, 1)[0]);
		}
		
		return invalid;
	}

	function set_frameIndex(Frame:Int):Int
	{
		if (_sprite.frames != null && numFrames > 0)
		{
			Frame = Frame % numFrames;
			_sprite.frame = _sprite.frames.frames[Frame];
			frameIndex = Frame;
			fireCallback();
		}

		return frameIndex;
	}

	inline function get_frameName():String
	{
		return _sprite.frame.name;
	}

	function set_frameName(Value:String):String
	{
		if (_sprite.frames != null && _sprite.frames.exists(Value))
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
				_curAnim = null;
			}

			var frame = _sprite.frames.getByName(Value);
			if (frame != null)
			{
				frameIndex = getFrameIndex(frame);
			}
		}

		return Value;
	}

	function get_name():String
	{
		var animName:String = null;
		if (_curAnim != null)
		{
			animName = _curAnim.name;
		}
		return animName;
	}

	function set_name(AnimName:String):String
	{
		play(AnimName);
		return AnimName;
	}

	/**
	 * Gets a list with all the animations that are added in a sprite.
	 * WARNING: Do not confuse with `getNameList`, this function returns the animation instances
	 * @return an array with all the animations.
	 * @since 4.11.0
	 */
	public function getAnimationList():Array<FlxAnimation>
	{
		var animList:Array<FlxAnimation> = [];

		for (anims in _animations)
		{
			animList.push(anims);
		}

		return animList;
	}

	/**
	 * Gets a list with all the name animations that are added in a sprite
	 * WARNING: Do not confuse with `getAnimationList`, this function returns the animation names
	 * @return an array with all the animation names in it.
	 * @since 4.11.0
	 */
	public function getNameList():Array<String>
	{
		var namesList:Array<String> = [];
		for (names in _animations.keys())
		{
			namesList.push(names);
		}

		return namesList;
	}

	/**
	 * Checks if an animation exists by it's name.
	 * @param name The animation name.
	 * @since 4.11.0
	 */
	public function exists(name:String):Bool
	{
		return _animations.exists(name);
	}

	/**
	 * Renames the animation with a new name.
	 * @param oldName the name that is replaced.
	 * @param newName the name that replaces the old one.
	 * @since 4.11.0
	 */
	public function rename(oldName:String, newName:String)
	{
		var anim = _animations.get(oldName);
		if (anim == null)
		{
			FlxG.log.warn('No animation called "$oldName"');
			return;
		}
		_animations.set(newName, anim);
		anim.name = newName;
		_animations.remove(oldName);
	}

	inline function get_curAnim():FlxAnimation
	{
		return _curAnim;
	}

	inline function set_curAnim(anim:FlxAnimation):FlxAnimation
	{
		if (anim != _curAnim)
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
			}

			if (anim != null)
			{
				anim.play();
			}
		}
		return _curAnim = anim;
	}

	inline function get_paused():Bool
	{
		var paused = false;
		if (_curAnim != null)
		{
			paused = _curAnim.paused;
		}
		return paused;
	}

	inline function set_paused(value:Bool):Bool
	{
		if (_curAnim != null)
		{
			if (value)
			{
				_curAnim.pause();
			}
			else
			{
				_curAnim.resume();
			}
		}
		return value;
	}

	function get_finished():Bool
	{
		var finished = true;
		if (_curAnim != null)
		{
			finished = _curAnim.finished;
		}
		return finished;
	}

	inline function set_finished(value:Bool):Bool
	{
		if (value && _curAnim != null)
		{
			_curAnim.finish();
		}
		return value;
	}

	inline function get_frames():Int
	{
		return _sprite.numFrames;
	}

	inline function get_numFrames():Int
	{
		return _sprite.numFrames;
	}

	/**
	 * Helper function used for finding index of `FlxFrame` in `_framesData`'s frames array
	 *
	 * @param   Frame   `FlxFrame` to find
	 * @return  position of specified `FlxFrame` object.
	 */
	public inline function getFrameIndex(frame:FlxFrame):Int
	{
		return _sprite.frames.frames.indexOf(frame);
	}
}
