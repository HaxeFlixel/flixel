package flixel.math;

import openfl.geom.Rectangle;
import flixel.util.FlxPool;
import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxStringUtil;

/**
 * Stores a rectangle.
 */
class FlxRect implements IFlxPooled
{
	public static var pool(get, never):IFlxPool<FlxRect>;

	static var _pool:FlxPool<FlxRect> = new FlxPool(FlxRect.new.bind(0, 0, 0, 0));
	// With the version below, this caused weird CI issues when FLX_NO_POINT_POOL is defined
	// static var _pool = new FlxPool<FlxRect>(FlxRect);

	/**
	 * Recycle or create new FlxRect.
	 * Be sure to put() them back into the pool after you're done with them!
	 */
	public static inline function get(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0):FlxRect
	{
		var rect = _pool.get().set(X, Y, Width, Height);
		rect._inPool = false;
		return rect;
	}

	/**
	 * Recycle or create a new FlxRect which will automatically be released
	 * to the pool when passed into a flixel function.
	 */
	public static inline function weak(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0):FlxRect
	{
		var rect = get(X, Y, Width, Height);
		rect._weak = true;
		return rect;
	}

	public var x:Float;
	public var y:Float;
	public var width:Float;
	public var height:Float;

	/**
	 * The x coordinate of the left side of the rectangle.
	 */
	public var left(get, set):Float;

	/**
	 * The x coordinate of the right side of the rectangle.
	 */
	public var right(get, set):Float;

	/**
	 * The y coordinate of the top of the rectangle.
	 */
	public var top(get, set):Float;

	/**
	 * The y coordinate of the bottom of the rectangle.
	 */
	public var bottom(get, set):Float;

	/**
	 * Whether width or height of this rectangle is equal to zero or not.
	 */
	public var isEmpty(get, never):Bool;

	var _weak:Bool = false;
	var _inPool:Bool = false;

	@:keep
	public function new(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0)
	{
		set(X, Y, Width, Height);
	}

	/**
	 * Add this FlxRect to the recycling pool.
	 */
	public inline function put():Void
	{
		if (!_inPool)
		{
			_inPool = true;
			_weak = false;
			_pool.putUnsafe(this);
		}
	}

	/**
	 * Add this FlxRect to the recycling pool if it's a weak reference (allocated via weak()).
	 */
	public inline function putWeak():Void
	{
		if (_weak)
		{
			put();
		}
	}

	/**
	 * Shortcut for setting both width and Height.
	 *
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	public inline function setSize(Width:Float, Height:Float):FlxRect
	{
		width = Width;
		height = Height;
		return this;
	}

	/**
	 * Shortcut for setting both x and y.
	 */
	public inline function setPosition(x:Float, y:Float):FlxRect
	{
		this.x = x;
		this.y = y;
		return this;
	}

	/**
	 * Fill this rectangle with the data provided.
	 *
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Width	Desired width of the rectangle.
	 * @param	Height	Desired height of the rectangle.
	 * @return	A reference to itself.
	 */
	public inline function set(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0):FlxRect
	{
		x = X;
		y = Y;
		width = Width;
		height = Height;
		return this;
	}

	/**
	 * Helper function, just copies the values from the specified rectangle.
	 *
	 * @param	Rect	Any FlxRect.
	 * @return	A reference to itself.
	 */
	public inline function copyFrom(Rect:FlxRect):FlxRect
	{
		x = Rect.x;
		y = Rect.y;
		width = Rect.width;
		height = Rect.height;

		Rect.putWeak();
		return this;
	}

	/**
	 * Helper function, just copies the values from this rectangle to the specified rectangle.
	 *
	 * @param	Point	Any FlxRect.
	 * @return	A reference to the altered rectangle parameter.
	 */
	public inline function copyTo(Rect:FlxRect):FlxRect
	{
		Rect.x = x;
		Rect.y = y;
		Rect.width = width;
		Rect.height = height;

		Rect.putWeak();
		return Rect;
	}

	/**
	 * Helper function, just copies the values from the specified Flash rectangle.
	 *
	 * @param	FlashRect	Any Rectangle.
	 * @return	A reference to itself.
	 */
	public inline function copyFromFlash(FlashRect:Rectangle):FlxRect
	{
		x = FlashRect.x;
		y = FlashRect.y;
		width = FlashRect.width;
		height = FlashRect.height;
		return this;
	}

