﻿package flixel.tweens.misc;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Tweens a color's red, green, and blue properties
 * independently. Can also tween an alpha value.
 */
class ColorTween extends FlxTween
{
	/**
	 * The current color.
	 */
	public var color:Int;

	/**
	 * The current alpha.
	 */
	public var alpha:Float = 1;
	
	/**
	 * Optional sprite object whose color to tween
	 */
	public var sprite:FlxSprite;

	/**
	 * Red value of the current color, from 0 to 255.
	 */
	public var red(default, null):Int;
	/**
	 * Green value of the current color, from 0 to 255.
	 */
	public var green(default, null):Int;
	/**
	 * Blue value of the current color, from 0 to 255.
	 */
	public var blue(default, null):Int;

	// Color information.
	var _startA:Float;
	var _startR:Float;
	var _startG:Float;
	var _startB:Float;
	var _rangeA:Float;
	var _rangeR:Float;
	var _rangeG:Float;
	var _rangeB:Float;
	
	/**
	 * Constructor.
	 * 
	 * @param	Complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?Complete:CompleteCallback, type:Int = 0)
	{
		super(0, type, Complete);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		sprite = null;
	}

	/**
	 * Tweens the color to a new color and an alpha to a new alpha.
	 * 
	 * @param	Duration		Duration of the tween.
	 * @param	FromColor		Start color.
	 * @param	ToColor			End color.
	 * @param	FromAlpha		Start alpha
	 * @param	ToAlpha			End alpha.
	 * @param	Ease			Optional easer function.
	 * @param	Sprite			Optional sprite object whose color to tween. 
	 * @return	The ColorTween.
	 */
	public function tween(Duration:Float, FromColor:Int, ToColor:Int, FromAlpha:Float = 1, ToAlpha:Float = 1, ?Ease:EaseFunction, ?Sprite:FlxSprite):ColorTween
	{
		FromColor &= 0xFFFFFF;
		ToColor &= 0xFFFFFF;
		color = FromColor;
		red = FromColor >> 16 & 0xFF;
		green = FromColor >> 8 & 0xFF;
		blue = FromColor & 0xFF;
		_startR = red / 255;
		_startG = green / 255;
		_startB = blue / 255;
		_rangeR = ((ToColor >> 16 & 0xFF) / 255) - _startR;
		_rangeG = ((ToColor >> 8 & 0xFF) / 255) - _startG;
		_rangeB = ((ToColor & 0xFF) / 255) - _startB;
		_startA = alpha = FromAlpha;
		_rangeA = ToAlpha - alpha;
		duration = Duration;
		_ease = Ease;
		sprite = Sprite;
		start();
		return this;
	}

	/** 
	 * Updates the Tween. 
	 */
	override public function update():Void
	{
		super.update();
		alpha = _startA + _rangeA * _t;
		red = Std.int((_startR + _rangeR * _t) * 255);
		green = Std.int((_startG + _rangeG * _t) * 255);
		blue = Std.int((_startB + _rangeB * _t) * 255);
		color = red << 16 | green << 8 | blue;
		
		if (sprite != null)
		{
			sprite.color = color;
			sprite.alpha = alpha;
		}
	}
}