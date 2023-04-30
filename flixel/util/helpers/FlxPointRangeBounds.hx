package flixel.util.helpers;

import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

/**
 * Helper object for holding beginning minimum/maximum and ending minimum/maximum values of FlxPoints, which have both an x and y component.
 * This would extends Range<Bounds<FlxPoint>> but this allows a more practical use of set().
 */
class FlxPointRangeBounds implements IFlxDestroyable
{
	/**
	 * The beginning X and Y values of this property.
	 */
	public var start:FlxBounds<FlxPoint>;

	/**
	 * The ending X and Y values of this property.
	 */
	public var end:FlxBounds<FlxPoint>;

	/**
	 * A flag that can be used to toggle the use of this property.
	 */
	public var active:Bool = true;

	/**
	 * Create a new FlxPointRangeBounds object.
	 *
	 * @param   startMinX  The minimum possible initial value of X for this property for particles launched from this emitter.
	 * @param   startMinY  The minimum possible initial value of Y for this property for particles launched from this emitter. Optional, will be set equal to startMinX if ignored.
	 * @param   startMaxX  The maximum possible initial value of X for this property for particles launched from this emitter. Optional, will be set equal to startMinX if ignored.
	 * @param   startMaxY  The maximum possible initial value of Y for this property for particles launched from this emitter. Optional, will be set equal to startMinY if ignored.
	 * @param   endMinX    The minimum possible final value of X for this property for particles launched from this emitter. Optional, will be set equal to startMinX if ignored.
	 * @param   endMinY    The minimum possible final value of Y for this property for particles launched from this emitter. Optional, will be set equal to startMinY if ignored.
	 * @param   endMaxX    The maximum possible final value of X for this property for particles launched from this emitter. Optional, will be set equal to endMinX if ignored.
	 * @param   endMaxY    The maximum possible final value of Y for this property for particles launched from this emitter. Optional, will be set equal to endMinY if ignored.
	 * @return  This FlxPointRangeBounds instance (nice for chaining stuff together).
	 */
	public function new(startMinX:Float, ?startMinY:Float, ?startMaxX:Float, ?startMaxY:Float, ?endMinX:Float, ?endMinY:Float, ?endMaxX:Float, ?endMaxY:Float)
	{
		start = new FlxBounds<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		end = new FlxBounds<FlxPoint>(FlxPoint.get(), FlxPoint.get());

		set(startMinX, startMinY, startMaxX, startMaxY, endMinX, endMinY, endMaxX, endMaxY);
	}

	/**
	 * Handy function to set the the beginning and ending range of values for a FlxPoint in one line.
	 *
	 * @param   startMinX  The minimum possible initial value of X for this property for particles launched from this emitter.
	 * @param   startMinY  The minimum possible initial value of Y for this property for particles launched from this emitter. Optional, will be set equal to startMinX if ignored.
	 * @param   startMaxX  The maximum possible initial value of X for this property for particles launched from this emitter. Optional, will be set equal to startMinX if ignored.
	 * @param   startMaxY  The maximum possible initial value of Y for this property for particles launched from this emitter. Optional, will be set equal to startMinY if ignored.
	 * @param   endMinX    The minimum possible final value of X for this property for particles launched from this emitter. Optional, will be set equal to startMinX if ignored.
	 * @param   endMinY    The minimum possible final value of Y for this property for particles launched from this emitter. Optional, will be set equal to startMinY if ignored.
	 * @param   endMaxX    The maximum possible final value of X for this property for particles launched from this emitter. Optional, will be set equal to endMinX if ignored.
	 * @param   endMaxY    The maximum possible final value of Y for this property for particles launched from this emitter. Optional, will be set equal to endMinY if ignored.
	 * @return  This FlxPointRangeBounds instance (nice for chaining stuff together).
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
	 * Function to compare this FlxPointRangeBounds to another.
	 *
	 * @param	OtherFlxPointRangeBounds  The other FlxPointRangeBounds to compare to this one.
	 * @return	True if the FlxPointRangeBounds have the same min and max value, false otherwise.
	 */
	public inline function equals(OtherFlxPointRangeBounds:FlxPointRangeBounds):Bool
	{
		return start.min.equals(OtherFlxPointRangeBounds.start.min)
			&& start.max.equals(OtherFlxPointRangeBounds.start.max)
			&& end.min.equals(OtherFlxPointRangeBounds.end.min)
			&& end.max.equals(OtherFlxPointRangeBounds.end.max);
	}

	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
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
