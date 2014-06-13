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
		set(min, max);
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
	 * Allows simple comparison of two Bounds objects, so that (bounds1 == bounds2) will be true if both contain the same min and max values.
	 */
	@:commutative
	@:op(A == B)
	private static inline function equal<T>(lhs:Bounds<T>, rhs:Bounds<T>):Bool
	{
		return lhs.min == rhs.min && lhs.max == rhs.max;
	}
	
	@:commutative
	@:op(A != B)
	private static inline function notEqual<T>(lhs:Bounds<T>, rhs:Bounds<T>):Bool
	{
		return lhs.min != rhs.min || lhs.max != rhs.max;
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