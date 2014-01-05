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
	/**
	 * Constructor.
	 * @param	complete		Optional completion callback.
	 * @param	type			Tween type.
	 */
	public function new(complete:CompleteCallback = null, type:Int = 0)
	{
		_vars = new Array<String>();
		_start = new Array<Float>();
		_range = new Array<Float>();
		_isInt = new Array<Bool>();
		
		super(0, type, complete);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
		_vars = null;
		_start = null;
		_range = null;
		_isInt = null;
	}
	
	/**
	 * Tweens multiple numeric public properties.
	 * @param	object		The object containing the properties.
	 * @param	properties	An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 * @param	areInts		Optional object containing key/value pairs of properties and info about their types (whether they are integers or floats).
	 */
	public function tween(object:Dynamic, properties:Dynamic, duration:Float, ease:EaseFunction = null, areInts:Dynamic = null):MultiVarTween
	{
		_object = object;
		FlxArrayUtil.setLength(_vars, 0);
		FlxArrayUtil.setLength(_start, 0);
		FlxArrayUtil.setLength(_range, 0);
		FlxArrayUtil.setLength(_isInt, 0);
		_target = duration;
		_ease = ease;
		var p:String;
		
		var fields:Array<String> = null;
		if (Reflect.isObject(properties))
		{
			fields = Reflect.fields(properties);
		}
		else
		{
			throw "Unsupported MultiVar properties container - use Object containing key/value pairs.";
		}
		
		for (p in fields)
		{
			if (Reflect.getProperty(object, p) == null)
			{
				throw "The Object does not have the property \"" + p + "\", or it is not accessible.";
			}
			
			var a:Dynamic = Reflect.getProperty(object, p);
			
			if (Math.isNaN(a)) 
			{
				throw "The property \"" + p + "\" is not numeric.";
			}
			_vars.push(p);
			_start.push(a);
			_range.push(Reflect.getProperty(properties, p) - a);
			
			if (areInts != null && Reflect.hasField(areInts, p))
			{
				var isInt:Bool = cast Reflect.field(areInts, p);
				_isInt.push(isInt);
			}
			else
			{
				_isInt.push(false);
			}
		}
		start();
		return this;
	}
	
	/**
	 * Updates the Tween. 
	 */
	override public function update():Void
	{
		super.update();
		var i:Int = _vars.length;
		var isInt:Bool;
		var value:Float;
		while (i-- > 0) 
		{
			if (_object != null)
			{
				value = _start[i] + _range[i] * _t;
				Reflect.setProperty(_object, _vars[i], (_isInt[i]) ? Math.round(value) : value);
			}
		}
	}
	
	// Tween information.
	private var _object:Dynamic;
	private var _vars:Array<String>;
	private var _start:Array<Float>;
	private var _range:Array<Float>;
	private var _isInt:Array<Bool>;
}