	/**
	 * Helper function, just copies the values from this rectangle to the specified Flash rectangle.
	 *
	 * @param	Point	Any Rectangle.
	 * @return	A reference to the altered rectangle parameter.
	 */
	public inline function copyToFlash(?FlashRect:Rectangle):Rectangle
	{
		if (FlashRect == null)
		{
			FlashRect = new Rectangle();
		}

		FlashRect.x = x;
		FlashRect.y = y;
		FlashRect.width = width;
		FlashRect.height = height;
		return FlashRect;
	}

	/**
	 * Checks to see if some FlxRect object overlaps this FlxRect object.
	 *
	 * @param	Rect	The rectangle being tested.
	 * @return	Whether or not the two rectangles overlap.
	 */
	public inline function overlaps(Rect:FlxRect):Bool
	{
		var result = (Rect.x + Rect.width > x) && (Rect.x < x + width) && (Rect.y + Rect.height > y) && (Rect.y < y + height);
		Rect.putWeak();
		return result;
	}

	/**
	 * Returns true if this FlxRect contains the FlxPoint
	 *
	 * @param	Point	The FlxPoint to check
	 * @return	True if the FlxPoint is within this FlxRect, otherwise false
	 */
	public inline function containsPoint(Point:FlxPoint):Bool
	{
		var result = FlxMath.pointInFlxRect(Point.x, Point.y, this);
		Point.putWeak();
		return result;
	}

	/**
	 * Add another rectangle to this one by filling in the
	 * horizontal and vertical space between the two rectangles.
	 *
	 * @param	Rect	The second FlxRect to add to this one
	 * @return	The changed FlxRect
	 */
	public inline function union(Rect:FlxRect):FlxRect
	{
		var minX:Float = Math.min(x, Rect.x);
		var minY:Float = Math.min(y, Rect.y);
		var maxX:Float = Math.max(right, Rect.right);
		var maxY:Float = Math.max(bottom, Rect.bottom);

		Rect.putWeak();
		return set(minX, minY, maxX - minX, maxY - minY);
	}

	/**
	 * Rounds x, y, width and height using Math.floor()
	 */
	public inline function floor():FlxRect
	{
		x = Math.floor(x);
		y = Math.floor(y);
		width = Math.floor(width);
		height = Math.floor(height);
		return this;
	}

	/**
	 * Rounds x, y, width and height using Math.ceil()
	 */
	public inline function ceil():FlxRect
	{
		x = Math.ceil(x);
		y = Math.ceil(y);
		width = Math.ceil(width);
		height = Math.ceil(height);
		return this;
	}

	/**
	 * Rounds x, y, width and height using Math.round()
	 */
	public inline function round():FlxRect
	{
		x = Math.round(x);
		y = Math.round(y);
		width = Math.round(width);
		height = Math.round(height);
		return this;
	}

	/**
	 * Calculation of bounding box for two points
	 *
	 * @param	point1	first point to calculate bounding box
	 * @param	point2	second point to calculate bounding box
	 * @return	this rectangle filled with the position and size of bounding box for two specified points
	 */
	public inline function fromTwoPoints(Point1:FlxPoint, Point2:FlxPoint):FlxRect
	{
		var minX:Float = Math.min(Point1.x, Point2.x);
		var minY:Float = Math.min(Point1.y, Point2.y);

		var maxX:Float = Math.max(Point1.x, Point2.x);
		var maxY:Float = Math.max(Point1.y, Point2.y);

		Point1.putWeak();
		Point2.putWeak();
		return this.set(minX, minY, maxX - minX, maxY - minY);
	}

	/**
	 * Add another point to this rectangle one by filling in the
	 * horizontal and vertical space between the point and this rectangle.
	 *
	 * @param	Point	point to add to this one
	 * @return	The changed FlxRect
	 */
	public inline function unionWithPoint(Point:FlxPoint):FlxRect
	{
		var minX:Float = Math.min(x, Point.x);
		var minY:Float = Math.min(y, Point.y);
		var maxX:Float = Math.max(right, Point.x);
		var maxY:Float = Math.max(bottom, Point.y);

		Point.putWeak();
		return set(minX, minY, maxX - minX, maxY - minY);
	}

	public inline function offset(dx:Float, dy:Float):FlxRect
	{
		x += dx;
		y += dy;
		return this;
	}

