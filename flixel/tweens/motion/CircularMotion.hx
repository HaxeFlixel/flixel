package flixel.tweens.motion;

/**
 * Determines a circular motion.
 */
class CircularMotion extends Motion
{
	/**
	 * The current position on the circle.
	 */
	public var angle(default, null):Float = 0;

	/**
	 * The circumference of the current circle motion.
	 */
	public var circumference(get, never):Float;

	// Circle information.
	var _centerX:Float = 0;
	var _centerY:Float = 0;
	var _radius:Float = 0;
	var _angleStart:Float = 0;
	var _angleFinish:Float = 0;

	/**
	 * Starts moving along a circle.
	 *
	 * @param	CenterX			X position of the circle's center.
	 * @param	CenterY			Y position of the circle's center.
	 * @param	Radius			Radius of the circle.
	 * @param	Angle			Starting position on the circle.
	 * @param	Clockwise		If the motion is clockwise.
	 * @param	DurationOrSpeed	Duration of the movement.
	 * @param	UseDuration		Duration of the movement.
	 */
	public function setMotion(CenterX:Float, CenterY:Float, Radius:Float, Angle:Float, Clockwise:Bool, DurationOrSpeed:Float,
			UseDuration:Bool = true):CircularMotion
	{
		_centerX = CenterX;
		_centerY = CenterY;
		_radius = Radius;
		this.angle = _angleStart = Angle * Math.PI / (-180);
		_angleFinish = (Math.PI * 2) * (Clockwise ? 1 : -1);

		if (UseDuration)
		{
			duration = DurationOrSpeed;
		}
		else
		{
			duration = (_radius * (Math.PI * 2)) / DurationOrSpeed;
		}

		start();
		return this;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		angle = _angleStart + _angleFinish * scale;
		x = _centerX + Math.cos(angle) * _radius;
		y = _centerY + Math.sin(angle) * _radius;
		if (finished)
		{
			postUpdate();
		}
	}

	function get_circumference():Float
	{
		return _radius * (Math.PI * 2);
	}
}
