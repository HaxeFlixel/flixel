package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.debug.log.FlxLogStyle;
import flixel.system.debug.log.LogStyle;
import haxe.PosInfos;

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

/**
 * Accessed via `FlxG.log`.
 */
class LogFrontEnd
{
	/**
	 * Whether everything you trace() is being redirected into the log window.
	 */
	public var redirectTraces(default, set):Bool = false;
	
	public final styles:FlxLogStylesList;

	var _standardTraceFunction:(Dynamic, ?PosInfos)->Void;
	
	public inline function add(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.normal, false, pos);
	}
	
	public inline function warn(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.warning, true, pos);
	}
	
	public inline function error(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.error, true, pos);
	}
	
	public inline function notice(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, styles.notice, false, pos);
	}
	
	/**
	 * Add an advanced log message to the debugger by also specifying a LogStyle. Backend to FlxG.log.add(), FlxG.log.warn(), FlxG.log.error() and FlxG.log.notice().
	 *
	 * @param   data      Any Data to log.
	 * @param   style     The LogStyle to use, for example LogStyle.WARNING. You can also create your own by importing the LogStyle class.
	 * @param   fireOnce  Whether you only want to log the Data in case it hasn't been added already
	 */
	@:haxe.warning("-WDeprecated")
	public function advanced(data:Any, ?style:LogStyle, fireOnce = false, ?pos:PosInfos):Void
	{
		if (style == null)
			style = LogStyle.NORMAL;
		
		final arrayData = (!(data is Array) ? [data] : cast data);
		
		#if FLX_DEBUG
		// Check null game since `FlxG.save.bind` may be called before `new FlxGame`
		if (FlxG.game == null || FlxG.game.debugger == null)
		{
			_standardTraceFunction(arrayData);
		}
		else if (FlxG.game.debugger.log.add(arrayData, style, fireOnce))
		{
			#if (FLX_SOUND_SYSTEM && !FLX_UNIT_TEST)
			if (style.errorSound != null)
			{
				final sound = FlxAssets.getSoundAddExtension(style.errorSound);
				if (sound != null)
					FlxG.sound.load(sound).play();
			}
			#end
			
			if (style.openConsole)
				FlxG.debugger.visible = true;
			
			if (style.callbackFunction != null)
				style.callbackFunction();
		}
		#end
		
		style.onLog.dispatch(data, pos);
		
		if (style.throwException)
			throw style.toLogString(arrayData);
	}

	/**
	 * Clears the log output.
	 */
	public inline function clear():Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.log.clear();
		#end
	}

	@:allow(flixel.FlxG)
	function new()
	{
		_standardTraceFunction = haxe.Log.trace;
		styles = new FlxLogStylesList();
	}

	inline function set_redirectTraces(redirect:Bool):Bool
	{
		haxe.Log.trace = (redirect) ? processTraceData : _standardTraceFunction;
		return redirectTraces = redirect;
	}

	/**
	 * Internal function used as a interface between trace() and add().
	 *
	 * @param   data  The data that has been traced
	 * @param   info  Information about the position at which trace() was called
	 */
	function processTraceData(data:Any, ?info:PosInfos):Void
	{
		var paramArray:Array<Any> = [data];

		if (info.customParams != null)
		{
			for (i in info.customParams)
			{
				paramArray.push(i);
			}
		}

		advanced(paramArray, styles.normal);
	}
}
