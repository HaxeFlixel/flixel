package org.flixel.tileSheetManager;

#if cpp
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxG;

/**
 * Object of this class holds information about single Tilesheet
 */
class TileSheetData
{
	
	public var tileSheet:Tilesheet;
	
	/**
	 * array to hold data about tiles in the tileSheet object
	 */
	public var pairsData:Array<RectanglePointPair>;
	
	/**
	 * special array to hold data for sprite drawing to different cameras
	 */
	public var drawData:Array<Array<Float>>;
	
	/**
	 * drawing flags
	 */
	public var flags:Int;
	
	/**
	 * special array to hold frame ids for FlxSprites with different sizes (width and height)
	 */
	public var flxSpriteFrames:Array<FlxSpriteFrames>;
	
	public function new(tileSheet:Tilesheet)
	{
		this.tileSheet = tileSheet;
		pairsData = new Array<RectanglePointPair>();
		drawData = new Array<Array<Float>>();
		flags = Graphics.TILE_SCALE | Graphics.TILE_ROTATION | Graphics.TILE_ALPHA | Graphics.TILE_RGB;
		
		flxSpriteFrames = new Array<FlxSpriteFrames>();
	}
	
	/**
	 * Adds new ID array for FlxSprite with specific dimensions
	 * @param	width	sprite width
	 * @param	height	sprite height
	 * @return			IDs of tileRectangles for FlxSprite with given dimensions
	 */
	public function addSpriteFramesData(width:Int, height:Int):Array<Int>
	{
		if (containsSpriteFrameData(width, height))
		{
			var id:Int = getIDforSpriteFrameData(width, height);
			return flxSpriteFrames[id].frameIDs;
		}
		
		var bitmapWidth:Int = tileSheet.nmeBitmap.width;
		var bitmapHeight:Int = tileSheet.nmeBitmap.height;
		var numRows:Int = Math.floor(bitmapHeight / height);
		var numCols:Int = Math.floor(bitmapWidth / width);
		
		var spriteData:FlxSpriteFrames = new FlxSpriteFrames(width, height);
		var tempPoint:Point;
		var tempRect:Rectangle;
		var tileID:Int;
		for (i in 0...(numCols))
		{
			for (j in 0...(numRows))
			{
				tempRect = new Rectangle(i * width, j * height, width, height);
				tempPoint = new Point(0.5 * width, 0.5 * height);
				tileID = addTileRect(tempRect, tempPoint);
				spriteData.frameIDs.push(tileID);
			}
		}
		flxSpriteFrames.push(spriteData);
		
		return spriteData.frameIDs;
	}
	
	public function containsSpriteFrameData(width:Int, height:Int):Bool
	{
		for (spriteData in flxSpriteFrames)
		{
			if (spriteData.width == width && spriteData.height == height)
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function getIDforSpriteFrameData(width:Int, height:Int):Int
	{
		var spriteData:FlxSpriteFrames;
		for (i in 0...(flxSpriteFrames.length))
		{
			spriteData = flxSpriteFrames[i];
			if (spriteData.width == width && spriteData.height == height)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	/**
	 * Clears data array for next frame
	 */
	public function clearDrawData():Void
	{
		for (dataArray in drawData)
		{
			dataArray = [];
		}
	}
	
	public function render(numCameras:Int):Void
	{
		var cameraGraphics:Graphics;
		for (i in 0...(numCameras))
		{
			cameraGraphics = FlxG.cameras[i]._flashSprite.graphics;
			cameraGraphics.drawTiles(tileSheet, drawData[i], false, flags);
		}
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
		drawData = null;
		
		for (spriteData in flxSpriteFrames)
		{
			spriteData.destroy();
		}
		flxSpriteFrames = null;
	}
	
}

class FlxSpriteFrames
{
	
	public var width:Int;
	public var height:Int;
	public var frameIDs:Array<Int>;
	
	public function new(width:Int, height:Int)
	{
		this.width = width;
		this.height = height;
		frameIDs = [];
	}
	
	public function destroy():Void
	{
		frameIDs = null;
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
#end