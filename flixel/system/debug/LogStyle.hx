package flixel.system.debug;

import flash.media.Sound;
import flixel.system.FlxAssets;

/**
 * A class that allows you to create a custom style for FlxG.log.advanced(). 
 * Also used internally for the pre-defined styles.
 */
class LogStyle
{
	public static var NORMAL:LogStyle = new LogStyle();
	public static var WARNING:LogStyle = new LogStyle("[WARNING] ", "FFFF00", 12, true, false, false,  
	                                                #if FLX_NO_SOUND_SYSTEM null, #else new BeepSound(), #end true);
	public static var ERROR:LogStyle = new LogStyle("[ERROR] ", "FF0000", 12, true, false, false, 
	                                                #if FLX_NO_SOUND_SYSTEM null, #else new BeepSound(), #end true);
	public static var NOTICE:LogStyle = new LogStyle("[NOTICE] ", "008000", 12, true);
	public static var CONSOLE:LogStyle = new LogStyle("&#62; ", "0000ff", 12, true);
	
	/**
	 * A prefix which is always attached to the start of the logged data.
	 */
	public var prefix:String;
	public var color:String;
	public var size:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var underlined:Bool;
	/**
	 * A sound to be played when this LogStyle is used.
	 */
	public var errorSound:Sound;
	/**
	 * Whether the console should be forced to open when this LogStyle is used.
	 */
	public var openConsole:Bool;
	/**
	 * A callback function that is called when this LogStyle is used.
	 */
	public var callbackFunction:Dynamic;
	
	/**
	 * Create a new LogStyle to be used in conjunction with FlxG.log.advanced()
	 * 
	 * @param	Prefix				A prefix which is always attached to the start of the logged data.
	 * @param	Color				The text color.
	 * @param	Size				The text size.
	 * @param 	Bold				Whether the text is bold or not.
	 * @param	Italic				Whether the text is italic or not.
	 * @param	Underlined			Whether the text is underlined or not.
	 * @param	ErrorSound			A sound to be played when this LogStyle is used.
	 * @param	OpenConsole			Whether the console should be forced to open when this LogStyle is used.
	 * @param	CallbackFunction	A callback function that is called when this LogStyle is used.
	 */
	public function new(Prefix:String = "", Color:String = "FFFFFF", Size:Int = 12, Bold:Bool = false, Italic:Bool = false, Underlined:Bool = false, ?ErrorSound:Sound, OpenConsole:Bool = false, ?CallbackFunction:Void->Void)
	{
		prefix = Prefix;
		color = Color;
		size = Size;
		bold = Bold;
		italic = Italic;
		underlined = Underlined;
		errorSound = ErrorSound;
		openConsole = OpenConsole;
		callbackFunction = CallbackFunction;
	}
}