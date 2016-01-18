package flixel.tweens.motion;

import flixel.math.FlxPoint;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxDestroyUtil;

/**
 * A series of points which will determine a path from the
 * beginning point to the end poing using quadratic curves.
 */
class QuadPath extends Motion
{
	// Path information.
	private var _points:Array<FlxPoint>;
	private var _distance:Float = 0;
	private var _speed:Float = 0;
	private var _index:Int = 0;
	private var _numSegs:Int = 0;
	
	// Curve information.
	private var _updateCurve:Bool = true;
	private var _curveT:Array<Float>;
	private var _curveD:Array<Float>;
	
	// Curve points.
	private var _a:FlxPoint;
	private var _b:FlxPoint;
	private var _c:FlxPoint;
	
	private function new(Options:TweenOptions)
	{
		super(Options);
		
		_points = [];
		_curveT = [];
		_curveD = [];
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		// recycle FlxPoints
		for (point in _points)
		{
			point = FlxDestroyUtil.put(point);
		}
		_a = FlxDestroyUtil.put(_a);
		_b = FlxDestroyUtil.put(_b);
		_c = FlxDestroyUtil.put(_c);
	}
	
	/**
	 * Starts moving along the path.
	 * 
	 * @param	DurationOrSpeed		Duration or speed of the movement.
	 * @param	UseDuration			Whether to use the previous param as duration or speed.
	 */
	public function setMotion(DurationOrSpeed:Float, UseDuration:Bool = true):QuadPath
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
		
		start();
		return this;
	}
	
	/**
	 * Adds the point to the path.
	 */
	public function addPoint(x:Float = 0, y:Float = 0):QuadPath
	{
		_updateCurve = true;
		_points.push(FlxPoint.get(x, y));
		return this;
	}
	
	/**
	 * Gets the point on the path.
	 */
	public function getPoint(index:Int = 0):FlxPoint
	{
		if (_points.length == 0) 
		{
			throw "No points have been added to the path yet.";
		}
		return _points[index % _points.length];
	}
	
	override public function start():QuadPath
	{
		_index = (backward) ? (_numSegs - 1) : 0; 
		super.start();
		return this;
	}
	
	override private function update(elapsed:Float):Void
	{
		super.update(elapsed);
		var td:Float;
		var tt:Float;
		
		if (!backward && (_points != null))
		{
			if (_index < _numSegs - 1)
			{
				while (scale > _curveT[_index + 1]) 
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
			td = (scale - td) / tt;
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
				while (scale < _curveT[_index])
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
			td = (scale - td) / tt;
			_a = _points[_index * 2 + 2];
			_b = _points[_index * 2 + 1];
			_c = _points[_index * 2];
			
			x = _a.x * (1 - td) * (1 - td) + _b.x * 2 * (1 - td) * td + _c.x * td * td;
			y = _a.y * (1 - td) * (1 - td) + _b.y * 2 * (1 - td) * td + _c.y * td * td;
		}
		super.postUpdate();
	}
	
	// [from, control, to, control, to, control, to, control, to ...]
	private function updatePath():Void
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
			_curveD[i] = getCurveLength(_points[j], _points[j + 1], _points[j + 2]);
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
	
	private function getCurveLength(start:FlxPoint, control:FlxPoint, finish:FlxPoint):Float
	{
		var a = FlxPoint.get();
		var b = FlxPoint.get();
		
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
			
		a.put();
		b.put();
			
		return (A32 * ABC + A2 * B * (ABC - C2) + (4 * C * A - B * B) * Math.log((2 * A2 + BA + ABC) / (BA + C2))) / (4 * A32);
	}
}
