package flixel.util.helpers;

import flixel.util.FlxStringUtil;
import flixel.math.FlxPoint;

/**
 * Helper object for holding beginning and ending values of various properties.
 */
class FlxRange<T>
{
	public var start:T;
	public var end:T;
	
	/**
	 * Create a new Range object. Must be typed, e.g. var myRange = new Range<Float>(0, 0);
	 * 
	 * @param	start  The beginning value of the property.
	 * @param	end    The ending value of the property. Optional, will be set equal to start if ignored.
	 */
	public function new(start:T, ?end:Null<T>)
	{
		this.start = start;
		this.end = end == null ? start : end;
	}
	
	/**
	 * Handy function to set the intial and final values of this Range object in one line.
	 * 
	 * @param	start  The new beginning value of the property.
	 * @param	end    The new final value of the property.  Optional, will be set equal to start if ignored.
	 * @return  This Range instance (nice for chaining stuff together).
	 */
	public function set(start:T, ?end:Null<T>):FlxRange<T>
	{
		this.start = start;
		this.end = end == null ? start : end;
		
		return this;
	}
	
	/**
	 * Function to compare this FlxRange to another.
	 * 
	 * @param	OtherFlxRange  The other FlxRange to compare to this one.
	 * @return	True if the FlxRanges have the same start and end value, false otherwise.
	 */
	public inline function equals(OtherRange:FlxRange<T>):Bool
	{
		return start == OtherRange.start && end == OtherRange.end;
	}
	
	/**
	 * Convert object to readable string name. Useful for debugging, save games, etc.
	 */
	public function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("start", start),
			LabelValuePair.weak("end", end)]);
	}
}