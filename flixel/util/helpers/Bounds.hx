package flixel.util.helpers;

import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;

/**
 * Helper object for holding bounds of various properties.
 */
class Bounds<T>
{
	public var min:T;
	public var max:T;
	
	/**
	 * Create a new Bounds object. Must be typed, e.g. var myBounds = new Bounds<Float>(0, 0);
	 * 
	 * @param	min  The minimum value of the property.
	 * @param	max  The maximum value of the property. Optional, will be set equal to min if ignored.
	 */
	public function new(min:T, ?max:Null<T>)
	{
		this.min = min;
		this.max = max == null ? min : max;
	}
	
	/**
	 * Handy function to set the minimum and maximum values of this Bounds object in one line.
	 * 
	 * @param	min  The new minimum value of the property.
	 * @param	max  The new maximum value of the property. Optional, will be set equal to min if ignored.
	 * @return  This Bounds instance (nice for chaining stuff together).
	 */
	public function set(min:T, ?max:Null<T>):Bounds<T>
	{
		this.min = min;
		this.max = max == null ? min : max;
		return this;
	}
	
	/**
	 * Function to compare two Bounds objects of the same type.
	 */
	public static inline function equal<T>(Bounds1:Bounds<T>, Bounds2:Bounds<T>):Bool
	{
		return Bounds1.min == Bounds2.min && Bounds1.max == Bounds2.max;
	}
	
	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("min", min),
			LabelValuePair.weak("max", max)]);
	}
}