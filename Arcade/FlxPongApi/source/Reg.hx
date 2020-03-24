package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.util.FlxSave;

class Reg
{
	public static inline var VERSION:String = "v 0.3";

	public static var PS:PlayState;
	public static var colorArray:Array<Int> = [];

	public static var lite(get, never):Int;

	static function get_lite():Int
	{
		return colorArray[3];
	}

	public static var med_lite(get, never):Int;

	static function get_med_lite():Int
	{
		return colorArray[2];
	}

	public static var med_dark(get, never):Int;

	static function get_med_dark():Int
	{
		return colorArray[1];
	}

	public static var dark(get, never):Int;

	static function get_dark():Int
	{
		return colorArray[0];
	}

	public static function genColors():Void
	{
		var base:Array<Int> = [];
		base.push(FlxG.random.int(64, 192)); // red
		base.push(FlxG.random.int(64, 192)); // green
		base.push(FlxG.random.int(64, 192)); // blue

		// wipe or initiate colorArray

		colorArray = [];

		// generate four colors

		for (i in 0...4)
		{
			var dist:Int = FlxG.random.int(32 * (i - 2), 24 * (i - 2));
			colorArray.push(255 << 24); // alpha
			colorArray[i] += base[0] + dist << 16; // red
			colorArray[i] += base[1] + dist << 8; // green
			colorArray[i] += base[2] + dist; // blue
		}
	}

	/**
	 * Returns a random color from the currently active color array.
	 */
	public static function randomColor():Int
	{
		return colorArray[FlxG.random.int(0, 3)];
	}

	/**
	 * Align any FlxObject to a vertical line at 1/4, 2/4, or 3/4 of the stage.
	 */
	public static function quarterX(Object:FlxObject, Num:Int = 2):Void
	{
		Object.x = (FlxG.width * Num / 2 - Object.width) / 2;
	}

	/**
	 * Generic levels Array that can be used for cross-state stuff.
	 * Example usage: Storing the levels of a platformer.
	 */
	public static var levels:Array<Dynamic> = [];

	/**
	 * Generic level variable that can be used for cross-state stuff.
	 * Example usage: Storing the current level number.
	 */
	public static var level:Int = 0;

	/**
	 * Generic scores Array that can be used for cross-state stuff.
	 * Example usage: Storing the scores for level.
	 */
	public static var scores:Array<Dynamic> = [];

	/**
	 * Generic score variable that can be used for cross-state stuff.
	 * Example usage: Storing the current score.
	 */
	public static var score:Int = 0;

	/**
	 * Generic bucket for storing different <code>FlxSaves</code>.
	 * Especially useful for setting up multiple save slots.
	 */
	public static var saves:Array<FlxSave> = [];

	/**
	 * Generic container for a <code>FlxSave</code>. You might want to
	 * consider assigning <code>FlxG._game._prefsSave</code> to this in
	 * your state if you want to use the same save flixel uses internally
	 */
	public static var save:FlxSave;
}
