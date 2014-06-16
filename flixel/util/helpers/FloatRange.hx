package flixel.util.helpers;

import flixel.tweens.FlxEase;

/**
 * Similar to Range<T>, but stores an easing function and calculates range.
 */
class FloatRange extends Range<Float>
{
	public var range(get, never):Float;
	public var ease:Float->Float = function(Value:Float) { return Value; };
	
	/**
	 * Retreive an eased value between start and end.
	 * 
	 * @param	Percent  The percentage of progress from start to end, on a scale from 0 to 1.
	 * @return  The eased progress value.
	 */
	public function progress(Percent:Float):Float
	{
		return start + range * ease(Percent);
	}
	
	private function get_range():Float
	{
		return end - start;
	}
}