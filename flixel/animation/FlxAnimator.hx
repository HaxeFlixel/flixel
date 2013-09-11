package flixel.animation;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxRandom;

class FlxAnimator  
{
	private var _sprite:FlxSprite;
	
	/**
	 * Internal, stores all the animations that were added to this sprite.
	 */
	private var _animations:Map<String, FlxAnimation>;
	/**
	 * Internal, keeps track of the current animation being played.
	 */
	private var _curAnim:FlxAnimation;
	
	/**
	 * Gets or sets the currently playing animation.
	 */
	public var animationName(get_animationName, set_animationName):String;
	
	public var animation(get, set):FlxAnimation;
	
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var frames(get, null):Int;
	
	/**
	 * Internal tracker for the animation callback.  Default is null.
	 * If assigned, will be called each time the current frame changes.
	 * A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
	 */
	public var callback:String->Int->Int->Void;
	
	private var _prerotated:FlxPrerotatedAnimation;
	
	public function new(Sprite:FlxSprite)
	{
		_sprite = Sprite;
		_animations = new Map<String, FlxAnimation>();
		_curAnim = null;
	}
	
	public function update():Void
	{
		if (_curAnim != null)
		{
			if (_curAnim.update())
			{
				_sprite.frame = _curAnim.curIndex;
				
				if (callback != null)
				{
					callback(((_curAnim != null) ? (_curAnim.name) : null), _curAnim.curFrame, _curAnim.curIndex);
				}
			}
		}
		else if (_prerotated != null)
		{
			if (_prerotated.update())
			{
				_sprite.frame = _prerotated.curIndex;
			}
		}
	}
	
	public function destroyAnimations():Void
	{
		clearAnimations();
		clearPrerotated();
	}
	
	private function clearPrerotated():Void
	{
		if (_prerotated != null)
		{
			_prerotated.destroy();
		}
		_prerotated = null;
	}
	
	private function clearAnimations():Void
	{
		if (_animations != null)
		{
			for (anim in _animations)
			{
				if (anim != null)
				{
					anim.destroy();
				}
			}
		}
		_curAnim = null;
	}
	
	public function destroy():Void
	{
		_sprite = null;
		destroyAnimations();
		_animations = null;
		callback = null;
	}
	
	public function clone(Sprite:FlxSprite):FlxAnimator
	{
		var animator:FlxAnimator = new FlxAnimator(Sprite);
		for (anim in _animations)
		{
			animator.add(anim.name, anim.frames, anim.frameRate, anim.looped);
		}
		
		if (_prerotated != null)
		{
			animator.createPrerotated();
		}
		
		return animator;
	}
	
