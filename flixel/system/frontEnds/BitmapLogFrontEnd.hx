package flixel.system.frontEnds;

import openfl.display.BitmapData;
import flixel.FlxG;

/**
 * Accessed via `FlxG.bitmapLog`.
 */
class BitmapLogFrontEnd
{
	public inline function add(Data:BitmapData, Name:String = ""):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.bitmapLog.add(Data, Name);
		#end
	}

	/**
	 * Clears all bitmaps
	 */
	public inline function clear():Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.bitmapLog.clear();
		#end
	}

	/**
	 * Clear one bitmap object from the log -- the last one, by default
	 * @param	Index
	 */
	public inline function clearAt(Index:Int = -1):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.bitmapLog.clearAt(Index);
		#end
	}

	/**
	 * Clears the bitmapLog window and adds the entire cache to it.
	 */
	public function viewCache():Void
	{
		#if FLX_DEBUG
		clear();
		for (cachedGraphic in FlxG.bitmap._cache)
		{
			add(cachedGraphic.bitmap, cachedGraphic.key);
		}
		#end
	}

	@:allow(flixel.FlxG)
	function new() {}
}
