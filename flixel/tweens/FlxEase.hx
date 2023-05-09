package flixel.tweens;

/**
 * Static class with useful easer functions that can be used by tweens.
 *
 * Operation of in/out easers:
 *
 * - **in(t)**:
 *
 *       return t;
 *
 * - **out(t)**
 *
 *       return 1 - in(1 - t);
 *
 * - **inOut(t)**
 *
 *       return (t <= .5) ? in(t * 2) / 2 : out(t * 2 - 1) / 2 + .5;
 */
class FlxEase
{
	/** Easing constants */
	static inline var PI2:Float = Math.PI / 2;
	static inline var DOUBLE_PI:Float = Math.PI * 2;

	static inline var DEFAULT_EL:Float = DOUBLE_PI / .45;
	static inline var DEFAULT_B1:Float = 1 / 2.75;
	static inline var DEFAULT_B2:Float = 2 / 2.75;
	static inline var DEFAULT_B3:Float = 1.5 / 2.75;
	static inline var DEFAULT_B4:Float = 2.5 / 2.75;
	static inline var DEFAULT_B5:Float = 2.25 / 2.75;
	static inline var DEFAULT_B6:Float = 2.625 / 2.75;
	static inline var DEFAULT_ELASTIC_AMPLITUDE:Float = 1;
	static inline var DEFAULT_ELASTIC_PERIOD:Float = 0.4;
	static inline var BOUNCE_OUT:Float->Float = bounceOutCustom(/*6*/);
	static inline var BOUNCE_IN:Float->Float = bounceInCustom(/*6*/);
	static inline var BOUNCE_IN_OUT:Float->Float = bounceInOutCustom(/*6*/);

	/** @since 4.3.0 */
	public static inline function linear(t:Float):Float
	{
		return t;
	}

	public static inline function quadIn(t:Float):Float
	{
		return t * t;
	}

	public static inline function quadOut(t:Float):Float
	{
		return -t * (t - 2);
	}

	public static inline function quadInOut(t:Float):Float
	{
		return t <= .5 ? quadIn(t) * 2 : 1 - (--t) * t * 2;
	}

	public static inline function cubeIn(t:Float):Float
	{
		return t * t * t;
	}

	public static inline function cubeOut(t:Float):Float
	{
		return 1 + (--t) * t * t;
	}

	public static inline function cubeInOut(t:Float):Float
	{
		return t <= .5 ? cubeIn(t) * 4 : quadOut(t) * 4;
	}

	public static inline function quartIn(t:Float):Float
	{
		return t * t * t * t;
	}

	public static inline function quartOut(t:Float):Float
	{
		return 1 - (t -= 1) * t * t * t;
	}

	public static inline function quartInOut(t:Float):Float
	{
		return t <= .5 ? quartIn(t) * 8 : (1 - (t = t * 2 - 2) * t * t * t) / 2 + .5;
	}

	public static inline function quintIn(t:Float):Float
	{
		return t * t * t * t * t;
	}

	public static inline function quintOut(t:Float):Float
	{
		return (t = t - 1) * t * t * t * t + 1;
	}

	public static inline function quintInOut(t:Float):Float
	{
		return ((t *= 2) < 1) ? quintIn(t) / 2 : ((t -= 2) * t * t * t * t + 2) / 2;
	}

	/** @since 4.3.0 */
	public static inline function smoothStepIn(t:Float):Float
	{
		return 2 * smoothStepInOut(t / 2);
	}

	/** @since 4.3.0 */
	public static inline function smoothStepOut(t:Float):Float
	{
		return 2 * smoothStepInOut(t / 2 + 0.5) - 1;
	}

	/** @since 4.3.0 */
	public static inline function smoothStepInOut(t:Float):Float
	{
		return t * t * (t * -2 + 3);
	}

	/** @since 4.3.0 */
	public static inline function smootherStepIn(t:Float):Float
	{
		return 2 * smootherStepInOut(t / 2);
	}

	/** @since 4.3.0 */
	public static inline function smootherStepOut(t:Float):Float
	{
		return 2 * smootherStepInOut(t / 2 + 0.5) - 1;
	}

	/** @since 4.3.0 */
	public static inline function smootherStepInOut(t:Float):Float
	{
		return t * t * t * (t * (t * 6 - 15) + 10);
	}

	public static inline function sineIn(t:Float):Float
	{
		return -Math.cos(PI2 * t) + 1;
	}

	public static inline function sineOut(t:Float):Float
	{
		return Math.sin(PI2 * t);
	}

	public static inline function sineInOut(t:Float):Float
	{
		return -Math.cos(Math.PI * t) / 2 + .5;
	}

	public static inline function bounceIn(t:Float):Float
	{
		return BOUNCE_IN(t);
		//return 1 - bounceOut(1 - t);
	}

	public static inline function bounceInCustom(/*bounces:Int = 6, */Bounce1:Float = DEFAULT_B1, Bounce2:Float = DEFAULT_B2, Bounce3:Float = DEFAULT_B3, Bounce4:Float = DEFAULT_B4, Bounce5:Float = DEFAULT_B5, Bounce6:Float = DEFAULT_B6):Float->Float
	{
		var outFunc:Float->Float = bounceOutCustom(/*bounces, */Bounce1, Bounce2, Bounce3, Bounce4, Bounce5, Bounce6);
		var func:Float->Float = function(t:Float)
		{
			return 1 - outFunc(1 - t);
		};
		return func;
	}

