package org.flixel.system.layer;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPoint;

import org.flixel.system.layer.TileSheetExt;
import org.flixel.system.layer.frames.FlxFrame;
import org.flixel.system.layer.frames.FlxSpriteFrames;

/**
 * Object of this class holds information about single Tilesheet
 */
class TileSheetData
{
	private static var tileSheetData:Array<TileSheetData> = new Array<TileSheetData>();
	
	public static var _DRAWCALLS:Int = 0;
	
	/**
	 * Adds new tileSheet to manager and returns it
	 * If manager already contains tileSheet with the same bitmapData then it returns this tileSheetData object 
	 */
	public static function addTileSheet(bitmapData:BitmapData):TileSheetData
	{
		if (containsTileSheet(bitmapData))
		{
			return getTileSheet(bitmapData);
		}
		
		var tilesheet:TileSheetExt = TileSheetExt.addTileSheet(bitmapData);
		var tempTileSheetData:TileSheetData = new TileSheetData(tilesheet);
		tileSheetData.push(tempTileSheetData);
		return tempTileSheetData;
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
	
	public static function removeTileSheet(tileSheetObj:TileSheetData):Void
	{
		for (i in 0...(tileSheetData.length))
		{
			if (tileSheetData[i] == tileSheetObj)
			{
				// Fast array removal (only do on arrays where order doesn't matter)
				tileSheetData[i] = tileSheetData[tileSheetData.length - 1];
				tileSheetData.pop();
				
				tileSheetObj.destroy();
				return;
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
		
		TileSheetExt.clear();
	}
	
	
	
	
	// TODO: make it work only on non-flash targets
	public var tileSheet:TileSheetExt;
	
	/**
	 * special array to hold frame ids for FlxSprites with different sizes (width and height)
	 */
	// TODO: redocument this
	private var flxSpriteFrames:Hash<FlxSpriteFrames>;
	
	// TODO: document this
	private var flxFrames:Hash<FlxFrame>;
	
	private function new(tileSheet:TileSheetExt)
	{
		this.tileSheet = tileSheet;
		flxSpriteFrames = new Hash<FlxSpriteFrames>();
		// TODO: fill this hash later
		flxFrames = new Hash<FlxFrame>();
	}
	
	/**
	 * Adds new ID array for FlxSprite with specific dimensions
	 * @param	width	sprite width
	 * @param	height	sprite height
	 * @return			IDs of tileRectangles for FlxSprite with given dimensions
	 */
	public function getSpriteSheetFrames(width:Int, height:Int, origin:Point = null, startX:Int = 0, startY:Int = 0, endX:Int = 0, endY:Int = 0, xSpacing:Int = 0, ySpacing:Int = 0):FlxSpriteFrames
	{
		var bitmapWidth:Int = tileSheet.nmeBitmap.width;
		var bitmapHeight:Int = tileSheet.nmeBitmap.height;
		
		if (endX == 0)
		{
			endX = bitmapWidth;
		}
		if (endY == 0)
		{
			endY = bitmapHeight;
		}
		
		var pointX:Float = 0.5 * width;
		var pointY:Float = 0.5 * height;
		
		if (origin != null)
		{
			pointX = origin.x;
			pointY = origin.y;
		}
		
		var key:String = getKeyForSpriteSheetFrames(width, height, startX, startY, endX, endY, xSpacing, ySpacing, pointX, pointY);
		if (flxSpriteFrames.exists(key))
		{
			return flxSpriteFrames.get(key);
		}
		
		var numRows:Int = Std.int((endY - startY) / (height + ySpacing));
		var numCols:Int = Std.int((endX - startX) / (width + xSpacing));
		
		var tempPoint:Point = origin;
		if (origin == null)
		{
			tempPoint = new Point(pointX, pointY);
		}
		
		var spriteData:FlxSpriteFrames = new FlxSpriteFrames(key);
		
		var tempRect:Rectangle;
		var frame:FlxFrame;
		
		var spacedWidth:Int = width + xSpacing;
		var spacedHeight:Int = height + ySpacing;
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))
			{
				tempRect = new Rectangle(startX + i * spacedWidth, startY + j * spacedHeight, width, height);
				frame = addSpriteSheetFrame(tempRect, tempPoint);
				spriteData.frames.push(frame);
			}
		}
		
		flxSpriteFrames.set(key, spriteData);
		return spriteData;
	}
	
	public function containsSpriteSheetFrames(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int, pointX:Float, pointY:Float):Bool
	{
		var key:String = getKeyForSpriteSheetFrames(width, height, startX, startY, endX, endY, xSpacing, ySpacing, pointX, pointY);
		return flxSpriteFrames.exists(key);
	}
	
	public function getKeyForSpriteSheetFrames(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int, pointX:Float, pointY:Float):String
	{
		return width + "_" + height + "_" + startX + "_" + startY + "_" + endX + "_" + endY + "_" + xSpacing + "_" + ySpacing + "_" + pointX + "_" + pointY;
	}
	
	// TODO: document this
	public function getSpriteSheetFrameKey(rect:Rectangle, point:Point):String
	{
		return rect.x + "_" + rect.y + "_" + rect.width + "_" + rect.height + "_" + point.x + "_" + point.y;
	}
	
	// TODO: document this
	public function addSpriteSheetFrame(rect:Rectangle, point:Point):FlxFrame
	{
		var key:String = getSpriteSheetFrameKey(rect, point);
		if (containsFrame(key))
		{
			return flxFrames.get(key);
		}
		
		var frame:FlxFrame = new FlxFrame(this);
		frame.tileID = addTileRect(rect, point);
		frame.name = key;
		frame.frame = rect;
		flxFrames.set(key, frame);
		return frame;
	}
	
	public function containsFrame(key:String):Bool
	{
		return flxFrames.exists(key);
	}
	
	public function addTileRect(tileRect, point):Int
	{
		return tileSheet.addTileRectID(tileRect, point);
	}
	
	public function destroy():Void
	{
		tileSheet = null;
		
		for (spriteData in flxSpriteFrames)
		{
			spriteData.destroy();
		}
		
		// TODO: destroy FlxSpriteFrames in flxSpriteFrames hash
		flxSpriteFrames = null;
		// TODO: destroy FlxFrames in flxFrames hash
		flxFrames = null;
	}
}