	/**
	 * Calculates the globally aligned bounding box of a `FlxRect` with the given angle and origin.
	 * @param degrees The rotation, in degrees of the rect.
	 * @param origin  The relative pivot point, or the point that the rectangle rotates around.
	 *                if `null` , the top-left (or 0,0) is used.
	 * @param newRect Optional output `FlxRect`, if `null`, a new one is created. Note: If you like, you can
	 *                pass in the input rect to manipulate it. ex: `rect.calcRotatedBounds(angle, null, rect)`
	 * @return A globally aligned `FlxRect` that fully contains the input rectangle.
	 * @since 4.11.0
	 */
	public function getRotatedBounds(degrees:Float, ?origin:FlxPoint, ?newRect:FlxRect):FlxRect
	{
		if (origin == null)
			origin = FlxPoint.weak(0, 0);
		
		if (newRect == null)
			newRect = FlxRect.get();
		
		degrees = degrees % 360;
		if (degrees == 0)
		{
			origin.putWeak();
			return newRect.set(x, y, width, height);
		}
		
		if (degrees < 0)
			degrees += 360;
		
		var radians = FlxAngle.TO_RAD * degrees;
		var cos = Math.cos(radians);
		var sin = Math.sin(radians);
		
		var left = -origin.x;
		var top = -origin.y;
		var right = -origin.x + width;
		var bottom = -origin.y + height;
		if (degrees < 90)
		{
			newRect.x = x + origin.x + cos * left - sin * bottom;
			newRect.y = y + origin.y + sin * left + cos * top;
		}
		else if (degrees < 180)
		{
			newRect.x = x + origin.x + cos * right - sin * bottom;
			newRect.y = y + origin.y + sin * left  + cos * bottom;
		}
		else if (degrees < 270)
		{
			newRect.x = x + origin.x + cos * right - sin * top;
			newRect.y = y + origin.y + sin * right + cos * bottom;
		}
		else
		{
			newRect.x = x + origin.x + cos * left - sin * top;
			newRect.y = y + origin.y + sin * right + cos * top;
		}
		// temp var, in case input rect is the output rect
		var newHeight = Math.abs(cos * height) + Math.abs(sin * width );
		newRect.width = Math.abs(cos * width ) + Math.abs(sin * height);
		newRect.height = newHeight;
		
		origin.putWeak();
		return newRect;
	}

	/**
	 * Necessary for IFlxDestroyable.
	 */
	public function destroy() {}

	/**
	 * Checks if this rectangle's properties are equal to properties of provided rect.
	 *
	 * @param	rect	Rectangle to check equality to.
	 * @return	Whether both rectangles are equal.
	 */
	public inline function equals(rect:FlxRect):Bool
	{
		var result = FlxMath.equal(x, rect.x) && FlxMath.equal(y, rect.y) && FlxMath.equal(width, rect.width) && FlxMath.equal(height, rect.height);
		rect.putWeak();
		return result;
	}

	/**
	 * Returns the area of intersection with specified rectangle.
	 * If the rectangles do not intersect, this method returns an empty rectangle.
	 *
	 * @param	rect	Rectangle to check intersection against.
	 * @return	The area of intersection of two rectangles.
	 */
	public function intersection(rect:FlxRect, ?result:FlxRect):FlxRect
	{
		if (result == null)
			result = FlxRect.get();

		var x0:Float = x < rect.x ? rect.x : x;
		var x1:Float = right > rect.right ? rect.right : right;
		if (x1 <= x0)
		{
			rect.putWeak();
			return result;
		}

		var y0:Float = y < rect.y ? rect.y : y;
		var y1:Float = bottom > rect.bottom ? rect.bottom : bottom;
		if (y1 <= y0)
		{
			rect.putWeak();
			return result;
		}

		rect.putWeak();
		return result.set(x0, y0, x1 - x0, y1 - y0);
	}

	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public inline function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y),
			LabelValuePair.weak("w", width),
			LabelValuePair.weak("h", height)
		]);
	}

	inline function get_left():Float
	{
		return x;
	}

	inline function set_left(Value:Float):Float
	{
		width -= Value - x;
		return x = Value;
	}

	inline function get_right():Float
	{
		return x + width;
	}

	inline function set_right(Value:Float):Float
	{
		width = Value - x;
		return Value;
	}

	inline function get_top():Float
	{
		return y;
	}

	inline function set_top(Value:Float):Float
	{
		height -= Value - y;
		return y = Value;
	}

	inline function get_bottom():Float
	{
		return y + height;
	}

	inline function set_bottom(Value:Float):Float
	{
		height = Value - y;
		return Value;
	}

	inline function get_isEmpty():Bool
	{
		return width == 0 || height == 0;
	}

	static function get_pool():IFlxPool<FlxRect>
	{
		return _pool;
	}
}
