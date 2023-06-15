package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;
import flixel.system.FlxAssets;
import haxe.Log;
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

	public inline function add(data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(data, LogStyle.NORMAL);
		#end
	}

	public inline function warn(data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(data, LogStyle.WARNING, true);
		#end
	}

	public inline function error(data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(data, LogStyle.ERROR, true);
		#end
	}

	public inline function notice(data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(data, LogStyle.NOTICE);
		#end
	}

	/**
	 * Add an advanced log message to the debugger by also specifying a LogStyle. Backend to FlxG.log.add(), FlxG.log.warn(), FlxG.log.error() and FlxG.log.notice().
	 *
	 * @param   data      Any Data to log.
	 * @param   style     The LogStyle to use, for example LogStyle.WARNING. You can also create your own by importing the LogStyle class.
	 * @param   fireOnce  Whether you only want to log the Data in case it hasn't been added already
	 */
	public function advanced(data:Dynamic, ?style:LogStyle, fireOnce:Bool = false):Void
	{
		#if FLX_DEBUG
		// Check null game since `FlxG.save.bind` may be called before `new FlxGame`
		if (FlxG.game == null || FlxG.game.debugger == null)
		{
			_standardTraceFunction(data);
			return;
		}

		if (style == null)
		{
			style = LogStyle.NORMAL;
		}

		if (!(data is Array))
		{
			data = [data];
		}

		if (FlxG.game.debugger.log.add(data, style, fireOnce))
		{
			#if (FLX_SOUND_SYSTEM && !FLX_UNIT_TEST)
			if (style.errorSound != null)
			{
				var sound = FlxAssets.getSound(style.errorSound);
				if (sound != null)
				{
					FlxG.sound.load(sound).play();
				}
			}
			#end

			if (style.openConsole)
			{
				FlxG.debugger.visible = true;
			}

			if (style.callbackFunction != null)
			{
				style.callbackFunction();
			}
			
			if (style.throwError)
			{
				throw style.toLogString(data);
			}
		}
		#end
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
		Log.trace = (redirect) ? processTraceData : _standardTraceFunction;
		return redirectTraces = redirect;
	}

	/**
	 * Internal function used as a interface between trace() and add().
	 *
	 * @param   data  The data that has been traced
	 * @param   info  Information about the position at which trace() was called
	 */
	function processTraceData(data:Dynamic, ?info:PosInfos):Void
	{
		var paramArray:Array<Dynamic> = [data];

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
