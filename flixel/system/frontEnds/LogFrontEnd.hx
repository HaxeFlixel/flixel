package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.LogStyle;
import haxe.PosInfos;

class LogFrontEnd
{
	@:allow(flixel.FlxG)
	private function new() 
	{ 
		// Create functions that take a variable amount of arguments
		add = Reflect.makeVarArgs(_add);
		warn = Reflect.makeVarArgs(_warn);
		error = Reflect.makeVarArgs(_error);
		notice = Reflect.makeVarArgs(_notice);
		
		_oldTrace = haxe.Log.trace;
	}
	
	/**
	 * Log data to the debugger. Example: <code>FlxG.add("Test", "1", "2", "3");</code> - will turn into "Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	public var add:Dynamic;
	
	private inline function _add(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.NORMAL); 
		#end
	}
	
	/**
	 * Add a warning to the debugger. Example: <code>FlxG.log.warn("Test", "1", "2", "3");</code> - will turn into "[WARNING] Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	public var warn:Dynamic;
	
	private inline function _warn(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.WARNING, true); 
		#end
	}
	
	/**
	 * Add an error to the debugger. Example: <code>FlxG.log.error("Test", "1", "2", "3");</code> - will turn into "[ERROR] Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	public var error:Dynamic;
	
	private inline function _error(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.ERROR, true); 
		#end
	}
	
	/**
	 * Add a notice to the debugger. Example: <code>FlxG.log.notice("Test", "1", "2", "3");</code> - will turn into "[NOTICE] Test 1 2 3".
	 * Infinite amount of arguments allowed, they will be pieced together to one String. 
	 */
	public var notice:Dynamic;
	
	private inline function _notice(Data:Array<Dynamic>):Void
	{
		#if !FLX_NO_DEBUG
		advanced(Data, LogStyle.NOTICE); 
		#end
	}
	
	/**
	 * Add an advanced log message to the debugger by also specifying a <code>LogStyle</code>. Backend to <code>FlxG.log.add(), FlxG.log.warn(), FlxG.log.error() and FlxG.log.notice()</code>.
	 * @param	Data  		Any Data to log.
	 * @param  	Style   	The <code>LogStyle</code> to use, for example <code>LogStyle.WARNING</code>. You can also create your own by importing the <code>LogStyle</code> class.
	 * @param  	FireOnce   	Whether you only want to log the Data in case it hasn't been added already
	 */ 
	public function advanced(Data:Dynamic, ?Style:LogStyle, FireOnce:Bool = false):Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger == null)
		{
			_oldTrace(Data);
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
	
	/**
	 * Whether everything you <code>trace()</code> is being redirected into the log window.
	 * True by default, except on android.
	 */
	public var redirectTraces(default, set):Bool = false;
	/**
	 * Internal var used to undo the redirection of traces.
	 */
	private var _oldTrace:Dynamic;	
	
	private function set_redirectTraces(Redirect:Bool):Bool
	{
		if (Redirect)
		{
			haxe.Log.trace = processTraceData;
		}
		else 
		{
			haxe.Log.trace = _oldTrace;
		}
		
		return redirectTraces = Redirect;
	}
	
	/**
	 * Internal function used as a interface between <code>trace()</code> and <code>add()</code>.
	 * @param	Data	The data that has been traced
	 * @param	Inf		Information about the position at which <code>trace()</code> was called
	 */
	private function processTraceData(Data:Dynamic, ?Inf:PosInfos):Void
	{
		var paramArray:Array<Dynamic> = [Data];
		
		if (Inf.customParams != null) 
		{
			for (i in Inf.customParams)
			{
				paramArray.push(i);
			}
		}
		
		Reflect.callMethod(this, add, paramArray);
	}
}