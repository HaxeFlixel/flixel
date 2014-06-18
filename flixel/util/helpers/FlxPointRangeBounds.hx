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
	public var start:Bounds<FlxPoint>;
	public var end:Bounds<FlxPoint>;
	
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
	public function new(startMinX:Float, ?startMinY:Null<Float>, ?startMaxX:Null<Float>, ?startMaxY:Null<Float>, ?endMinX:Null<Float>, ?endMinY:Null<Float>, ?endMaxX:Null<Float>, ?endMaxY:Null<Float>)
	{
		start = new Bounds<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		end = new Bounds<FlxPoint>(FlxPoint.get(), FlxPoint.get());
		
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
	public function set(startMinX:Float, ?startMinY:Null<Float>, ?startMaxX:Null<Float>, ?startMaxY:Null<Float>, ?endMinX:Null<Float>, ?endMinY:Null<Float>, ?endMaxX:Null<Float>, ?endMaxY:Null<Float>):FlxPointRangeBounds
	{
		start.min.x = startMinX;
		start.min.y = startMinY == null ? start.min.x : startMinY;
		start.max.x = startMaxX == null ? start.min.x : startMaxX;
		start.max.y = startMaxY == null ? start.max.y : startMaxY;
		end.min.x = endMinX == null ? start.min.x : endMinX;
		end.min.y = endMinY == null ? start.min.y : endMinY;
		end.max.x = endMaxX == null ? end.min.x : endMaxX;
		end.max.y = endMaxY == null ? end.min.y : endMaxY;
		
		return this;
	}
	
	/**
	 * Function to compare two FlxPointRangeBounds objects of the same type.
	 */
	public static inline function equal(FlxPointRangeBounds1:FlxPointRangeBounds, FlxPointRangeBounds2:FlxPointRangeBounds):Bool
	{
		return FlxPoint.equal(FlxPointRangeBounds1.start.min, FlxPointRangeBounds2.start.min) && 
				FlxPoint.equal(FlxPointRangeBounds1.start.max, FlxPointRangeBounds2.start.max) && 
				FlxPoint.equal(FlxPointRangeBounds1.end.min, FlxPointRangeBounds2.end.min) && 
				FlxPoint.equal(FlxPointRangeBounds1.end.max, FlxPointRangeBounds2.end.max);
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
			LabelValuePair.weak("end.max.y", end.max.y)]);
	}
	
	public function destroy():Void
	{
		FlxDestroyUtil.put(start.min);
		FlxDestroyUtil.put(start.max);
		FlxDestroyUtil.put(end.min);
		FlxDestroyUtil.put(end.max);
		start.min = null;
		start.max = null;
		end.min = null;
		end.max = null;
	}
}