package flixel.tweens.motion;

import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxTween.CompleteCallback;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxPoint;
import flixel.util.FlxPool;

/**
 * A series of points which will determine a path from the
 * beginning point to the end poing using quadratic curves.
 */
class QuadPath extends Motion
{
	/**
	 * A pool that contains QuadPaths for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<QuadPath>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool():FlxPool<QuadPath>
	{
		if (_pool == null)
		{
			_pool = new FlxPool<QuadPath>(QuadPath);
		}
		return _pool;
	}
	
	// Path information.
	private var _points:Array<FlxPoint>;
	private var _distance:Float;
	private var _speed:Float;
	private var _index:Int;
	private var _numSegs:Int;
	
	// Curve information.
	private var _updateCurve:Bool;
	private var _curveT:Array<Float>;
	private var _curveD:Array<Float>;
	
	// Curve points.
	private var _a:FlxPoint;
	private var _b:FlxPoint;
	private var _c:FlxPoint;
	
	/**
	 * This function is called when tween is created, or recycled.
	 *
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	Eease		Optional easer function.
	 */
	override public function init(Complete:CompleteCallback, TweenType:Int)
	{
		FlxArrayUtil.setLength(_points, 0);
		FlxArrayUtil.setLength(_curveD, 0);
		FlxArrayUtil.setLength(_curveT, 0);
		_distance = _speed = _index = _numSegs = 0;
		_updateCurve = true;
		return super.init(Complete, TweenType);
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
		
		ease = Ease;
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
	
	override inline public function put():Void
	{
		_pool.put(this);
	}
	
	override public function update():Void
	{
		super.update();
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
	
	private function new()
	{
		super();
		_points = new Array<FlxPoint>();
		_curveT = new Array<Float>();
		_curveD = new Array<Float>();
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