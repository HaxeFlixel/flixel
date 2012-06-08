package org.flixel.tileSheetManager;
#if (cpp || neko)

import nme.display.BitmapData;
import nme.display.Tilesheet;
import nme.geom.Rectangle;
import nme.geom.Point;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxTilemap;

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
	public static function addTileSheet(bitmapData:BitmapData, ?isTilemap:Bool = false):TileSheetData
	{
		var tempTileSheetData:TileSheetData;
		
		if (containsTileSheet(bitmapData))
		{
			tempTileSheetData = getTileSheet(bitmapData);
			if (tempTileSheetData.isTilemap != isTilemap)
			{
				tempTileSheetData.isTilemap = false;
			}
			return getTileSheet(bitmapData);
		}
		
		tempTileSheetData = new TileSheetData(new Tilesheet(bitmapData), isTilemap);
		tileSheetData.push(tempTileSheetData);
		return (tileSheetData[tileSheetData.length - 1]);
	}
	
	/**
	 * Clears drawData arrays of all tileSheets
	 */
	public static function clearAllDrawData():Void
	{
		var numCameras:Int = FlxG.cameras.length;
		var numPositions:Int;
		
		for (dataObject in tileSheetData)
		{
			dataObject.clearDrawData();
			numPositions = dataObject.positionData.length;
			if (numPositions < numCameras)
			{
				var diff:Int = numCameras - numPositions;
				for (i in 0...(diff))
				{
					dataObject.drawData.push(new Array<Float>());
					dataObject.positionData.push(0);
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
	
	/**
	 * Method for changing draw order of two objects (FlxSprite, FlxText, FlxTilemap etc.)
	 */
	public static function swapDrawableObjects(obj1:FlxObject, obj2:FlxObject):Void
	{
		if (obj1 == null || obj2 == null) return;
		if (obj1 == obj2) return;
		
		var id1:Int = -1;
		var id2:Int = -1;
		
		if (Std.is(obj1, FlxSprite))
		{
			id1 = cast(obj1, FlxSprite).getTileSheetIndex();
		}
		else if (Std.is(obj1, FlxTilemap))
		{
			id1 = cast(obj1, FlxTilemap).getTileSheetIndex();
		}
		
		if (Std.is(obj2, FlxSprite))
		{
			id2 = cast(obj2, FlxSprite).getTileSheetIndex();
		}
		else if (Std.is(obj2, FlxTilemap))
		{
			id2 = cast(obj2, FlxTilemap).getTileSheetIndex();
		}
		
		if (id1 < 0 || id2 < 0) return;
		
		swapTileSheets(id1, id2);
	}
	
	/**
	 * Method for changing draw order of two tileSheets
	 * @param	id1		id of the first tileSheet
	 * @param	id2		id of the second tileSheet
	 */
	public static function swapTileSheets(id1:Int, id2:Int):Void
	{
		if (id1 == id2) return;
		
		var tempTileSheetData:TileSheetData = tileSheetData[id1];
		tileSheetData[id1] = tileSheetData[id2];
		tileSheetData[id2] = tempTileSheetData;
	}
	
	/**
	 * Method for setting draw order of the tileSheet with given id
	 * @param	id			id of the tileSheet
	 * @param	index		drawing index (less - earlier or lower, more - later or higher)
	 */
	public static function setTileSheetIndex(id:Int, index:Int):Void
	{
		if (id < 0 || id > getMaxIndex() || id == index)
		{
			// This tileSheet doesn't exist or we try to set it's index to the same value as it is already
			return;
		}
		
		var tsd:TileSheetData = tileSheetData[id];
		tileSheetData.remove(tsd);
		tileSheetData.insert(index, tsd);
	}
	
	/**
	 * Gets tileSheetData's index. This is internal method
	 */
	public static function getTileSheetIndex(tileSheet:TileSheetData):Int
	{
		for (i in 0...(tileSheetData.length))
		{
			if (tileSheetData[i] == tileSheet)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	/**
	 * Gets the maximum drawing index
	 */
	public static function getMaxIndex():Int
	{
		return (tileSheetData.length - 1);
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