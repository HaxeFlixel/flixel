package flixel.system.debug.log;

/**
 * A class that allows you to create a custom style for `FlxG.log.advanced()`.
 * Also used internally for the pre-defined styles.
 */
class LogStyle
{
	public static var NORMAL:LogStyle = new LogStyle();
	public static var WARNING:LogStyle = new LogStyle("[WARNING] ", "D9F85C", 12, false, false, false, "flixel/sounds/beep", true);
	public static var ERROR:LogStyle = new LogStyle("[ERROR] ", "FF8888", 12, false, false, false, "flixel/sounds/beep", true);
	public static var NOTICE:LogStyle = new LogStyle("[NOTICE] ", "5CF878", 12, false);
	public static var CONSOLE:LogStyle = new LogStyle("> ", "5A96FA", 12, false);

	/**
	 * A prefix which is always attached to the start of the logged data
	 */
	public var prefix:String;

	public var color:String;
	public var size:Int;
	public var bold:Bool;
	public var italic:Bool;
	public var underlined:Bool;

	/**
	 * A sound to be played when this LogStyle is used
	 */
	public var errorSound:String;

	/**
	 * Whether the console should be forced to open when this LogStyle is used
	 */
	public var openConsole:Bool;

	/**
	 * A callback function that is called when this LogStyle is used
	 */
	public var callbackFunction:()->Void;

	/**
	 * Create a new LogStyle to be used in conjunction with `FlxG.log.advanced()`
	 *
	 * @param   prefix       A prefix which is always attached to the start of the logged data
	 * @param   color        The text color
	 * @param   size         The text size
	 * @param   bold         Whether the text is bold or not
	 * @param   italic       Whether the text is italic or not
	 * @param   underlined   Whether the text is underlined or not
	 * @param   errorSound   A sound to be played when this LogStyle is used
	 * @param   openConsole  Whether the console should be forced to open when this LogStyle is used
	 * @param   callback     A callback function that is called when this LogStyle is used
	 * @param   throwError   Whether an error is thrown when this LogStyle is used
	 */
	public function new(prefix = "", color = "FFFFFF", size = 12, bold = false, italic = false, underlined = false,
			?errorSound:String, openConsole = false, ?callback:()->Void, throwError = false)
	{
		this.prefix = prefix;
		this.color = color;
		this.size = size;
		this.bold = bold;
		this.italic = italic;
		this.underlined = underlined;
		this.errorSound = errorSound;
		this.openConsole = openConsole;
		this.callbackFunction = callback;
		this.throwError = throwError;
	}
}
