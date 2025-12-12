package flixel.system.debug.log;

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
	
	public function new(prefix = "", color = "FFFFFF", size = 12, bold = false, italic = false, underlined = false,
			?errorSound:String, openConsole = false, ?callbackFunction:()->Void, ?callback:(Any, ?PosInfos)->Void, throwException = false)
	{
		this = new FlxLogStyle(prefix, color, size, bold, italic, underlined, errorSound, openConsole, throwException);
		
		this.callbackFunction = callbackFunction;
		if (callback != null)
			this.onLog.add(callback);
	}
}
