package flixel.tweens.misc;

import flixel.math.FlxPoint;
import flixel.util.FlxAxes;

/**
 * Shake effect for a FlxSprite
 */
class ShakeTween extends FlxTween
{
	/**
	 * Percentage representing the maximum distance that the object can move while shaking.
	 */
	var intensity:Float;

	/**
	 * Defines on what axes to `shake()`. Default value is `XY` / both.
	 */
	var axes:FlxAxes;

	/**
	 * The sprite to shake.
	 */
	var sprite:FlxSprite;

	/**
	 * Defines the initial position of the sprite at the beginning of the shake effect.
	 */
	var initialXY:FlxPoint;

	/**
	 * A simple shake effect for FlxSprite.
	 *
	 * @param	Sprite       Sprite to shake.
	 * @param   Intensity    Percentage representing the maximum distance
	 *                       that the sprite can move while shaking.
	 * @param   Duration     The length in seconds that the shaking effect should last.
	 * @param   Axes         On what axes to shake. Default value is `FlxAxes.XY` / both.
	 */
	public function tween(Sprite:FlxSprite, Intensity:Float = 0.05, Duration:Float = 1, Axes:FlxAxes = XY):ShakeTween
	{
		intensity = Intensity;
		sprite = Sprite;
		duration = Duration;
		axes = Axes;
		initialXY = new FlxPoint(Sprite.x, Sprite.y);
		start();
		return this;
	}

	override function destroy()
	{
		super.destroy();
		// Return the sprite to its initial position.
		sprite.setPosition(initialXY.x, initialXY.y);

		sprite = null;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (axes != Y)
			sprite.x = initialXY.x + FlxG.random.float(-intensity * sprite.width, intensity * sprite.width);
		if (axes != X)
			sprite.y = initialXY.y + FlxG.random.float(-intensity * sprite.height, intensity * sprite.height);
	}

	override function isTweenOf(Object:Dynamic, ?Field:String):Bool
	{
		return sprite == Object && (Field == null || Field == "shake");
	}
}
