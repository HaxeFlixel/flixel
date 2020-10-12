package flixel.tweens.motion;

/**
 * Determines motion along a cubic curve.
 */
class CubicMotion extends Motion
{
	// Curve information.
	var _fromX:Float = 0;
	var _fromY:Float = 0;
	var _toX:Float = 0;
	var _toY:Float = 0;
	var _aX:Float = 0;
	var _aY:Float = 0;
	var _bX:Float = 0;
	var _bY:Float = 0;
	var _ttt:Float = 0;
	var _tt:Float = 0;

	/**
	 * Starts moving along the curve.
	 *
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	aX			First control x.
	 * @param	aY			First control y.
	 * @param	bX			Second control x.
	 * @param	bY			Second control y.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 */
	public function setMotion(fromX:Float, fromY:Float, aX:Float, aY:Float, bX:Float, bY:Float, toX:Float, toY:Float, duration:Float):CubicMotion
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
		start();
		return this;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		x = scale * scale * scale * (_toX + 3 * (_aX - _bX) - _fromX)
			+ 3 * scale * scale * (_fromX - 2 * _aX + _bX)
			+ 3 * scale * (_aX - _fromX)
			+ _fromX;
		y = scale * scale * scale * (_toY + 3 * (_aY - _bY) - _fromY)
			+ 3 * scale * scale * (_fromY - 2 * _aY + _bY)
			+ 3 * scale * (_aY - _fromY)
			+ _fromY;
		if (finished)
		{
			postUpdate();
		}
	}
}
