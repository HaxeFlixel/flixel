package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.LogStyle;
import haxe.Log;
import haxe.PosInfos;

class LogFrontEnd
{
	/**
	 * Whether everything you trace() is being redirected into the log window.
	 * True by default, except on android.
	 */
	public var redirectTraces(default, set):Bool = false;
	
	private var _standardTraceFunction:Dynamic;	
	
	public inline function add(Data:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.NORMAL); 
		#end
	}
	
	public inline function warn(Data:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.WARNING, true); 
		#end
	}
	
	public inline function error(Data:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.ERROR, true); 
		#end
	}
	
	public inline function notice(Data:Dynamic):Void
	{
		#if !FLX_NO_DEBUG
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
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger == null)
		{
			_standardTraceFunction(Data);
			return;
		}
		
		if (Style == null)
		{
			Style = LogStyle.NORMAL;
		}
		
		if (!Std.is(Data, Array))
		{
			Data = [Data]; 
		}
		
		if (FlxG.game.debugger.log.add(Data, Style, FireOnce))
		{
			#if !FLX_NO_SOUND_SYSTEM
			if (Style.errorSound != null)
			{
				FlxG.sound.load(Style.errorSound).play();
			}
			#end
			
			if (Style.openConsole) 
			{
				FlxG.debugger.visible = true;
			}
			
			if (Style.callbackFunction = null)
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
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.log.clear();
		#end
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{ 
		_standardTraceFunction = haxe.Log.trace;
	}
	
	private inline function set_redirectTraces(Redirect:Bool):Bool
	{
		Log.trace = (Redirect) ?  processTraceData : _standardTraceFunction;
		return redirectTraces = Redirect;
	}
	
	/**
	 * Internal function used as a interface between trace() and add().
	 * 
	 * @param	Data	The data that has been traced
	 * @param	Inf		Information about the position at which trace() was called
	 */
	private function processTraceData(Data:Dynamic, ?Info:PosInfos):Void
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