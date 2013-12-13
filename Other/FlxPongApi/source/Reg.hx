package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxRandom;
import flixel.util.FlxSave;

class Reg
{
	inline static public var VERSION:String = "0.1a";
	
	static public var PS:PlayState;
	static public var colorArray:Array<Int> = [];
	
	inline static public var GAME_ID:Int = 19975;
	
	static public var lite(get, null):Int;
	
	static private function get_lite():Int
	{
		return colorArray[3];
	}
	
	static public var med_lite(get, null):Int;
	
	static private function get_med_lite():Int
	{
		return colorArray[2];
	}
	
	static public var med_dark(get, null):Int;
	
	static private function get_med_dark():Int
	{
		return colorArray[1];
	}
	
	static public var dark(get, null):Int;
	
	static private function get_dark():Int
	{
		return colorArray[0];
	}
	
	static public function genColors():Void
	{
		var base:Array<Int> = [];
		base.push( FlxRandom.intRanged( 64, 192 ) ); // red
		base.push( FlxRandom.intRanged( 64, 192 ) ); // green
		base.push( FlxRandom.intRanged( 64, 192 ) ); // blue
		
		// wipe or initiate colorArray
		
		colorArray = [];
		
		// generate four colors
		
		for ( i in 0...4 ) {
			var dist:Int = FlxRandom.intRanged( 32 * ( i - 2 ), 24 * ( i - 2 ) );
			colorArray.push( 255 << 24 ); // alpha
			colorArray[i] += base[0] + dist << 16; //red
			colorArray[i] += base[1] + dist << 8; //green
			colorArray[i] += base[2] + dist; // blue
		}
	}
	
	/**
	 * Returns a random color from the currently active color array.
	 */
	static public function randomColor():Int
	{
		return colorArray[ FlxRandom.intRanged( 0, 3 ) ];
	}
	
	/**
	 * Align any FlxObject to a vertical line at 1/4, 2/4, or 3/4 of the stage.
	 * 
	 * @param	Object
	 * @param	Num
	 */
	static public function quarterX( Object:FlxObject, Num:Int = 2 ):Void {
		Object.x = ( FlxG.width * Num / 2 - Object.width ) / 2;
	}
	
	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	static public var levels:Array<Dynamic> = [];
	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	static public var level:Int = 0;
	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	static public var scores:Array<Dynamic> = [];
	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	static public var score:Int = 0;
	/**
	 * Generic bucket for storing different <code>FlxSaves</code>.
	 * Especially useful for setting up multiple save slots.
	 */
	static public var saves:Array<FlxSave> = [];
	/**
	 * Generic container for a <code>FlxSave</code>. You might want to 
	 * consider assigning <code>FlxG._game._prefsSave</code> to this in
	 * your state if you want to use the same save flixel uses internally
	 */
	static public var save:FlxSave;
}