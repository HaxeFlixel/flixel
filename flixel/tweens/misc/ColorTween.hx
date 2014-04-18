package flixel.tweens.misc;

import flixel.FlxSprite;
import flixel.tweens.FlxTween;

/**
 * Tweens a color's red, green, and blue properties
 * independently. Can also tween an alpha value.
 */
class ColorTween extends FlxTween
{
	public var color(default, null):Int;
	public var alpha(default, null):Float = 1;
	
	/**
	 * Optional sprite object whose color to tween
	 */
	public var sprite(default, null):FlxSprite;

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
	private var _startA:Float;
	private var _startR:Float;
	private var _startG:Float;
	private var _startB:Float;
	private var _rangeA:Float;
	private var _rangeR:Float;
	private var _rangeG:Float;
	private var _rangeB:Float;
	
	/**
	 * Clean up references
	 */
	override public function destroy() 
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
	 * @param	Sprite			Optional sprite object whose color to tween.
	 * @return	The ColorTween.
	 */
	public function tween(Duration:Float, FromColor:Int, ToColor:Int, FromAlpha:Float = 1, ToAlpha:Float = 1, ?Sprite:FlxSprite):ColorTween
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
		sprite = Sprite;
		start();
		return this;
	}
	
	override private function update():Void
	{
		super.update();
		alpha = _startA + _rangeA * scale;
		red = Std.int((_startR + _rangeR * scale) * 255);
		green = Std.int((_startG + _rangeG * scale) * 255);
		blue = Std.int((_startB + _rangeB * scale) * 255);
		color = red << 16 | green << 8 | blue;
		
		if (sprite != null)
		{
			sprite.color = color;
			sprite.alpha = alpha;
		}
	}
}