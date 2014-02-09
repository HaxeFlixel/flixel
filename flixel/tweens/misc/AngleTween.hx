package flixel.tweens.misc;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxRandom;

/**
 * Tweens from one angle to another.
 */
class AngleTween extends FlxTween
{
	public var angle:Float = 0;
	
	/**
	 * Optional sprite object whose angle to tween
	 */
	public var sprite:FlxSprite;
	
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * @param	Complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?Complete:CompleteCallback, type:Int = 0) 
	{
		super(0, type, Complete);
	}
	
	/**
	 * Tweens the value from one angle to another.
	 * 
	 * @param	FromAngle		Start angle.
	 * @param	ToAngle			End angle.
	 * @param	Duration		Duration of the tween.
	 * @param	Ease			Optional easer function.
	 */
	public function tween(FromAngle:Float, ToAngle:Float, Duration:Float, ?Ease:EaseFunction, ?Sprite:FlxSprite):AngleTween
	{
		_start = angle = FromAngle;
		var d:Float = ToAngle - angle;
		var a:Float = Math.abs(d);
		if (a > 181) 
		{
			_range = (360 - a) * (d > 0 ? -1 : 1);
		}
		else if (a < 179) 
		{
			_range = d;
		}
		else 
		{
			_range = FlxRandom.floatRanged(180, -180);
		}
		duration = Duration;
		ease = Ease;
		sprite = Sprite;
		start();
		return this;
	}
	
	override public function update():Void
	{
		super.update();
		
		angle = (_start + _range * scale) % 360;
		
		if (angle < 0) 
		{
			angle += 360;
		}
		
		if (sprite != null)
		{
			sprite.angle = angle;
		}
	}
}