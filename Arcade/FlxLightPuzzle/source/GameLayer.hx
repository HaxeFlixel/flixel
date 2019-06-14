package;

import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;

/**
 * The game-related drawing functions are collected here.
 * Drawing, tweening, and removing game objects.
 * @author MSGHero
 */
class GameLayer extends FlxGroup
{
	var defaultDrawStyle:DrawStyle;

	public function new()
	{
		super();

		defaultDrawStyle = {smoothing: true};
	}

	public function drawSegment(segment:Segment, delay:Float):Void
	{
		var light = new FlxSprite();
		light.makeGraphic(1000, 1, ColorMaps.defaultColorMap[segment.color], true);

		light.x = segment.start.x;
		light.y = segment.start.y;

		light.origin.set(0, 0);
		light.angle = segment.vector.radians * 180 / Math.PI;

		light.clipRect = new FlxRect(0, 0, 1, 1);

		segment.graphic = light;

		var length = segment.vector.length;

		FlxTween.num(1, length, length / Optics.SPEED_OF_LIGHT, {onStart: addSprite.bind(light), startDelay: delay}, updateLightClip.bind(light));
	}

	function addSprite(sprite:FlxSprite, ft:FlxTween):Void
	{
		add(sprite);
	}

	function removeSprite(sprite:FlxSprite, ft:FlxTween):Void
	{
		remove(sprite, true);
	}

	function updateLightClip(light:FlxSprite, t:Float):Void
	{
		light.clipRect.width = t; // clip the light graphic to the desired length instead of using the full length
		light.clipRect = light.clipRect;
	}

	public function drawCircle(circle:Circle, delay:Float, duration:Float = .54):Void
	{
		// since we're using an elasticOut tween, the scale of the circle will stretch past 1.0
		// that looks bad if we're being honest, so we're now creating a bigger circle than we want and scaling that to 70 percent instead of stretching it past 100 percent
		var resize = 1 / .7;

		var sprite = new FlxSprite();
		sprite.makeGraphic(Math.ceil(circle.radius * 2 * resize), Math.ceil(circle.radius * 2 * resize), FlxColor.TRANSPARENT, true);
		add(sprite);

		sprite.x = circle.center.x;
		sprite.y = circle.center.y;
		sprite.offset.set(circle.radius * resize, circle.radius * resize);

		sprite.scale.set(0, 0);

		circle.graphic = sprite;

		FlxSpriteUtil.drawCircle(sprite, -1, -1, circle.radius * resize, ColorMaps.defaultColorMap[circle.color], null, defaultDrawStyle);

		FlxTween.num(0, 1 / resize, duration, {onStart: addSprite.bind(sprite), startDelay: delay, ease: FlxEase.elasticOut}, updateCircle.bind(sprite));
	}

	function updateCircle(circle:FlxSprite, t:Float):Void
	{
		circle.scale.set(t, t);
	}

	public function eraseCircle(circle:Circle, delay:Float):Void
	{
		// erasing the circle is also on a tween
		FlxTween.num(.7, 0, .27, {startDelay: delay, ease: FlxEase.elasticIn, onComplete: removeCircle.bind(circle)}, updateCircle.bind(circle.graphic));
	}

	function removeCircle(circle:Circle, ft:FlxTween):Void
	{
		remove(circle.graphic, true);
	}
}
