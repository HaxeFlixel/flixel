package flixel.util.helpers;

import flixel.util.FlxStringUtil;

/**
 * Helper object for holding beginning and ending values of various properties.
 */
class FlxRange<T>
{
	/**
	 * The beginning value of this property.
	 */
	public var start:T;

	/**
	 * The ending value of this property.
	 */
	public var end:T;

	/**
	 * A flag that can be used to toggle the use of this property.
	 */
	public var active:Bool = true;

	/**
	 * Creates a new `FlxRange` object. Must be typed (e.g., `var myRange = new Range<Float>(0, 0);`).
	 *
	 * @param start The beginning value of the property.
	 * @param end The ending value of the property. Will be set to `start` if ignored.
	 */
	public function new(start:T, ?end:T)
	{
		this.start = start;
		this.end = end == null ? start : end;
	}

	/**
	 * Handy function to set the initial and final values of this `FlxRange` object in one line.
	 *
	 * @param start The new beginning value of the property.
	 * @param end The new final value of the property. Will be set to `start` if ignored.
	 * @return This `FlxRange` instance (nice for chaining stuff together).
	 */
	public function set(start:T, ?end:T):FlxRange<T>
	{
		this.start = start;
		this.end = end == null ? start : end;

		return this;
	}

	/**
	 * Compares this `FlxRange` to another.
	 *
	 * @param OtherFlxRange The other `FlxRange` to compare to this one.
	 * @return Whether the `FlxRange`s have the same `start` and `end` values.
	 */
	public inline function equals(OtherFlxRange:FlxRange<T>):Bool
	{
		return start == OtherFlxRange.start && end == OtherFlxRange.end;
	}

	/**
	 * Converts the object to a readable string. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("start", start), LabelValuePair.weak("end", end)]);
	}
}
