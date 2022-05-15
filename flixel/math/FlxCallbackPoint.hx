package flixel.math;

import flash.geom.Point;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxPool;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;

/**
 * A FlxPoint that calls a function when set_x(), set_y() or set() is called. Used in FlxSpriteGroup.
 * IMPORTANT: Calling set(x, y); is MUCH FASTER than setting x and y separately. Needs to be destroyed unlike simple FlxPoints!
 */
class FlxCallbackPoint extends FlxBasePoint
{
	var _setXCallback:FlxPoint->Void;
	var _setYCallback:FlxPoint->Void;
	var _setXYCallback:FlxPoint->Void;

	/**
	 * If you only specify one callback function, then the remaining two will use the same.
	 *
	 * @param	setXCallback	Callback for set_x()
	 * @param	setYCallback	Callback for set_y()
	 * @param	setXYCallback	Callback for set()
	 */
	public function new(setXCallback:FlxPoint->Void, ?setYCallback:FlxPoint->Void, ?setXYCallback:FlxPoint->Void)
	{
		super();

		_setXCallback = setXCallback;
		_setYCallback = setXYCallback;
		_setXYCallback = setXYCallback;

		if (_setXCallback != null)
		{
			if (_setYCallback == null)
				_setYCallback = setXCallback;
			if (_setXYCallback == null)
				_setXYCallback = setXCallback;
		}
	}

	override public function set(X:Float = 0, Y:Float = 0):FlxCallbackPoint
	{
		super.set(X, Y);
		if (_setXYCallback != null)
			_setXYCallback(this);
		return this;
	}

	override function set_x(Value:Float):Float
	{
		super.set_x(Value);
		if (_setXCallback != null)
			_setXCallback(this);
		return Value;
	}

	override function set_y(Value:Float):Float
	{
		super.set_y(Value);
		if (_setYCallback != null)
			_setYCallback(this);
		return Value;
	}

	override public function destroy():Void
	{
		super.destroy();
		_setXCallback = null;
		_setYCallback = null;
		_setXYCallback = null;
	}

	override public function put():Void {} // don't pool FlxCallbackPoints
}
