package flixel.animation;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

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
	var _animations(default, null):Map<String, FlxAnimation>;

	var _prerotated:FlxPrerotatedAnimation;

	public function new(Sprite:FlxSprite)
	{
		_sprite = Sprite;
		_animations = new Map<String, FlxAnimation>();
	}

	public function update(elapsed:Float):Void
	{
		if (_curAnim != null)
		{
			_curAnim.update(elapsed);
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
	 * @param   Name        What this animation should be called (e.g. `"run"`).
	 * @param   Frames      An array of indices indicating what frames to play in what order (e.g. `[0, 1, 2]`).
	 * @param   FrameRate   The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   Looped      Whether or not the animation is looped or just plays once.
	 * @param   FlipX       Whether the frames should be flipped horizontally.
	 * @param   FlipY       Whether the frames should be flipped vertically.
	 */
	public function add(Name:String, Frames:Array<Int>, FrameRate:Float = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void
	{
		// Check _animations frames
		var framesToAdd:Array<Int> = Frames;
		var numFrames:Int = framesToAdd.length - 1;
		var i:Int = numFrames;
		while (i >= 0)
		{
			if (framesToAdd[i] >= frames)
			{
				// Splicing original Frames array could lead to unexpected results
				// So we are cloning it (only once) and will use its copy
				if (framesToAdd == Frames)
				{
					framesToAdd = Frames.copy();
				}

				framesToAdd.splice(i, 1);
			}
			i--;
		}

		if (framesToAdd.length > 0)
		{
			var anim = new FlxAnimation(this, Name, framesToAdd, FrameRate, Looped, FlipX, FlipY);
			_animations.set(Name, anim);
		}
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
	 * @param   Name     What the existing animation is called (e.g. `"run"`).
	 * @param   Frames   An array of indices indicating what frames to append (e.g. `[0, 1, 2]`).
	 */
	public function append(Name:String, Frames:Array<Int>):Void
	{
		var anim:FlxAnimation = _animations.get(Name);
		if (anim == null)
		{
			// anim must already exist
			FlxG.log.warn("No animation called \"" + Name + "\"");
			return;
		}

		// Check _animations frames
		var numFrames:Int = Frames.length - 1;
		var i:Int = numFrames;
		while (i >= 0)
		{
			if (Frames[numFrames - i] < frames)
			{
				// add to existing animation, forward to backward
				anim.frames.push(Frames[numFrames - i]);
			}
			i--;
		}
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
	public function addByNames(Name:String, FrameNames:Array<String>, FrameRate:Int = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void
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
	public function appendByNames(Name:String, FrameNames:Array<String>):Void
	{
		var anim:FlxAnimation = _animations.get(Name);
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Name + "\"");
			return;
		}

		if (_sprite.frames != null)
		{
			byNamesHelper(anim.frames, FrameNames); // finds frames and appends them to the existing array
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
	public function addByStringIndices(Name:String, Prefix:String, Indices:Array<String>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true,
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
	 * @param   Name      What the existing animation is called (e.g. `"run"`).
	 * @param   Prefix    Common beginning of image names in the atlas (e.g. `"tiles-"`).
	 * @param   Indices   An array of strings indicating what frames to append (e.g. `["01", "02", "03"]`).
	 * @param   Postfix   Common ending of image names in atlas (e.g. `".png"`).
	 */
	public function appendByStringIndices(Name:String, Prefix:String, Indices:Array<String>, Postfix:String):Void
	{
		var anim:FlxAnimation = _animations.get(Name);
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Name + "\"");
			return;
		}

		if (_sprite.frames != null)
		{
			// finds frames and appends them to the existing array
			byStringIndicesHelper(anim.frames, Prefix, Indices, Postfix);
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
	public function addByIndices(Name:String, Prefix:String, Indices:Array<Int>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true, FlipX:Bool = false,
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
	 * @param   Name      What the existing animation is called (e.g. `"run"`).
	 * @param   Prefix    Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @param   Indices   An array of numbers indicating what frames to append (e.g. `[0, 1, 2]`).
	 * @param   Postfix   Common ending of image names in atlas (e.g. `".png"`).
	 */
	public function appendByIndices(Name:String, Prefix:String, Indices:Array<Int>, Postfix:String):Void
	{
		var anim:FlxAnimation = _animations.get(Name);
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Name + "\"");
			return;
		}

		if (_sprite.frames != null)
		{
			// finds frames and appends them to the existing array
			byIndicesHelper(anim.frames, Prefix, Indices, Postfix);
		}
	}

	/**
	 * Find a sprite frame so that for `Prefix = "file"; Index = 5; Postfix = ".png"`
	 * It will find frame with name `"file5.png"`. If it doesn't exist it will try
	 * to find `"file05.png"`, allowing 99 frames per animation.
	 * Returns the found frame or `-1` on failure.
	 */
	function findSpriteFrame(Prefix:String, Index:Int, Postfix:String):Int
	{
		var numFrames:Int = frames;
		var flxFrames:Array<FlxFrame> = _sprite.frames.frames;
		for (i in 0...numFrames)
		{
			var name:String = flxFrames[i].name;
			if (StringTools.startsWith(name, Prefix) && StringTools.endsWith(name, Postfix))
			{
				var index:Null<Int> = Std.parseInt(name.substring(Prefix.length, name.length - Postfix.length));
				if (index != null && index == Index)
				{
					return i;
				}
			}
		}

		return -1;
	}

	/**
	 * Adds a new animation to the sprite.
	 *
	 * @param   Name        What this animation should be called (e.g. `"run"`).
	 * @param   Prefix      Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @param   FrameRate   The speed in frames per second that the animation should play at (e.g. `40` fps).
	 * @param   Looped      Whether or not the animation is looped or just plays once.
	 * @param   FlipX       Whether the frames should be flipped horizontally.
	 * @param   FlipY       Whether the frames should be flipped vertically.
	 */
	public function addByPrefix(Name:String, Prefix:String, FrameRate:Int = 30, Looped:Bool = true, FlipX:Bool = false, FlipY:Bool = false):Void
	{
		if (_sprite.frames != null)
		{
			var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			findByPrefix(animFrames, Prefix); // adds valid frames to animFrames

			if (animFrames.length > 0)
			{
				var frameIndices:Array<Int> = new Array<Int>();
				byPrefixHelper(frameIndices, animFrames, Prefix); // finds frames and appends them to the blank array

				if (frameIndices.length > 0)
				{
					var anim:FlxAnimation = new FlxAnimation(this, Name, frameIndices, FrameRate, Looped, FlipX, FlipY);
					_animations.set(Name, anim);
				}
			}
		}
	}

	/**
	 * Adds to an existing animation in the sprite by appending the specified frames to the existing frames.
	 * Use this method when the names of each frame from the atlas share a common prefix
	 * (e.g. `"walk00.png"`, `"walk01.png"`).
	 * Frames are sorted numerically while ignoring postfixes (e.g. `".png"`, `".gif"`).
	 * The animation must already exist in order to append frames to it.
	 *
	 * @param   Name     What the existing animation is called (e.g. `"run"`).
	 * @param   Prefix   Common beginning of image names in atlas (e.g. `"tiles-"`)
	 */
	public function appendByPrefix(Name:String, Prefix:String):Void
	{
		var anim:FlxAnimation = _animations.get(Name);
		if (anim == null)
		{
			FlxG.log.warn("No animation called \"" + Name + "\"");
			return;
		}

		if (_sprite.frames != null)
		{
			var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			findByPrefix(animFrames, Prefix); // adds valid frames to animFrames

			if (animFrames.length > 0)
			{
				// finds frames and appends them to the existing array
				byPrefixHelper(anim.frames, animFrames, Prefix);
			}
		}
	}

	/**
	 * Plays an existing animation (e.g. `"run"`).
	 * If you call an animation that is already playing, it will be ignored.
	 *
	 * @param   AnimName   The string name of the animation you want to play.
	 * @param   Force      Whether to force the animation to restart.
	 * @param   Reversed   Whether to play animation backwards or not.
	 * @param   Frame      The frame number in the animation you want to start from.
	 *                     If a negative value is passed, a random frame is used.
	 */
	public function play(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == null)
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
			}
			_curAnim = null;
		}

		if (AnimName == null || _animations.get(AnimName) == null)
		{
			FlxG.log.warn("No animation called \"" + AnimName + "\"");
			return;
		}

		var oldFlipX:Bool = false;
		var oldFlipY:Bool = false;

		if (_curAnim != null && AnimName != _curAnim.name)
		{
			oldFlipX = _curAnim.flipX;
			oldFlipY = _curAnim.flipY;
			_curAnim.stop();
		}
		_curAnim = _animations.get(AnimName);
		_curAnim.play(Force, Reversed, Frame);

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
	public inline function getByName(Name:String):FlxAnimation
	{
		return _animations.get(Name);
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
		frameIndex = FlxG.random.int(0, frames - 1);
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

	function byNamesHelper(AddTo:Array<Int>, FrameNames:Array<String>):Void
	{
		for (frameName in FrameNames)
		{
			if (_sprite.frames.framesHash.exists(frameName))
			{
				var frameToAdd:FlxFrame = _sprite.frames.framesHash.get(frameName);
				AddTo.push(getFrameIndex(frameToAdd));
			}
		}
	}

	function byStringIndicesHelper(AddTo:Array<Int>, Prefix:String, Indices:Array<String>, Postfix:String):Void
	{
		for (index in Indices)
		{
			var name:String = Prefix + index + Postfix;
			if (_sprite.frames.framesHash.exists(name))
			{
				var frameToAdd:FlxFrame = _sprite.frames.framesHash.get(name);
				AddTo.push(getFrameIndex(frameToAdd));
			}
		}
	}

	function byIndicesHelper(AddTo:Array<Int>, Prefix:String, Indices:Array<Int>, Postfix:String):Void
	{
		for (index in Indices)
		{
			var indexToAdd:Int = findSpriteFrame(Prefix, index, Postfix);
			if (indexToAdd != -1)
			{
				AddTo.push(indexToAdd);
			}
		}
	}

	function byPrefixHelper(AddTo:Array<Int>, AnimFrames:Array<FlxFrame>, Prefix:String):Void
	{
		var name:String = AnimFrames[0].name;
		var postIndex:Int = name.indexOf(".", Prefix.length);
		var postFix:String = name.substring(postIndex == -1 ? name.length : postIndex, name.length);
		FlxFrame.sort(AnimFrames, Prefix.length, postFix.length);

		for (animFrame in AnimFrames)
		{
			AddTo.push(getFrameIndex(animFrame));
		}
	}

	function findByPrefix(AnimFrames:Array<FlxFrame>, Prefix:String):Void
	{
		for (frame in _sprite.frames.frames)
		{
			if (frame.name != null && StringTools.startsWith(frame.name, Prefix))
			{
				AnimFrames.push(frame);
			}
		}
	}

	function set_frameIndex(Frame:Int):Int
	{
		if (_sprite.frames != null && frames > 0)
		{
			Frame = Frame % frames;
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
		if (_sprite.frames != null && _sprite.frames.framesHash.exists(Value))
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
				_curAnim = null;
			}

			var frame = _sprite.frames.framesHash.get(Value);
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

	inline function set_curAnim(Anim:FlxAnimation):FlxAnimation
	{
		if (Anim != _curAnim)
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
			}

			if (Anim != null)
			{
				Anim.play();
			}
		}
		return _curAnim = Anim;
	}

	inline function get_paused():Bool
	{
		var paused:Bool = false;
		if (_curAnim != null)
		{
			paused = _curAnim.paused;
		}
		return paused;
	}

	inline function set_paused(Value:Bool):Bool
	{
		if (_curAnim != null)
		{
			if (Value)
			{
				_curAnim.pause();
			}
			else
			{
				_curAnim.resume();
			}
		}
		return Value;
	}

	function get_finished():Bool
	{
		var finished:Bool = true;
		if (_curAnim != null)
		{
			finished = _curAnim.finished;
		}
		return finished;
	}

	inline function set_finished(Value:Bool):Bool
	{
		if (Value && _curAnim != null)
		{
			_curAnim.finish();
		}
		return Value;
	}

	inline function get_frames():Int
	{
		return _sprite.numFrames;
	}

	/**
	 * Helper function used for finding index of `FlxFrame` in `_framesData`'s frames array
	 *
	 * @param   Frame   `FlxFrame` to find
	 * @return  position of specified `FlxFrame` object.
	 */
	public inline function getFrameIndex(Frame:FlxFrame):Int
	{
		return _sprite.frames.frames.indexOf(Frame);
	}
}
