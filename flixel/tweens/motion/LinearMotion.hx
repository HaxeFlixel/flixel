package flixel.tweens.motion;

/**
 * Determines motion along a line, from one point to another.
 */
class LinearMotion extends Motion
{
	/**
	 * Length of the current line of movement.
	 */
	public var distance(get, never):Float;

	// Line information.
	var _fromX:Float = 0;
	var _fromY:Float = 0;
	var _moveX:Float = 0;
	var _moveY:Float = 0;
	var _distance:Float = -1;

	/**
	 * Starts moving along a line.
	 *
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 */
	public function setMotion(FromX:Float, FromY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true):LinearMotion
	{
		_distance = -1;
		x = _fromX = FromX;
		y = _fromY = FromY;
		_moveX = ToX - FromX;
		_moveY = ToY - FromY;

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
		x = _fromX + _moveX * scale;
		y = _fromY + _moveY * scale;

		if ((x == (_fromX + _moveX)) && (y == (_fromY + _moveY)) && active && (_secondsSinceStart >= duration))
		{
			finished = true;
		}
		if (finished)
		{
			postUpdate();
		}
	}

	function get_distance():Float
	{
		if (_distance >= 0)
			return _distance;
		return _distance = Math.sqrt(_moveX * _moveX + _moveY * _moveY);
	}
}
