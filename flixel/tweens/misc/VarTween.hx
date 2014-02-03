package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

/**
 * Tweens a numeric public property of an Object.
 */
class VarTween extends FlxTween
{
	private var _object:Dynamic;
	private var _property:String;
	private var _start:Float;
	private var _range:Float;
	
	/**
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, type:Int = 0) 
	{
		super(0, type, complete);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
	}
	
	/**
	 * Tweens a numeric public property.
	 * 
	 * @param	object		The object containing the property.
	 * @param	property	The name of the property (eg. "x").
	 * @param	to			Value to tween to.
	 * @param	duration	Duration of the tween.
	 * @param	ease		Optional easer function.
	 */
	public function tween(object:Dynamic, property:String, to:Float, duration:Float, ?ease:EaseFunction):VarTween
	{
		_object = object;
		this.ease = ease;
		
		// Check to make sure we have valid parameters
		if (!Reflect.isObject(object))
		{
			throw "A valid object was not passed.";
		}
		
		_property = property;
		
		// Check if the variable is a number
		if (Reflect.getProperty(_object, property) == null)
		{
			throw "The Object does not have the property\"" + property + "\", or it is not accessible.";
		}
		
		var a = Reflect.getProperty(_object, property);
		
		if (Math.isNaN(a)) 
		{
			throw "The property \"" + property + "\" is not numeric.";
		}
		
		_start = a;
		_range = to - _start;
		this.duration = duration;
		start();
		return this;
	}
	
	override public function update():Void
	{
		super.update();
		Reflect.setProperty(_object, _property, (_start + _range * scale));
	}
}