	public function createPrerotated(Sprite:FlxSprite = null):Void
	{
		destroyAnimations();
		_prerotated = new FlxPrerotatedAnimation((Sprite != null) ? Sprite : _sprite);
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the animation is looped or just plays once.
	 */
	public function add(Name:String, Frames:Array<Int>, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		// Check animation frames
		var numFrames:Int = Frames.length - 1;
		var i:Int = numFrames;
		while (i >= 0)
		{
			if (Frames[i] >= frames)
			{
				Frames.splice(i, 1);
			}
			i--;
		}
		
		if (Frames.length > 0)
		{
			var anim:FlxAnimation = new FlxAnimation(_sprite, Name, Frames, FrameRate, Looped);
			_animations.set(Name, anim);
		}
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name			What this animation should be called (e.g. "run").
	 * @param	FrameNames		An array of image names from atlas indicating what frames to play in what order.
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the animation is looped or just plays once.
	 */
	public function addByNames(Name:String, FrameNames:Array<String>, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var indices:Array<Int> = new Array<Int>();
			var l:Int = FrameNames.length;
			for (i in 0...l)
			{
				var name:String = FrameNames[i];
				if (_sprite.framesData.framesHash.exists(name))
				{
					var frameToAdd:FlxFrame = _sprite.framesData.framesHash.get(name);
					indices.push(getFrameIndex(frameToAdd));
				}
			}
			
			if (indices.length > 0)
			{
				var anim:FlxAnimation = new FlxAnimation(_sprite, Name, indices, FrameRate, Looped);
				_animations.set(Name, anim);
			}
		}
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name			What this animation should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indicies		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the animation is looped or just plays once.
	 */
	public function addByIndicies(Name:String, Prefix:String, Indicies:Array<String>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			var l:Int = Indicies.length;
			for (i in 0...l)
			{
				var name:String = Prefix + Indicies[i] + Postfix;
				if (_sprite.framesData.framesHash.exists(name))
				{
					var frameToAdd:FlxFrame = _sprite.framesData.framesHash.get(name);
					frameIndices.push(getFrameIndex(frameToAdd));
				}
			}
			
			if (frameIndices.length > 0)
			{
				var anim:FlxAnimation = new FlxAnimation(_sprite, Name, frameIndices, FrameRate, Looped);
				_animations.set(Name, anim);
			}
		}
	}
	
	/**
	 * Adds a new animation to the sprite.
	 * @param	Name			What this animation should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	FrameRate		The speed in frames per second that the animation should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the animation is looped or just plays once.
	*/
	public function addByPrefix(Name:String, Prefix:String, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var animFrames:Array<FlxFrame> = new Array<FlxFrame>();
			var l:Int = _sprite.framesData.frames.length;
			for (i in 0...l)
			{
				if (StringTools.startsWith(_sprite.framesData.frames[i].name, Prefix))
				{
					animFrames.push(_sprite.framesData.frames[i]);
				}
			}
			
			if (animFrames.length > 0)
			{
				var name:String = animFrames[0].name;
				var postFix:String = name.substring(name.indexOf(".", Prefix.length), name.length);
				FlxAnimator.prefixLength = Prefix.length;
				FlxAnimator.postfixLength = postFix.length;
				animFrames.sort(FlxAnimator.frameSortFunction);
				var frameIndices:Array<Int> = new Array<Int>();
				
				l = animFrames.length;
				for (i in 0...l)
				{
					frameIndices.push(getFrameIndex(animFrames[i]));
				}
				
				if (frameIndices.length > 0)
				{
					var anim:FlxAnimation = new FlxAnimation(_sprite, Name, frameIndices, FrameRate, Looped);
					_animations.set(Name, anim);
				}
			}
		}
	}
	
	/**
	 * Plays an existing animation (e.g. "run").
	 * If you call an animation that is already playing it will be ignored.
	 * @param	AnimName	The string name of the animation you want to play.
	 * @param	Force		Whether to force the animation to restart.
	 * @param	Frame		The frame number in animation you want to start from (0 by default). If you pass negative value then it will start from random frame
	 */
	public function play(AnimName:String, Force:Bool = false, Frame:Int = 0):Void
	{
		if (!_animations.exists(AnimName))
		{
			FlxG.log.warn("No animation called \"" + AnimName + "\"");
			return;
		}
		
		if (_curAnim != null && AnimName != _curAnim.name)
		{
			_curAnim.stop();
		}
		
		if (!Force && (_curAnim != null) && (AnimName == _curAnim.name) && (_curAnim.looped || !_curAnim.finished)) 
		{
			_curAnim.paused = false;
			return;
		}
		
		_curAnim = _animations.get(AnimName);
		_curAnim.play(Force, Frame);
	}
	
	/**
	 * Sends the playhead to the specified frame in current animation and plays from that frame.
	 * @param	Frame	frame number in current animation
	 */
	public function gotoAndPlay(Frame:Int = 0):Void
	{
		if (_curAnim == null || _curAnim.frames.length <= Frame)
		{
			return;
		}
		
		_curAnim.play(true, Frame);
	}
	
	/**
	 * Sends the playhead to the specified frame in current animation and pauses it there.
	 * @param	Frame	frame number in current animation
	 */
	public function gotoAndPause(Frame:Int = 0):Void
	{
		if (_curAnim == null || _curAnim.frames.length <= Frame)
		{
			return;
		}
		
		_curAnim.curFrame = Frame;
		_curAnim.paused = true;
	}
	
	/**
	 * Pauses current animation
	 */
	inline public function pause():Void
	{
		if (_curAnim != null)
		{
			_curAnim.paused = true;
		}
	}
	
	/**
	 * Resumes current animation if it's exist
	 */
	inline public function resume():Void
	{
		if (_curAnim != null)
		{
			_curAnim.paused = false;
		}
	}
	
	public var finished(get, null):Bool;
	
	private function get_finished():Bool
	{
		if (_curAnim != null)
		{
			return _curAnim.finished;
		}
		
		return true;
	}
	
	public var paused(get, set):Bool;
	
	private function get_paused():Bool
	{
		if (_curAnim != null)
		{
			return _curAnim.paused;
		}
		
		return true;
	}
	
