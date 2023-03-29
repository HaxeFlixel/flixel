package flixel.util.helpers;

import flixel.util.FlxStringUtil;

/**
 * Helper object for holding beginning minimum/maximum and ending minimum/maximum values of different properties.
 * It would extend `FlxRange<FlxBounds<T>>`, but this allows a more practical use of `set()`.
 */
class FlxRangeBounds<T>
{
	/**
	 * The beginning minimum and maximum values of this property.
	 */
	public var start:FlxBounds<T>;

	/**
	 * The ending minimum and maximum values of this property.
	 */
	public var end:FlxBounds<T>;

	/**
	 * A flag that can be used to toggle the use of this property.
	 */
	public var active:Bool = true;

	/**
	 * Creates a new `FlxRangeBounds` object. Must be typed (e.g., `var myRangeBounds = new RangeBounds<Float>(0, 0, 0, 0);`).
	 *
	 * @param startMin The minimum possible initial value of this property.
	 * @param startMax The maximum possible initial value of this property. Will be set to `startMin` if ignored.
	 * @param endMin The minimum possible final value of this property. Will be set to `startMin` if ignored.
	 * @param endMax The maximum possible final value of this property. Will be set to `startMax` if ignored.
	 * @return This `FlxRangeBounds` instance (nice for chaining stuff together).
	 */
	public function new(startMin:T, ?startMax:T, ?endMin:T, ?endMax:T)
	{
		start = new FlxBounds<T>(startMin, startMax == null ? startMin : startMax);
		end = new FlxBounds<T>(endMin == null ? startMin : endMin, endMax == null ? start.max : endMax);
	}

	/**
	 * Handy function to set the the beginning and ending range of values of this `FlxRangeBounds` object in one line.
	 *
	 * @param startMin The minimum possible initial value of this property.
	 * @param startMax The maximum possible initial value of this property. Will be set to `startMin` if ignored.
	 * @param endMin The minimum possible final value of this property. Will be set to `startMin` if ignored.
	 * @param endMax The maximum possible final value of this property. Will be set to `startMax` if ignored.
	 * @return This `FlxRangeBounds` instance (nice for chaining stuff together).
	 */
	public function set(startMin:T, ?startMax:T, ?endMin:T, ?endMax:T):FlxRangeBounds<T>
	{
		start.min = startMin;
		start.max = startMax == null ? start.min : startMax;
		end.min = endMin == null ? start.min : endMin;
		end.max = endMax == null ? (endMin == null ? start.max : end.min) : endMax;

		return this;
	}

	/**
	 * Compares this `FlxRangeBounds` to another.
	 *
	 * @param OtherRangeBounds The other `FlxRangeBounds` to compare to this one.
	 * @return Whether the `FlxRangeBounds` instances have the same `min` and `max` values.
	 */
	public inline function equals(OtherRangeBounds:FlxRangeBounds<T>):Bool
	{
		return start.equals(OtherRangeBounds.start) && end.equals(OtherRangeBounds.end);
	}

	/**
	 * Converts the object to a readable string. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("start.min", start.min),
			LabelValuePair.weak("start.max", start.min),
			LabelValuePair.weak("end.min", end.min),
			LabelValuePair.weak("end.max", end.max)
		]);
	}
}
