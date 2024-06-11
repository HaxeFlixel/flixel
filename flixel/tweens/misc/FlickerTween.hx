package flixel.tweens.misc;

import flixel.FlxBasic;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Special tween options for flicker tweens
 * @since 5.7.0
 */
/*Note: FlickerTweenOptions previously referenced TweenOptions, but was causing a "Unsupported recursive type" circular dependency issue when targeting HashLink
 * See https://github.com/HaxeFlixel/flixel/issues/3149
 */
typedef FlickerTweenOptions =
{
	/**
	 * Tween type - bit field of `FlxTween`'s static type constants.
	 */
	@:optional var type:FlxTweenType;
	
	/**
	 * Optional easer function (see `FlxEase`).
	 */
	@:optional var ease:EaseFunction;
	
	/**
	 * Optional start callback function.
	 */
	@:optional var onStart:TweenCallback;
	
	/**
	 * Optional update callback function.
	 */
	@:optional var onUpdate:TweenCallback;
	
	/**
	 * Optional complete callback function.
	 */
	@:optional var onComplete:TweenCallback;
	
	/**
	 * Seconds to wait until starting this tween, `0` by default.
	 */
	@:optional var startDelay:Float;
	
	/**
	 * Seconds to wait between loops of this tween, `0` by default.
	 */
	@:optional var loopDelay:Float;
	
	/**
	 * Whether the object will show after the tween, defaults to `true`
	 */
	@:optional var endVisibility:Bool;
	
	/**
	 * The amount of time the object will show, compared to the total duration, The default is `0.5`,
	 * meaning equal times visible and invisible.
	 */
	@:optional var ratio:Float;
	
	/**
	 * An optional custom flicker function, defaults to
	 * `function (tween) { return (tween.time / tween.period) % 1 > tween.ratio; }`
	 */
	@:optional var tweenFunction:(FlickerTween) -> Bool;
};

/**
 * Flickers an object. See `FlxTween.flicker()`
 * @since 5.7.0
 */
class FlickerTween extends FlxTween
{
	/** The object being flickered */
	public var basic(default, null):FlxBasic;
	
	/** Controls how the object flickers over time */
	public var tweenFunction(default, null):(FlickerTween) -> Bool;
	
	/** Whether the object will show after the tween, defaults to `true` */
	public var endVisibility(default, null):Bool = true;
	
	/** How often, in seconds, the visibility cycles */
	public var period(default, null):Float = 0.08;
	
	/**
	 * The ratio of time the object will show, default is `0.5`,
	 * meaning equal times visible and invisible.
	 */
	public var ratio(default, null):Float = 0.5;
	
	function new(options:FlickerTweenOptions, ?manager:FlxTweenManager):Void
	{
		tweenFunction = defaultTweenFunction;
		if (options != null)
		{
			if (options.endVisibility != null)
				endVisibility = options.endVisibility;
			
			if (options.ratio != null)
				ratio = options.ratio;
			
			if (options.tweenFunction != null)
				tweenFunction = options.tweenFunction;
		}
		
		super(options, manager);
	}
	
	/**
	 * Clean up references
	 */
	override function destroy()
	{
		super.destroy();
		basic = null;
	}
	
	/**
	 * Flickers the desired object
	 *
	 * @param   basic     The object to flicker
	 * @param   duration  Duration of the tween, in seconds
	 * @param   period    How often, in seconds, the visibility cycles
	 */
	public function tween(basic:FlxBasic, duration:Float, period:Float):FlickerTween
	{
		this.basic = basic;
		this.duration = duration;
		this.period = period;
		
		if (period <= 0.0)
		{
			this.period = 1.0 / FlxG.updateFramerate;
			FlxG.log.warn('Cannot flicker with a period of 0.0 or less, using 1.0 / FlxG.updateFramerate, instead');
		}
		
		start();
		return this;
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (tweenFunction != null && _secondsSinceStart >= _delayToUse)
		{
			final visible = tweenFunction(this);
			// do not call setter every frame
			if (basic.visible != visible)
				basic.visible = visible;
		}
	}
	
	override function onEnd()
	{
		super.onEnd();
		
		basic.visible = endVisibility;
	}
	
	override function isTweenOf(object:Dynamic, ?field:String):Bool
	{
		return basic == object && (field == null || field == "visible" || field == "flicker");
	}
	
	/**
	 * The default tween function of flicker tweens
	 * @param   tween  The tween handling the flickering
	 */
	public static function defaultTweenFunction(tween:FlickerTween)
	{
		return (tween.time / tween.period) % 1 > tween.ratio;
	}
}
