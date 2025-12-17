package flixel.system.debug.log;

import flixel.system.debug.log.FlxLogStyle;
import flixel.util.FlxColor;
import haxe.PosInfos;

/**
 * A class that allows you to create a custom style for `FlxG.log.advanced()`.
 * Also used internally for the pre-defined styles.
 */
@:forward
@:deprecated("LogStyle is deprecated, use FlxLogStyle, instead")
abstract LogStyle(FlxLogStyle) from FlxLogStyle to FlxLogStyle
{
	@:deprecated("LogStyle.NORMAL is deprecated, use FlxG.log.styles.NORMAL, instead")
	public static var NORMAL (default, set):LogStyle;
	static function set_NORMAL(style:LogStyle)
	{
		@:bypassAccessor
		FlxG.log.styles.normal = style;
		return NORMAL = style;
	}
	
	@:deprecated("LogStyle.WARNING is deprecated, use FlxG.log.styles.WARNING, instead")
	public static var WARNING(default, set):LogStyle;
	static function set_WARNING(style:LogStyle)
	{
		@:bypassAccessor
		FlxG.log.styles.warning = style;
		return WARNING = style;
	}
	
	@:deprecated("LogStyle.ERROR is deprecated, use FlxG.log.styles.ERROR, instead")
	public static var ERROR  (default, set):LogStyle;
	static function set_ERROR(style:LogStyle)
	{
		@:bypassAccessor
		FlxG.log.styles.error = style;
		return ERROR = style;
	}
	
	@:deprecated("LogStyle.NOTICE is deprecated, use FlxG.log.styles.NOTICE, instead")
	public static var NOTICE (default, set):LogStyle;
	static function set_NOTICE(style:LogStyle)
	{
		@:bypassAccessor
		FlxG.log.styles.notice = style;
		return NOTICE = style;
	}
	
	@:deprecated("LogStyle.CONSOLE is deprecated, use FlxG.log.styles.CONSOLE, instead")
	public static var CONSOLE(default, set):LogStyle;
	static function set_CONSOLE(style:LogStyle)
	{
		@:bypassAccessor
		FlxG.log.styles.console = style;
		return CONSOLE = style;
	}
	
	
	public var color(get, set):String;
	inline function get_color() return this.format.getColorString();
	inline function set_color(value:String) return this.format.setColorString(value);
	
	public var size(get, set):Int;
	inline function get_size() return this.format.size;
	inline function set_size(value:Int) return this.format.size = value;
	
	public var bold(get, set):Bool;
	inline function get_bold() return this.format.bold;
	inline function set_bold(value:Bool) return this.format.bold = value;
	
	public var italic(get, set):Bool;
	inline function get_italic() return this.format.italic;
	inline function set_italic(value:Bool) return this.format.italic = value;
	
	public var underlined(get, set):Bool;
	inline function get_underlined() return this.format.underlined;
	inline function set_underlined(value:Bool) return this.format.underlined = value;
	
	
	@:deprecated("LogStyle is deprecated, use FlxLogStyle, instead")
	public function new(prefix = "", color = "FFFFFF", size = 12, bold = false, italic = false, underlined = false,
			?errorSound:String, openConsole = false, ?callbackFunction:()->Void, ?callback:(Any, ?PosInfos)->Void, throwException = false)
	{
		final format = new FlxLogFormat(FlxColor.fromString('#$color'), size, bold, italic, underlined);
		this = new FlxLogStyle(prefix, format, errorSound, openConsole, throwException);
		
		this.callbackFunction = callbackFunction;
		if (callback != null)
			this.onLog.add(callback);
	}
}
