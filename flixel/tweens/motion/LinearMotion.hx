﻿package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.util.FlxPool;

/**
 * Determines motion along a line, from one point to another.
 */
class LinearMotion extends Motion
{
	/**
	 * A pool that contains LinearMotions for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<LinearMotion>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool()
	{
		if (_pool == null)
		{
			_pool = new FlxPool<LinearMotion>(LinearMotion);
		}
		return _pool;
	}
	
	/**
	 * Length of the current line of movement.
	 */
	public var distance(get, never):Float;
	
	// Line information.
	private var _fromX:Float;
	private var _fromY:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	private var _distance:Float;
	
	override private function init(Options:TweenOptions)
	{
		_fromX = _fromY = _moveX = _moveY = 0;
		_distance = -1;
		return super.init(Options);
	}

	/**
	 * Starts moving along a line.
	 * 
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 */
	public function setMotion(FromX:Float, FromY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true):LinearMotion
	{
		_distance = -1;
		x = _fromX = FromX;
		y = _fromY = FromY;
		_moveX = ToX - FromX;
		_moveY = ToY - FromY;
		
		if (UseDuration)
		{
			duration = DurationOrSpeed;
		}
		else
		{
			duration = distance / DurationOrSpeed;
		}
		
		start();
		
		return this;
	}

	override private function update():Void
	{
		super.update();
		x = _fromX + _moveX * scale;
		y = _fromY + _moveY * scale;
		
		if ((x == (_fromX + _moveX)) && (y == (_fromY + _moveY)) 
		    && active && (_secondsSinceStart >= duration))
		{
			finished = true;
		}
		if (finished)
		{
			postUpdate();
		}
	}

	private function get_distance():Float
	{
		if (_distance >= 0) return _distance;
		return (_distance = Math.sqrt(_moveX * _moveX + _moveY * _moveY));
	}
	
	override inline private function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}
}
