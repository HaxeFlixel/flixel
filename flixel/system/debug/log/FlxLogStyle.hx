package flixel.system.debug.log;

import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import haxe.PosInfos;

using flixel.util.FlxStringUtil;

/**
 * A class that allows you to create a custom style for `FlxG.log.advanced()`.
 * Also used internally for the pre-defined styles.
 * @since 6.2.0
 */
class FlxLogStyle
{
	/**
	 * A prefix which is always attached to the start of the logged data
	 */
	public var prefix:String;
	
	/**
	 * The formatting applied to the text
	 */
	public var format:FlxLogFormat;
	
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
	@:deprecated("callbackFunction is deprecated, use callback, instead")
	public var callbackFunction:()->Void;
	
	/**
	 * A callback function that is called when this LogStyle is used
	 * **Note:** Unlike the deprecated `callbackFunction`, this is called every time,
	 * even when logged with `once = true` and even in release mode.
	 */
	public final onLog = new FlxTypedSignal<(data:Any, ?pos:PosInfos) -> Void>();
	
	/**
	 * Whether an exception is thrown when this LogStyle is used.
	 * **Note**: Unlike other log style properties, this happens even in release mode.
	 * @since 5.4.0
	 */
	public var throwException:Bool = false;
	
	/**
	 * Create a new LogStyle to be used in conjunction with `FlxG.log.advanced()`
	 *
	 * @param   prefix            A prefix which is always attached to the start of the logged data
	 * @param   style             The formatting applied to the text
	 * @param   errorSound        A sound to be played when this LogStyle is used
	 * @param   openConsole       Whether the console should be forced to open when this LogStyle is used
	 * @param   callback          A callback function that is called when this LogStyle is used
	 * @param   throwError        Whether an error is thrown when this LogStyle is used
	 */
	 @:haxe.warning("-WDeprecated")
	public function new(prefix = "", ?format:FlxLogFormat, ?errorSound:String, openConsole = false, throwException = false)
	{
		this.prefix = prefix;
		this.format = format != null ? format : {};
		this.errorSound = errorSound;
		this.openConsole = openConsole;
		this.throwException = throwException;
	}
	
	/**
	 * Converts the data into a log message according to this style.
	 * 
	 * @param   data  The data being logged
	 */
	public function toLogString(data:Array<Any>)
	{
		// Format FlxPoints, Arrays, Maps or turn the data entry into a String
		final texts = new Array<String>();
		for (i in 0...data.length)
		{
			final text = Std.string(data[i]);
			
			// Make sure you can't insert html tags
			texts.push(StringTools.htmlEscape(text));
		}
		
		return prefix + texts.join(" ");
	}
	
	/**
	 * Converts the data into an html log message according to this style.
	 * 
	 * @param   data  The data being logged
	 */
	public inline function toHtmlString(data:Array<Any>)
	{
		return toLogString(data).htmlFormat(format.size, format.getColorString(), format.bold, format.italic, format.underlined);
	}
}

@:structInit
class FlxLogFormat
{
	public var color = FlxColor.WHITE;
	public var size = 12;
	public var bold = false;
	public var italic = false;
	public var underlined = false;
	
	public function new(color = FlxColor.WHITE, size = 12, bold = false, italic = false, underlined = false)
	{
		this.color = color;
		this.size = size;
		this.bold = bold;
		this.italic = italic;
		this.underlined = underlined;
	}
	
	public function getColorString(prefix = "")
	{
		return color.toHexString(prefix, false);
	}
	
	public function setColorString(value:String)
	{
		color = FlxColor.fromString('#$value');
		return value;
	}
}