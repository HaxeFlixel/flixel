package flixel.system.frontEnds;

import openfl.display.BitmapData;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;

/**
 * Accessed via `FlxG.bitmapLog`.
 */
class BitmapLogFrontEnd
{
	public overload inline extern function add(data:BitmapData, name = ""):Void
	{
		#if FLX_DEBUG
		FlxG.game.debugger.bitmapLog.add(data, name);
		#end
	}
	
	public overload inline extern function add(graphic:FlxGraphic, ?name:String):Void
	{
		addGraphic(graphic, name);
	}
	
	function addGraphic(graphic:FlxGraphic, ?name:String):Void
	{
		#if FLX_DEBUG
		if (graphic != null && graphic.bitmap != null)
		{
			if (name == null)
				name = getGraphicName(graphic);
			
			add(graphic.bitmap, name);
		}
		#end
	}
	
	function getGraphicName(graphic:FlxGraphic)
	{
		if (graphic.key != null)
			return graphic.key;
		
		if (graphic.assetsKey != null)
			return graphic.assetsKey;
		
		if (graphic.assetsClass != null)
			return Type.getClassName(graphic.assetsClass);
		
		#if FLX_TRACK_GRAPHICS
		if (graphic.trackingInfo != null)
			return graphic.trackingInfo;
		#end
		
		return null;
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
