package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;
import flixel.system.FlxAssets;
import haxe.PosInfos;

/**
 * Accessed via `FlxG.log`.
 */
class LogFrontEnd
{
	/**
	 * Whether everything you trace() is being redirected into the log window.
	 */
	public var redirectTraces(default, set):Bool = false;

	var _standardTraceFunction:(Dynamic, ?PosInfos)->Void;
	
	public inline function add(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, LogStyle.NORMAL, false, pos);
	}
	
	public inline function warn(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, LogStyle.WARNING, true, pos);
	}
	
	public inline function error(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, LogStyle.ERROR, true, pos);
	}
	
	public inline function notice(data:Dynamic, ?pos:PosInfos):Void
	{
		advanced(data, LogStyle.NOTICE, false, pos);
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

		advanced(paramArray, LogStyle.NORMAL);
	}
}
