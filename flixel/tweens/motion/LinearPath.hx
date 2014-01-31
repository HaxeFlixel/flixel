package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.CompleteCallback;
import flixel.util.FlxPoint;

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
	public function new(?complete:CompleteCallback, type:Int = 0)
	{
		super(0, complete, type, null);
		_points = new Array<FlxPoint>();
		_pointD = new Array<Float>();
		_pointT = new Array<Float>();

		distance = _speed = _index = 0;
		
		_pointD[0] = _pointT[0] = 0;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_points = null;
		_pointD = null;
		_pointT = null;
		_last = null;
		_prevPoint = null;
		_nextPoint = null;
	}

	/**
	 * Starts moving along the path.
	 * @param	DurationOrSpeed		Duration or speed of the movement.
	 * @param	UseDuration			Whether to use the previous param as duration or speed.
	 * @param	Ease				Optional easer function.
	 */
	public function setMotion(DurationOrSpeed:Float, UseDuration:Bool = true, ?Ease:EaseFunction):LinearPath
	{
		updatePath();
		
		if (UseDuration)
		{
			duration = DurationOrSpeed;
			_speed = distance / DurationOrSpeed;
		}
		else
		{
			duration = distance / DurationOrSpeed;
			_speed = DurationOrSpeed;
		}
		
		_ease = Ease;
		start();
		return this;
	}

	/**
	 * Adds the point to the path.
	 * @param	x		X position.
	 * @param	y		Y position.
	 */
	public function addPoint(x:Float = 0, y:Float = 0):LinearPath
	{
		if (_last != null)
		{
			distance += Math.sqrt((x - _last.x) * (x - _last.x) + (y - _last.y) * (y - _last.y));
			_pointD[_points.length] = distance;
		}
		_points[_points.length] = _last = new FlxPoint(x, y);
		return this;
	}

	/**
	 * Gets a point on the path.
	 * @param	index		Index of the point.
	 * @return	The Point object.
	 */
	public function getPoint(index:Int = 0):FlxPoint
	{
		if (_points.length == 0) 
		{
			throw "No points have been added to the path yet.";
		}
		return _points[index % _points.length];
	}

	/** @private Starts the Tween. */
	override public function start():LinearPath
	{
		if (!_backward)
		{
			_index = 0;
		}
		else
		{
			_index = _points.length - 1;
		}
		
		super.start();
		return this;
	}

	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		var td:Float;
		var	tt:Float;
		
		if (!_backward && _points != null)
		{
			if (_index < _points.length - 1)
			{
				while (_t > _pointT[_index + 1]) 
				{
					_index ++;
					if (_index == _points.length - 1)
					{
						_index -= 1;
						break;
					}
				}
			}
			td = _pointT[_index];
			tt = _pointT[_index + 1] - td;
			td = (_t - td) / tt;
			_prevPoint = _points[_index];
			_nextPoint = _points[_index + 1];
			x = _prevPoint.x + (_nextPoint.x - _prevPoint.x) * td;
			y = _prevPoint.y + (_nextPoint.y - _prevPoint.y) * td;
		}
		else if (_points != null)
		{
			if (_index > 0) 
			{
				while (_t < _pointT[_index - 1])
				{
					_index -= 1;
					if (_index == 0)
					{
						_index += 1;
						break;
					}
				}
			}
			td = _pointT[_index];
			tt = _pointT[_index - 1] - td;
			td = (_t - td) / tt;
			_prevPoint = _points[_index];
			_nextPoint = _points[_index - 1];
			x = _prevPoint.x + (_nextPoint.x - _prevPoint.x) * td;
			y = _prevPoint.y + (_nextPoint.y - _prevPoint.y) * td;
		}
		
		super.postUpdate();
	}

	/** @private Updates the path, preparing it for motion. */
	function updatePath():Void
	{
		if (_points.length < 2)	throw "A LinearPath must have at least 2 points to operate.";
		if (_pointD.length == _pointT.length) return;
		// evaluate t for each point
		var i:Int = 0;
		while (i < _points.length) 
		{
			_pointT[i] = _pointD[i++] / distance;
		}
	}

	/**
	 * The full length of the path.
	 */
	public var distance(default, null):Float;

	/**
	 * How many points are on the path.
	 */
	public var pointCount(get_pointCount, never):Float;
	function get_pointCount():Float { return _points.length; }

	// Path information.
	var _points:Array<FlxPoint>;
	var _pointD:Array<Float>;
	var _pointT:Array<Float>;
	var _speed:Float;
	var _index:Int;

	// Line information.
	var _last:FlxPoint;
	var _prevPoint:FlxPoint;
	var _nextPoint:FlxPoint;
}