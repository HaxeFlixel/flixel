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

	var _standardTraceFunction:Dynamic->?PosInfos->Void;

	public inline function add(Data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(Data, LogStyle.NORMAL);
		#end
	}

	public inline function warn(Data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(Data, LogStyle.WARNING, true);
		#end
	}

	public inline function error(Data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(Data, LogStyle.ERROR, true);
		#end
	}

	public inline function notice(Data:Dynamic):Void
	{
		#if FLX_DEBUG
		advanced(Data, LogStyle.NOTICE);
		#end
	}

	/**
	 * Add an advanced log message to the debugger by also specifying a LogStyle. Backend to FlxG.log.add(), FlxG.log.warn(), FlxG.log.error() and FlxG.log.notice().
	 *
	 * @param	Data  		Any Data to log.
	 * @param  	Style   	The LogStyle to use, for example LogStyle.WARNING. You can also create your own by importing the LogStyle class.
	 * @param  	FireOnce   	Whether you only want to log the Data in case it hasn't been added already
	 */
	public function advanced(Data:Dynamic, ?Style:LogStyle, FireOnce:Bool = false):Void
	{
		#if FLX_DEBUG
		// Check null game since `FlxG.save.bind` may be called before `new FlxGame`
		if (FlxG.game == null || FlxG.game.debugger == null)
		{
			_standardTraceFunction(Data);
			return;
		}

		if (Style == null)
		{
			Style = LogStyle.NORMAL;
		}

		if (!(Data is Array))
		{
			Data = [Data];
		}

		if (FlxG.game.debugger.log.add(Data, Style, FireOnce))
		{
			#if (FLX_SOUND_SYSTEM && !FLX_UNIT_TEST)
			if (Style.errorSound != null)
			{
				var sound = FlxAssets.getSound(Style.errorSound);
				if (sound != null)
				{
					FlxG.sound.load(sound).play();
				}
			}
			#end

			if (Style.openConsole)
			{
				FlxG.debugger.visible = true;
			}

			if (Style.callbackFunction != null)
			{
				Style.callbackFunction();
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

	inline function set_redirectTraces(Redirect:Bool):Bool
	{
		Log.trace = (Redirect) ? processTraceData : _standardTraceFunction;
		return redirectTraces = Redirect;
	}

	/**
	 * Internal function used as a interface between trace() and add().
	 *
	 * @param	Data	The data that has been traced
	 * @param	Inf		Information about the position at which trace() was called
	 */
	function processTraceData(Data:Dynamic, ?Info:PosInfos):Void
	{
		var paramArray:Array<Dynamic> = [Data];

		if (Info.customParams != null)
		{
			for (i in Info.customParams)
			{
				paramArray.push(i);
			}
		}

		advanced(paramArray, LogStyle.NORMAL);
	}
}
