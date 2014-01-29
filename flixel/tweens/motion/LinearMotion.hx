package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.CompleteCallback;
/**
 * Determines motion along a line, from one point to another.
 */
class LinearMotion extends Motion
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, type:Int = 0)
	{
		super(0, complete, type, null);
		_fromX = _fromY = _moveX = _moveY = 0;
		_distance = -1;
	}

	/**
	 * Starts moving along a line.
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Ease			Optional easer function.
	 */
	public function setMotion(FromX:Float, FromY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true, ?Ease:EaseFunction):LinearMotion
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
		
		_ease = Ease;
		start();
		
		return this;
	}

	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		x = _fromX + _moveX * _t;
		y = _fromY + _moveY * _t;
		if (x == _fromX + _moveX && y == _fromY + _moveY && active && (_time >= duration))
		{
			finished = true;
		}
		if (finished)
		{
			postUpdate();
		}
	}

	/**
	 * Length of the current line of movement.
	 */
	public var distance(get_distance, null):Float;
	private function get_distance():Float
	{
		if (_distance >= 0) return _distance;
		return (_distance = Math.sqrt(_moveX * _moveX + _moveY * _moveY));
	}

	// Line information.
	private var _fromX:Float;
	private var _fromY:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	private var _distance:Float;
}
