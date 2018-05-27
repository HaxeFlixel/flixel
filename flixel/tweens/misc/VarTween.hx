package flixel.tweens.misc;

import flixel.tweens.FlxTween;

/**
 * Tweens multiple numeric properties of an object simultaneously.
 */
class VarTween extends FlxTween
{
	var _object:Dynamic;
	var _properties:Dynamic;
	var _propertyInfos:Array<VarTweenProperty> = [];
	
	function new(options:TweenOptions, ?manager:FlxTweenManager)
	{
		super(options, manager);
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
		#if FLX_DEBUG
		if (object == null)
			throw "Cannot tween variables of an object that is null.";
		else if (properties == null)
			throw "Cannot tween null properties.";
		#end
		
		_object = object;
		_properties = properties;
		this.duration = duration;
		start();
		return this;
	}
	
	override function update(elapsed:Float):Void
	{
		var delay:Float = (executions > 0) ? loopDelay : startDelay;
		
		// Leave properties alone until delay is over
		if (_secondsSinceStart < delay)
			super.update(elapsed);
		else
		{
			// We don't initialize() in tween() because otherwise the start values
			// will be inaccurate with delays
			if (_propertyInfos.length == 0)
				initializeVars();
			
			super.update(elapsed);
			
			for (info in _propertyInfos)
				Reflect.setProperty(_object, info.name, (info.startValue + info.range * scale));
		}
	}
	
	function initializeVars():Void
	{
		var fields:Array<String>;
		if (Reflect.isObject(_properties))
			fields = Reflect.fields(_properties);
		else
			throw "Unsupported properties container - use an object containing key/value pairs.";
		
		for (field in fields)
		{
			if (Reflect.getProperty(_object, field) == null)
				throw 'The Object does not have the property "$field"';
			
			var value:Dynamic = Reflect.getProperty(_object, field);
			
			if (Math.isNaN(value))
				throw 'The property "$field" is not numeric.';
			
			_propertyInfos.push({
				name: field,
				startValue: value,
				range: Reflect.getProperty(_properties, field) - value
			});
		}
	}

	override public function destroy():Void
	{
		super.destroy();
		_object = null;
		_properties = null;
		_propertyInfos = null;
	}
}

typedef VarTweenProperty =
{
	name:String,
	startValue:Float,
	range:Float
}
