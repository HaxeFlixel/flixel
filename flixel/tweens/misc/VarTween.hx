package flixel.tweens.misc;

import flixel.tweens.FlxTween;

/**
 * Tweens multiple numeric properties of an object simultaneously.
 */
class VarTween extends FlxTween
{
	var _object:Dynamic;
	var _properties:Dynamic;
	var _propertyInfos:Array<VarTweenProperty>;
	
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
		_propertyInfos = [];
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
				Reflect.setProperty(info.object, info.field, info.startValue + info.range * scale);
		}
	}
	
	function initializeVars():Void
	{
		var fieldPaths:Array<String>;
		if (Reflect.isObject(_properties))
			fieldPaths = Reflect.fields(_properties);
		else
			throw "Unsupported properties container - use an object containing key/value pairs.";
		
		for (fieldPath in fieldPaths)
		{
			var target = _object;
			var path = fieldPath.split(".");
			var field = path.pop();
			for (component in path)
			{
				target = Reflect.getProperty(target, component);
				if (!Reflect.isObject(target))
					throw 'The object does not have the property "$component" in "$fieldPath"';
			}

			if (Reflect.getProperty(target, field) == null)
				throw 'The object does not have the property "$field"';
			
			var value:Dynamic = Reflect.getProperty(target, field);
			if (Math.isNaN(value))
				throw 'The property "$field" is not numeric.';
			
			var targetValue:Dynamic = Reflect.getProperty(_properties, fieldPath);
			_propertyInfos.push({
				object: target,
				field: field,
				startValue: value,
				range: targetValue - value
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

	/**
	 * returns true if this is tweening any of the specified fields on the object
	 * 
	 * @param Object The object
	 * @param Fields Optional list of tween fields. If empty, any tween field is matched
	 */
	override function isTweenOf(object:Dynamic, fields:Array<String> = null):Bool
	{
		if (_object != object)
			return false;
		
		if (fields != null){
			
			for (field in fields)
			{
				if (Reflect.hasField(_properties, field))
					return true;
			}
			
			return false;
		}
		
		return true;
	}
}

private typedef VarTweenProperty =
{
	object:Dynamic,
	field:String,
	startValue:Float,
	range:Float
}
