package flixel.tweens;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.interfaces.IFlxDestroyable;
import flixel.plugin.TweenManager;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.misc.AngleTween;
import flixel.tweens.misc.ColorTween;
import flixel.tweens.misc.MultiVarTween;
import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.tweens.motion.CircularMotion;
import flixel.tweens.motion.CubicMotion;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.motion.LinearPath;
import flixel.tweens.motion.QuadMotion;
import flixel.tweens.motion.QuadPath;
import flixel.util.FlxPoint;
import flixel.util.FlxTimer;

#if !FLX_NO_SOUND_SYSTEM
import flixel.tweens.sound.Fader;
#end

class FlxTween implements IFlxDestroyable
{
	/**
	 * Persistent Tween type, will stop when it finishes.
	 */
	public static inline var PERSIST:Int = 1;
	/**
	 * Looping Tween type, will restart immediately when it finishes.
	 */
	public static inline var LOOPING:Int = 2;
	/**
	 * "To and from" Tween type, will play tween hither and thither
	 */
	public static inline var PINGPONG:Int = 4;
	/**
	 * Oneshot Tween type, will stop and remove itself from its core container when it finishes.
	 */
	public static inline var ONESHOT:Int = 8;
	/**
	 * Backward Tween type, will play tween in reverse direction
	 */
	public static inline var BACKWARD:Int = 16;
	
	/**
	 * The tweening plugin that handles all the tweens.
	 */
	public static var manager:TweenManager;
	
	/**
	 * Creates a singleVar or multiVar FlxTween based on how many fields you want to tween.
	 * Shorthand for creating a VarTween or MultiVar tween, starting it and adding it to the TweenPlugin.
	 * 
	 * Example: FlxTween.tween(Object, { x: 500, y: 350 }, 500, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object		The object containing the properties to tween.
	 * @param	Values		The object containing values to tween (eg. { x: 500 } for singleVar, or { x: 500, y: 350 } for multiVar).
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 *  					loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	FlxTween that was added to TweenManager plugin.
	 */
	public static function tween(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var fields = Reflect.fields(Values);
		if (fields.length == 1)
		{
			return cast singleVar(Object, fields[0], Reflect.field(Values, fields[0]), Duration, Options);
		}
		else
		{
			return cast multiVar(Object, Values, Duration, Options);
		}
	}
	
	/**
	 * Tweens some numeric value. Shorthand for creating a NumTween objects, starting it and adding it to the TweenPlugin. Using it in 
	 * conjunction with a TweenFunction requires more setup, but is faster than MulitVarTween and SingleVarTween because it doesn't use Reflection.
	 * 
	 * Example: 
	 *    private function tweenFunction(s:FlxSprite, v:Float) { s.alpha = v; }
	 *    FlxTween.num(1, 0, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT }, tweenFunction.bind(mySprite));
	 * 
	 * @param	FromValue	Start value.
	 * @param	ToValue		End value.
	 * @param	Duration	Duration of the tween.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @param	TweenFunction	A function to be called when the tweened value updates.  It is recommended not to use an anonoymous 
	 *							function if you are maximizing performance, as those will be compiled to Dynamics on cpp.
	 * @return	The added NumTween object.
	 */
	public static function num(FromValue:Float, ToValue:Float, Duration:Float, ?Options:TweenOptions, ?TweenFunction:Float->Void):NumTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = NumTween._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.tween(FromValue, ToValue, Duration, Options.ease, TweenFunction);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Tweens numeric value which represents angle. Shorthand for creating a AngleTween objects, starting it and adding it to the TweenManager.
	 * Example: FlxTween.angle(Sprite, -90, 90, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Sprite		Optional Sprite whose angle should be tweened.
	 * @param	FromAngle	Start angle.
	 * @param	ToAngle		End angle.
	 * @param	Duration	Duration of the tween.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added AngleTween object.
	 */
	public static function angle(Sprite:FlxSprite, FromAngle:Float, ToAngle:Float, Duration:Float, ?Options:TweenOptions):AngleTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = AngleTween._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.tween(FromAngle, ToAngle, Duration, Options.ease, Sprite);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Tweens numeric value which represents color. Shorthand for creating a ColorTween objects, starting it and adding it to a TweenPlugin.
	 * Example: FlxTween.color(Sprite, 2.0, 0x000000, 0xffffff, 0.0, 1.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Sprite		Optional Sprite whose color should be tweened.
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	FromColor	Start color.
	 * @param	ToColor		End color.
	 * @param	FromAlpha	Start alpha.
	 * @param	ToAlpha		End alpha.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added ColorTween object.
	 */
	public static function color(Sprite:FlxSprite, Duration:Float, FromColor:Int, ToColor:Int, FromAlpha:Float = 1, ToAlpha:Float = 1, ?Options:TweenOptions):ColorTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = ColorTween._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.tween(Duration, FromColor, ToColor, FromAlpha, ToAlpha, Options.ease, Sprite);
		manager.add(tween);
		return tween;
	}
	
	#if !FLX_NO_SOUND_SYSTEM
	/**
	 * Tweens FlxG.sound.volume. Shorthand for creating a Fader tweens, starting it and adding it to the TweenManager.
	 * Example: FlxTween.fader(0.5, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 *
	 * @param	Volume		The volume to fade to.
	 * @param	Duration	Duration of the fade in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added Fader object.
	 */
	public static function fader(Volume:Float, Duration:Float, ?Options:TweenOptions):Fader
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = Fader._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.fadeTo(Volume, Duration, Options.ease);
		manager.add(tween);
		return tween;
	}
	#end
	
