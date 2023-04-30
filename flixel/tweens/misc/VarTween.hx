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
		initializeVars();
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
			// Wait until the delay is done to set the starting values of tweens
			if (Math.isNaN(_propertyInfos[0].startValue))
				setStartValues();

			super.update(elapsed);

			if (active)
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

			_propertyInfos.push({
				object: target,
				field: field,
				startValue: Math.NaN, // gets set after delay
				range: Reflect.getProperty(_properties, fieldPath)
			});
		}
	}

	function setStartValues()
	{
		for (info in _propertyInfos)
		{
			if (Reflect.getProperty(info.object, info.field) == null)
				throw 'The object does not have the property "${info.field}"';

			var value:Dynamic = Reflect.getProperty(info.object, info.field);
			if (Math.isNaN(value))
				throw 'The property "${info.field}" is not numeric.';

			info.startValue = value;
			info.range = info.range - value;
		}
	}

	override public function destroy():Void
	{
		super.destroy();
		_object = null;
		_properties = null;
		_propertyInfos = null;
	}

	override function isTweenOf(object:Dynamic, ?field:String):Bool
	{
		if (object == _object && field == null)
			return true;
		
		for (property in _propertyInfos)
		{
			if (object == property.object && (field == property.field || field == null))
				return true;
		}

		return false;
	}
}

private typedef VarTweenProperty =
{
	object:Dynamic,
	field:String,
	startValue:Float,
	range:Float
}
