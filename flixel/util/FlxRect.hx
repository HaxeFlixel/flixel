package flixel.util;

import flash.geom.Rectangle;
import flixel.FlxG;

/**
 * Stores a rectangle.
 */
class FlxRect
{
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
	 * Shortcut for setting both width and Height.
	 * 
	 * @param	Width	The new sprite width.
	 * @param	Height	The new sprite height.
	 */
	inline public function setSize(Width:Float, Height:Float)
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
	inline public function set(X:Float = 0, Y:Float = 0, Width:Float = 0, Height:Float = 0):FlxRect
	{
		x = X;
		y = Y;
		width = Width;
		height = Height;
		return this;
	}

	/**
	 * Helper function, just copies the values from the specified rectangle.
	 * @param	Rect	Any <code>FlxRect</code>.
	 * @return	A reference to itself.
	 */
	inline public function copyFrom(Rect:FlxRect):FlxRect
	{
		x = Rect.x;
		y = Rect.y;
		width = Rect.width;
		height = Rect.height;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this rectangle to the specified rectangle.
	 * @param	Point	Any <code>FlxRect</code>.
	 * @return	A reference to the altered rectangle parameter.
	 */
	inline public function copyTo(Rect:FlxRect):FlxRect
	{
		Rect.x = x;
		Rect.y = y;
		Rect.width = width;
		Rect.height = height;
		return Rect;
	}
	
	/**
	 * Helper function, just copies the values from the specified Flash rectangle.
	 * @param	FlashRect	Any <code>Rectangle</code>.
	 * @return	A reference to itself.
	 */
	inline public function copyFromFlash(FlashRect:Rectangle):FlxRect
	{
		x = FlashRect.x;
		y = FlashRect.y;
		width = FlashRect.width;
		height = FlashRect.height;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this rectangle to the specified Flash rectangle.
	 * @param	Point	Any <code>Rectangle</code>.
	 * @return	A reference to the altered rectangle parameter.
	 */
	inline public function copyToFlash(FlashRect:Rectangle):Rectangle
	{
		FlashRect.x = x;
		FlashRect.y = y;
		FlashRect.width = width;
		FlashRect.height = height;
		return FlashRect;
	}
	
	/**
	 * Checks to see if some <code>FlxRect</code> object overlaps this <code>FlxRect</code> object.
	 * @param	Rect	The rectangle being tested.
	 * @return	Whether or not the two rectangles overlap.
	 */
	inline public function overlaps(Rect:FlxRect):Bool
	{
		return (Rect.x + Rect.width > x) && (Rect.x < x + width) && (Rect.y + Rect.height > y) && (Rect.y < y + height);
	}
	
	/**
	 * Returns true if this FlxRect contains the FlxPoint
	 * 
	 * @param	Point	The FlxPoint to check
	 * @return	True if the FlxPoint is within this FlxRect, otherwise false
	 */
	inline public function containsFlxPoint(Point:FlxPoint):Bool
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
	inline public function union(Rect:FlxRect):FlxRect
	{
		var minX:Float = Math.min(x, Rect.x);
		var minY:Float = Math.min(y, Rect.y);
		var maxX:Float = Math.max(right, Rect.right);
		var maxY:Float = Math.max(bottom, Rect.bottom);
		
		return set(minX, minY, maxX - minX, maxY - minY);
	}
	
	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	inline public function toString():String
	{
		var p = FlxG.debugger.precision;
		return "(x: " + FlxMath.roundDecimal(x, p) + " | y: " + FlxMath.roundDecimal(y, p) + " | w: " + FlxMath.roundDecimal(width, p) + " | h: " + FlxMath.roundDecimal(height, p) + ")"; 
	}
}