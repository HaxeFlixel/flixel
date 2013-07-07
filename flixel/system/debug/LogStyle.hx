package flixel.system.debug;

/**
 * A class that allows you to create a custom style
 * for <code>FlxG.log.advanced()</code>. Also used 
 * internally for the pre-defined styles.
 */
class LogStyle
{
	/**
	 * A prefix which is always attached to the start of the logged data.
	 * @default ""
	 */
	public var prefix:String;
	/**
	 * The text color.
	 * @default "FFFFFF"
	 */
	public var color:String;
	/**
	 * The text size.
	 * @default 12
	 */
	public var size:Int;
	/**
	 * Whether the text is bold or not.
	 * @default false
	 */
	public var bold:Bool;
	/**
	 * Whether the text is italic or not.
	 * @default false
	 */
	public var italic:Bool;
	/**
	 * Whether the text is underlined or not.
	 * @default false
	 */
	public var underlined:Bool;
	/**
	 * A sound to be played when this <code>LogStyle</code> is used.
	 * @default null
	 */
	public var errorSound:String;
	/**
	 * Whether the console should be forced to open when this <code>LogStyle</code> is used.
	 * @default false
	 */
	public var openConsole:Bool;
	/**
	 * A callback function that is called when this <code>LogStyle</code> is used.
	 * @default null
	 */
	public var callbackFunction:Dynamic;
	
	/**
	 * Create a new <code>LogStyle</code> to be used in conjunction with <code>FlxG.log.advanced()</code>
	 * @param	Prefix				A prefix which is always attached to the start of the logged data.
	 * @param	Color				The text color.
	 * @param	Size				The text size.
	 * @param 	Bold				Whether the text is bold or not.
	 * @param	Italic				Whether the text is italic or not.
	 * @param	Underlined			Whether the text is underlined or not.
	 * @param	ErrorSound			A sound to be played when this <code>LogStyle</code> is used.
	 * @param	OpenConsole			Whether the console should be forced to open when this <code>LogStyle</code> is used.
	 * @param	CallbackFunction	A callback function that is called when this <code>LogStyle</code> is used.
	 */
	public function new(Prefix:String = "", Color:String = "FFFFFF", Size:Int = 12, Bold:Bool = false, Italic:Bool = false, Underlined:Bool = false, ErrorSound:String = null, OpenConsole:Bool = false, CallbackFunction:Dynamic = null)
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