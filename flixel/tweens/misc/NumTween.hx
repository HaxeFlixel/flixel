package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Tweens a numeric value.
 */
class NumTween extends FlxTween
{
	/**
	 * The current value.
	 */
	public var value:Float;
	
	// Tween information.
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(complete:CompleteCallback = null, type:Int = 0) 
	{
		value = 0;
		super(0, type, complete);
	}
	
	/**
	 * Tweens the value from one value to another.
	 * 
	 * @param	fromValue		Start value.
	 * @param	toValue			End value.
	 * @param	duration		Duration of the tween.
	 * @param	ease			Optional easer function.
	 */
	public function tween(fromValue:Float, toValue:Float, duration:Float, ease:EaseFunction = null):NumTween
	{
		_start = value = fromValue;
		_range = toValue - value;
		this.duration = duration;
		this.ease = ease;
		start();
		return this;
	}
	
	override public function update():Void
	{
		super.update();
		value = _start + _range * scale;
	}
}