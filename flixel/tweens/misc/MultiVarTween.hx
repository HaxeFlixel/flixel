package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxArrayUtil;

import Type;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class MultiVarTween extends FlxTween
{
	private var _object:Dynamic;
	private var _properties:Dynamic;
	private var _vars:Array<String>;
	private var _start:Array<Float>;
	private var _range:Array<Float>;
	
	/**
	 * @param	complete		Optional completion callback.
	 * @param	type			Tween type.
	 */
	public function new(?complete:CompleteCallback, type:Int = 0)
	{
		_vars = new Array<String>();
		_start = new Array<Float>();
		_range = new Array<Float>();
		
		super(0, type, complete);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
		_properties = null;
		_vars = null;
		_start = null;
		_range = null;
	}
	
	/**
	 * Tweens multiple numeric public properties.
	 * 
	 * @param	object		The object containing the properties.
	 * @param	properties	An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 */
	public function tween(object:Dynamic, properties:Dynamic, duration:Float, ?ease:EaseFunction):MultiVarTween
	{
		_object = object;
		_properties = properties;
		this.duration = duration;
		this.ease = ease;
		
		FlxArrayUtil.setLength(_vars, 0);
		FlxArrayUtil.setLength(_start, 0);
		FlxArrayUtil.setLength(_range, 0);
		
		start();
		return this;
	}
	
	override public function update():Void
	{
		if (_vars.length < 1)
		{
			// We don't initalize() in tween() because otherwise the start values 
			// will be inaccurate with delays
			initialize();
		}
		
		super.update();
		var i:Int = _vars.length;
		while (i-- > 0) 
		{
			if (_object != null)
			{
				Reflect.setProperty(_object, _vars[i], (_start[i] + _range[i] * scale));
			}
		}
	}
	
	private function initialize():Void
	{
		var p:String;
		var fields:Array<String>;
		
		if (Reflect.isObject(_properties))
		{
			fields = Reflect.fields(_properties);
		}
		else
		{
			throw "Unsupported MultiVar properties container - use Object containing key/value pairs.";
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
			_start.push(a);
			_range.push(Reflect.getProperty(_properties, p) - a);
		}
	}
}