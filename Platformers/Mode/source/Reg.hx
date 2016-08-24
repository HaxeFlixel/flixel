package;

/**
 * Handy, pre-built Registry class that can be used to store 
 * references to objects and other things for quick-access. Feel
 * free to simply ignore it or change it in any way you like.
 */
class Reg
{
	public static inline var BULLET:String = "images/bullet.png";
	public static inline var SPAWNER_GIBS:String = "images/spawner_gibs.png";
	public static inline var SPAWNER:String = "images/spawner.png";
	public static inline var SPACEMAN:String = "images/spaceman.png";
	public static inline var BOT:String = "images/bot.png";
	public static inline var JET:String = "images/jet.png";
	public static inline var BOT_BULLET:String = "images/bot_bullet.png";
	public static inline var TECH_TILES:String = "images/tech_tiles.png";
	public static inline var IMG_TILES:String = "images/img_tiles.png";
	public static inline var DIRT_TOP:String = "images/dirt_top.png";
	public static inline var DIRT:String = "images/dirt.png";
	public static inline var GIBS:String = "images/gibs.png";
	public static inline var MINI_FRAME:String = "images/miniframe.png";
	public static inline var CURSOR:String = "images/cursor.png";

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
}