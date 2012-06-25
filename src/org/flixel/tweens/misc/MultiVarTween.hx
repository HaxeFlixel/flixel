package org.flixel.tweens.misc;

import org.flixel.FlxU;
import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

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
	public function new(?complete:CompleteCallback, ?type:TweenType)
	{
		_vars = new Array<String>();
		_start = new Array<Float>();
		_range = new Array<Float>();
		
		super(0, type, complete);
	}
	
	/**
	 * Tweens multiple numeric public properties.
	 * @param	object		The object containing the properties.
	 * @param	values		An object containing key/value pairs of properties and target values.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 */
	public function tween(object:Dynamic, values:Dynamic, duration:Float, ?ease:EaseFunction = null):Void
	{
		_object = object;
		FlxU.SetArrayLength(_vars, 0);
		FlxU.SetArrayLength(_start, 0);
		FlxU.SetArrayLength(_range, 0);
		_target = duration;
		_ease = ease;
		var p:String;
		var fields:Array<String> = Reflect.fields(values);
		for (p in fields)
		{
			if (!Reflect.hasField(object, p)) 
			{
				throw "The Object does not have the property\"" + p + "\", or it is not accessible.";
			}
			var a:Float = Reflect.field(object, p);
			if (Math.isNaN(a)) 
			{
				throw "The property \"" + p + "\" is not numeric.";
			}
			_vars.push(p);
			_start.push(a);
			_range.push(Reflect.field(values, p) - a);
		}
		start();
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		var i:Int = _vars.length;
		while (i-- > 0) 
		{
			Reflect.setField(_object, _vars[i], _start[i] + _range[i] * _t);
		}
	}

	// Tween information.
	private var _object:Dynamic;
	private var _vars:Array<String>;
	private var _start:Array<Float>;
	private var _range:Array<Float>;
}