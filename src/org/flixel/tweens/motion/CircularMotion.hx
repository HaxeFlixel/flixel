package org.flixel.tweens.motion;

import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * Determines a circular motion.
 */
class CircularMotion extends Motion
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(complete:CompleteCallback = null, type:Int = 0)
	{
		_centerX = _centerY = 0;
		_radius = angle = 0;
		_angleStart = _angleFinish = 0;
		super(0, complete, type, null);
	}

	/**
	 * Starts moving along a circle.
	 * @param	centerX		X position of the circle's center.
	 * @param	centerY		Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	angle		Starting position on the circle.
	 * @param	clockwise	If the motion is clockwise.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(centerX:Float, centerY:Float, radius:Float, angle:Float, clockwise:Bool, duration:Float, ease:EaseFunction = null):Void
	{
		_centerX = centerX;
		_centerY = centerY;
		_radius = radius;
		this.angle = _angleStart = angle * Math.PI / ( -180);
		_angleFinish = _CIRC * (clockwise ? 1 : -1);
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Starts moving along a circle at the speed.
	 * @param	centerX		X position of the circle's center.
	 * @param	centerY		Y position of the circle's center.
	 * @param	radius		Radius of the circle.
	 * @param	angle		Starting position on the circle.
	 * @param	clockwise	If the motion is clockwise.
	 * @param	speed		Speed of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(centerX:Float, centerY:Float, radius:Float, angle:Float, clockwise:Bool, speed:Float, ease:EaseFunction = null):Void
	{
		_centerX = centerX;
		_centerY = centerY;
		_radius = radius;
		this.angle = _angleStart = angle * Math.PI / ( -180);
		_angleFinish = _CIRC * (clockwise ? 1 : -1);
		_target = (_radius * _CIRC) / speed;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		angle = _angleStart + _angleFinish * _t;
		x = _centerX + Math.cos(angle) * _radius;
		y = _centerY + Math.sin(angle) * _radius;
	}

	/**
	 * The current position on the circle.
	 */
	public var angle(default, null):Float;

	/**
	 * The circumference of the current circle motion.
	 */
	public var circumference(get_circumference, never):Float;
	private function get_circumference():Float { return _radius * _CIRC; }

	// Circle information.
	private var _centerX:Float;
	private var _centerY:Float;
	private var _radius:Float;
	private var _angleStart:Float;
	private var _angleFinish:Float;
	private static inline var _CIRC:Float = Math.PI * 2;
}