package flixel.graphics.tile;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.util.FlxDestroyUtil;
import openfl.display.Tilesheet;

class FlxTilesheet extends Tilesheet implements IFlxDestroyable
{
	/**
	 * Tracks total number of drawTiles() calls made each frame.
	 */
	public static var _DRAWCALLS:Int = 0;
	
	/**
	 * Creates new FlxTilesheet object and adds all tiles from specified tilesheet onto it.
	 * And it destroys old FlxTilesheet to free some memory.
	 * 
	 * @param	old		Tilesheet to rebuild new FlxTilesheet from.
	 * @param	bitmap	BitmapData to use for new FlxTilesheet.
	 * @return	New FlxTilesheet object with the same tile as in the old FlxTilesheet.
	 */
	public static function rebuildFromOld(old:FlxTilesheet, bitmap:BitmapData):FlxTilesheet
	{
		var newSheet:FlxTilesheet = new FlxTilesheet(bitmap);
		
		for (i in 0...(old.tileOrder.length))
		{
			newSheet.addTileRect(old.tileOrder[i], new Point(0.5 * old.tileOrder[i].width, 0.5 * old.tileOrder[i].height));
		}
		
		FlxDestroyUtil.destroy(old);
		return newSheet;
	}
	
	/**
	 * Holds all rectangles which had been added into this tilesheet.
	 * Useful for tilesheet regeneration (after context loss).
	 */
	public var tileOrder:Array<Rectangle>;
	
	public function new(bitmap:BitmapData)
	{
		super(bitmap);
		tileOrder = new Array<Rectangle>();
	}
	
	/**
	 * Adds new tileRect to tileSheet object and stores info about it for tilesheet regeneration 
	 * (which we might need after context loss event).
	 * 
	 * @return id of added tileRect
	 */
	override public function addTileRect(rectangle:Rectangle, centerPoint:Point = null):Int 
	{
		var tileID:Int = super.addTileRect(rectangle, centerPoint);
		tileOrder[tileID] = rectangle;
		return tileID;
	}
	
	public function destroy():Void
	{
		tileOrder = null;
	}
}