package org.flixel.tweens.misc;

import org.flixel.tweens.FlxTween;
import org.flixel.tweens.util.Ease;

/**
 * Tweens a numeric public property of an Object.
 */
class VarTween extends FlxTween
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, ?type:TweenType) 
	{
		super(0, type, complete);
	}
	
	/**
	 * Tweens a numeric public property.
	 * @param	object		The object containing the property.
	 * @param	property	The name of the property (eg. "x").
	 * @param	to			Value to tween to.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 */
	public function tween(object:Dynamic, property:String, to:Float, duration:Float, ?ease:EaseFunction = null):Void
	{
		_object = object;
		_ease = ease;
		
		// Check to make sure we have valid parameters
		if (!Reflect.isObject(object))
		{
			throw "A valid object was not passed.";
		}
		#if !cpp //Getting errors in cpp even when the object has the field
		if (!Reflect.hasField(object, property))
		{
			throw "The Object does not have the property\"" + property + "\", or it is not accessible.";
		}
		#end
		_property = property;
		_method = false;
		var a:Float = Reflect.getProperty(_object, property);
		
		// Check if we need to use a getter/setter method
		if (Math.isNaN(a))
		{
			// set the first letter to uppercase
			property = property.substr(0, 1).toUpperCase() + property.substr(1);
			var getter:Dynamic = getMethod("get" + property); // ex. getAlpha
			_method = getMethod("set" + property); // ex. setAlpha
			_property = "";
			
			a = cast(Reflect.callMethod(object, getter, []), Float);
			
			// still equal to nan??
			if (Math.isNaN(a)) 
			{
				throw "The property \"" + property + "\" is not numeric.";
			}
		}
		
		_start = a;
		_range = to - _start;
		_target = duration;
		start();
	}
	
	private function getMethod(funcName:String):Dynamic
	{
		if (Reflect.hasField(_object, funcName))
		{
			var method:Dynamic = Reflect.getProperty(_object, funcName);
			if (Reflect.isFunction(method))
			{
				return method;
			}
		}
		
		throw "The object doe not have the method \"" + funcName + "\", or it is not accessible.";
		return null;
	}
	
	/** @private Updates the Tween. */
	override public function update():Void
	{
		super.update();
		var val:Float = _start + _range * _t;
		if (_property != "")
		{
			Reflect.setProperty(_object, _property, val);
		}
		else
		{
			Reflect.callMethod(_object, _method, [val]);
		}
	}
	
	// Tween information.
	private var _object:Dynamic;
	private var _method:Dynamic;
	private var _property:String;
	private var _start:Float;
	private var _range:Float;
}