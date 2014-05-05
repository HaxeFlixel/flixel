package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;

class BitmapLogFrontEnd
{
	public inline function add(Data:BitmapData, Name:String = ""):Void
	{
		#if !FLX_NO_DEBUG
		FlxG.game.debugger.bitmapLog.add(Data, Name);
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
	
	/**
	 * Clears the bitmapLog window and adds the entire cache to it.
	 */
	public function viewCache():Void
	{
		#if !FLX_NO_DEBUG
		clear();
		for (cachedGraphic in FlxG.bitmap._cache)
		{
			add(cachedGraphic.bitmap, cachedGraphic.key);
		}
		#end
	}
	
	@:allow(flixel.FlxG)
	private function new() {}
}