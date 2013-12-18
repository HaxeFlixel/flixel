package flixel.tweens;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.plugin.TweenManager;
import flixel.tweens.misc.AngleTween;
import flixel.tweens.misc.ColorTween;
import flixel.tweens.misc.MultiVarTween;
import flixel.tweens.misc.NumTween;
import flixel.tweens.misc.VarTween;
import flixel.tweens.motion.CircularMotion;
import flixel.tweens.motion.CubicMotion;
import flixel.tweens.motion.LinearMotion;
import flixel.tweens.motion.LinearPath;
import flixel.tweens.motion.Motion;
import flixel.tweens.motion.Motion.Movable;
import flixel.tweens.motion.MotionType;
import flixel.tweens.motion.PathType;
import flixel.tweens.motion.QuadMotion;
import flixel.tweens.motion.QuadPath;
import flixel.tweens.motion.QuadPath2;
import flixel.tweens.sound.Fader;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.util.FlxPoint;

class FlxTween
{
	/**
	 * The tweening plugin that handles all the tweens.
	 */
	static public var manager:TweenManager;
	
	/**
	 * Tweens numeric public properties of an Object. Shorthand for creating a MultiVarTween tween, starting it and adding it to the TweenPlugin.
	 * Example: FlxTween.multiVar(Object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * @param	Object		The object containing the properties to tween.
	 * @param	Values		An object containing key/value pairs of properties and target values.
	 * @param	Duration	Duration of the tween.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added MultiVarTween object.
	 */
	static public function multiVar(Object:Dynamic, Values:Dynamic, Duration:Float, ?Options:TweenOptions):MultiVarTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:MultiVarTween = new MultiVarTween(Options.complete, Options.type);
		tween.tween(Object, Values, Duration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens some numeric value. Shorthand for creating a NumTween objects, starting it and adding it to the TweenPlugin.
	 * Example: FlxTween.num(-1000, 0, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	FromValue	Start value.
	 * @param	ToValue		End value.
	 * @param	Duration	Duration of the tween.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added NumTween object.
	 */
	static public function num(FromValue:Float, ToValue:Float, Duration:Float, ?Options:TweenOptions):NumTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:NumTween = new NumTween(Options.complete, Options.type);
		tween.tween(FromValue, ToValue, Duration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens numeric value which represents angle. Shorthand for creating a AngleTween objects, starting it and adding it to the TweenManager.
	 * Example: FlxTween.angle(-90, 90, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	FromAngle	Start angle.
	 * @param	ToAngle		End angle.
	 * @param	Duration	Duration of the tween.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added AngleTween object.
	 */
	static public function angle(FromAngle:Float, ToAngle:Float, Duration:Float, ?Options:TweenOptions):AngleTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:AngleTween = new AngleTween(Options.complete, Options.type);
		tween.tween(FromAngle, ToAngle, Duration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens numeric value which represents color. Shorthand for creating a ColorTween objects, starting it and adding it to a TweenPlugin.
	 * Example: FlxTween.color(2.0, 0x000000, 0xffffff, 0.0, 1.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Duration	Duration of the tween.
	 * @param	FromColor	Start color.
	 * @param	ToColor		End color.
	 * @param	FromAlpha	Start alpha
	 * @param	ToAlpha		End alpha.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added ColorTween object.
	 */
	static public function color(Duration:Float, FromColor:Int, ToColor:Int, FromAlpha:Float = 1, ToAlpha:Float = 1, ?Options:TweenOptions, ?Sprite:FlxSprite):ColorTween
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:ColorTween = new ColorTween(Options.complete, Options.type);
		tween.tween(Duration, FromColor, ToColor, FromAlpha, ToAlpha, Options.ease, Sprite);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens <code>FlxG.sound.volume</code> . Shorthand for creating a Fader tweens, starting it and adding it to the TweenManager.
	 * Example: FlxTween.fader(0.5, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Volume		The volume to fade to.
	 * @param	Duration	Duration of the fade.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added Fader object.
	 */
	static public function fader(Volume:Float, Duration:Float, ?Options:TweenOptions):Fader
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:Fader = new Fader(Options.complete, Options.type);
		tween.fadeTo(Volume, Duration, Options.ease);
		manager.add(tween);
		
		return tween;
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
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * @return The LinearMotion object.
	 */
	static public function linearMotion(Object:Movable, FromX:Float, FromY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):LinearMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:LinearMotion = new LinearMotion(Options.complete, Options.type);
		tween.setObject(Object);
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
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * @return The QuadMotion object.
	 */
	static public function quadMotion(Object:Movable, FromX:Float, FromY:Float, ControlX:Float, ControlY:Float, ToX:Float, ToY:Float, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):QuadMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:QuadMotion = new QuadMotion(Options.complete, Options.type);
		tween.setObject(Object);
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
	 * @param	Duration	Duration of the movement.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return The CubicMotion object.
	 */
	static public function cubicMotion(Object:Movable, FromX:Float, FromY:Float, aX:Float, aY:Float, bX:Float, bY:Float, ToX:Float, ToY:Float, Duration:Float, ?Options:TweenOptions):CubicMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:CubicMotion = new CubicMotion(Options.complete, Options.type);
		tween.setObject(Object);
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
	 * @param	DurationOrSpeed	Duration of the movement.
	 * @param	UseDuration		Duration of the movement.
	 * @param	Eease			Optional easer function.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * @return The CircularMotion object.
	 */
	static public function circularMotion(Object:Movable, CenterX:Float, CenterY:Float, Radius:Float, Angle:Float, Clockwise:Bool, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):CircularMotion
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:CircularMotion = new CircularMotion(Options.complete, Options.type);
		tween.setObject(Object);
		tween.setMotion(CenterX, CenterY, Radius, Angle, Clockwise, DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Create a new LinearPath tween.
	 * Example: FlxTween.linearPath(Object, [new FlxPoint(0, 0), new FlxPoint(100, 100)], 2, true, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object 			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	Points			An array of at least 2 FlxPoints defining the path
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * @return	The LinearPath object.
	 */
	static public function linearPath(Object:Movable, Points:Array<FlxPoint>, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):LinearPath
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:LinearPath = new LinearPath(Options.complete, Options.type);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setMotion(DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Create a new QuadPath tween.
	 * Example: FlxTween.quadPath(Object, [new FlxPoint(0, 0), new FlxPoint(200, 200), new FlxPoint(400, 0)], 2, true, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	Points			An array of at least 3 FlxPoints defining the path
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * @return	The LinearPath object.
	 */
	static public function quadPath(Object:Movable, Points:Array<FlxPoint>, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):QuadPath
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:QuadPath = new QuadPath(Options.complete, Options.type);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setMotion(DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
	/**
	 * Create a new QuadPath2 tween.
	 * The main difference from QuadPath tween is that this tween doesn't generate control points of the path.
	 * Example: FlxTween.quadPath2(Object, [new FlxPoint(0, 0), new FlxPoint(200, 200), new FlxPoint(400, 0)], 2, true, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object			The object to move (FlxObject or FlxSpriteGroup)
	 * @param	Points			An array of at least 3 FlxPoints defining the path
	 * @param	DurationOrSpeed	Duration or speed of the movement.
	 * @param	UseDuration		Whether to use the previous param as duration or speed.
	 * @param	Options			An object containing key/value pairs of the following optional parameters:
	 * 							type		Tween type.
	 * 							complete	Optional completion callback function.
	 * 							ease		Optional easer function.
	 * @return	The LinearPath object.
	 */
	static public function quadPath2(Object:Movable, Points:Array<FlxPoint>, DurationOrSpeed:Float, UseDuration:Bool = true, ?Options:TweenOptions):QuadPath2
	{
		if (Options == null)
		{
			Options = { type : ONESHOT };
		}
		
		var tween:QuadPath2 = new QuadPath2(Options.complete, Options.type);
		
		if (Points != null)
		{
			for (point in Points)
			{
				tween.addPoint(point.x, point.y);
			}
		}
		
		tween.setObject(Object);
		tween.setMotion(DurationOrSpeed, UseDuration, Options.ease);
		manager.add(tween);
		
		return tween;
	}
	
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
	
	public var active:Bool;
	public var complete:CompleteCallback;
	/**
	 * How many times this tween has been executed / has finished so far - useful to 
	 * stop the LOOPING and PINGPONG types after a certain amount of time
	 */
	public var executions(default, null):Int = 0;
	/**
	 * Useful to store values you want to access within your callback function.
	 */
	public var userData:Dynamic = null;

	/**
	 * Constructor. Specify basic information about the Tween.
	 * @param	duration	Duration of the tween (in seconds or frames).
	 * @param	type		Tween type, one of Tween.PERSIST (default), Tween.LOOPING, or Tween.ONESHOT.
	 * @param	complete	Optional callback for when the Tween completes.
	 * @param	ease		Optional easer function to apply to the Tweened value.
	 */
	public function new(duration:Float, type:Int = 0, ?complete:CompleteCallback, ?ease:EaseFunction)
	{
		_target = duration;
		if (type == 0) 
		{
			type = FlxTween.ONESHOT;
		}
		else if (type == FlxTween.BACKWARD)
		{
			type = FlxTween.PERSIST | FlxTween.BACKWARD;
		}
		_type = type;
		this.complete = complete;
		_ease = ease;
		_t = 0;
		
		_backward = (_type & BACKWARD) > 0;
		userData = { };
	}
	
	public function destroy():Void
	{
		complete = null;
		_ease = null;
		userData = null;
	}

	/**
	 * Updates the Tween, called by World.
	 */
	public function update():Void
	{
		_time += FlxG.elapsed;
		_t = _time / _target;
		if (_ease != null)
		{
			_t = _ease(_t);
		}
		if (_backward)
		{
			_t = 1 - _t;
		}
		if (_time >= _target)
		{
			if (!_backward)
			{
				_t = 1;
			}
			else
			{
				_t = 0;
			}
			
			finished = true;
		}
	}

	/**
	 * Starts the Tween, or restarts it if it's currently running.
	 */
	public function start():Dynamic
	{
		_time = 0;
		if (_target == 0)
		{
			active = false;
			return this;
		}
		active = true;
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

	/** @private Called when the Tween completes. */
	public function finish():Void
	{
		executions++;
		
		if (complete != null) 
		{
			complete(this);
		}
		
		switch ((_type & ~ FlxTween.BACKWARD))
		{
			case FlxTween.PERSIST:
				_time = _target;
				active = false;
			case FlxTween.LOOPING:
				_time %= _target;
				_t = _time / _target;
				if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
				start();
			case FlxTween.PINGPONG:
				_time %= _target;
				_t = _time / _target;
				if (_ease != null && _t > 0 && _t < 1) _t = _ease(_t);
				_backward = !_backward;
				if (_backward) _t = 1 - _t;
				start();
			case FlxTween.ONESHOT:
				_time = _target;
				active = false;
				manager.remove(this, true);
		}

		finished = false;
	}

	public var percent(get_percent, set_percent):Float;
	private function get_percent():Float { return _time / _target; }
	private function set_percent(value:Float):Float { _time = _target * value; return _time; }

	public var scale(get_scale, null):Float;
	private function get_scale():Float { return _t; }

	public var finished(default, null):Bool;

	private var _type:Int;
	private var _ease:EaseFunction;
	private var _t:Float;

	private var _time:Float;
	private var _target:Float;
	
	private var _backward:Bool;
}

typedef CompleteCallback = FlxTween->Void;

typedef TweenOptions = {
	?type:Int,
	?ease:EaseFunction,
	?complete:CompleteCallback
}