	/**
	 * Create a new LinearMotion tween.
	 * Example: FlxTween.linearMotion(Object, 0, 0, 500, 20, 5, false, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration (in seconds) or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 *  						startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 							loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return The LinearMotion object.
	 */
	public static function linearMotion(Object:FlxObject, FromX:Float, FromY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):LinearMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = LinearMotion._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setObject(Object);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.setMotion(FromX, FromY, ToX, ToY, DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Create a new QuadMotion tween.
	 * Example: FlxTween.quadMotion(Object, 0, 100, 300, 500, 100, 2, 5, false, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	FromX			X start.
	 * @param	FromY			Y start.
	 * @param	ControlX		X control, used to determine the curve.
	 * @param	ControlY		Y control, used to determine the curve.
	 * @param	ToX				X finish.
	 * @param	ToY				Y finish.
	 * @param	DurationOrSpeed	Duration (in seconds) or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 *  						startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 							loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return The QuadMotion object.
	 */
	public static function quadMotion(Object:FlxObject, FromX:Float, FromY:Float, ControlX:Float, ControlY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):QuadMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = QuadMotion._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setObject(Object);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.setMotion(FromX, FromY, ControlX, ControlY, ToX, ToY, DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Create a new CubicMotion tween.
	 * Example: FlxTween.cubicMotion(_sprite, 0, 0, 500, 100, 400, 200, 100, 100, 2, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object 		The object to move (FlxObject or FlxSpriteGroup)
	 * @param	FromX		X start.
	 * @param	FromY		Y start.
	 * @param	aX			First control x.
	 * @param	aY			First control y.
	 * @param	bX			Second control x.
	 * @param	bY			Second control y.
	 * @param	ToX			X finish.
	 * @param	ToY			Y finish.
	 * @param	Duration	Duration of the movement in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return The CubicMotion object.
	 */
	public static function cubicMotion(Object:FlxObject, FromX:Float, FromY:Float, aX:Float, aY:Float, bX:Float, bY:Float, ToX:Float, ToY:Float, Duration:Float, ?Options:TweenOptions):CubicMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = CubicMotion._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setObject(Object);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.setMotion(FromX, FromY, aX, aY, bX, bY, ToX, ToY, Duration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Create a new CircularMotion tween.
	 * Example: FlxTween.circularMotion(Object, 250, 250, 50, 0, true, 2, true { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	CenterX			X position of the circle's center.
	 * @param	CenterY			Y position of the circle's center.
	 * @param	Radius			Radius of the circle.
	 * @param	Angle			Starting position on the circle.
	 * @param	Clockwise		If the motion is clockwise.
	 * @param	DurationOrSpeed	Duration of the movement in seconds.
	 * @param	UseDuration		Duration of the movement.
	 * @param	Eease			Optional easer function.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 *  						startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 							loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return The CircularMotion object.
	 */
	public static function circularMotion(Object:FlxObject, CenterX:Float, CenterY:Float, Radius:Float, Angle:Float, Clockwise:Bool, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):CircularMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = CircularMotion._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setObject(Object);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.setMotion(CenterX, CenterY, Radius, Angle, Clockwise, DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Create a new LinearPath tween.
	 * Example: FlxTween.linearPath(Object, [FlxPoint.get(0, 0), FlxPoint.get(100, 100)], 2, true, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object 			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	Points			An array of at least 2 FlxPoints defining the path
	 * @param	DurationOrSpeed	Duration (in seconds) or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * 							startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 							loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The LinearPath object.
	 */
	public static function linearPath(Object:FlxObject, Points:Array<FlxPoint>, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):LinearPath
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = LinearPath._pool.get();
		tween.init(Options.complete, Options.type);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.setMotion(DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Create a new QuadPath tween.
	 * Example: FlxTween.quadPath(Object, [FlxPoint.get(0, 0), FlxPoint.get(200, 200), FlxPoint.get(400, 0)], 2, true, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	Points			An array of at least 3 FlxPoints defining the path
	 * @param	DurationOrSpeed	Duration (in seconds) or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * 							startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 							loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The QuadPath object.
	 */
	public static function quadPath(Object:FlxObject, Points:Array<FlxPoint>, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):QuadPath
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = QuadPath._pool.get();
		tween.init(Options.complete, Options.type);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.setMotion(DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Tweens numeric public property of an Object. Shorthand for creating a VarTween tween, starting it and adding it to the TweenPlugin.
	 * Example: FlxTween.singleVar(Object, "x", 500, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object		The object containing the properties to tween.
	 * @param	Property	The name of the property (eg. "x").
	 * @param	To			Value to tween to.
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 *  					loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added MultiVarTween object.
	 */
	private static function singleVar(Object:Dynamic, Property:String, To:Float, Duration:Float, ?Options:TweenOptions):VarTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = VarTween._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.tween(Object, Property, To, Duration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	/**
	 * Tweens numeric public properties of an Object. Shorthand for creating a MultiVarTween tween, starting it and adding it to the TweenPlugin.
	 * Example: FlxTween.multiVar(Object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object		The object containing the properties to tween.
	 * @param	Values		An object containing key/value pairs of properties and target values.
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added MultiVarTween object.
	 */
	private static function multiVar(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):FlxTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween = MultiVarTween._pool.get();
		tween.init(Options.complete, Options.type);
		tween.setDelays(Options.startDelay, Options.loopDelay);
		tween.tween(Object, Values, Duration, Options.ease);
		manager.add(tween);
		return tween;
	}
	
	public var active:Bool;
	public var complete:CompleteCallback;
	public var duration:Float;
	public var ease:EaseFunction;
	
	/**
	 * Useful to store values you want to access within your callback function.
	 */
	public var userData:Dynamic = null;
	
	public var type(default, set):Int;
	public var percent(get, set):Float;
	public var finished(default, null):Bool;
	public var scale(default, null):Float;
	public var backward(default, null):Bool;
	
	/**
	 * How many times this tween has been executed / has finished so far - useful to 
	 * stop the LOOPING and PINGPONG types after a certain amount of time
	 */
	public var executions(default, null):Int = 0;
	
	/**
	 * Seconds to wait until starting this tween, 0 by default
	 */
	public var startDelay(default, set):Float = 0;
	
	/**
	 * Seconds to wait between loops of this tween, 0 by default
	 */
	public var loopDelay(default, set):Float = 0;
	
	private var _secondsSinceStart:Float = 0;
	
	private var _delayToUse:Float = 0;

	/**
	 * This function is called when tween is created, or recycled.
	 */
	public function init(Complete:CompleteCallback, TweenType:Int):Void
	{
		type = TweenType;
		complete = Complete;
		userData = {};
	}
	
	public function destroy():Void
	{
		complete = null;
		ease = null;
		userData = null;
	}

	public function update():Void
	{
		_secondsSinceStart += FlxG.elapsed;
		var delay:Float = (executions > 0) ? loopDelay : startDelay;
		scale = Math.max((_secondsSinceStart - delay), 0) / duration;
		if (ease != null)
		{
			scale = ease(scale);
		}
		if (backward)
		{
			scale = 1 - scale;
		}
		if (_secondsSinceStart >= duration + delay)
		{
			scale = (backward) ? 0 : 1;
			finished = true;
		}
	}

	/**
	 * Starts the Tween, or restarts it if it's currently running.
	 */
	public function start():FlxTween
	{
		_secondsSinceStart = 0;
		_delayToUse = (executions > 0) ? loopDelay : startDelay;
		if (duration == 0)
		{
			active = false;
			return this;
		}
		active = true;
		finished = false;
		return this;
	}
	
	/**
	 * Immediately stops the Tween and removes it from its Tweener without calling the complete callback.
	 */
	public function cancel():Void
	{
		active = false;
		manager.remove(this);
	}
	
	public function finish():Void
	{
		executions++;
		
		if (complete != null) 
		{
			complete(this);
		}
		
		switch ((type & ~ FlxTween.BACKWARD))
		{
			case FlxTween.PERSIST:
				_secondsSinceStart = duration + startDelay;
				active = false;
				finished = true;
				
			case FlxTween.ONESHOT:
				active = false;
				finished = true;
				_secondsSinceStart = duration + startDelay;
				manager.remove(this, true); // destroy tween
				
			case FlxTween.LOOPING:
				_secondsSinceStart = (_secondsSinceStart - _delayToUse) % duration + _delayToUse;
				scale = Math.max((_secondsSinceStart - _delayToUse), 0) / duration;
				if ((ease != null) && (scale > 0) && (scale < 1))
				{
					scale = ease(scale);
				}
				start();
				
			case FlxTween.PINGPONG:
				_secondsSinceStart = (_secondsSinceStart - _delayToUse) % duration + _delayToUse;
				scale = Math.max((_secondsSinceStart - _delayToUse), 0) / duration;
				if ((ease != null) && (scale > 0) && (scale < 1))
				{
					scale = ease(scale);
				}
				backward = !backward;
				if (backward)
				{
					scale = 1 - scale;
				}
				start();
		}
	}
	
	/**
	 * Set both type of delays for this tween.
	 * 
	 * @param	startDelay		Seconds to wait until starting this tween, 0 by default.
	 * @param	loopDelay		Seconds to wait between loops of this tween, 0 by default.
	 */
	public function setDelays(?StartDelay:Float, ?LoopDelay:Float):Void
	{
		startDelay = StartDelay != null ? StartDelay : 0;
		loopDelay = LoopDelay != null ? LoopDelay : 0;
	}
	
	/**
	 * Empty constructor because of pooling.
	 */
	private function new() {}
	
	private function set_startDelay(value:Float):Float
	{
		var dly:Float = Math.abs(value);
		if (executions == 0)
		{
			_secondsSinceStart = duration * percent + Math.max((dly - startDelay), 0);
			_delayToUse = dly;
		}
		return startDelay = dly;
	}
	
	private function set_loopDelay(value:Null<Float>):Float
	{
		var dly:Float = Math.abs(value);
		if (executions > 0)
		{
			_secondsSinceStart = duration * percent + Math.max((dly - loopDelay), 0);
			_delayToUse = dly;
		}
		return loopDelay = dly;
	}
	
	private inline function get_percent():Float 
	{ 
		return Math.max((_secondsSinceStart - _delayToUse), 0) / duration; 
	}
	
	private function set_percent(value:Float):Float
	{ 
		return _secondsSinceStart = duration * value + _delayToUse;
	}
	
	private function set_type(value:Int):Int
	{
		if (value == 0) 
		{
			value = FlxTween.ONESHOT;
		}
		else if (value == FlxTween.BACKWARD)
		{
			value = FlxTween.PERSIST | FlxTween.BACKWARD;
		}
		
		backward = (value & FlxTween.BACKWARD) > 0;
		
		return type = value;
	}
}

typedef CompleteCallback = FlxTween->Void;

typedef TweenOptions = {
	?type:Int,
	?ease:EaseFunction,
	?complete:CompleteCallback,
	?startDelay:Null<Float>,
	?loopDelay:Null<Float>
}
