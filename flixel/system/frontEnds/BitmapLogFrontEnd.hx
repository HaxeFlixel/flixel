package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;

class BitmapLogFrontEnd
{
	public inline function add(Data:BitmapData):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bitmapLog.add(Data);
		#end
	}
	
	/**
	 * Clears all bitmaps
	 */
	public inline function clear():Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bitmapLog.clear();
		#end
	}
	
	/**
	 * Clear one bitmap object from the log -- the last one, by default 
	 * @param	Index
	 */
	public inline function clearAt(Index:Int = -1):Void 
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bitmapLog.clearAt(Index);
		#end
	}
	
	@:allow(flixel.FlxG)
	private function new() {}
}