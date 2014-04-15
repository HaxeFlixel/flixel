package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.CompleteCallback;
import flixel.tweens.FlxTween.TweenOptions;
import flixel.util.FlxPool;

/**
 * Determines a circular motion.
 */
class CircularMotion extends Motion
{
	/**
	 * A pool that contains CircularMotions for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<CircularMotion>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool()
	{
		if (_pool == null)
		{
			_pool = new FlxPool<CircularMotion>(CircularMotion);
		}
		return _pool;
	}
	
	/**
	 * The current position on the circle.
	 */
	public var angle:Float;

	/**
	 * The circumference of the current circle motion.
	 */
	public var circumference(get, never):Float;
	
	// Circle information.
	private var _centerX:Float;
	private var _centerY:Float;
	private var _radius:Float;
	private var _angleStart:Float;
	private var _angleFinish:Float;
	
	override private function init(Options:TweenOptions)
	{
		_centerX = _centerY = 0;
		_radius = angle = 0;
		_angleStart = _angleFinish = 0;
		return super.init(Options);
	}

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
	public function setMotion(CenterX:Float, CenterY:Float, Radius:Float, Angle:Float, Clockwise:Bool, DurationOrSpeed:Float, UseDuration:Bool = true):CircularMotion
	{
		_centerX = CenterX;
		_centerY = CenterY;
		_radius = Radius;
		this.angle = _angleStart = Angle * Math.PI / ( -180);
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

	override private function update():Void
	{
		super.update();
		angle = _angleStart + _angleFinish * scale;
		x = _centerX + Math.cos(angle) * _radius;
		y = _centerY + Math.sin(angle) * _radius;
		if (finished)
		{
			postUpdate();
		}
	}
	
	override inline private function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}

	private function get_circumference():Float 
	{ 
		return _radius * (Math.PI * 2); 
	}
}
