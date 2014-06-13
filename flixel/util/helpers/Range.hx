package flixel.util.helpers;

import flixel.util.FlxStringUtil;

/**
 * Helper object for holding beginning and ending values of various properties.
 */
class Range<T>
{
	public var start:T;
	public var end:T;
	public var range(get, set):T;
	
	/**
	 * Create a new Range object. Must be typed, e.g. var myRange = new Range<Float>(0, 0);
	 * 
	 * @param	start  The beginning value of the property.
	 * @param	end    The ending value of the property. Optional, will be set equal to start if ignored.
	 */
	public function new(start:T, ?end:Null<T>)
	{
		set(start, end);
	}
	
	/**
	 * Handy function to set the intial and final values of this Range object in one line.
	 * 
	 * @param	start  The new beginning value of the property.
	 * @param	end    The new final value of the property.  Optional, will be set equal to start if ignored.
	 * @return  This Range instance (nice for chaining stuff together).
	 */
	public function set(start:T, ?end:Null<T>):Range<T>
	{
		this.start = start;
		this.end = end == null ? start : end;
		
		return this;
	}
	
	private inline function get_range():T
	{
		return (end - start);
	}
	
	private inline function set_range(Value:T):T
	{
		end = Value - start;
		
		return range;
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("start", start),
			LabelValuePair.weak("end", end)]);
	}
}