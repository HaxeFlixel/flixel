package flixel.util;

import flixel.FlxG;
import flash.geom.Point;
import flixel.interfaces.IFlxDestroyable;

/**
 * Stores a 2D floating point coordinate.
 */
class FlxPoint implements IFlxDestroyable
{
	public static var pool = new FlxPool<FlxPoint>(FlxPoint);
	
	/**
	 * Recycle or create a new FlxPoint. 
	 * Be sure to put() them back into the pool after you're done with them!
	 * 
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	public static inline function get(X:Float = 0, Y:Float = 0):FlxPoint
	{
		return pool.get().set(X, Y);
	}
	
	public var x(default, set):Float = 0;
	public var y(default, set):Float = 0;
	
	/**
	 * Add this FlxPoint to the recycling pool.
	 */
	public inline function put():Void
	{
		pool.put(this);
	}
	
	/**
	 * Set the coordinates of this point object.
	 * 
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
	 * 
	 * @param	Point	Any FlxPoint.
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
	public function copyFromFlash(FlashPoint:Point):FlxPoint
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
	public function copyToFlash(FlashPoint:Point):Point
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
		return FlxStringUtil.getDebugString([ { label: "x", value: x }, 
		                                      { label: "y", value: y }]);
	}
	
	private function new() {}
	
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
