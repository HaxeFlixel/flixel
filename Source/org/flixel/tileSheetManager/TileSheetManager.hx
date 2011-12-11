package org.flixel.tileSheetManager;
#if cpp

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
	 * Adds new tileSheet to manager and returns it
	 * If manager already contains tileSheet with the same bitmapData then it returns this tileSheetData object 
	 */
	public static function addTileSheet(bitmapData:BitmapData):TileSheetData
	{
		if (containsTileSheet(bitmapData))
		{
			//return getTileSheetID(bitmapData);
			return getTileSheet(bitmapData);
		}
		
		var tempTileSheetData:TileSheetData = new TileSheetData(new Tilesheet(bitmapData));
		tileSheetData.push(tempTileSheetData);
		//return (tileSheetData.length - 1);
		return (tileSheetData[tileSheetData.length - 1]);
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
				var diff:Int = numCameras - dataObject.drawData.length;
				for (i in 0...(diff))
				{
					dataObject.drawData.push(new Array<Float>());
				}
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
	
	public static function getTileSheet(bitmapData:BitmapData):TileSheetData
	{
		for (tsd in tileSheetData)
		{
			if (tsd.tileSheet.nmeBitmap == bitmapData)
			{
				return tsd;
			}
		}
		
		return null;
	}
	
	public static function removeTileSheet(tileSheetObj:TileSheetData):Void
	{
		for (i in 0...(tileSheetData.length))
		{
			if (tileSheetData[i] == tileSheetObj)
			{
				tileSheetData.splice(i, 1);
				tileSheetObj.destroy();
			}
		}
	}
	
	public static function clear():Void
	{
		for (dataObject in tileSheetData)
		{
			dataObject.destroy();
		}
		
		tileSheetData = new Array<TileSheetData>();
	}
	
}
#end