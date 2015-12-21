package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.util.FlxArrayUtil;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class VarTween extends FlxTween
{
	private var _object:Dynamic;
	private var _properties:Dynamic;
	private var _propertyInfos:Array<VarTweenProperty> = [];
	
	/**
	 * Clean up references
	 */
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
		_properties = null;
	}
	
	private function new(Options:TweenOptions)
	{
		super(Options);
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
			if (_propertyInfos.length == 0)
			{
				// We don't initalize() in tween() because otherwise the start values 
				// will be inaccurate with delays
				initializeVars();
			}
			
			super.update(elapsed);
			
			for (info in _propertyInfos)
			{
				Reflect.setProperty(_object, info.name, (info.startValue + info.range * scale));
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
			
			_propertyInfos.push({ name: p, startValue: a, range: Reflect.getProperty(_properties, p) - a });
		}
	}
}

typedef VarTweenProperty = {
	name:String,
	startValue:Float,
	range:Float
}
