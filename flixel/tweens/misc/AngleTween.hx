﻿package flixel.tweens.misc;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;

/**
 * Tweens from one angle to another.
 */
class AngleTween extends FlxTween
{
	public var angle(default, null):Float;
	
	/**
	 * Optional sprite object whose angle to tween
	 */
	public var sprite(default, null):FlxSprite;
	
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * Clean up references
	 */
	override public function destroy()
	{
		super.destroy();
		sprite = null;
	}
	
	/**
	 * Tweens the value from one angle to another.
	 * 
	 * @param	FromAngle		Start angle.
	 * @param	ToAngle			End angle.
	 * @param	Duration		Duration of the tween.
	 */
	public function tween(FromAngle:Float, ToAngle:Float, Duration:Float, ?Sprite:FlxSprite):AngleTween
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
			_range = FlxG.random.float(180, -180);
		}
		duration = Duration;
		sprite = Sprite;
		start();
		return this;
	}
	
	override private function update():Void
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