package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.FlxG;

class BmpLogFrontEnd
{
	/**
	 * Adds a bitmap to the bmpLog output
	 * @param	Data
	 */
	public function add(Data:BitmapData):Void
	{
		#if !FLX_NO_DEBUG
		if (FlxG.game.debugger != null)
		{
			FlxG.game.debugger.bmpLog.add(Data);
			if (Data != null) {
				FlxG.game.debugger.setButtonVisibility("bmpLog", true);
			}
		}
		#end
	}
	
	/**
	 * Shows the previous bmp in the bmpLog output
	 */
	public inline function previous():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bmpLog.previous();
		#end
	}
	
	/**
	 * Shows the next bmp in the bmpLog output
	 */
	public inline function next():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bmpLog.next();
		#end
	}
	
	/**
	 * Clears all bitmaps in the bmpLog output.
	 */
	public inline function clear():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bmpLog.clear();
		#end
	}
	
	/**
	 * Clear one bitmap object from the log -- the last one, by default 
	 * @param	Index
	 */
	public inline function clearAt(Index:Int = -1):Void {
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bmpLog.clearAt(Index);
		#end
	}
	
	@:allow(flixel.FlxG)
	private function new() 
	{ 
		//do stuff
	}
}