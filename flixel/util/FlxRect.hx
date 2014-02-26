package flixel.util;

import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;

/**
 * Stores a rectangle.
 */
class FlxRect implements IFlxDestroyable
{
	/**
	 * A pool that contains FlxTimers for recycling.
	 */
	public static var pool = new FlxPool<FlxRect>(FlxRect);
	
	/**
	 * @default 0
	 */
	public var x:Float;
	/**
	 * @default 0
	 */
	public var y:Float;
	/**
	 * @default 0
	 */
	public var width:Float;
	/**
	 * @default 0
	 */
	public var height:Float;
	
	/**
	 * Instantiate a new rectangle.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 * @param	Width	Desired width of the rectangle.
	 * @param	Height	Desired height of the rectangle.
	 */
	public function new(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0)
	{
		x = X; 
		y = Y;
		width = Width;
		height = Height;
	}
	
	/**
	 * Recycle or create new FlxRect.
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public static inline function get(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0):FlxRect
	{
		return pool.get().set(X, Y, Width, Height);
	}
	
	/**
	 * Add this FlxRect to the recycling pool.
	 */
	public inline function put():Void
	{
		pool.put(this);
	}
	
	/**
	 * Shortcut for setting both width and Height.
	 * 
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	public inline function setSize(Width:Float, Height:Float)
	{
		width = Width;
		height = Height;
	}
	
	/**
	 * The x coordinate of the left side of the rectangle.
	 */
	public var left(get, set):Float;
	
	private function get_left():Float
	{
		return x;
	}
	
	private function set_left(Value:Float):Float
	{
		width -= Value - x;
		return x = Value;
	}
	
	/**
	 * The x coordinate of the right side of the rectangle.
	 */
	public var right(get, set):Float;
	
	private function get_right():Float
	{
		return x + width;
	}
	
	private function set_right(Value:Float):Float
	{
		width = Value - x;
		return Value;
	}
	
	/**
	 * The x coordinate of the top of the rectangle.
	 */
	public var top(get, set):Float;
	
	private function get_top():Float
	{
		return y;
	}
	
	private function set_top(Value:Float):Float
	{
		height -= Value - y;
		return y = Value;
	}
	
	/**
	 * The y coordinate of the bottom of the rectangle.
	 */
	public var bottom(get, set):Float;
	
	private function get_bottom():Float
	{
		return y + height;
	}
	
	private function set_bottom(Value:Float):Float
	{
		height = Value - y;
		return Value;
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
	 * @param	Rect	Any FlxRect.
	 * @return	A reference to itself.
	 */
	public inline function copyFrom(Rect:FlxRect):FlxRect
	{
		x = Rect.x;
		y = Rect.y;
		width = Rect.width;
		height = Rect.height;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this rectangle to the specified rectangle.
	 * @param	Point	Any FlxRect.
	 * @return	A reference to the altered rectangle parameter.
	 */
	public inline function copyTo(Rect:FlxRect):FlxRect
	{
		Rect.x = x;
		Rect.y = y;
		Rect.width = width;
		Rect.height = height;
		return Rect;
	}
	
	/**
	 * Helper function, just copies the values from the specified Flash rectangle.
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
	 * @param	Point	Any Rectangle.
	 * @return	A reference to the altered rectangle parameter.
	 */
	public inline function copyToFlash(FlashRect:Rectangle):Rectangle
	{
		FlashRect.x = x;
		FlashRect.y = y;
		FlashRect.width = width;
		FlashRect.height = height;
		return FlashRect;
	}
	
	/**
	 * Checks to see if some FlxRect object overlaps this FlxRect object.
	 * @param	Rect	The rectangle being tested.
	 * @return	Whether or not the two rectangles overlap.
	 */
	public inline function overlaps(Rect:FlxRect):Bool
	{
		return (Rect.x + Rect.width > x) && (Rect.x < x + width) && (Rect.y + Rect.height > y) && (Rect.y < y + height);
	}
	
	/**
	 * Returns true if this FlxRect contains the FlxPoint
	 * 
	 * @param	Point	The FlxPoint to check
	 * @return	True if the FlxPoint is within this FlxRect, otherwise false
	 */
	public inline function containsFlxPoint(Point:FlxPoint):Bool
	{
		return FlxMath.pointInFlxRect(Point.x, Point.y, this);
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
		
		return set(minX, minY, maxX - minX, maxY - minY);
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
		return FlxStringUtil.getDebugString([ { label: "x", value: x }, 
		                                      { label: "y", value: y },
		                                      { label: "w", value: width },
		                                      { label: "h", value: height } ]);
	}
}