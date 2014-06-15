package flixel.util.helpers;

import flixel.tweens.FlxEase;

class FloatRange extends Range<Float>
{
	public var range(get, never):Float;
	public var ease:Float->Float = function(Value:Float) { return Value; };
	
	public function progress(Percent:Float):Float
	{
		return start + range * ease(Percent);
	}
	
	private function get_range():Float
	{
		return end - start;
	}
}