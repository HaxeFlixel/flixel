package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPool;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class MultiVarTween extends FlxTween
{
	/**
	 * A pool that contains MultiVarTweens for recycling.
	 */
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<MultiVarTween>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool()
	{
		if (_pool == null)
		{
			_pool = new FlxPool<MultiVarTween>(MultiVarTween);
		}
		return _pool;
	}
	
	private var _object:Dynamic;
	private var _properties:Dynamic;
	private var _vars:Array<String>;
	private var _start:Array<Float>;
	private var _range:Array<Float>;
	
	/**
	 * Clean up references and pool this object for recycling.
	 */
	override public function destroy():Void 
	{
		super.destroy();
		_object = null;
		_properties = null;
	}
	
	/**
	 * This function is called when tween is created, or recycled.
	 *
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 * @param	Eease		Optional easer function.
	 */
	override public function init(Complete:CompleteCallback, TweenType:Int, UsePooling:Bool)
	{
		FlxArrayUtil.setLength(_vars, 0);
		FlxArrayUtil.setLength(_start, 0);
		FlxArrayUtil.setLength(_range, 0);
		return super.init(Complete, TweenType, UsePooling);
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
		start();
		return this;
	}
	
	override public function update():Void
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
			if (_object != null)
			{
				Reflect.setProperty(_object, _vars[i], (_start[i] + _range[i] * scale));
			}
		}
	}
	
	override inline public function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}
	
	private function new()
	{
		super();
		_vars = new Array<String>();
		_start = new Array<Float>();
		_range = new Array<Float>();
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