package flixel.tweens.misc;

import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxArrayUtil;
import flixel.util.FlxPool;

/**
 * Tweens multiple numeric public properties of an Object simultaneously.
 */
class VarTween extends FlxTween
{
	@:isVar 
	@:allow(flixel.tweens.FlxTween)
	private static var _pool(get, null):FlxPool<VarTween>;
	
	/**
	 * Only allocate the pool if needed.
	 */
	private static function get__pool()
	{
		if (_pool == null)
		{
			_pool = new FlxPool<VarTween>(VarTween);
		}
		return _pool;
	}
	
	private var _object:Dynamic;
	private var _properties:Dynamic;
	private var _vars:Array<String>;
	private var _startValues:Array<Float>;
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
	
	override private function init(Options:TweenOptions)
	{
		FlxArrayUtil.setLength(_vars, 0);
		FlxArrayUtil.setLength(_startValues, 0);
		FlxArrayUtil.setLength(_range, 0);
		return super.init(Options);
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
	
	override inline private function put():Void
	{
		if (!_inPool)
			_pool.putUnsafe(this);
	}
	
	private function new()
	{
		super();
		_vars = new Array<String>();
		_startValues = new Array<Float>();
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