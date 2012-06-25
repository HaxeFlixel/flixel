package org.flixel.tweens.motion;

import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;
import nme.geom.Point;

/**
 * Determines linear motion along a set of points.
 */
class LinearPath extends Motion
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, ?type:TweenType)
	{
		_points = new Array<Point>();
		_pointD = new Array<Float>();
		_pointT = new Array<Float>();

		distance = _speed = _index = 0;

		super(0, complete, type, null);
		_pointD[0] = _pointT[0] = 0;
	}

	/**
	 * Starts moving along the path.
	 * @param	duration		Duration of the movement.
	 * @param	ease			Optional easer function.
	 */
	public function setMotion(duration:Float, ?ease:EaseFunction = null):Void
	{
		updatePath();
		_target = duration;
		_speed = distance / duration;
		_ease = ease;
		start();
	}

	/**
	 * Starts moving along the path at the speed.
	 * @param	speed		Speed of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(speed:Float, ?ease:EaseFunction = null):Void
	{
		updatePath();
		_target = distance / speed;
		_speed = speed;
		_ease = ease;

		start();
	}

	/**
	 * Adds the point to the path.
	 * @param	x		X position.
	 * @param	y		Y position.
	 */
	public function addPoint(?x:Float = 0, ?y:Float = 0):Void
	{
		if (_last != null)
		{
			distance += Math.sqrt((x - _last.x) * (x - _last.x) + (y - _last.y) * (y - _last.y));
			_pointD[_points.length] = distance;
		}
		_points[_points.length] = _last = new Point(x, y);
	}

	/**
	 * Gets a point on the path.
	 * @param	index		Index of the point.
	 * @return	The Point object.
	 */
	public function getPoint(?index:Int = 0):Point
	{
		if (_points.length == 0) 
		{
			throw "No points have been added to the path yet.";
		}
		return _points[index % _points.length];
	}

	/** @private Starts the Tween. */
	override public function start():Void
	{
		_index = 0;
		super.start();
	}

	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		if (_index < _points.length - 1)
		{
			while (_t > _pointT[_index + 1]) _index ++;
		}
		var td:Float = _pointT[_index];
		var	tt:Float = _pointT[_index + 1] - td;
		td = (_t - td) / tt;
		_prevPoint = _points[_index];
		_nextPoint = _points[_index + 1];
		x = _prevPoint.x + (_nextPoint.x - _prevPoint.x) * td;
		y = _prevPoint.y + (_nextPoint.y - _prevPoint.y) * td;
	}

	/** @private Updates the path, preparing it for motion. */
	private function updatePath():Void
	{
		if (_points.length < 2)	throw "A LinearPath must have at least 2 points to operate.";
		if (_pointD.length == _pointT.length) return;
		// evaluate t for each point
		var i:Int = 0;
		while (i < _points.length) 
		{
			_pointT[i] = _pointD[i ++] / distance;
		}
	}

	/**
	 * The full length of the path.
	 */
	public var distance(default, null):Float;

	/**
	 * How many points are on the path.
	 */
	public var pointCount(getPointCount, never):Float;
	private function getPointCount():Float { return _points.length; }

	// Path information.
	private var _points:Array<Point>;
	private var _pointD:Array<Float>;
	private var _pointT:Array<Float>;
	private var _speed:Float;
	private var _index:Int;

	// Line information.
	private var _last:Point;
	private var _prevPoint:Point;
	private var _nextPoint:Point;
}