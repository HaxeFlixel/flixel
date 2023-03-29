package flixel.util.helpers;

import flixel.util.FlxStringUtil;

/**
 * Helper object for holding minimum and maximum values of various properties.
 */
class FlxBounds<T>
{
	/**
	 * The minimum value of this property.
	 */
	public var min:T;

	/**
	 * The maximum value of this property.
	 */
	public var max:T;

	/**
	 * A flag that can be used to toggle the use of this property.
	 */
	public var active:Bool = true;

	/**
	 * Create a new `FlxBounds` object. Must be typed (e.g., `var bounds = new FlxBounds<Float>(0, 0);`).
	 *
	 * @param min The minimum value of the property.
	 * @param max The maximum value of the property. Will be set to `min` if ignored.
	 */
	public function new(min:T, ?max:T)
	{
		this.min = min;
		this.max = max == null ? min : max;
	}

	/**
	 * Handy function to set the minimum and maximum values of this `FlxBounds` object in one line.
	 *
	 * @param min The new minimum value of the property.
	 * @param max The new maximum value of the property. Will be set equal to `min` if ignored.
	 * @return This `FlxBounds` instance (nice for chaining stuff together).
	 */
	public function set(min:T, ?max:T):FlxBounds<T>
	{
		this.min = min;
		this.max = max == null ? min : max;
		return this;
	}

	/**
	 * Compares this `FlxBounds` to another.
	 *
	 * @param otherBounds The other `FlxBounds` to compare to this one.
	 * @return Whether the `FlxBounds` instances have the same `min` and `max` values.
	 */
	public inline function equals(otherBounds:FlxBounds<T>):Bool
	{
		return min == otherBounds.min && max == otherBounds.max;
	}

	/**
	 * Converts the object to a readable string. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("min", min), LabelValuePair.weak("max", max)]);
	}
}
