package org.flixel.tweens.motion;

import org.flixel.FlxPoint;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * Determines motion along a quadratic curve.
 */
class QuadMotion extends Motion
{
	
	public static var point:FlxPoint = new FlxPoint();
	public static var point2:FlxPoint = new FlxPoint();
	
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(complete:CompleteCallback = null, type:Int = 0)
	{
		_distance = -1;
		_fromX = _fromY = _toX = _toY = 0;
		_controlX = _controlY = 0;
		super(0, complete, type, null);
	}
	
	/**
	 * Starts moving along the curve.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	controlX	X control, used to determine the curve.
	 * @param	controlY	Y control, used to determine the curve.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(fromX:Float, fromY:Float, controlX:Float, controlY:Float, toX:Float, toY:Float, duration:Float, ease:EaseFunction = null):Void
	{
		_distance = -1;
		x = _fromX = fromX;
		y = _fromY = fromY;
		_controlX = controlX;
		_controlY = controlY;
		_toX = toX;
		_toY = toY;
		_target = duration;
		_ease = ease;
		start();
	}
	
	/**
	 * Starts moving along the curve at the speed.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	controlX	X control, used to determine the curve.
	 * @param	controlY	Y control, used to determine the curve.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	speed		Speed of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(fromX:Float, fromY:Float, controlX:Float, controlY:Float, toX:Float, toY:Float, speed:Float, ease:EaseFunction = null):Void
	{
		_distance = -1;
		x = _fromX = fromX;
		y = _fromY = fromY;
		_controlX = controlX;
		_controlY = controlY;
		_toX = toX;
		_toY = toY;
		_target = distance / speed;
		_ease = ease;
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		x = _fromX * (1 - _t) * (1 - _t) + _controlX * 2 * (1 - _t) * _t + _toX * _t * _t;
		y = _fromY * (1 - _t) * (1 - _t) + _controlY * 2 * (1 - _t) * _t + _toY * _t * _t;
	}
	
	/**
	 * The distance of the entire curve.
	 */
	public var distance(get_distance, null):Float;
	private function get_distance():Float
	{
		if (_distance >= 0) return _distance;
		var a:FlxPoint = QuadMotion.point;
		var b:FlxPoint = QuadMotion.point2;
		a.x = x - 2 * _controlX + _toX;
		a.y = y - 2 * _controlY + _toY;
		b.x = 2 * _controlX - 2 * x;
		b.y = 2 * _controlY - 2 * y;
		var A:Float = 4 * (a.x * a.x + a.y * a.y),
			B:Float = 4 * (a.x * b.x + a.y * b.y),
			C:Float = b.x * b.x + b.y * b.y,
			ABC:Float = 2 * Math.sqrt(A + B + C),
			A2:Float = Math.sqrt(A),
			A32:Float = 2 * A * A2,
			C2:Float = 2 * Math.sqrt(C),
			BA:Float = B / A2;
		return (A32 * ABC + A2 * B * (ABC - C2) + (4 * C * A - B * B) * Math.log((2 * A2 + BA + ABC) / (BA + C2))) / (4 * A32);
	}
	
	// Curve information.
	private var _distance:Float;
	private var _fromX:Float;
	private var _fromY:Float;
	private var _toX:Float;
	private var _toY:Float;
	private var _controlX:Float;
	private var _controlY:Float;
}