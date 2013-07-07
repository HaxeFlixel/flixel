package flixel.animation;

import flixel.FlxSprite;
import flixel.system.FlxAnim;

class FlxAnimator  
{
	private var _sprite:FlxSprite;
	
	/**
	 * Internal, stores all the animations that were added to this sprite.
	 */
	private var _animations:Map<String, FlxAnim>;
	/**
	 * Internal, keeps track of the current animation being played.
	 */
	private var _curAnim:FlxAnim;
	
	/**
	 * The total number of frames in this image.  WARNING: assumes each row in the sprite sheet is full!
	 */
	public var frames(default, null):Int;
	/**
	 * Internal, keeps track of the current index into the tile sheet based on animation or rotation.
	 */
	private var _curIndex:Int;
	/**
	 * Internal tracker for the animation callback.  Default is null.
	 * If assigned, will be called each time the current frame changes.
	 * A function that has 3 parameters: a string name, a uint frame number, and a uint frame index.
	 */
	private var _callback:String->Int->Int->Void;
	
	/**
	 * Gets or sets the currently playing animation.
	 */
	public var curAnim(get_curAnim, set_curAnim):String;
	
	public function new(Sprite:FlxSprite)
	{
		_sprite = Sprite;
		_animations = new Map<String, FlxAnim>();
		_curAnim = null;
		_curIndex = 0;
	}
	
	public function update():Void
	{
		
	}
	
	public function destroy():Void
	{
		_sprite = null;
		
		if (_animations != null)
		{
			for (anim in _animations)
			{
				if (anim != null)
				{
					anim.destroy();
				}
			}
			_animations = null;
		}
		
		_curAnim = null;
		_callback = null;
		
	}
	
}