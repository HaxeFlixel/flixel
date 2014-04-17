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
	private var _vars:Array<String>;
	private var _startValues:Array<Float>;
	private var _range:Array<Float>;
	
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
	
	override private function update():Void
	{
		if (_vars.length < 1)
		{
			// We don't initalize() in tween() because otherwise the start values 
			// will be inaccurate with delays
			initializeVars();
		}
		
		super.update();
		var i:Int = _vars.length;
		while (i-- > 0) 
		{
			Reflect.setProperty(_object, _vars[i], (_startValues[i] + _range[i] * scale));
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
				throw "The Object does not have the property \"" + p + "\", or it is not accessible.";
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