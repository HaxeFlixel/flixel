package flixel.tweens.motion;

import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.FlxTween.CompleteCallback;
import flixel.util.FlxPool;

/**
 * Determines a circular motion.
 */
class CircularMotion extends Motion
{
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
	
	/**
	 * A pool that contains CircularMotions for recycling.
	 */
	@:isVar public static var pool(get, null):FlxPool<CircularMotion>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	public static function get_pool()
	{
		if (pool == null)
		{
			pool = new FlxPool<CircularMotion>(CircularMotion);
		}
		return pool;
	}
	
	/**
	 * Clean up references and pool this object for recycling.
	 */
	override public function destroy()
	{
		super.destroy();
		pool.put(this);
	}
	
	/**
	 * This function is called when tween is created, or recycled.
	 *
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	Eease		Optional easer function.
	 */
	override public function init(Complete:CompleteCallback, TweenType:Int)
	{
		_centerX = _centerY = 0;
		_radius = angle = 0;
		_angleStart = _angleFinish = 0;
		return super.init(Complete, TweenType);
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
	 * @param	Eease			Optional easer function.
	 */
	public function setMotion(CenterX:Float, CenterY:Float, Radius:Float, Angle:Float, Clockwise:Bool, DurationOrSpeed:Float, UseDuration:Bool = true, ?Ease:EaseFunction):CircularMotion
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
		
		this.ease = Ease;
		start();
		return this;
	}

	override public function update():Void
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

	private function get_circumference():Float 
	{ 
		return _radius * (Math.PI * 2); 
	}
}
