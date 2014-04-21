package flixel.util;

import flixel.FlxG;
import flash.geom.Point;
import flixel.interfaces.IFlxPooled;
import flixel.util.FlxStringUtil;

/**
 * Stores a 2D floating point coordinate.
 */
class FlxPoint implements IFlxPooled
{
	private static var _pool = new FlxPool<FlxPoint>(FlxPoint);
	
	/**
	 * Recycle or create a new FlxPoint. 
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @return	This point.
	 */
	public static inline function get(X:Float = 0, Y:Float = 0):FlxPoint
	{
		var point = _pool.get().set(X, Y);
		point._inPool = false;
		return point;
	}
	
	/**
	 * Recycle or create a new FlxPoint which will automatically be released 
	 * to the pool when passed into a flixel function.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @return	This point.
	 */
	public static inline function weak(X:Float = 0, Y:Float = 0):FlxPoint
	{
		var point = _pool.get().set(X, Y);
		point._weak = true;
		return point;
	}
	
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	
	private var _weak:Bool = false;
	private var _inPool:Bool = false;
	
	public function new(X:Float = 0, Y:Float = 0) 
	{
		set(X, Y);
	}
	
	/**
	 * Add this FlxPoint to the recycling pool.
	 */
	public function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_pool.putUnsafe(this);
		}
	}
	
	/**
	 * Add this FlxPoint to the recycling pool if it's a weak reference (allocated via weak()).
	 */
	public inline function putWeak():Void
	{
		if (_weak)
		{
			_pool.put(this);
		}
	}
	
	/**
	 * Set the coordinates of this point.
	 * 
	 * @param	X	The X-coordinate of the point in space.
	 * @param	Y	The Y-coordinate of the point in space.
	 * @return	This point.
	 */
	public function set(X:Float = 0, Y:Float = 0):FlxPoint
	{
		x = X;
		y = Y;
		return this;
	}
	
	/**
	 * Adds the to the coordinates of this point.
	 * 
	 * @param	X	Amount to add to x
	 * @param	Y	Amount to add to y
	 * @return	This point.
	 */
	public inline function add(X:Float = 0, Y:Float = 0):FlxPoint
	{
		x += X;
		y += Y;
		return this;
	}
	
	/**
	 * Adds the coordinates of another point to the coordinates of this point.
	 * 
	 * @param	point	The point to add to this point
	 * @return	This point.
	 */
	public function addPoint(point:FlxPoint):FlxPoint
	{
		x += point.x;
		y += point.y;
		point.putWeak();
		return this;
	}
	
	/**
	 * Adds the to the coordinates of this point.
	 * 
	 * @param	X	Amount to subtract from x
	 * @param	Y	Amount to subtract from y
	 * @return	This point.
	 */
	public inline function subtract(X:Float = 0, Y:Float = 0):FlxPoint
	{
		x -= X;
		y -= Y;
		return this;
	}
	
	/**
	 * Adds the coordinates of another point to the coordinates of this point.
	 * 
	 * @param	point	The point to subtract from this point
	 * @return	This point.
	 */
	public function subtractPoint(point:FlxPoint):FlxPoint
	{
		x -= point.x;
		y -= point.y;
		point.putWeak();
		return this;
	}
	
	/**
	 * Helper function, just copies the values from the specified point.
	 * 
	 * @param	point	Any FlxPoint.
	 * @return	A reference to itself.
	 */
	public inline function copyFrom(point:FlxPoint):FlxPoint
	{
		x = point.x;
		y = point.y;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this point to the specified point.
	 * 
	 * @param	Point	Any FlxPoint.
	 * @return	A reference to the altered point parameter.
	 */
	public function copyTo(?point:FlxPoint):FlxPoint
	{
		if (point == null)
		{
			point = FlxPoint.get();
		}
		point.x = x;
		point.y = y;
		return point;
	}
	
	/**
	 * Helper function, just copies the values from the specified Flash point.
	 * 
	 * @param	Point	Any Point.
	 * @return	A reference to itself.
	 */
	public inline function copyFromFlash(FlashPoint:Point):FlxPoint
	{
		x = FlashPoint.x;
		y = FlashPoint.y;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this point to the specified Flash point.
	 * 
	 * @param	Point	Any Point.
	 * @return	A reference to the altered point parameter.
	 */
	public inline function copyToFlash(FlashPoint:Point):Point
	{
		FlashPoint.x = x;
		FlashPoint.y = y;
		return FlashPoint;
	}
	
	/**
	 * Returns true if this point is within the given rectangular block
	 * 
	 * @param	RectX		The X value of the region to test within
	 * @param	RectY		The Y value of the region to test within
	 * @param	RectWidth	The width of the region to test within
	 * @param	RectHeight	The height of the region to test within
	 * @return	True if the point is within the region, otherwise false
	 */
	public inline function inCoords(RectX:Float, RectY:Float, RectWidth:Float, RectHeight:Float):Bool
	{
		return FlxMath.pointInCoordinates(x, y, RectX, RectY, RectWidth, RectHeight);
	}
	
	/**
	 * Returns true if this point is within the given rectangular block
	 * 
	 * @param	Rect	The FlxRect to test within
	 * @return	True if pointX/pointY is within the FlxRect, otherwise false
	 */
	public inline function inFlxRect(Rect:FlxRect):Bool
	{
		return FlxMath.pointInFlxRect(x, y, Rect);
	}
	
	/**
	 * Calculate the distance to another point.
	 * 
	 * @param 	AnotherPoint	A FlxPoint object to calculate the distance to.
	 * @return	The distance between the two points as a Float.
	 */
	public inline function distanceTo(AnotherPoint:FlxPoint):Float
	{
		return FlxMath.getDistance(this, AnotherPoint);
	}
	
	/**
	 * Rounds x and y using Math.floor()
	 */
	public inline function floor():FlxPoint
	{
		x = Math.floor(x);
		y = Math.floor(y);
		return this;
	}
	
	/**
	 * Rounds x and y using Math.ceil()
	 */
	public inline function ceil():FlxPoint
	{
		x = Math.ceil(x);
		y = Math.ceil(y);
		return this;
	}
	
	/**
	 * Necessary for IFlxDestroyable.
	 */
	public function destroy() {}
	
	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public inline function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y)]);
	}
	
	/**
	 * Necessary for FlxPointHelper in FlxSpriteGroup.
	 */
	private function set_x(Value:Float):Float 
	{ 
		return x = Value;
	}
	
	/**
	 * Necessary for FlxPointHelper in FlxSpriteGroup.
	 */
	private function set_y(Value:Float):Float
	{
		return y = Value; 
	}
}

/**
 * A FlxPoint that calls a function when set_x(), set_y() or set() is called. Used in FlxSpriteGroup.
 * IMPORTANT: Calling set(x, y); is MUCH FASTER than setting x and y separately. Needs to be destroyed unlike simple FlxPoints!
 */
class FlxCallbackPoint extends FlxPoint
{
	private var _setXCallback:FlxPoint->Void;
	private var _setYCallback:FlxPoint->Void;
	private var _setXYCallback:FlxPoint->Void;
	
	/**
	 * If you only specifiy one callback function, then the remaining two will use the same.
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
	
	override public inline function set(X:Float = 0, Y:Float = 0):FlxCallbackPoint
	{
		super.set(X, Y);
		if (_setXYCallback != null)
			_setXYCallback(this);
		return this;
	}
	
	override private inline function set_x(Value:Float):Float
	{
		super.set_x(Value);
		if (_setXCallback != null)
			_setXCallback(this);
		return Value;
	}
	
	override private inline function set_y(Value:Float):Float
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
