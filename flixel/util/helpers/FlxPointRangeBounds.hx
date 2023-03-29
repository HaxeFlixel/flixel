package flixel.util.helpers;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

/**
 * Helper object for holding beginning minimum/maximum and ending minimum/maximum values of `FlxPoint`s, which have both an `x` and `y` component.
 * This would extend `FlxRange<FlxBounds<FlxPoint>>`, but this allows a more practical use of `set()`.
 */
class FlxPointRangeBounds implements IFlxDestroyable
{
	/**
	 * The beginning x- and y-values of this property.
	 */
	public var start:FlxBounds<FlxPoint>;

	/**
	 * The ending x- and y-values of this property.
	 */
	public var end:FlxBounds<FlxPoint>;

	/**
	 * A flag that can be used to toggle the use of this property.
	 */
	public var active:Bool = true;

	/**
	 * Creates a new `FlxPointRangeBounds` object.
	 *
	 * @param startMinX The minimum possible initial x-value for this property.
	 * @param startMinY The minimum possible initial y-value for this property. Will be set to `startMinX` if ignored.
	 * @param startMaxX The maximum possible initial x-value for this property. Will be set to `startMinX` if ignored.
	 * @param startMaxY The maximum possible initial y-value for this property. Will be set to `startMinY` if ignored.
	 * @param endMinX The minimum possible final x-value for this property. Will be set to `startMinX` if ignored.
	 * @param endMinY The minimum possible final y-value for this property. Will be set to `startMinY` if ignored.
	 * @param endMaxX The maximum possible final x-value for this property. Will be set to `endMinX` if ignored.
	 * @param endMaxY The maximum possible final y-value for this property. Will be set to `endMinY` if ignored.
	 */
	public function new(startMinX:Float, ?startMinY:Float, ?startMaxX:Float, ?startMaxY:Float, ?endMinX:Float, ?endMinY:Float, ?endMaxX:Float, ?endMaxY:Float)
	{
		start = new FlxBounds<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		end = new FlxBounds<FlxPoint>(FlxPoint.get(), FlxPoint.get());

		set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY, endMaxX, endMaxY);
	}

	/**
	 * Handy function to set the the beginning and ending range of values of this `FlxPointRangeBounds` object in one line.
	 *
	 * @param startMinX The minimum possible initial x-value for this property.
	 * @param startMinY The minimum possible initial y-value for this property. Will be set to `startMinX` if ignored.
	 * @param startMaxX The maximum possible initial x-value for this property. Will be set to `startMinX` if ignored.
	 * @param startMaxY The maximum possible initial y-value for this property. Will be set to `startMinY` if ignored.
	 * @param endMinX The minimum possible final x-value for this property. Will be set to `startMinX` if ignored.
	 * @param endMinY The minimum possible final y-value for this property. Will be set to `startMinY` if ignored.
	 * @param endMaxX The maximum possible final x-value for this property. Will be set to `endMinX` if ignored.
	 * @param endMaxY The maximum possible final y-value for this property. Will be set to `endMinY` if ignored.
	 * @return This `FlxPointRangeBounds` instance (nice for chaining stuff together).
	 */
	public function set(startMinX:Float, ?startMinY:Float, ?startMaxX:Float, ?startMaxY:Float, ?endMinX:Float, ?endMinY:Float, ?endMaxX:Float,
			?endMaxY:Float):FlxPointRangeBounds
	{
		start.min.x = startMinX;
		start.min.y = startMinY == null ? start.min.x : startMinY;
		start.max.x = startMaxX == null ? start.min.x : startMaxX;
		start.max.y = startMaxY == null ? start.min.y : startMaxY;
		end.min.x = endMinX == null ? start.min.x : endMinX;
		end.min.y = endMinY == null ? start.min.y : endMinY;
		end.max.x = endMaxX == null ? (endMinX == null ? start.max.x : end.min.x) : endMaxX;
		end.max.y = endMaxY == null ? (endMinY == null ? start.max.y : end.min.y) : endMaxY;

		return this;
	}

	/**
	 * Compares this `FlxPointRangeBounds` to another.
	 *
	 * @param OtherFlxPointRangeBounds The other `FlxPointRangeBounds` to compare to this one.
	 * @return Whether the `FlxPointRangeBounds` instances have the same `min` and `max` values.
	 */
	public inline function equals(OtherFlxPointRangeBounds:FlxPointRangeBounds):Bool
	{
		return start.min.equals(OtherFlxPointRangeBounds.start.min)
			&& start.max.equals(OtherFlxPointRangeBounds.start.max)
			&& end.min.equals(OtherFlxPointRangeBounds.end.min)
			&& end.max.equals(OtherFlxPointRangeBounds.end.max);
	}

	/**
	 * Converts the object to readable a string. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("start.min.x", start.min.x),
			LabelValuePair.weak("start.min.y", start.min.y),
			LabelValuePair.weak("start.max.x", start.max.x),
			LabelValuePair.weak("start.max.y", start.max.y),
			LabelValuePair.weak("end.min.x", end.min.x),
			LabelValuePair.weak("end.min.y", end.min.y),
			LabelValuePair.weak("end.max.x", end.max.x),
			LabelValuePair.weak("end.max.y", end.max.y)
		]);
	}

	public function destroy():Void
	{
		start.min = FlxDestroyUtil.put(start.min);
		start.max = FlxDestroyUtil.put(start.max);
		end.min = FlxDestroyUtil.put(end.min);
		end.max = FlxDestroyUtil.put(end.max);
	}
}
