﻿package flixel.tweens.motion;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.CompleteCallback;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.util.FlxPoint;

/**
 * A series of points which will determine a path from the
 * beginning point to the end poing using quadratic curves.
 */
class QuadPath extends Motion
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
		_curveD = new Array<Float>();
		_curveT = new Array<Float>();
		_distance = _speed = _index = _numSegs = 0;
		_updateCurve = true;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_points = null;
		_curveD = null;
		_curveT = null;
		_a = null;
		_b = null;
		_c = null;
	}
	
	/**
	 * Starts moving along the path.
	 * @param	DurationOrSpeed		Duration or speed of the movement.
	 * @param	UseDuration			Whether to use the previous param as duration or speed.
	 * @param	Ease				Optional easer function.
	 */
	public function setMotion(DurationOrSpeed:Float, UseDuration:Bool = true, ?Ease:EaseFunction):QuadPath
	{
		updatePath();
		
		if (UseDuration)
		{
			duration = DurationOrSpeed;
			_speed = _distance / DurationOrSpeed;
		}
		else
		{
			duration = _distance / DurationOrSpeed;
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
	public function addPoint(x:Float = 0, y:Float = 0):QuadPath
	{
		_updateCurve = true;
		_points[_points.length] = new FlxPoint(x, y);
		return this;
	}
	
	/**
	 * Gets the point on the path.
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
	override public function start():QuadPath
	{
		if (!_backward)
		{
			_index = 0;
		}
		else
		{
			_index = _numSegs - 1;
		}
		
		super.start();
		return this;
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		var td:Float;
		var tt:Float;
		
		if (!_backward && _points != null)
		{
			if (_index < _numSegs - 1)
			{
				while (_t > _curveT[_index + 1]) 
				{
					_index++;
					if (_index == _numSegs - 1)
					{
						break;
					}
				}
			}
			td = _curveT[_index];
			tt = _curveT[_index + 1] - td;
			td = (_t - td) / tt;
			_a = _points[_index * 2];
			_b = _points[_index * 2 + 1];
			_c = _points[_index * 2 + 2];
			
			x = _a.x * (1 - td) * (1 - td) + _b.x * 2 * (1 - td) * td + _c.x * td * td;
			y = _a.y * (1 - td) * (1 - td) + _b.y * 2 * (1 - td) * td + _c.y * td * td;
		}
		else if (_points != null)
		{
			if (_index > 0)
			{
				while (_t < _curveT[_index])
				{
					_index--;
					if (_index == 0)
					{
						break;
					}
				}
			}
			
			td = _curveT[_index+1];
			tt = _curveT[_index] - td;
			td = (_t - td) / tt;
			_a = _points[_index * 2 + 2];
			_b = _points[_index * 2 + 1];
			_c = _points[_index * 2];
			
			x = _a.x * (1 - td) * (1 - td) + _b.x * 2 * (1 - td) * td + _c.x * td * td;
			y = _a.y * (1 - td) * (1 - td) + _b.y * 2 * (1 - td) * td + _c.y * td * td;
		}
		
		super.postUpdate();
	}
	
	/** @private Updates the path, preparing the curve. */
	// [from, control, to, control, to, control, to, control, to ...]
	function updatePath():Void
	{
		if ((_points.length - 1) % 2 != 0 || _points.length < 3)	
		{
			throw "A QuadPath must have at least 3 points to operate and number of points must be a odd.";
		} 
		if (!_updateCurve) 
		{
			return;
		}
		_updateCurve = false;
		
		// find the total distance of the path
		var i:Int = 0;
		var j:Int = 0;
		_distance = 0;
		_numSegs = Std.int((_points.length - 1) / 2);
		while (i < _numSegs)
		{
			j = i * 2;
			_curveD[i] = curveLength(_points[j], _points[j + 1], _points[j + 2]);
			_distance += _curveD[i++];
		}
		
		// find t for each point on the curve
		i = 0;
		var d:Float = 0;
		while (i < _numSegs)
		{
			d += _curveD[i];
			_curveT[i++] = d / _distance;
		}
		_curveT[_numSegs - 1] = 1;
		_curveT.unshift(0);
	}
	
	/**
	 * Amount of points on the path.
	 */
	public var pointCount(get_pointCount, null):Float;
	function get_pointCount():Float { return _points.length; }
	
	/** @private Calculates the lenght of the curve. */
	function curveLength(start:FlxPoint, control:FlxPoint, finish:FlxPoint):Float
	{
		var a:FlxPoint = QuadPath._Point,
			b:FlxPoint = QuadPath._Point2;
		a.x = start.x - 2 * control.x + finish.x;
		a.y = start.y - 2 * control.y + finish.y;
		b.x = 2 * control.x - 2 * start.x;
		b.y = 2 * control.y - 2 * start.y;
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
	
	// Path information.
	var _points:Array<FlxPoint>;
	var _distance:Float;
	var _speed:Float;
	var _index:Int;
	var _numSegs:Int;
	
	// Curve information.
	var _updateCurve:Bool;
	var _curveT:Array<Float>;
	var _curveD:Array<Float>;
	
	// Curve points.
	var _a:FlxPoint;
	var _b:FlxPoint;
	var _c:FlxPoint;
	
	static var _Point:FlxPoint = new FlxPoint();
	static var _Point2:FlxPoint = new FlxPoint();
}