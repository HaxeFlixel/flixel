package flixel.animation;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxRandom;

class FlxAnimationController  
{
	/**
	 * Property access for currently playing FlxAnimation (warning: can be null).
	 */
	public var curAnim(get, set):FlxAnimation;
	
	/**
	 * Tell the sprite to change to a specific frame of the _curAnim.
	 */
	@:isVar public var frameIndex(default, set):Int = 0;
	
	/**
	 * Tell the sprite to change to a frame with specific name.
	 * Useful for sprites with loaded TexturePacker atlas.
	 */
	public var frameName(get, set):String;
	
	/**
	 * Gets or sets the currently playing _animations (warning: can be null).
	 */
	public var name(get, set):String;
	
	/**
	 * Pause & resume _curAnim.
	 */
	public var paused(get, set):Bool;
	
	/**
	 * Returns whether an _animations is finished playing.
	 */
	public var finished(get, set):Bool;
	
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var frames(get, null):Int;
	
	/**
	 * If assigned, will be called each time the current frame changes.
	 * A function that has 3 parameters: a string name, a frame number, and a frame index.
	 */
	public var callback:String->Int->Int->Void;
	
	/**
	 * Internal, reference to owner sprite.
	 */
	private var _sprite:FlxSprite;
	
	/**
	 * Internal, currently playing animation.
	 */
	@:allow(flixel.animation) private var _curAnim:FlxAnimation;
	
	/**
	 * Internal, store all the _animations that were added to this sprite.
	 */
	private var _animations(default, null):Map<String, FlxAnimation>;
	/**
	 * Internal helper constants used for _animations's frame sorting.
	 */
	private static var prefixLength:Int = 0;
	private static var postfixLength:Int = 0;
	
	private var _prerotated:FlxPrerotatedAnimation;
	
	public function new(Sprite:FlxSprite)
	{
		_sprite = Sprite;
		_animations = new Map<String, FlxAnimation>();
	}
	
	public function update():Void
	{
		if (_curAnim != null)
		{
			_curAnim.update();
		}
		else if (_prerotated != null)
		{
			_prerotated.angle = _sprite.angle;
		}
	}
	
	public function clone(controller:FlxAnimationController):FlxAnimationController
	{
		for (anim in controller._animations)
		{
			add(anim.name, anim._frames, anim.frameRate, anim.looped);
		}
		
		if (controller._prerotated != null)
		{
			createPrerotated();
		}
		
		name = controller.name;
		frameIndex = controller.frameIndex;
		
		return this;
	}
	
	public function createPrerotated(Controller:FlxAnimationController = null):Void
	{
		destroyAnimations();
		Controller = (Controller != null) ? Controller : this;
		_prerotated = new FlxPrerotatedAnimation(Controller, Controller._sprite.bakedRotation);
	}
	
	public function destroyAnimations():Void
	{
		clear_animations();
		clear_prerotated();
	}
	
	public function destroy():Void
	{
		destroyAnimations();
		_animations = null;
		callback = null;
		_sprite = null;
	}
	
	private function clear_prerotated():Void
	{
		if (_prerotated != null)
		{
			_prerotated.destroy();
		}
		_prerotated = null;
	}
	
	private function clear_animations():Void
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
	
