package org.flixel.tweens;

import org.flixel.tweens.util.Ease;
import org.flixel.FlxBasic;

typedef CompleteCallback = Void->Void;

/**
 * Friend class for access to Tween private members
 */
typedef FriendTween = {
	private function finish():Void;

	private var _finish:Bool;
	private var _parent:FlxBasic;
	private var _prev:FriendTween;
	private var _next:FriendTween;
}

class FlxTween
{
	/**
	* Persistent Tween type, will stop when it finishes.
	*/
	public static inline var PERSIST:Int = 1;

	/**
	* Looping Tween type, will restart immediately when it finishes.
	*/
	public static inline var LOOPING:Int = 2;
	
	/**
	 * "To and from" Tween type, will play tween hither and thither
	 */
	public static inline var PINGPONG:Int = 4;

	/**
	* Oneshot Tween type, will stop and remove itself from its core container when it finishes.
	*/
	public static inline var ONESHOT:Int = 8;
	
	/**
	 * Backward Tween type, will play tween in reverse direction
	 */
	public static inline var BACKWARD:Int = 16;
	
	public var active:Bool;
	public var complete:CompleteCallback;

	/**
	 * Constructor. Specify basic information about the Tween.
	 * @param	duration		Duration of the tween (in seconds or frames).
	 * @param	type			Tween type, one of Tween.PERSIST (default), Tween.LOOPING, or Tween.ONESHOT.
	 * @param	complete		Optional callback for when the Tween completes.
	 * @param	ease			Optional easer function to apply to the Tweened value.
	 */
	public function new(duration:Float, type:Int = 0, complete:CompleteCallback = null, ease:EaseFunction = null)
	{
		_target = duration;
		if (type == 0) 
		{
			type = FlxTween.PERSIST;
		}
		else if (type == FlxTween.BACKWARD)
		{
			type = FlxTween.PERSIST | FlxTween.BACKWARD;
		}
		_type = type;
		this.complete = complete;
		_ease = ease;
		_t = 0;
		
		_backward = (_type & BACKWARD) > 0;
	}
	
	public function destroy():Void
	{
		complete = null;
		_parent = null;
		_ease = null;
	}

	/**
	 * Updates the Tween, called by World.
	 */
	public function update():Void
	{
		_time += FlxG.elapsed;
		_t = _time / _target;
		if (_ease != null)
		{
			_t = _ease(_t);
		}
		if (_backward)
		{
			_t = 1 - _t;
		}
		if (_time >= _target)
		{
			if (!_backward)
			{
				_t = 1;
			}
			else
			{
				_t = 0;
			}
			_finish = true;
		}
	}

	/**
	 * Starts the Tween, or restarts it if it's currently running.
	 */
	public function start():Void
	{
		_time = 0;
		if (_target == 0)
		{
			active = false;
			return;
		}
		active = true;
	}
	
	/**
	 * Immediately stops the Tween and removes it from its Tweener without calling the complete callback.
	 */
	public function cancel():Void
	{
		active = false;
		if (_parent != null)
		{
			_parent.removeTween(this);
		}
	}

	/** @private Called when the Tween completes. */
	private function finish():Void
	{
		if (complete != null) complete();
		
		switch ((_type & ~ FlxTween.BACKWARD))
		{
			case FlxTween.PERSIST:
				_time = _target;
				active = false;
			case FlxTween.LOOPING:
				_time %= _target;
				_t = _time / _target;
				if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
				start();
			case FlxTween.PINGPONG:
				_time %= _target;
				_t = _time / _target;
				if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
				if (_backward) _t = 1 - _t;
				_backward = !_backward;
				start();
			case FlxTween.ONESHOT:
				_time = _target;
				active = false;
				_parent.removeTween(this, true);
		}
		_finish = false;
	}

	public var percent(get_percent, set_percent):Float;
	private function get_percent():Float { return _time / _target; }
	private function set_percent(value:Float):Float { _time = _target * value; return _time; }

	public var scale(get_scale, null):Float;
	private function get_scale():Float { return _t; }

	private var _type:Int;
	private var _ease:EaseFunction;
	private var _t:Float;

	private var _time:Float;
	private var _target:Float;

	private var _finish:Bool;
	private var _parent:FlxBasic;
	private var _prev:FriendTween;
	private var _next:FriendTween;
	
	private var _backward:Bool;
}