package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxSave;

class Reg
{
	static public var halfWidth:Int = Std.int( FlxG.width / 2 );
	static public var halfHeight:Int = Std.int( FlxG.height / 2 );
	
	inline public static var LITE:Int = 0xffEFF5E0;
	inline public static var MED_LITE:Int = 0xffA5CA53;
	inline public static var MED_DARK:Int = 0xff3D4E18;
	inline public static var DARK:Int = 0xff0C1005;
	
	static public function centerX( Object:FlxObject ):Void {
		Object.x = ( FlxG.width - Object.width ) / 2;
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