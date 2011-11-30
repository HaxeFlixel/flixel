package org.flixel.tileSheetManager;

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import nme.geom.Point;
import org.flixel.FlxG;

/**
 * ...
 * @author Zaphod
 */

class TileSheetManager 
{
	
	public static var tileSheetData:Array<TileSheetData> = new Array<TileSheetData>();
	
	public function new() {  }
	
	/**
	 * Adds new tileSheet to manager and returns its ID (index in tileSheetData array)
	 * If manager already contains tileSheet with the same bitmapData then it return ID of this tileSheetData object 
	 */
	public static function addTileSheet(bitmapData:BitmapData):Int
	{
		if (containsTileSheet(bitmapData))
		{
			return getTileSheetID(bitmapData);
		}
		
		var tempTileSheetData:TileSheetData = new TileSheetData(new Tilesheet(bitmapData));
		tileSheetData.push(tempTileSheetData);
		return (tileSheetData.length - 1);
	}
	
	/**
	 * Clears drawData arrays of all tileSheets
	 */
	public static function clearAllDrawData():Void
	{
		var numCameras:Int = FlxG.cameras.length;
		
		for (dataObject in tileSheetData)
		{
			dataObject.clearDrawData();
			if (dataObject.drawData.length < numCameras)
			{
				dataObject.drawData.push(new Array<Float>());
			}
		}
	}
	
	public static function renderAll():Void
	{
		var numCameras:Int = FlxG.cameras.length;
		
		for (dataObject in tileSheetData)
		{
			dataObject.render(numCameras);
		}
	}
	
	public static function containsTileSheet(bitmapData:BitmapData):Bool
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
	
	public static function getTileSheetID(bitmapData:BitmapData):Int
	{
		for (i in 0...(tileSheetData.length))
		{
			if (tileSheetData[i].tileSheet.nmeBitmap == bitmapData)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	public static function clear():Void
	{
		for (dataObject in tileSheetData)
		{
			dataObject.destroy();
		}
		
		tileSheetData = [];
	}
	
}