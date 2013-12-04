package flixel.util;

import flash.geom.Point;

/**
 * Stores a 2D floating point coordinate.
 */
class FlxPoint
{
	/**
	 * @default 0
	 */
	public var x(default, set):Float = 0;
	
	private function set_x(Value:Float):Float
	{
		return x = Value;
	}
	
	/**
	 * @default 0
	 */
	public var y(default, set):Float = 0;
	
	private function set_y(Value:Float):Float
	{
		return y = Value;
	}
	
	/**
	 * Instantiate a new point object.
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public function new(X:Float = 0, Y:Float = 0)
	{
		x = X;
		y = Y;
	}
	
	/**
	 * Set the coordinates of this point object.
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public function set(X:Float = 0, Y:Float = 0):FlxPoint
	{
		x = X;
		y = Y;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from the specified point.
	 * @param	Point	Any <code>FlxPoint</code>.
	 * @return	A reference to itself.
	 */
	public function copyFrom(point:FlxPoint):FlxPoint
	{
		x = point.x;
		y = point.y;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this point to the specified point.
	 * @param	Point	Any <code>FlxPoint</code>.
	 * @return	A reference to the altered point parameter.
	 */
	public function copyTo(point:FlxPoint = null):FlxPoint
	{
		if (point == null)
		{
			point = new FlxPoint();
		}
		point.x = x;
		point.y = y;
		return point;
	}
	
	/**
	 * Helper function, just copies the values from the specified Flash point.
	 * @param	Point	Any <code>Point</code>.
	 * @return	A reference to itself.
	 */
	public function copyFromFlash(FlashPoint:Point):FlxPoint
	{
		x = FlashPoint.x;
		y = FlashPoint.y;
		return this;
	}
	
	/**
	 * Helper function, just copies the values from this point to the specified Flash point.
	 * @param	Point	Any <code>Point</code>.
	 * @return	A reference to the altered point parameter.
	 */
	public function copyToFlash(FlashPoint:Point):Point
	{
		FlashPoint.x = x;
		FlashPoint.y = y;
		return FlashPoint;
	}
	
	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getClassName(this, true);
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
	inline public function inCoords(RectX:Float, RectY:Float, RectWidth:Float, RectHeight:Float):Bool
	{
		return FlxMath.pointInCoordinates(x, y, RectX, RectY, RectWidth, RectHeight);
	}
	
	/**
	 * Returns true if this point is within the given rectangular block
	 * 
	 * @param	Rect	The FlxRect to test within
	 * @return	True if pointX/pointY is within the FlxRect, otherwise false
	 */
	inline public function inFlxRect(Rect:FlxRect):Bool
	{
		return FlxMath.pointInFlxRect(x, y, Rect);
	}
	
	/**
	 * Calculate the distance to another point.
	 * 
	 * @param 	AnotherPoint	A <code>FlxPoint</code> object to calculate the distance to.
	 * @return	The distance between the two points as a Float.
	 */
	inline public function distanceTo(AnotherPoint:FlxPoint):Float
	{
		return FlxMath.getDistance(this, AnotherPoint);
	}
	
	public function destroy() { }
}