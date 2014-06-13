package flixel.util.helpers;

import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;

/**
 * Helper object for holding beginning minimum/maximum and ending minimum/maximum values of different variables.
 */
class RangeBounds<T> extends Range<Bounds<T>>
{
	/**
	 * Create a new RangeBounds object. Must be typed, e.g. var myRangeBounds = new RangeBounds<Float>(0, 0, 0, 0);
	 * 
	 * @param   startMin  The minimum possible initial value of this property for particles launched from this emitter.
	 * @param   startMax  The maximum possible initial value of this property for particles launched from this emitter. Optional, will be set equal to startMin if ignored.
	 * @param   endMin    The minimum possible final value of this property for particles launched from this emitter. Optional, will be set equal to startMin if ignored.
	 * @param   endMax    The maximum possible final value of this property for particles launched from this emitter. Optional, will be set equal to startMax if ignored.
	 * @return  This RangeBounds instance (nice for chaining stuff together).
	 */
	public function new(startMin:T, ?startMax:Null<T>, ?endMin:Null<T>, ?endMax:Null<T>)
	{
		super(null);
		
		start = new Bounds<T>(startMin, startMax);
		end = new Bounds<T>(endMin, endMax);
		
		setAll(startMin, startMax, endMin, endMax);
	}
	
	/**
	 * Handy function to set the the beginning and ending range of values for an emitter property in one line.
	 * 
	 * @param   startMin  The minimum possible initial value of this property for particles launched from this emitter.
	 * @param   startMax  The maximum possible initial value of this property for particles launched from this emitter. Optional, will be set equal to startMin if ignored.
	 * @param   endMin    The minimum possible final value of this property for particles launched from this emitter. Optional, will be set equal to startMin if ignored.
	 * @param   endMax    The maximum possible final value of this property for particles launched from this emitter. Optional, will be set equal to startMax if ignored.
	 * @return  This RangeBounds instance (nice for chaining stuff together).
	 */
	public function setAll(startMin:T, ?startMax:Null<T>, ?endMin:Null<T>, ?endMax:Null<T>):RangeBounds<T>
	{
		start.min = startMin;
		start.max = startMax == null ? start.min : startMax;
		end.min = endMin == null ? start.min : endMin;
		end.max = endMax == null ? end.min : endMax;
		
		return this;
	}
	
	override public function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("start.min", start.min),
			LabelValuePair.weak("start.max", start.min),
			LabelValuePair.weak("end.min", end.min),
			LabelValuePair.weak("end.max", end.max)]);
	}
}