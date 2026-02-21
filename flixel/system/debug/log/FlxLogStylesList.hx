package flixel.system.debug.log;

class FlxLogStylesList
{
	public var normal (default, set):FlxLogStyle;
	public var warning(default, set):FlxLogStyle;
	public var error  (default, set):FlxLogStyle;
	public var notice (default, set):FlxLogStyle;
	public var console(default, set):FlxLogStyle;
	
	@:haxe.warning("-WDeprecated")
	public function new ()
	{
		final sound = "flixel/sounds/beep";
		
		normal  = new FlxLogStyle();
		notice  = new FlxLogStyle("[NOTICE] ", { color: 0x5CF878 });
		warning = new FlxLogStyle("[WARNING] ", { color: 0xD9F85C }, sound, true);
		error   = new FlxLogStyle("[ERROR] ", { color: 0xFF8888 }, sound, true);
		console = new FlxLogStyle("> ", { color: 0x5A96FA });
		
		final order = [normal, notice, warning, error];
		#if FLX_LOG_THROW
		final level = getLevel('${haxe.macro.Compiler.getDefine("FLX_LOG_THROW")}');
		for (i in 0...order.length)
			order[i].throwException = i >= level;
		#end
		
		#if FLX_LOG_PLAY_SOUND
		final level = getLevel('${haxe.macro.Compiler.getDefine("FLX_LOG_PLAY_SOUND")}');
		for (i in 0...order.length)
			order[i].errorSound = i >= level ? sound : null;
		#end
		
		#if FLX_LOG_OPEN_CONSOLE
		final level = getLevel('${haxe.macro.Compiler.getDefine("FLX_LOG_OPEN_CONSOLE")}');
		for (i in 0...order.length)
			order[i].openConsole = i >= level;
		#end
	}
	
	static function getLevel(definedValue:String)
	{
		return switch definedValue.toUpperCase()
		{
			case "ERROR"  : 3;
			case "WARNING": 2;
			case "NOTICE" : 1;
			case "NORMAL" : 0;
			case "NONE"   : 4;
			default       : 4;
		}
	}
	
	@:haxe.warning("-WDeprecated")
	function set_normal (style:FlxLogStyle)
	{
		@:bypassAccessor LogStyle.NORMAL = style;
		return this.normal = style;
	}
	
	@:haxe.warning("-WDeprecated")
	function set_warning(style:FlxLogStyle)
	{
		@:bypassAccessor LogStyle.WARNING = style;
		return this.warning = style;
	}
	
	@:haxe.warning("-WDeprecated")
	function set_error  (style:FlxLogStyle)
	{
		@:bypassAccessor LogStyle.ERROR = style;
		return this.error = style;
	}
	
	@:haxe.warning("-WDeprecated")
	function set_notice (style:FlxLogStyle)
	{
		@:bypassAccessor LogStyle.NOTICE = style;
		return this.notice = style;
	}
	
	@:haxe.warning("-WDeprecated")
	function set_console(style:FlxLogStyle)
	{
		@:bypassAccessor LogStyle.CONSOLE = style;
		return this.console = style;
	}
	
}