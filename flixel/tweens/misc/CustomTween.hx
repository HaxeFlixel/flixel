package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Use a custom function to tween
 */
class CustomTween<T> extends FlxTween
{
	private var _object:T;
	private var _tweenFunction:T->Float->Void;
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, type:Int = 0) 
	{
		super(0, type, complete);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_tweenFunction = null;
		_object = null;
	}
	
	/**
	 * Use a custom function to tween
	 * 
	 * @param	object		The object to be tweened.
	 * @param	tweenFunction	The function used to tween the object. e.g. function(s:FlxSprite, v:Float) s.alpha = v
	 * @param	from		Value to tween from.
	 * @param	to			Value to tween to.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 */
	public function tween(object:T, tweenFunction:T->Float->Void, from:Float, to:Float, duration:Float, ?ease:EaseFunction):CustomTween<T>
	{
		_object = object;
		
		if (tweenFunction == null)
			throw "tweenFunction must be non-null";
		
		_tweenFunction = tweenFunction;
		_start = from;
		_range = to - _start;
		
		this.ease = ease;
		this.duration = duration;
		start();
		return this;
	}
	
	override public function update():Void
	{
		super.update();
		_tweenFunction(_object, _start + _range * scale);
	}
}
