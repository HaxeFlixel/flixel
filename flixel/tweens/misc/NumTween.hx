package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxPool;

/**
 * Tweens a numeric value. See FlxTween.num()
 */
class NumTween extends FlxTween
{
	/**
	 * A pool that contains NumTweens for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<NumTween>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool()
	{
		if (_pool == null)
		{
			_pool = new FlxPool<NumTween>(NumTween);
		}
		return _pool;
	}
	
	/**
	 * The current value.
	 */
	public var value:Float;
	
	// Tween information.
	private var _tweenFunction:Float->Void;
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * Clean up references and pool this object for recycling.
	 */
	override public function destroy():Void 
	{
		super.destroy();
		_tweenFunction = null;
	}
	
	/**
	 * Tweens the value from one value to another.
	 * 
	 * @param	fromValue		Start value.
	 * @param	toValue			End value.
	 * @param	duration		Duration of the tween.
	 * @param	tweenFunction	Optional tween function. See FlxTween.num()
	 */
	public function tween(fromValue:Float, toValue:Float, duration:Float, ?tweenFunction:Float->Void):NumTween
	{	
		_tweenFunction = tweenFunction;
		_start = value = fromValue;
		_range = toValue - value;
		this.duration = duration;
		start();
		return this;
	}
	
	override private function update():Void
	{
		super.update();
		value = _start + _range * scale;
		
		if (_tweenFunction != null)
			_tweenFunction(value);
	}
	
	override inline private function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}
}