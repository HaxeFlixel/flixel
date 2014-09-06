package flixel.tweens.motion;

import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;

/**
 * Determines linear motion along a set of points.
 */
class LinearPath extends Motion
{
	/**
	 * The full length of the path.
	 */
	public var distance(default, null):Float = 0;

	public var points:Array<FlxPoint>;
	
	// Path information.
	private var _pointD:Array<Float>;
	private var _pointT:Array<Float>;
	private var _speed:Float = 0;
	private var _index:Int = 0;

	// Line information.
	private var _last:FlxPoint;
	private var _prevPoint:FlxPoint;
	private var _nextPoint:FlxPoint;
	
	private function new(Options:TweenOptions)
	{
		super(Options);
		
		points = [];
		_pointD = [0];
		_pointT = [0];
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		// recycle FlxPoints
		for (point in points)
		{
			point = FlxDestroyUtil.put(point);
		}
		_last = FlxDestroyUtil.put(_last);
		_prevPoint = FlxDestroyUtil.put(_prevPoint);
		_nextPoint = FlxDestroyUtil.put(_nextPoint);
	}

	/**
	 * Starts moving along the path.
	 * 
	 * @param	DurationOrSpeed		Duration or speed of the movement.
	 * @param	UseDuration			Whether to use the previous param as duration or speed.
	 */
	public function setMotion(DurationOrSpeed:Float, UseDuration:Bool = true):LinearPath
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
		
		start();
		return this;
	}

	public function addPoint(x:Float = 0, y:Float = 0):LinearPath
	{
		if (_last != null)
		{
			distance += Math.sqrt((x - _last.x) * (x - _last.x) + (y - _last.y) * (y - _last.y));
			_pointD[points.length] = distance;
		}
		points[points.length] = _last = FlxPoint.get(x, y);
		return this;
	}
	
	public function getPoint(index:Int = 0):FlxPoint
	{
		if (points.length == 0) 
		{
			throw "No points have been added to the path yet.";
		}
		return points[index % points.length];
	}

	override private function start():LinearPath
	{
		_index = (backward) ? (points.length - 1) : 0;
		super.start();
		return this;
	}

	override private function update(elapsed:Float):Void
	{
		super.update(elapsed);
		var td:Float;
		var	tt:Float;
		
		if (points == null)
			return;
		
		if (!backward)
		{
			if (_index < points.length - 1)
			{
				while (scale > _pointT[_index + 1]) 
				{
					_index++;
					if (_index == points.length - 1)
					{
						_index -= 1;
						break;
					}
				}
			}
			
			td = _pointT[_index];
			tt = _pointT[_index + 1] - td;
			td = (scale - td) / tt;
			_prevPoint = points[_index];
			_nextPoint = points[_index + 1];
			x = _prevPoint.x + (_nextPoint.x - _prevPoint.x) * td;
			y = _prevPoint.y + (_nextPoint.y - _prevPoint.y) * td;
		}
		else
		{
			if (_index > 0) 
			{
				while (scale < _pointT[_index - 1])
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
			td = (scale - td) / tt;
			_prevPoint = points[_index];
			_nextPoint = points[_index - 1];
			x = _prevPoint.x + (_nextPoint.x - _prevPoint.x) * td;
			y = _prevPoint.y + (_nextPoint.y - _prevPoint.y) * td;
		}
		
		super.postUpdate();
	}

	/**
	 * Updates the path, preparing it for motion. 
	 */
	private function updatePath():Void
	{
		if (points.length < 2)	throw "A LinearPath must have at least 2 points to operate.";
		if (_pointD.length == _pointT.length) return;
		// evaluate t for each point
		var i:Int = 0;
		while (i < points.length) 
		{
			_pointT[i] = _pointD[i++] / distance;
		}
	}
}