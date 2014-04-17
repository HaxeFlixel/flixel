﻿package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween;
import flixel.util.FlxPool;

/**
 * Determines motion along a cubic curve.
 */
class CubicMotion extends Motion
{
	/**
	 * A pool that contains CubicMotions for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<CubicMotion>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool()
	{
		if (_pool == null)
		{
			_pool = new FlxPool<CubicMotion>(CubicMotion);
		}
		return _pool;
	}
	
	// Curve information.
	private var _fromX:Float;
	private var _fromY:Float;
	private var _toX:Float;
	private var _toY:Float;
	private var _aX:Float;
	private var _aY:Float;
	private var _bX:Float;
	private var _bY:Float;
	private var _ttt:Float;
	private var _tt:Float;
	
	override private function init(Options:TweenOptions)
	{
		_fromX = _fromY = _toX = _toY = 0;
		_aX = _aY = _bX = _bY = 0;
		return super.init(Options);
	}
	
	/**
	 * Starts moving along the curve.
	 * 
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	aX			First control x.
	 * @param	aY			First control y.
	 * @param	bX			Second control x.
	 * @param	bY			Second control y.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 */
	public function setMotion(fromX:Float, fromY:Float, aX:Float, aY:Float, bX:Float, bY:Float, toX:Float, toY:Float, duration:Float):CubicMotion
	{
		x = _fromX = fromX;
		y = _fromY = fromY;
		_aX = aX;
		_aY = aY;
		_bX = bX;
		_bY = bY;
		_toX = toX;
		_toY = toY;
		this.duration = duration;
		start();
		return this;
	}
	
	override private function update():Void
	{
		super.update();
		x = scale * scale * scale * (_toX + 3 * (_aX - _bX) - _fromX) + 3 * scale * scale * (_fromX - 2 * _aX + _bX) + 3 * scale * (_aX - _fromX) + _fromX;
		y = scale * scale * scale * (_toY + 3 * (_aY - _bY) - _fromY) + 3 * scale * scale * (_fromY - 2 * _aY + _bY) + 3 * scale * (_aY - _fromY) + _fromY;
		if (finished)
		{
			postUpdate();
		}
	}
	
	override inline private function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}
}
