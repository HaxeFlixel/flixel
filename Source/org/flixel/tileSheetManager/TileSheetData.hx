package org.flixel.tileSheetManager;

import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;

/**
 * Object of this class holds information about single Tilesheet
 */
class TileSheetData
{
	
	public var tileSheet:Tilesheet;
	public var pairsData:Array<RectanglePointPair>;
	public var drawData:Array<Array<Float>>;
	
	public function new(tileSheet:Tilesheet)
	{
		this.tileSheet = tileSheet;
		pairsData = new Array<RectanglePointPair>();
		drawData = new Array<Array<Float>>();
	}
	
	/**
	 * Clears data array for next frame
	 */
	public function clearDrawData():Void
	{
		drawData = [];
	}
	
	/**
	 * Adds new tileRect to tileSheet object
	 * @return id of added tileRect
	 */
	public function addTileRect(rect:Rectangle, ?point:Point = null):Int
	{
		if (this.containsTileRect(rect, point))
		{
			return getTileRectID(rect, point);
		}
		
		tileSheet.addTileRect(rect, point);
		pairsData.push(new RectanglePointPair(rect, point));
		return (pairsData.length - 1);
	}
	
	/**
	 * Search for given data of tileRect and returns true if tileSheet already contains such tileRect
	 */
	public function containsTileRect(rect:Rectangle, ?point:Point = null):Bool
	{
		for (pair in pairsData)
		{
			if (pair.rect.equals(rect))
			{
				if (pair.point != null && point != null && pair.point.equals(point))
				{
					return true;
				}
				else if (pair.point == null && point == null)
				{
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Search for given data of tileRect and returns ID of that tileRect (if this tileRect doesn't exist then returns -1)
	 */
	public function getTileRectID(rect:Rectangle, ?point:Point = null):Int
	{
		var pair:RectanglePointPair;
		for (i in 0...(pairsData.length))
		{
			pair = pairsData[i];
			if (pair.rect.equals(rect))
			{
				if (pair.point != null && point != null && pair.point.equals(point))
				{
					return i;
				}
				else if (pair.point == null && point == null)
				{
					return i;
				}
			}
		}
		
		return -1;
	}
	
	public function destroy():Void
	{
		tileSheet.nmeBitmap = null;
		tileSheet = null;
		
		for (pair in pairsData)
		{
			pair.destroy();
		}
		pairsData = null;
	}
	
}

/**
 * Helper class to store data about "frames" of tilesheets
 */
class RectanglePointPair
{
	
	public var rect:Rectangle;
	public var point:Point;
	
	public function new(rect:Rectangle, point:Point)
	{
		this.rect = rect;
		this.point = point;
	}
	
	public function destroy():Void
	{
		rect = null;
		point = null;
	}
	
}