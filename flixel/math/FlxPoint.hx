package flixel.math;

import flash.geom.Point;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;
import openfl.geom.Matrix;

/**
 * Stores a 2D floating point coordinate.
 */
@:allow(flixel.math.FlxVector)
class FlxPoint implements IFlxPooled
{
	public static var pool(get, never):IFlxPool<FlxPoint>;

	static var _pool:FlxPool<FlxPoint> = new FlxPool<FlxPoint>(FlxPoint);

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
		var point = get(X, Y);
		point._weak = true;
		return point;
	}

	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;

	var _weak:Bool = false;
	var _inPool:Bool = false;

	@:keep
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
			_weak = false;
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
			put();
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
	 * Adds to the coordinates of this point.
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
		addPointWeak(point);
		point.putWeak();
		return this;
	}

	/**
	 * Adds the coordinates of another point to the coordinates of this point.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param	point	The point to add to this point
	 * @return	This point.
	 */
	inline function addPointWeak(point:FlxPoint):FlxPoint
	{
		x += point.x;
		y += point.y;
		return this;
	}

	/**
	 * Subtracts from the coordinates of this point.
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
	 * Subtracts the coordinates of another point from the coordinates of this point.
	 *
	 * @param	point	The point to subtract from this point
	 * @return	This point.
	 */
	public function subtractPoint(point:FlxPoint):FlxPoint
	{
		subtractPointWeak(point);
		point.putWeak();
		return this;
	}

	/**
	 * Subtracts the coordinates of another point from the coordinates of this point.
	 * Meant for internal use, does not call putWeak.
	 *
	 * @param	point	The point to subtract from this point
	 * @return	This point.
	 */
	inline function subtractPointWeak(point:FlxPoint):FlxPoint
	{
		x -= point.x;
		y -= point.y;
		return this;
	}

	/**
	 * Scale this point.
	 *
	 * @param	k - scale coefficient
	 * @return	scaled point
	 * @since   4.1.0
	 */
	public function scale(k:Float):FlxPoint
	{
		x *= k;
		y *= k;
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
		point.putWeak();
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
		if (FlashPoint == null)
		{
			FlashPoint = new Point();
		}

		FlashPoint.x = x;
		FlashPoint.y = y;
		return FlashPoint;
	}

	/**
	 * Helper function, just increases the values of the specified Flash point by the values of this point.
	 *
	 * @param	Point	Any Point.
	 * @return	A reference to the altered point parameter.
	 */
	public inline function addToFlash(FlashPoint:Point):Point
	{
		FlashPoint.x += x;
		FlashPoint.y += y;

		return FlashPoint;
	}

	/**
	 * Helper function, just decreases the values of the specified Flash point by the values of this point.
	 *
	 * @param	Point	Any Point.
	 * @return	A reference to the altered point parameter.
	 */
	public inline function subtractFromFlash(FlashPoint:Point):Point
	{
		FlashPoint.x -= x;
		FlashPoint.y -= y;

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
	public inline function inRect(Rect:FlxRect):Bool
	{
		return FlxMath.pointInFlxRect(x, y, Rect);
	}

	/**
	 * Calculate the distance to another point.
	 *
	 * @param 	AnotherPoint	A FlxPoint object to calculate the distance to.
	 * @return	The distance between the two points as a Float.
	 */
	public function distanceTo(point:FlxPoint):Float
	{
		var dx:Float = x - point.x;
		var dy:Float = y - point.y;
		point.putWeak();
		return FlxMath.vectorLength(dx, dy);
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
	 * Rounds x and y using Math.round()
	 */
	public inline function round():FlxPoint
	{
		x = Math.round(x);
		y = Math.round(y);
		return this;
	}

	/**
	 * Rotates this point clockwise in 2D space around another point by the given angle.
	 *
	 * @param   Pivot   The pivot you want to rotate this point around
	 * @param   Angle   Rotate the point by this many degrees clockwise.
	 * @return  A FlxPoint containing the coordinates of the rotated point.
	 */
	public function rotate(Pivot:FlxPoint, Angle:Float):FlxPoint
	{
		var radians:Float = Angle * FlxAngle.TO_RAD;
		var sin:Float = FlxMath.fastSin(radians);
		var cos:Float = FlxMath.fastCos(radians);

		var dx:Float = x - Pivot.x;
		var dy:Float = y - Pivot.y;
		x = cos * dx - sin * dy + Pivot.x;
		y = sin * dx + cos * dy + Pivot.y;

		Pivot.putWeak();
		return this;
	}

	/**
	 * Calculates the angle between this and another point. 0 degrees points straight up.
	 *
	 * @param   point   The other point.
	 * @return  The angle in degrees, between -180 and 180.
	 */
	public function angleBetween(point:FlxPoint):Float
	{
		var x:Float = point.x - x;
		var y:Float = point.y - y;
		var angle:Float = 0;

		if ((x != 0) || (y != 0))
		{
			var c1:Float = Math.PI * 0.25;
			var c2:Float = 3 * c1;
			var ay:Float = (y < 0) ? -y : y;

			if (x >= 0)
			{
				angle = c1 - c1 * ((x - ay) / (x + ay));
			}
			else
			{
				angle = c2 - c1 * ((x + ay) / (ay - x));
			}
			angle = ((y < 0) ? -angle : angle) * FlxAngle.TO_DEG;

			if (angle > 90)
			{
				angle = angle - 270;
			}
			else
			{
				angle += 90;
			}
		}

		point.putWeak();
		return angle;
	}

	/**
	 * Function to get a `FlxVector` from this `FlxPoint`
	 * @since 4.3.0
	 */
	@:deprecated("The `toVector` method is deprecated, FlxPoints can be casted to FlxVectors implicitly")
	public inline function toVector():FlxVector
	{
		return FlxVector.get(x, y);
	}

	/**
	 * Function to compare this FlxPoint to another.
	 *
	 * @param	point  The other FlxPoint to compare to this one.
	 * @return	True if the FlxPoints have the same x and y value, false otherwise.
	 */
	public inline function equals(point:FlxPoint):Bool
	{
		var result = FlxMath.equal(x, point.x) && FlxMath.equal(y, point.y);
		point.putWeak();
		return result;
	}

	/**
	 * Necessary for IFlxDestroyable.
	 */
	public function destroy() {}

	/**
	 * Applies transformation matrix to this point
	 * @param	matrix	transformation matrix
	 * @return	transformed point
	 */
	public inline function transform(matrix:Matrix):FlxPoint
	{
		var x1:Float = x * matrix.a + y * matrix.c + matrix.tx;
		var y1:Float = x * matrix.b + y * matrix.d + matrix.ty;

		return set(x1, y1);
	}

	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public inline function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("x", x), LabelValuePair.weak("y", y)]);
	}

	/**
	 * Necessary for FlxCallbackPoint.
	 */
	function set_x(Value:Float):Float
	{
		return x = Value;
	}

	/**
	 * Necessary for FlxCallbackPoint.
	 */
	function set_y(Value:Float):Float
	{
		return y = Value;
	}

	static function get_pool():IFlxPool<FlxPoint>
	{
		return _pool;
	}
}

/**
 * A FlxPoint that calls a function when set_x(), set_y() or set() is called. Used in FlxSpriteGroup.
 * IMPORTANT: Calling set(x, y); is MUCH FASTER than setting x and y separately. Needs to be destroyed unlike simple FlxPoints!
 */
class FlxCallbackPoint extends FlxPoint
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
