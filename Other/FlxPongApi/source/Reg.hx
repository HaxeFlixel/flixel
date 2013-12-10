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
	/**
	 * The currently active state. Used by trophyToast to add the toast.
	 */
	static public var CS:FlxState;
	
	static public var halfWidth:Int = Std.int( FlxG.width / 2 );
	static public var halfHeight:Int = Std.int( FlxG.height / 2 );
	
	inline public static var LITE:Int = 0xffEFF5E0;
	inline public static var MED_LITE:Int = 0xffA5CA53;
	inline public static var MED_DARK:Int = 0xff3D4E18;
	inline public static var DARK:Int = 0xff0C1005;
	
	inline public static var GAME_ID:Int = 19975;
	
	/**
	 * Horizontally center any FlxObject on the stage.
	 * 
	 * @param	Object	The object to center.
	 */
	static public function centerX( Object:FlxObject ):Void
	{
		Object.x = ( FlxG.width - Object.width ) / 2;
	}
	
	static public function randomColor():Int
	{
		var i:Int = FlxRandom.intRanged( 0, 3 );
		var r:Int = 0;
		
		switch ( i ) {
			case 0:
				r = LITE;
			case 1:
				r = MED_LITE;
			case 2:
				r = MED_DARK;
			case 3:
				r = DARK;
		}
		
		return r;
	}
	
	/**
	 * Align any FlxObject to a vertical line at 1/4, 2/4, or 3/4 of the stage.
	 * 
	 * @param	Object
	 * @param	Num
	 */
	static public function quarterX( Object:FlxObject, Num:Int = 1 ):Void {
		Object.x = ( FlxG.width * Num / 2 - Object.width ) / 2;
	}
	
	static public function trophyToast( Data:Dynamic ):Void {
		if ( CS == null ) {
			return;
		}
		trace("yep");
		var toast:FlxSprite = new FlxSprite( FlxG.width, FlxG.height - 40 );
		toast.makeGraphic( 30, 30, 0xffFF0000 );
		CS.add( toast );
		FlxTween.linearMotion( toast, toast.x, toast.y, FlxG.width - 40, toast.y, 5 );
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