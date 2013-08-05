package flixel.tweens;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.FlxG;
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
import flixel.tweens.motion.MotionType;
import flixel.tweens.motion.PathType;
import flixel.tweens.motion.QuadMotion;
import flixel.tweens.motion.QuadPath;
import flixel.tweens.sound.Fader;
import flixel.tweens.FlxEase.EaseFunction;

class FlxTween
{
	/**
	 * The tweening plugin that handles all the tweens.
	 */
	static public var plugin:TweenManager;
	
	/**
	 * Tweens numeric public properties of an Object. Shorthand for creating a MultiVarTween tween, starting it and adding it to the TweenPlugin.
	 * @param	object		The object containing the properties to tween.
	 * @param	values		An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added MultiVarTween object.
	 *
	 * Example: FlxTween.multiVar(object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 */
	public static function multiVar(object:Dynamic, values:Dynamic, duration:Float, options:Dynamic = null):MultiVarTween
	{
		var type:Int = FlxTween.ONESHOT,
			complete:CompleteCallback = null,
			ease:EaseFunction = null;
			
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
		}
		var tween:MultiVarTween = new MultiVarTween(complete, type);
		tween.tween(object, values, duration, ease);
		plugin.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens some numeric value. Shorthand for creating a NumTween objects, starting it and adding it to the TweenPlugin.
	 * @param	fromValue	Start value.
	 * @param	toValue		End value.
	 * @param	duration	Duration of the tween.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added NumTween object.
	 *
	 * Example: FlxTween.num(-1000, 0, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 */
	public static function num(fromValue:Float, toValue:Float, duration:Float, options:Dynamic = null):NumTween
	{
		var type:Int = FlxTween.ONESHOT,
			complete:CompleteCallback = null,
			ease:EaseFunction = null;
		
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
		}
		var tween:NumTween = new NumTween(complete, type);
		tween.tween(fromValue, toValue, duration, ease);
		plugin.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens numeric value which represents angle. Shorthand for creating a AngleTween objects, starting it and adding it to the TweenManager.
	 * @param	fromAngle	Start angle.
	 * @param	toAngle		End angle.
	 * @param	duration	Duration of the tween.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added AngleTween object.
	 *
	 * Example: FlxTween.angle(-90, 90, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 */
	public static function angle(fromAngle:Float, toAngle:Float, duration:Float, options:Dynamic = null):AngleTween
	{
		var type:Int = FlxTween.ONESHOT,
			complete:CompleteCallback = null,
			ease:EaseFunction = null;
		
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
		}
		var tween:AngleTween = new AngleTween(complete, type);
		tween.tween(fromAngle, toAngle, duration, ease);
		plugin.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens numeric value which represents color. Shorthand for creating a ColorTween objects, starting it and adding it to a TweenPlugin.
	 * @param	duration	Duration of the tween.
	 * @param	fromColor	Start color.
	 * @param	toColor		End color.
	 * @param	fromAlpha	Start alpha
	 * @param	toAlpha		End alpha.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added ColorTween object.
	 *
	 * Example: FlxTween.color(2.0, 0x000000, 0xffffff, 0.0, 1.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 */
	public static function color(duration:Float, fromColor:Int, toColor:Int, fromAlpha:Float = 1, toAlpha:Float = 1, options:Dynamic = null):ColorTween
	{
		var type:Int = FlxTween.ONESHOT,
			complete:CompleteCallback = null,
			ease:EaseFunction = null;
		
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
		}
		var tween:ColorTween = new ColorTween(complete, type);
		tween.tween(duration, fromColor, toColor, fromAlpha, toAlpha, ease);
		plugin.add(tween);
		
		return tween;
	}
	
	/**
	 * Tweens <code>FlxG.sound.volume</code> . Shorthand for creating a Fader tweens, starting it and adding it to the TweenManager.
	 * @param	volume		The volume to fade to.
	 * @param	duration	Duration of the fade.
	 * @param	options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						complete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 * @return	The added Fader object.
	 *
	 * Example: FlxTween.fader(0.5, 2.0, { ease: easeFunction, complete: onComplete, type: FlxTween.ONESHOT });
	 */
	public static function fader(volume:Float, duration:Float, options:Dynamic = null):Fader
	{
		var type:Int = FlxTween.ONESHOT,
			complete:CompleteCallback = null,
			ease:EaseFunction = null;
		
		if (options != null)
		{
			if (Reflect.hasField(options, "type")) type = options.type;
			if (Reflect.hasField(options, "complete")) complete = options.complete;
			if (Reflect.hasField(options, "ease")) ease = options.ease;
		}
		var tween:Fader = new Fader(complete, type);
		tween.fadeTo(volume, duration, ease);
		plugin.add(tween);
		
		return tween;
	}
	
	/**
	 * Creates new Motion object. The type of it depends on motionType value. It could be LinearMotion, CircularMotion, QuadMotion or CubicMotion.
	 * @param	motionType	type of motion
	 * @param	tweener		object to add Motion tween to.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @return	Newly created Motion object.
	 */
	public static function motion(motionType:MotionType, tweener:FlxObject, complete:CompleteCallback = null, type:Int = 0):Dynamic
	{
		var motion:Motion = null;
		
		switch (motionType)
		{
			case MotionType.LINEAR:
				motion = new LinearMotion(complete, type);
			case MotionType.CIRCULAR:
				motion = new CircularMotion(complete, type);
			case MotionType.QUAD:
				motion = new QuadMotion(complete, type);
			case MotionType.CUBIC:
				motion = new CubicMotion(complete, type);
		}
		
		plugin.add(motion);
		motion.setObject(tweener);
		
		return motion;
	}
	
	/**
	 * Creates new Motion object. The type of it depends on pathType value. It could be LinearPath or QuadPath.
	 * @param	pathType	type of motion
	 * @param	tweener		object to add Motion tween to.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @return	Newly created Motion object.
	 */
	public static function path(pathType:PathType, tweener:FlxObject, complete:CompleteCallback = null, type:Int = 0):Dynamic
	{
		var motion:Motion = null;
		
		switch (pathType)
		{
			case PathType.LINEAR:
				motion = new LinearPath(complete, type);
			case PathType.QUAD:
				motion = new QuadPath(complete, type);
		}
		
		plugin.add(motion);
		motion.setObject(tweener);
		
		return motion;
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
			type = FlxTween.PERSIST;
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
			
			finish();
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
		plugin.remove(this);
	}

	/** @private Called when the Tween completes. */
	private function finish():Void
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
				if (_backward) _t = 1 - _t;
				_backward = !_backward;
				start();
			case FlxTween.ONESHOT:
				_time = _target;
				active = false;
				plugin.remove(this, true);
		}
	}

	public var percent(get_percent, set_percent):Float;
	private function get_percent():Float { return _time / _target; }
	private function set_percent(value:Float):Float { _time = _target * value; return _time; }

	public var scale(get_scale, null):Float;
	private function get_scale():Float { return _t; }

	private var _type:Int;
	private var _ease:EaseFunction;
	private var _t:Float;

	private var _time:Float;
	private var _target:Float;
	
	private var _backward:Bool;
}

typedef CompleteCallback = FlxTween->Void;