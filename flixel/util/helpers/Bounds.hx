package flixel.util.helpers;

/**
 * Helper object for holding bounds of various properties.
 */
class Bounds<T:(Float, Int)>
{
	public var min:T;
	public var max:T;
	public var range(get, set):T;
	
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
	
	private inline function get_range():T
	{
		return (max - min);
	}
	
	private inline function set_range(Value:T):T
	{
		max = Value - min;
		
		return range;
	}
	
	@:op("=", true)
	private inline function assign(Value:T):Bounds<T>
	{
		return min = max = Value;
	}
	
	@:commutative
	@:op(A == B)
	private static inline function equal<T>(lhs:Bounds<T>, rhs:Bounds<T>):Bool
	{
		return lhs.min == rhs.min && lhs.max == rhs.max;
	}
	
	@:commutative
	@:op(A == B)
	private static inline function equal<T>(lhs:Bounds<T>, rhs:Bounds<T>):Bool
	{
		return lhs.min != rhs.min || lhs.max != rhs.max;
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("min", min),
			LabelValuePair.weak("max", max)]);
	}
}