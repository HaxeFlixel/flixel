/**
 * ...
 * @author Zaphod
 */

package org.flixel;
import nme.geom.Point;

/**
 * Stores a 2D floating point coordinate.
 */
class FlxPoint 
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
	 * Instantiate a new point object.
	 * @param	X		The X-coordinate of the point in space.
	 * @param	Y		The Y-coordinate of the point in space.
	 */
	inline public function make(X:Float = 0, Y:Float = 0):FlxPoint
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
	inline public function copyFrom(point:FlxPoint):FlxPoint
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
	inline public function copyTo(point:FlxPoint):FlxPoint
	{
		point.x = x;
		point.y = y;
		return point;
	}
	
	/**
	 * Helper function, just copies the values from the specified Flash point.
	 * @param	Point	Any <code>Point</code>.
	 * @return	A reference to itself.
	 */
	inline public function copyFromFlash(FlashPoint:Point):FlxPoint
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
	inline public function copyToFlash(FlashPoint:Point):Point
	{
		FlashPoint.x = x;
		FlashPoint.y = y;
		return FlashPoint;
	}
	
	/**
	 * Convert object to readable string name.  Useful for debugging, save games, etc.
	 */
	inline public function toString():String
	{
		return FlxU.getClassName(this, true);
	}
	
}