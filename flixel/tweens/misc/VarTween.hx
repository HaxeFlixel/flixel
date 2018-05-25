package flixel.tweens.misc;

import flixel.tweens.FlxTween;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class VarTween extends FlxTween
{
	var _object:Dynamic;
	var _properties:Dynamic;
	var _propertyInfos:Array<VarTweenProperty> = [];
	
	/**
	 * Clean up references
	 */
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
		_properties = null;
	}
	
	function new(Options:TweenOptions, ?manager:FlxTweenManager)
	{
		super(Options, manager);
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
	
	override function update(elapsed:Float):Void
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
				// We don't initialize() in tween() because otherwise the start values 
				// will be inaccurate with delays
				initializeVars();
			}
			
			super.update(elapsed);
			
			for (info in _propertyInfos)
			{
				var exploded:Array<String> = info.name.split(".");
				var target = _object;
				var prop = exploded[0];
				
				//Drill down to get the final target object and property if it's a nested object (like FlxSprite.scale)
				var i:Int = 0;
				while (i < exploded.length - 1){ 
					target = Reflect.getProperty(target, exploded[i]);
					prop = exploded[i + 1];
					i++;
				}
				Reflect.setProperty(target, prop, (info.startValue + info.range * scale));
			}
		}
	}
	
	function initializeVars():Void
	{
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
			var prop = p;
			var exploded:Array<String> = p.split(".");
			var target:Dynamic = _object;
			var i:Int = 0;
			while (i < exploded.length-1){
				if (Reflect.isObject(Reflect.getProperty(target, exploded[i]))){
					target = Reflect.getProperty(target, exploded[i]);
					prop = exploded[i + 1];
				}
				i++;
			}
			
			if (Reflect.getProperty(target, prop) == null)
			{
				throw 'The Object does not have the property "$p"';
			}
			
			var a:Dynamic = Reflect.getProperty(target, prop);
			
			if (Math.isNaN(a)) 
			{
				throw "The property \"" + p + "\" is not numeric.";
			}
			
			_propertyInfos.push({ name: p, startValue: a, range: Reflect.getProperty(_properties, p) - a });
		}
	}
}

typedef VarTweenProperty =
{
	name:String,
	startValue:Float,
	range:Float
}
