package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.misc.VarTween.ThenCommand;
import flixel.tweens.misc.VarTween.TweenData;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxTimer;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class VarTween extends FlxTween
{
	private var _object:Dynamic;
	private var _properties:Dynamic;
	private var _vars:Array<String>;
	private var _startValues:Array<Float>;
	private var _range:Array<Float>;
	
	private var _thens:Array<ThenCommand>;
	
	/**
	 * Clean up references
	 */
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
		_properties = null;
		_thens = null;
	}
	
	private function new(Options:TweenOptions)
	{
		super(Options);
		
		_vars = [];
		_startValues = [];
		_range = [];
	}
	
	/**
	 * Tweens multiple numeric public properties.
	 * 
	 * @param	object		The object containing the properties.
	 * @param	properties	An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 */
	public function tween(object:Dynamic, properties:Dynamic, duration:Float):VarTween
	{
		#if !FLX_NO_DEBUG
		if (object == null)
		{
			throw "Cannot tween variables of an object that is null.";
		}
		else if (properties == null)
		{
			throw "Cannot tween null properties.";
		}
		#end
		
		_object = object;
		_properties = properties;
		this.duration = duration;
		start();
		return this;
	}
	
	/**
	 * After this tween has finished, wait this many seconds, then do the next chained "then" command
	 * @param	Delay The number of seconds to wait
	 * @return
	 */
	public function thenWait(Delay:Float):VarTween
	{
		if (_thens == null)
		{
			_thens = [];
		}
		_thens.push(new ThenCommand(Delay, null));
		return this;
	}
	
	/**
	 * After the first tween has finished, do this tween next
	 * Tweens numeric public properties of an Object. Shorthand for creating a VarTween, starting it and adding it to the TweenManager.
	 * Example: thenTween(Object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, onStart: onStart, onUpdate: onUpdate, onComplete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Object		The object containing the properties to tween.
	 * @param	Values		An object containing key/value pairs of properties and target values.
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						onStart		Optional start callback function.
	 * 						onUpdate	Optional update callback function.
	 * 						onComplete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added VarTween object.
	 */
	public function thenTween(Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions):VarTween
	{
		if (_thens == null)
		{
			_thens = [];
		}
		var tween = { object:Object, values:Values, duration:Duration, options:Options };
		_thens.push(new ThenCommand(0, tween));
		return this;
	}
	
	/**
	 * After the first tween has finished, wait this many seconds, then do this tween next
	 * Tweens numeric public properties of an Object. Shorthand for creating a VarTween, starting it and adding it to the TweenManager.
	 * Example: thenWaitAndTween(5, Object, { x: 500, y: 350 }, 2.0, { ease: easeFunction, onStart: onStart, onUpdate: onUpdate, onComplete: onComplete, type: FlxTween.ONESHOT });
	 * 
	 * @param	Delay		The number of seconds to wait
	 * @param	Object		The object containing the properties to tween.
	 * @param	Values		An object containing key/value pairs of properties and target values.
	 * @param	Duration	Duration of the tween in seconds.
	 * @param	Options		An object containing key/value pairs of the following optional parameters:
	 * 						type		Tween type.
	 * 						onStart		Optional start callback function.
	 * 						onUpdate	Optional update callback function.
	 * 						onComplete	Optional completion callback function.
	 * 						ease		Optional easer function.
	 *  					startDelay	Seconds to wait until starting this tween, 0 by default.
	 * 						loopDelay	Seconds to wait between loops of this tween, 0 by default.
	 * @return	The added VarTween object.
	 */
	public function thenWaitAndTween(Delay:Float, Object:Dynamic, Values:Dynamic, Duration:Float = 1, ?Options:TweenOptions):VarTween
	{
		if (_thens == null)
		{
			_thens = [];
		}
		var tween = { object:Object, values:Values, duration:Duration, options:Options };
		_thens.push(new ThenCommand(Delay, null));
		_thens.push(new ThenCommand(0    , tween));
		return this;
	}
	
	@:access(flixel.tweens.FlxTween)
	override function onEnd():Void 
	{
		super.onEnd();
		if (_thens != null && _thens.length > 0)
		{
			var then = _thens[0];
			var data = then.tween;
			var tween = null;
			
			_thens.splice(0, 1);
			
			if (then.delay <= 0)
			{
				if (data != null)
				{
					doNextTween(data, _thens);
				}
			}
			else
			{
				doNextTween( { object:this, values: { }, duration:then.delay, options:null }, _thens);
			}
			_thens = null;
		}
	}
	
	private function doNextTween(data:TweenData, thens:Array<ThenCommand>):Void
	{
		var tween = FlxTween.tween(data.object, data.values, data.duration, data.options);
		if (thens != null)
		{
			tween._thens = _thens;
		}
	}
	
	override private function update(elapsed:Float):Void
	{
		var delay:Float = (executions > 0) ? loopDelay : startDelay;
		
		if (_secondsSinceStart < delay)
		{
			// Leave properties alone until delay is over
			super.update(elapsed);
		}
		else
		{
			if (_vars.length < 1)
			{
				// We don't initalize() in tween() because otherwise the start values 
				// will be inaccurate with delays
				initializeVars();
			}
			
			super.update(elapsed);
			
			var i:Int = _vars.length;
			while (i-- > 0) 
			{
				Reflect.setProperty(_object, _vars[i], (_startValues[i] + _range[i] * scale));
			}
		}
	}
	
	private function initializeVars():Void
	{
		var p:String;
		var fields:Array<String>;
		
		if (Reflect.isObject(_properties))
		{
			fields = Reflect.fields(_properties);
		}
		else
		{
			throw "Unsupported properties container - use an object containing key/value pairs.";
		}
		
		for (p in fields)
		{
			if (Reflect.getProperty(_object, p) == null)
			{
				throw 'The Object does not have the property "$p"';
			}
			
			var a:Dynamic = Reflect.getProperty(_object, p);
			
			if (Math.isNaN(a)) 
			{
				throw "The property \"" + p + "\" is not numeric.";
			}
			_vars.push(p);
			_startValues.push(a);
			_range.push(Reflect.getProperty(_properties, p) - a);
		}
	}
}

typedef TweenData = { object:Dynamic, values:Dynamic, duration:Float, options:TweenOptions };

class ThenCommand
{
	public var delay:Float;
	public var tween:TweenData;
	
	public function new(delay:Float, tween:TweenData)
	{
		this.delay = delay;
		this.tween = tween;
	}
}
