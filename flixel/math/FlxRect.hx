package flixel.math;

import flixel.util.FlxPool.IFlxPooled;
import flixel.util.FlxPool;
import flixel.util.FlxStringUtil;
import openfl.geom.Rectangle;

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
	 * @param   x       The X-coordinate of the point in space
	 * @param   y       The Y-coordinate of the point in space
	 * @param   width   Desired width of the rectangle
	 * @param   height  Desired height of the rectangle
	 * @return  This rectangle
	 */
	public inline function set(x = 0.0, y = 0.0, width = 0.0, height = 0.0):FlxRect
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
		return this;
	}
	
	/**
	 * Fill this rectangle from the two given corner locations
	 *
	 * @param   x1  The position of this rect
	 * @param   y1  The position of this rect
	 * @param   x2  The position of this rect's opposite corner
	 * @param   y2  The position of this rect's opposite corner
	 * @return  This rectangle
	 */
	public inline function setBounds(x1:Float, y1:Float, x2:Float, y2:Float):FlxRect
	{
		return set(x1, y1, x2 - x1, y2 - y1);
	}
	
	/**
	 * Fills the rectangle so that it has always has a positive width and height. For example:
	 * ```haxe
	 * rect.setAbs(100, 100, -50, -50);
	 * // Is the same as
	 * rect.set(50, 50, 50, 50);
	 * ```
	 * 
	 * @param x       The X-coordinate of the point in space
	 * @param y       The Y-coordinate of the point in space
	 * @param width   Desired width of the rectangle
	 * @param height  Desired height of the rectangle
	 * @return  This rectangle
	 */
	public inline function setAbs(x:Float, y:Float, width:Float, height:Float)
	{
		this.x = width > 0 ? x : x + width;
		this.y = height > 0 ? y : y + height;
		this.width = width > 0 ? width : -width;
		this.height = height > 0 ? height : -height;
		return this;
	}
	
	/**
	 * Fills the rectangle so that it has always has a positive width and height. For example:
	 * ```haxe
	 * rect.setBoundsAbs(100, 100, 50, 50);
	 * // Is the same as
	 * rect.setBounds(50, 50, 100, 100);
	 * // ...or
	 * rect.set(50, 50, 50, 50);
	 * ```
	 *
	 * @param   x1  The position of this rect
	 * @param   y1  The position of this rect
	 * @param   x2  The position of this rect's opposite corner
	 * @param   y2  The position of this rect's opposite corner
	 * @return  This rectangle
	 */
	public overload inline extern function setBoundsAbs(x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0):FlxRect
	{
		return setAbs(x1, y1, x2 - x1, y2 - y1);
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
	 * Checks to see if this rectangle overlaps another
	 *
	 * @param   rect  The other rectangle
	 * @return  Whether the two rectangles overlap
	 */
	public inline function overlaps(rect:FlxRect):Bool
	{
		final result = rect.right > left
			&& rect.left < right
			&& rect.bottom > top
			&& rect.top < bottom;
		rect.putWeak();
		return result;
	}

	/**
	 * Checks to see if this rectangle fully contains another
	 *
	 * @param   rect  The other rectangle
	 * @return  Whether this rectangle contains the given rectangle
	 * @since 6.1.0
	 */
	public inline function contains(rect:FlxRect):Bool
	{
		final result = rect.left >= left
			&& rect.right <= right
			&& rect.top >= top
			&& rect.bottom <= bottom;
		rect.putWeak();
		return result;
	}

	/**
	 * Returns true if this FlxRect contains the FlxPoint
	 *
	 * @param   point  The FlxPoint to check
	 * @return  True if the FlxPoint is within this FlxRect, otherwise false
	 */
	public inline function containsPoint(point:FlxPoint):Bool
	{
		final result = containsXY(point.x, point.y);
		point.putWeak();
		return result;
	}

	/**
	 * Returns true if this FlxRect contains the FlxPoint
	 *
	 * @param   xPos  The x position to check
	 * @param   yPos  The y position to check
	 * @return  True if the FlxPoint is within this FlxRect, otherwise false
	 */
	public inline function containsXY(xPos:Float, yPos:Float):Bool
	{
		return xPos >= left && xPos <= right && yPos >= top && yPos <= bottom;
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
	 * @param   rect    Rectangle to check intersection against
	 * @param   result  The resulting instance, if `null`, a new one is created
	 * @return  The area of intersection of two rectangles
	 */
	public function intersection(rect:FlxRect, ?result:FlxRect):FlxRect
	{
		if (result == null)
			result = FlxRect.get();
		
		final x0:Float = x < rect.x ? rect.x : x;
		final x1:Float = right > rect.right ? rect.right : right;
		final y0:Float = y < rect.y ? rect.y : y;
		final y1:Float = bottom > rect.bottom ? rect.bottom : bottom;
		rect.putWeak();
		
		if (x1 <= x0 || y1 <= y0)
			return result.set(0, 0, 0, 0);
		
		return result.set(x0, y0, x1 - x0, y1 - y0);
	}
	
	/**
	 * Resizes `this` instance so that it fits within the intersection of the this and
	 * the target rect. If there is no overlap between them, The result is an empty rect.
	 *
	 * @param   rect    Rectangle to check intersection against
	 * @return  This rect, useful for chaining
	 * @since 5.9.0
	 */
	public function clipTo(rect:FlxRect):FlxRect
	{
		return rect.intersection(this, this);
	}
	
	/**
	 * The middle point of this rect
	 * 
	 * @param   point  The point to hold the result, if `null` a new one is created
	 * @since 5.9.0
	 */
	public function getMidpoint(?point:FlxPoint)
	{
		if (point == null)
			point = FlxPoint.get();
		
		return point.set(x + 0.5 * width, y + 0.5 * height);
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

@:forward
@:forward.new
@:forward.variance
abstract FlxReadOnlyRect(FlxRect) from FlxRect to IFlxPooled
{
	public static var pool(get, never):IFlxPool<FlxRect>;
	static inline function get_pool()
	{
		return FlxRect.pool;
	}

	/**
	 * Recycle or create new FlxRect.
	 * Be sure to put() them back into the pool after you're done with them!
	 */
	public static inline function get(x = 0.0, y = 0.0, width = 0.0, height = 0.0):FlxReadOnlyRect
	{
		return FlxRect.get(x, y, width, height);
	}

	/**
	 * Recycle or create a new FlxRect which will automatically be released
	 * to the pool when passed into a flixel function.
	 */
	public static inline function weak(x = 0.0, y = 0.0, width = 0.0, height = 0.0):FlxReadOnlyRect
	{
		return FlxRect.weak(x, y, width, height);
	}

	public var x(get, never):Float;
	inline function get_x() return this.x;
	
	public var y(get, never):Float;
	inline function get_y() return this.y;
	
	public var width(get, never):Float;
	inline function get_width() return this.width;
	
	public var height(get, never):Float;
	inline function get_height() return this.height;
	
	/** The x coordinate of the left side of the rectangle */
	public var left(get, never):Float;
	inline function get_left() return this.left;

	/** The x coordinate of the right side of the rectangle */
	public var right(get, never):Float;
	inline function get_right() return this.right;

	/** The y coordinate of the top of the rectangle */
	public var top(get, never):Float;
	inline function get_top() return this.top;

	/** The y coordinate of the bottom of the rectangle */
	public var bottom(get, never):Float;
	inline function get_bottom() return this.bottom;
	
	/** Whether width or height of this rectangle is equal to zero or not */
	public var isEmpty(get, never):Bool;
	inline function get_isEmpty() return this.isEmpty;
	
	// Hide functions that set fields, by making private versions
	inline function destroy() return this.destroy();
	inline function setSize(w, h) return this.setSize(w, h);
	inline function setPosition(x, y) return this.setPosition(x, y);
	inline function set(x = 0.0, y = 0.0, w = 0.0, h = 0.0) return this.set(x, y, w, h);
	inline function setBounds(x1, y1, x2, y2) return this.setBounds(x1, y1, x2, y2);
	inline function setAbs(x, y, w, h) return this.setAbs(x, y, w, h);
	inline function setBoundsAbs(x1 = 0.0, y1 = 0.0, x2 = 0.0, y2 = 0.0) return this.setBoundsAbs(x1, y1, x2, y2);
	inline function copyFrom(rect) return this.copyFrom(rect);
	inline function copyFromFlash(rect) return this.copyFromFlash(rect);
	inline function union(rect) return this.union(rect);
	inline function floor() return this.floor();
	inline function ceil() return this.ceil();
	inline function round() return this.round();
	inline function fromTwoPoints(p1, p2) return this.fromTwoPoints(p1, p2);
	inline function unionWithPoint(p) return this.unionWithPoint(p);
	inline function offset(dx, dy) return this.offset(dx, dy);
	inline function clipTo(rect) return this.clipTo(rect);
}