	/**
	 * Gets an animation by name
	 * @param	Name		The name of the animation.
	 * @return	Animation	FlxAnimation object with the specified name.
	 */
	public function get(Name:String):FlxAnimation
	{
		return _animations.get(Name);
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name		What this animation should be called (e.g. "run").
	 * @param	Frames		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	FrameRate	The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped		Whether or not the _animations is looped or just plays once.
	 */
	public function add(Name:String, Frames:Array<Int>, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		// Check _animations frames
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
			var anim:FlxAnimation = new FlxAnimation(this, Name, Frames, FrameRate, Looped);
			_animations.set(Name, anim);
		}
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	FrameNames		An array of image names from atlas indicating what frames to play in what order.
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
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
				var anim:FlxAnimation = new FlxAnimation(this, Name, indices, FrameRate, Looped);
				_animations.set(Name, anim);
			}
		}
	}
	
	/**
	 * Adds a new _animations to the sprite. Should works a little bit faster than addByIndicies()
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indicies		An array of strings indicating what frames to play in what order (e.g. ["01", "02", "03"]).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	public function addByStringIndicies(Name:String, Prefix:String, Indicies:Array<String>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true):Void
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
				var anim:FlxAnimation = new FlxAnimation(this, Name, frameIndices, FrameRate, Looped);
				_animations.set(Name, anim);
			}
		}
	}
	
	/**
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	Indicies		An array of numbers indicating what frames to play in what order (e.g. 1, 2, 3).
	 * @param	Postfix			Common ending of image names in atlas (e.g. ".png")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
	 */
	public function addByIndicies(Name:String, Prefix:String, Indicies:Array<Int>, Postfix:String, FrameRate:Int = 30, Looped:Bool = true):Void
	{
		if (_sprite.cachedGraphics != null && _sprite.cachedGraphics.data != null)
		{
			var frameIndices:Array<Int> = new Array<Int>();
			var l:Int = Indicies.length;
			for (i in 0...l)
			{
				var indexToAdd:Int = findSpriteFrame(Prefix, Indicies[i], Postfix);
				if (indexToAdd != -1) 
				{
					frameIndices.push(indexToAdd);
				}
			}
			
			if (frameIndices.length > 0)
			{
				var anim:FlxAnimation = new FlxAnimation(this, Name, frameIndices, FrameRate, Looped);
				_animations.set(Name, anim);
			}
		}
	}
	
	/**
	 * Find a sprite frame so that for Prefix = "file"; Indice = 5; Postfix = ".png"
	 * It will find frame with name "file5.png", but if it desn't exist it will try
	 * to find "file05.png" so allowing 99 frames per animation
	 * Returns found frame and null if nothing is found
	 */
	private function findSpriteFrame(Prefix:String, Index:Int, Postfix:String):Int
	{
		var numFrames:Int = frames;
		var flxFrames:Array<FlxFrame> = _sprite.framesData.frames;
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
	 * Adds a new _animations to the sprite.
	 * @param	Name			What this _animations should be called (e.g. "run").
	 * @param	Prefix			Common beginning of image names in atlas (e.g. "tiles-")
	 * @param	FrameRate		The speed in frames per second that the _animations should play at (e.g. 40 fps).
	 * @param	Looped			Whether or not the _animations is looped or just plays once.
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
				FlxAnimationController.prefixLength = Prefix.length;
				FlxAnimationController.postfixLength = postFix.length;
				animFrames.sort(FlxAnimationController.frameSortFunction);
				var frameIndices:Array<Int> = new Array<Int>();
				
				l = animFrames.length;
				for (i in 0...l)
				{
					frameIndices.push(getFrameIndex(animFrames[i]));
				}
				
				if (frameIndices.length > 0)
				{
					var anim:FlxAnimation = new FlxAnimation(this, Name, frameIndices, FrameRate, Looped);
					_animations.set(Name, anim);
				}
			}
		}
	}
	
	/**
	 * Plays an existing _animations (e.g. "run").
	 * If you call an _animations that is already playing it will be ignored.
	 * @param	AnimName	The string name of the _animations you want to play.
	 * @param	Force		Whether to force the _animations to restart.
	 * @param	Frame		The frame number in _animations you want to start from (0 by default). If you pass negative value then it will start from random frame
	 */
	public function play(AnimName:String, Force:Bool = false, Frame:Int = 0):Void
	{
		if (AnimName == null)
		{
			if (_curAnim != null)
			{
				_curAnim.stop();
			}
			_curAnim = null;
		}
		
		if (_animations.get(AnimName) == null)
		{
			FlxG.log.warn("No animation called \"" + AnimName + "\"");
			return;
		}
		
		if (_curAnim != null && AnimName != _curAnim.name)
		{
			_curAnim.stop();
		}
		_curAnim = _animations.get(AnimName);
		_curAnim.play(Force, Frame);
	}
	
	/**
	 * Pauses current _animations
	 */
	inline public function pause():Void
	{
		if (_curAnim != null)
		{
			_curAnim.paused = true;
		}
	}
	
	/**
	 * Resumes current _animations if it's exist
	 */
	inline public function resume():Void
	{
		if (_curAnim != null)
		{
			_curAnim.paused = false;
		}
	}
	
	/**
  	 * Gets the FlxAnim object with the specified name.
	*/
	inline public function getByName(Name:String):FlxAnimation
	{
		return _animations.get(Name); 
	}
	
	/**
	 * Tell the sprite to change to a random frame of _animations
	 * Useful for instantiating particles or other weird things.
	 */
	public function randomFrame():Void
	{
		if (_curAnim != null)
		{
			_curAnim.stop();
			_curAnim = null;
		}
		frameIndex = Std.int(Math.random() * frames);
	}
	
	private function set_frameIndex(Frame:Int):Int
	{
		if (_sprite.framesData != null)
		{
			Frame = Frame % frames;
			_sprite.frame = _sprite.framesData.frames[Frame];
			
			if (callback != null)
			{
				callback(((_curAnim != null) ? (_curAnim.name) : null), ((_curAnim != null) ? (_curAnim.curFrame) : Frame), Frame);
			}
		}
		
		return frameIndex = Frame;
	}
	
	inline private function get_frameName():String
	{
		return _sprite.frame.name;
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
			
			var frame = _sprite.framesData.framesHash.get(Value);
			if (frame != null)
			{
				frameIndex = getFrameIndex(frame);
			}
		}
		
		return Value;
	}
	
	/**
	 * Gets the name of the currently playing _animations (warning: can be null)
	 */
	inline private function get_name():String
	{
		var animName:String = null;
		if (_curAnim != null)
		{
			animName = _curAnim.name;
		}
		return animName;
	}
	
	/**
	 * Plays a specified _animations (same as calling play)
	 * @param	AnimName	The name of the _animations you want to play.
	 */
	inline private function set_name(AnimName:String):String
	{
		play(AnimName);
		return AnimName;
	}
	
	/**
	 * Gets the currently playing _animations (warning: can return null).
	 */
	inline private function get_curAnim():FlxAnimation
	{
		var anim:FlxAnimation = null;
		if ((_curAnim != null) && (_curAnim.delay > 0) && (_curAnim.looped || !_curAnim.finished))
		{
			anim = _curAnim;
		}
		return anim;
	}
	
	/**
	 * Plays a specified _animations (same as calling play)
	 * @param	AnimName	The name of the _animations you want to play.
	 */
	inline private function set_curAnim(Anim:FlxAnimation):FlxAnimation
	{
		if (Anim != null && Anim != _curAnim)
		{
			if (_curAnim != null) 
			{
				_curAnim.stop();
			}
			Anim.play();
		}
		return _curAnim = Anim;
	}
	
	inline private function get_paused():Bool
	{
		var paused:Bool = false;
		if (_curAnim != null)
		{
			paused = _curAnim.paused;
		}
		return paused;
	}
	
	inline private function set_paused(Value:Bool):Bool
	{
		if (_curAnim != null)
		{
			_curAnim.paused = Value;
		}
		return Value;
	}
	
	inline private function get_finished():Bool
	{
		var finished:Bool = true;
		if (_curAnim != null)
		{
			finished = _curAnim.finished;
		}
		return finished;
	}
	
	inline private function set_finished(Value:Bool):Bool
	{
		if (Value == true && _curAnim != null)
		{
			_curAnim.finished = true;
			frameIndex = _curAnim.numFrames - 1;
		}
		return Value;
	}
	
	inline private function get_frames():Int
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