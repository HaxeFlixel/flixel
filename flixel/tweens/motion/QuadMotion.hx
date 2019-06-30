package flixel.tweens.motion;

import flixel.math.FlxPoint;

/**
 * Determines motion along p1 quadratic curve.
 */
class QuadMotion extends Motion
{
	/**
	 * The distance of the entire curve.
	 */
	public var distance(get, never):Float;

	// Curve information.
	var _distance:Float = -1;
	var _fromX:Float = 0;
	var _fromY:Float = 0;
	var _toX:Float = 0;
	var _toY:Float = 0;
	var _controlX:Float = 0;
	var _controlY:Float = 0;

	/**
	 * Starts moving along the curve.
	 *
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ControlX		X control, used to determine the curve.
	 * @param	ControlY		Y control, used to determine the curve.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Duration of the movement.
	 */
	public function setMotion(FromX:Float, FromY:Float, ControlX:Float, ControlY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float,
			UseDuration:Bool = true):QuadMotion
	{
		_distance = -1;
		x = _fromX = FromX;
		y = _fromY = FromY;
		_controlX = ControlX;
		_controlY = ControlY;
		_toX = ToX;
		_toY = ToY;

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

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		x = _fromX * (1 - scale) * (1 - scale) + _controlX * 2 * (1 - scale) * scale + _toX * scale * scale;
		y = _fromY * (1 - scale) * (1 - scale) + _controlY * 2 * (1 - scale) * scale + _toY * scale * scale;
		if (finished)
		{
			postUpdate();
		}
	}

	function get_distance():Float
	{
		if (_distance >= 0)
			return _distance;

		var p1 = FlxPoint.get();
		var p2 = FlxPoint.get();
		p1.x = x - 2 * _controlX + _toX;
		p1.y = y - 2 * _controlY + _toY;
		p2.x = 2 * _controlX - 2 * x;
		p2.y = 2 * _controlY - 2 * y;
		var a:Float = 4 * (p1.x * p1.x + p1.y * p1.y),
			b:Float = 4 * (p1.x * p2.x + p1.y * p2.y),
			c:Float = p2.x * p2.x + p2.y * p2.y,
			abc:Float = 2 * Math.sqrt(a + b + c),
			a2:Float = Math.sqrt(a),
			a32:Float = 2 * a * a2,
			c2:Float = 2 * Math.sqrt(c),
			ba:Float = b / a2;

		p1.put();
		p2.put();

		return (a32 * abc + a2 * b * (abc - c2) + (4 * c * a - b * b) * Math.log((2 * a2 + ba + abc) / (ba + c2))) / (4 * a32);
	}
}
