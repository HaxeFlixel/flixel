package;

import flixel.util.FlxSave;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	inline static public var BULLET:String = "images/bullet.png";
	inline static public var SPAWNER_GIBS:String = "images/spawner_gibs.png";
	inline static public var SPAWNER:String = "images/spawner.png";
	inline static public var SPACEMAN:String = "images/spaceman.png";
	inline static public var BOT:String = "images/bot.png";
	inline static public var JET:String = "images/jet.png";
	inline static public var BOT_BULLET:String = "images/bot_bullet.png";
	inline static public var TECH_TILES:String = "images/tech_tiles.png";
	inline static public var IMG_TILES:String = "images/img_tiles.png";
	inline static public var DIRT_TOP:String = "images/dirt_top.png";
	inline static public var DIRT:String = "images/dirt.png";
	inline static public var GIBS:String = "images/gibs.png";
	inline static public var MINI_FRAME:String = "images/miniframe.png";
	inline static public var CURSOR:String = "images/cursor.png";
	
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
}