	public static inline function bounceOutCustom(/*bounces:Int = 6, */Bounce1:Float = DEFAULT_B1, Bounce2:Float = DEFAULT_B2, Bounce3:Float = DEFAULT_B3, Bounce4:Float = DEFAULT_B4, Bounce5:Float = DEFAULT_B5, Bounce6:Float = DEFAULT_B6):Float->Float
	{
		var func:Float->Float = function(t:Float)
		{
			if (t < Bounce1)
				return 7.5625 * t * t;
			if (t < Bounce2)
				return 7.5625 * (t - Bounce3) * (t - Bounce3) + .75;
			if (t < Bounce4)
				return 7.5625 * (t - Bounce5) * (t - Bounce5) + .9375;
			return 7.5625 * (t - Bounce6) * (t - Bounce6) + .984375;
		};
		return func;
	}
	
	// /*bounces:Int = 6, */Bounce1:Float = DEFAULT_B1, Bounce2:Float = DEFAULT_B2, Bounce3:Float = DEFAULT_B3, Bounce4:Float = DEFAULT_B4, Bounce5:Float = DEFAULT_B5, Bounce6:Float = DEFAULT_B6
	public static inline function bounceInOutCustom(/*bounces:Int = 6, */Bounce1:Float = DEFAULT_B1, Bounce2:Float = DEFAULT_B2, Bounce3:Float = DEFAULT_B3, Bounce4:Float = DEFAULT_B4, Bounce5:Float = DEFAULT_B5, Bounce6:Float = DEFAULT_B6):Float->Float
	{
		var outFunc:Float->Float = bounceOutCustom(/*bounces, */Bounce1, Bounce2, Bounce3, Bounce4, Bounce5, Bounce6);
		var func:Float->Float = function(t:Float)
		{
			return t < 0.5
				? (1 - outFunc(1 - 2 * t)) / 2
				: (1 + outFunc(2 * t - 1)) / 2;
		};
		return func;
	}

	public static inline function bounceOut(t:Float):Float
	{
		return BOUNCE_OUT(t);
		/*if (t < DEFAULT_B1)
			return 7.5625 * t * t;
		if (t < DEFAULT_B2)
			return 7.5625 * (t - DEFAULT_B3) * (t - DEFAULT_B3) + .75;
		if (t < DEFAULT_B4)
			return 7.5625 * (t - DEFAULT_B5) * (t - DEFAULT_B5) + .9375;
		return 7.5625 * (t - DEFAULT_B6) * (t - DEFAULT_B6) + .984375;*/
	}

	public static inline function bounceInOut(t:Float):Float
	{
		return BOUNCE_IN_OUT(t);
		/*return t < 0.5
			? (1 - bounceOut(1 - 2 * t)) / 2
			: (1 + bounceOut(2 * t - 1)) / 2;*/
	}

	public static inline function circIn(t:Float):Float
	{
		return -(Math.sqrt(1 - t * t) - 1);
	}

	public static inline function circOut(t:Float):Float
	{
		return Math.sqrt(1 - (t - 1) * (t - 1));
	}

	public static function circInOut(t:Float):Float
	{
		return t <= .5 ? (Math.sqrt(1 - t * t * 4) - 1) / -2 : (Math.sqrt(1 - (t * 2 - 2) * (t * 2 - 2)) + 1) / 2;
	}

	public static inline function expoIn(t:Float):Float
	{
		return Math.pow(2, 10 * (t - 1));
	}

	public static inline function expoOut(t:Float):Float
	{
		return -Math.pow(2, -10 * t) + 1;
	}

	public static function expoInOut(t:Float):Float
	{
		return t < .5 ? Math.pow(2, 10 * (t * 2 - 1)) / 2 : (-Math.pow(2, -10 * (t * 2 - 1)) + 2) / 2;
	}

	public static inline function backIn(t:Float):Float
	{
		return t * t * (2.70158 * t - 1.70158);
	}

	public static inline function backOut(t:Float):Float
	{
		return 1 - (--t) * (t) * (-2.70158 * t - 1.70158);
	}

	public static function backInOut(t:Float):Float
	{
		t *= 2;
		if (t < 1)
			return t * t * (2.70158 * t - 1.70158) / 2;
		t--;
		return (1 - (--t) * (t) * (-2.70158 * t - 1.70158)) / 2 + .5;
	}

	public static inline function elasticIn(t:Float):Float
	{
		return -(DEFAULT_ELASTIC_AMPLITUDE * Math.pow(2,
			10 * (t -= 1)) * Math.sin((t - (DEFAULT_ELASTIC_PERIOD / (DOUBLE_PI) * Math.asin(1 / DEFAULT_ELASTIC_AMPLITUDE))) * (DOUBLE_PI) / DEFAULT_ELASTIC_PERIOD));
	}

	public static inline function elasticOut(t:Float):Float
	{
		return (DEFAULT_ELASTIC_AMPLITUDE * Math.pow(2,
			-10 * t) * Math.sin((t - (DEFAULT_ELASTIC_PERIOD / (DOUBLE_PI) * Math.asin(1 / DEFAULT_ELASTIC_AMPLITUDE))) * (DOUBLE_PI) / DEFAULT_ELASTIC_PERIOD)
			+ 1);
	}

	public static function elasticInOut(t:Float):Float
	{
		if (t < 0.5)
		{
			return -0.5 * (Math.pow(2, 10 * (t -= 0.5)) * Math.sin((t - (DEFAULT_ELASTIC_PERIOD / 4)) * (DOUBLE_PI) / DEFAULT_ELASTIC_PERIOD));
		}
		return Math.pow(2, -10 * (t -= 0.5)) * Math.sin((t - (DEFAULT_ELASTIC_PERIOD / 4)) * (DOUBLE_PI) / DEFAULT_ELASTIC_PERIOD) * 0.5 + 1;
	}
}

typedef EaseFunction = Float->Float;
