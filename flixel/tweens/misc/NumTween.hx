package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Tweens a numeric value. See FlxTween.num()
 */
class NumTween extends FlxTween
{
	/**
	 * The current value.
	 */
	public var value:Float;
	
	// Tween information.
	private var _tweenFunction:Float->Void;
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
	 * @param	ease			Optional easer function.
	 * @param	tweenFunction	Optional tween function. See FlxTween.num()
	 */
	public function tween(fromValue:Float, toValue:Float, duration:Float, ease:EaseFunction = null, ?tweenFunction:Float->Void):NumTween
	{	
		_tweenFunction = tweenFunction;
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
		
		if(_tweenFunction != null)
			_tweenFunction(value);
	}
}