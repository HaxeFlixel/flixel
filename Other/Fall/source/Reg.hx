package;

import flixel.util.FlxRandom;
import flixel.util.FlxSave;

class Reg
{
	static public var PS:PlayState;
	
	static public function leafColor():Int
	{
		return COLOR_ARRAY()[ FlxRandom.intRanged( 0, COLOR_ARRAY().length - 1 ) ];
	}
	
	inline static private function COLOR_ARRAY():Array<Int>
	{
		return [ 0xffb14211, 0xffd9541a, 0xff663408,
					0xffbc5815, 0xffecb338, 0xffbf1313 ];
	}
	
	/**
	 * Generic bucket for storing different <code>FlxSaves</code>.
	 * Especially useful for setting up multiple save slots.
	 */
	static public var save:FlxSave = new FlxSave();
}