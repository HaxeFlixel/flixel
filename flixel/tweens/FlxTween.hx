package flixel.tweens;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.interfaces.IFlxDestroyable;
import flixel.plugin.TweenManager;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.tweens.misc.AngleTween;
import flixel.tweens.misc.ColorTween;
import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.tweens.motion.CircularMotion;
import flixel.tweens.motion.CubicMotion;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.motion.LinearPath;
import flixel.tweens.motion.QuadMotion;
import flixel.tweens.motion.QuadPath;
import flixel.util.FlxPoint;

@:allow(flixel.plugin.TweenManager)
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
	 * Tweens numeric public properties of an Object. Shorthand for creating a VarTween, starting it and adding it to the TweenManager.
	 * Example: FlxTween.tween(Object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
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
	 * @return	The added VarTween object.
	 */
	public static function tween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions):VarTween
	{
		var tween = new VarTween(Options);
		tween.tween(Object, Values, Duration);
		return manager.add(tween);
	}
	
	/**
	 * Tweens some numeric value. Shorthand for creating a NumTween, starting it and adding it to the TweenManager. Using it in 
	 * conjunction with a TweenFunction requires more setup, but is faster than VarTween because it doesn't use Reflection.
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
	public static function num(FromValue:Float, ToValue:Float, Duration:Float = 1, ?Options:TweenOptions, ?TweenFunction:Float->Void):NumTween
	{
		var tween = new NumTween(Options);
		tween.tween(FromValue, ToValue, Duration, TweenFunction);
		return manager.add(tween);
	}
	
	/**
	 * Tweens numeric value which represents angle. Shorthand for creating a AngleTween object, starting it and adding it to the TweenManager.
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
	public static function angle(?Sprite:FlxSprite, FromAngle:Float, ToAngle:Float, Duration:Float = 1, ?Options:TweenOptions):AngleTween
	{
		var tween = new AngleTween(Options);
		tween.tween(FromAngle, ToAngle, Duration, Sprite);
		return manager.add(tween);
	}
	
	/**
	 * Tweens numeric value which represents color. Shorthand for creating a ColorTween object, starting it and adding it to a TweenPlugin.
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
	public static function color(?Sprite:FlxSprite, Duration:Float = 1, FromColor:Int, ToColor:Int, FromAlpha:Float = 1, ToAlpha:Float = 1, ?Options:TweenOptions):ColorTween
	{
		var tween = new ColorTween(Options);
		tween.tween(Duration, FromColor, ToColor, FromAlpha, ToAlpha, Sprite);
		return manager.add(tween);
	}
	
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
	public static function linearMotion(Object:FlxObject, FromX:Float, FromY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float = 1, UseDuration:Bool = true, ?Options:TweenOptions):LinearMotion
	{
		var tween = new LinearMotion(Options);
		tween.setObject(Object);
		tween.setMotion(FromX, FromY, ToX, ToY, DurationOrSpeed, UseDuration);
		return manager.add(tween);
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
	public static function quadMotion(Object:FlxObject, FromX:Float, FromY:Float, ControlX:Float, ControlY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float = 1, UseDuration:Bool = true, ?Options:TweenOptions):QuadMotion
	{
		var tween = new QuadMotion(Options);
		tween.setObject(Object);
		tween.setMotion(FromX, FromY, ControlX, ControlY, ToX, ToY, DurationOrSpeed, UseDuration);
		return manager.add(tween);
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
	public static function cubicMotion(Object:FlxObject, FromX:Float, FromY:Float, aX:Float, aY:Float, bX:Float, bY:Float, ToX:Float, ToY:Float, Duration:Float = 1, ?Options:TweenOptions):CubicMotion
	{
		var tween = new CubicMotion(Options);
		tween.setObject(Object);
		tween.setMotion(FromX, FromY, aX, aY, bX, bY, ToX, ToY, Duration);
		return manager.add(tween);
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
	public static function circularMotion(Object:FlxObject, CenterX:Float, CenterY:Float, Radius:Float, Angle:Float, Clockwise:Bool, DurationOrSpeed:Float = 1, UseDuration:Bool = true, ?Options:TweenOptions):CircularMotion
	{
		var tween = new CircularMotion(Options);
		tween.setObject(Object);
		tween.setMotion(CenterX, CenterY, Radius, Angle, Clockwise, DurationOrSpeed, UseDuration);
		return manager.add(tween);
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
	public static function linearPath(Object:FlxObject, Points:Array<FlxPoint>, DurationOrSpeed:Float = 1, UseDuration:Bool = true, ?Options:TweenOptions):LinearPath
	{
		var tween = new LinearPath(Options);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setMotion(DurationOrSpeed, UseDuration);
		return manager.add(tween);
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
	public static function quadPath(Object:FlxObject, Points:Array<FlxPoint>, DurationOrSpeed:Float = 1, UseDuration:Bool = true, ?Options:TweenOptions):QuadPath
	{
		var tween = new QuadPath(Options);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setMotion(DurationOrSpeed, UseDuration);
		return manager.add(tween);
	}
	
	public var active:Bool = true;
	public var duration:Float = 0;
	public var ease:EaseFunction;
	public var complete:CompleteCallback;
	
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
	private function new(Options:TweenOptions):Void
	{
		Options = resolveTweenOptions(Options);
		
		type = Options.type;
		complete = Options.complete;
		ease = Options.ease;
		setDelays(Options.startDelay, Options.loopDelay);
	}
	
	private function resolveTweenOptions(Options:TweenOptions):TweenOptions
	{
		if (Options == null)
			Options = { type : ONESHOT };
		
		if (Options.type == null)
			Options.type = ONESHOT;
		
		return Options;
	}
	
	public function destroy():Void
	{
		complete = null;
		ease = null;
	}

	private function update():Void
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
	private function start():FlxTween
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
	 * Immediately stops the Tween and removes it from the 
	 * TweenManager without calling the complete callback.
	 */
	public function cancel():Void
	{
		active = false;
		finished = true;
		manager.remove(this);
	}
	
	private function finish():Void
	{
		executions++;
		
		if (complete != null) 
			complete(this);
		
		switch (type & ~ FlxTween.BACKWARD)
		{
			case FlxTween.PERSIST:
				_secondsSinceStart = duration + startDelay;
				active = false;
				finished = true;
				
			case FlxTween.ONESHOT:
				active = false;
				finished = true;
				_secondsSinceStart = duration + startDelay;
				manager.remove(this);
				
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
	 * @param	startDelay	Seconds to wait until starting this tween, 0 by default.
	 * @param	loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 */
	private function setDelays(?StartDelay:Null<Float>, ?LoopDelay:Null<Float>):FlxTween
	{
		startDelay = (StartDelay != null) ? StartDelay : 0;
		loopDelay = (LoopDelay != null) ? LoopDelay : 0;
		return this;
	}
	
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
	?type:Null<Int>,
	?ease:EaseFunction,
	?complete:CompleteCallback,
	?startDelay:Null<Float>,
	?loopDelay:Null<Float>,
}