	private function set_paused(Value:Bool):Bool
	{
		pause();
		return Value;
	}
	
	/**
  	 * Gets the FlxAnim object with the specified name.
	*/
	inline public function getAnimation(Name:String):FlxAnimation
	{
		return _animations.get(Name); 
	}
	
	public var animations(get, never):Map<String, FlxAnimation>;
	
	private function get_animations():Map<String, FlxAnimation>
	{
		return _animations;
	}
	
	/**
	 * Tell the sprite to change to a random frame of animation
	 * Useful for instantiating particles or other weird things.
	 */
	public function randomFrame():Void
	{
		if (_curAnim != null)
		{
			_curAnim.stop();
			_curAnim = null;
		}
		_sprite.frame = Std.int(Math.random() * frames);
	}
	
	public var sprite(get_sprite, set_sprite):FlxSprite;
	
	function get_sprite():FlxSprite 
	{
		return _sprite;
	}
	
	function set_sprite(value:FlxSprite):FlxSprite 
	{
		_sprite = value;
		
		for (anim in _animations)
		{
			anim.sprite = value;
		}
		
		if (_prerotated != null)
		{
			_prerotated.sprite = value;
		}
		
		return value;
	}
	
	/**
	 * Tell the sprite to change to a specific frame of animation.
	 */
	public var frame(get, set):Int;
	
	private function get_frame():Int
	{
		return _sprite.frame;
	}
	
	private function set_frame(Frame:Int):Int
	{
		if (_curAnim != null)
		{
			_curAnim.stop();
			_curAnim = null;
		}
		
		if (Frame < 0)
		{
			Frame = Std.int(Math.random() * frames);
		}
		
		_sprite.frame = Frame % frames;
		return Frame;
	}
	
	/**
	 * Tell the sprite to change to a frame with specific name.
	 * Useful for sprites with loaded TexturePacker atlas.
	 */
	public var frameName(get, set):String;
	
	private function get_frameName():String
	{
		return _sprite.flxFrame.name;
	}
	
	private function set_frameName(Value:String):String
	{
		if (_sprite.framesData != null && _sprite.framesData.framesHash.exists(Value))
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
				_curAnim = null;
			}
			
			var flxFrame = _sprite.framesData.framesHash.get(Value);
			_sprite.frame = getFrameIndex(flxFrame);
		}
		
		return Value;
	}
	
	private function get_animationName():String
	{
		if ((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !_curAnim.finished))
		{
			return _curAnim.name;
		}
		return null;
	}
	
	/**
	 * Plays a specified animation (same as calling play)
	 * @param	AnimName	The name of the animation you want to play.
	 */
	inline private function set_animationName(AnimName:String):String
	{
		play(AnimName);
		return AnimName;
	}
	
	private function get_animation():FlxAnimation
	{
		if ((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !_curAnim.finished))
		{
			return _curAnim;
		}
		return null;
	}
	
	/**
	 * Plays a specified animation (same as calling play)
	 * @param	AnimName	The name of the animation you want to play.
	 */
	inline private function set_animation(Anim:FlxAnimation):FlxAnimation
	{
		play(Anim.name);
		return Anim;
	}
	
	private function get_frames():Int
	{
		return _sprite.frames;
	}
	
	/**
	 * Helper function used for finding index of FlxFrame in _framesData's frames array
	 * @param	Frame	FlxFrame to find
	 * @return	position of specified FlxFrame object.
	 */
	inline public function getFrameIndex(Frame:FlxFrame):Int
	{
		return FlxArrayUtil.indexOf(_sprite.framesData.frames, Frame);
	}
	
	/**
	 * Helper constants used for animation's frame sorting
	 */
	private static var prefixLength:Int = 0;
	private static var postfixLength:Int = 0;
	
	/**
	 * Helper frame sorting function used by addAnimationByPrefixFromTexture() method
	 */
	static function frameSortFunction(frame1:FlxFrame, frame2:FlxFrame):Int
	{
		var name1:String = frame1.name;
		var name2:String = frame2.name;
		
		var num1:Int = Std.parseInt(name1.substring(prefixLength, name1.length - postfixLength));
		var num2:Int = Std.parseInt(name2.substring(prefixLength, name2.length - postfixLength));
		
		if (num1 > num2)
		{
			return 1;
		}
		else if (num2 > num1)
		{
			return -1;
		}

		return 0;
	}
	
}