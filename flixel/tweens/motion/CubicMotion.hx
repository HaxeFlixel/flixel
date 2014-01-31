package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.CompleteCallback;

/**
 * Determines motion along a cubic curve.
 */
class CubicMotion extends Motion
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, type:Int = 0)
	{
		_fromX = _fromY = _toX = _toY = 0;
		_aX = _aY = _bX = _bY = 0;
		super(0, complete, type, null);
	}
	
	/**
	 * Starts moving along the curve.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	aX			First control x.
	 * @param	aY			First control y.
	 * @param	bX			Second control x.
	 * @param	bY			Second control y.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(fromX:Float, fromY:Float, aX:Float, aY:Float, bX:Float, bY:Float, toX:Float, toY:Float, duration:Float, ?ease:EaseFunction):CubicMotion
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
		_ease = ease;
		start();
		return this;
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		x = _t * _t * _t * (_toX + 3 * (_aX - _bX) - _fromX) + 3 * _t * _t * (_fromX - 2 * _aX + _bX) + 3 * _t * (_aX - _fromX) + _fromX;
		y = _t * _t * _t * (_toY + 3 * (_aY - _bY) - _fromY) + 3 * _t * _t * (_fromY - 2 * _aY + _bY) + 3 * _t * (_aY - _fromY) + _fromY;
		if(finished)
		{
			postUpdate();
		}
	}
	
	// Curve information.
	var _fromX:Float;
	var _fromY:Float;
	var _toX:Float;
	var _toY:Float;
	var _aX:Float;
	var _aY:Float;
	var _bX:Float;
	var _bY:Float;
	var _ttt:Float;
	var _tt:Float;
}
