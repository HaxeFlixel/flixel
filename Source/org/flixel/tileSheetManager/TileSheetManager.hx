package org.flixel.tileSheetManager;

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import nme.geom.Point;

/**
 * ...
 * @author Zaphod
 */

class TileSheetManager 
{
	
	public var tileSheetData:Array<TileSheetData>;
	
	public function new() 
	{
		tileSheetData = new Array<TileSheetData>();
	}
	
	/**
	 * Adds new tileSheet to manager and returns its ID (index in tileSheetData array)
	 * If manager already contains tileSheet with the same bitmapData then it return ID of this tileSheetData object 
	 */
	public function addTileSheet(bitmapData:BitmapData):Int
	{
		if (containsTileSheet(bitmapData))
		{
			return getTileSheetID(bitmapData);
		}
		
		// TODO: continue here
	}
	
	public function addTileRectToTileSheet(tileSheetID:Int, rect:Rectangle, ?point:Point = null):Int
	{
		if (tileSheetID >= tileSheetData.length) return -1;
		
		// TODO: continue here
		
	}
	
	// Какие еще методы добавить в данный класс ???????????????????????????????????
	
	public function containsTileSheet(bitmapData:BitmapData):Bool
	{
		for (tsd in tileSheetData)
		{
			if (tsd.tileSheet.nmeBitmap == bitmapData)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function getTileSheetID(bitmapData:BitmapData):Int
	{
		var tileSheet:Tilesheet;
		for (i in 0...(tileSheetData.length))
		{
			if (tileSheetData[i].tileSheet.nmeBitmap == bitmapData)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	public function clear():Void
	{
		// TODO: continue here
	}
	
	public function destroy():Void
	{
		// TODO: continue here
	}
	
}