package org.flixel.system.layer;

import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxPoint;

/**
 * Object of this class holds information about single Tilesheet
 */
class TileSheetData
{
	public static var tileSheetData:Array<TileSheetData> = new Array<TileSheetData>();
	
	public static var _DRAWCALLS:Int = 0;
	
	/**
	 * Adds new tileSheet to manager and returns it
	 * If manager already contains tileSheet with the same bitmapData then it returns this tileSheetData object 
	 */
	public static function addTileSheet(bitmapData:BitmapData):TileSheetData
	{
		var tempTileSheetData:TileSheetData;
		
		if (containsTileSheet(bitmapData))
		{
			tempTileSheetData = getTileSheet(bitmapData);
			return getTileSheet(bitmapData);
		}
		
		tempTileSheetData = new TileSheetData(new Tilesheet(bitmapData));
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
	}
	
	
	
	
	// TODO: make it work only on non-flash targets
	public var tileSheet:Tilesheet;
	
	/**
	 * array to hold data about tiles in the tileSheet object
	 */
	private var pairsData:Array<RectanglePointPair>;
	
	/**
	 * special array to hold frame ids for FlxSprites with different sizes (width and height)
	 */
	// TODO: redocument this
	private var flxSpriteFrames:Hash<FlxSpriteFrames>;
	
	// TODO: document this
	private var flxFrames:Hash<FlxFrame>;
	
	public function new(tileSheet:Tilesheet)
	{
		this.tileSheet = tileSheet;
		pairsData = new Array<RectanglePointPair>();
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
		
		var frame:FlxFrame = new FlxFrame();
		frame.tileID = addTileRect(rect, point);
		frame.rotated = false;
		frame.trimmed = false;
		frame.name = key;
		frame.offset = new FlxPoint();
		frame.sourceSize = new FlxPoint(rect.width, rect.height);
		frame.frame = rect;
		flxFrames.set(key, frame);
		return frame;
	}
	
	public function containsFrame(key:String):Bool
	{
		return flxFrames.exists(key);
	}
	
	public function getTexturePackerFrames(name:String, animated:Bool = false):FlxSpriteFrames
	{
		// TODO: implement this
		return null;
	}
	
	// TODO: document and implement this
	/*public function addTexturePackerFrame(key:String, ):FlxFrame
	{
		
		if (this.containsFrame(rect, point))
		{
			return getTileRectID(rect, point);
		}
		
		tileSheet.addTileRect(rect, point);
		pairsData.push(new RectanglePointPair(rect, point));
		return (pairsData.length - 1);
	}*/
	
	/**
	 * Adds new tileRect to tileSheet object
	 * @return id of added tileRect
	 */
	public function addTileRect(rect:Rectangle, point:Point = null):Int
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
	public function containsTileRect(rect:Rectangle, point:Point = null):Bool
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
	public function getTileRectID(rect:Rectangle, point:Point = null):Int
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

class FlxSpriteFrames
{
	public var frames:Array<FlxFrame>;
	public var name:String;
	
	public function new(name:String)
	{
		this.name = name;
		frames = [];
	}
	
	public function destroy():Void
	{
		frames = null;
		name = null;
	}	
}

class FlxFrame
{
	public var name:String = null;
	public var rotated:Bool = false;
	public var trimmed:Bool = false;
	public var frame:Rectangle = null;
	public var sourceSize:FlxPoint = null;
	public var offset:FlxPoint = null;
	public var tileID:Int = -1;
	
	public function new()
	{
		
	}
	
	public function destroy():Void
	{
		name = null;
		frame = null;
		sourceSize = null;
		offset = null;
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