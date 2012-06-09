package org.flixel.tileSheetManager;

#if (cpp || neko)
import nme.display.Graphics;
import nme.display.Tilesheet;
import nme.geom.Point;
import nme.geom.Rectangle;
import org.flixel.FlxCamera;
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
	
	/**
	 * smoothing for tileSheet
	 */
	public var antialiasing:Bool;
	
	/**
	 * logical flag showing what draw mode use for the tileSheet 
	 * if it is true then tileSheet is drawn with rotation, alpha and scale 
	 */
	private var _isTilemap:Bool;
	
	private var _isColored:Bool;
	
	public var positionData:Array<Int>;
	
	public function new(tileSheet:Tilesheet, ?isTilemap:Bool = false)
	{
		this.tileSheet = tileSheet;
		antialiasing = false;
		pairsData = new Array<RectanglePointPair>();
		drawData = new Array<Array<Float>>();
		
		_isTilemap = isTilemap;
		_isColored = false;
		updateFlags();
		
		positionData = [];
		
		flxSpriteFrames = new Array<FlxSpriteFrames>();
	}
	
	/**
	 * Adds new ID array for FlxSprite with specific dimensions
	 * @param	width	sprite width
	 * @param	height	sprite height
	 * @return			IDs of tileRectangles for FlxSprite with given dimensions
	 */
	public function addSpriteFramesData(width:Int, height:Int, ?origin:Point = null, ?startX:Int = 0, ?startY:Int = 0, ?endX:Int = 0, ?endY:Int = 0, ?xSpacing:Int = 0, ?ySpacing:Int = 0):FlxSpriteFrames
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
		
		if (containsSpriteFrameData(width, height, startX, startY, endX, endY, xSpacing, ySpacing))
		{
			var id:Int = getIDforSpriteFrameData(width, height, startX, startY, endX, endY, xSpacing, ySpacing);
			return flxSpriteFrames[id];
		}
		
		var numRows:Int = Math.floor((endY - startY) / (height + ySpacing));
		var numCols:Int = Math.floor((endX - startX) / (width + xSpacing));
		
		var spriteData:FlxSpriteFrames = new FlxSpriteFrames(width, height, startX, startY, endX, endY, xSpacing, ySpacing);
		var tempPoint:Point = origin;
		if (origin == null)
		{
			tempPoint = new Point(0.5 * width, 0.5 * height);
		}
		
		var tempRect:Rectangle;
		var tileID:Int;
		
		var spacedWidth:Int = width + xSpacing;
		var spacedHeight:Int = height + ySpacing;
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))
			{
				tempRect = new Rectangle(i * spacedWidth, j * spacedHeight, width, height);
				tileID = addTileRect(tempRect, tempPoint);
				spriteData.frameIDs.push(tileID);
			}
		}
		
		spriteData.halfFrameNumber = Math.floor(0.5 * spriteData.frameIDs.length);
		flxSpriteFrames.push(spriteData);
		//return spriteData.frameIDs;
		return spriteData;
	}
	
	public function containsSpriteFrameData(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int):Bool
	{
		for (spriteData in flxSpriteFrames)
		{
			if ((spriteData.width == width) && (spriteData.height == height) && (spriteData.startX == startX) && (spriteData.startY == startY) && (spriteData.endX == endX) && (spriteData.endY == endY) && (spriteData.xSpacing == xSpacing) && (spriteData.ySpacing == ySpacing))
			{
				return true;
			}
		}
		
		return false;
	}
	
	public function getIDforSpriteFrameData(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int):Int
	{
		var spriteData:FlxSpriteFrames;
		for (i in 0...(flxSpriteFrames.length))
		{
			spriteData = flxSpriteFrames[i];
			if ((spriteData.width == width) && (spriteData.height == height) && (spriteData.startX == startX) && (spriteData.startY == startY) && (spriteData.endX == endX) && (spriteData.endY == endY) && (spriteData.xSpacing == xSpacing) && (spriteData.ySpacing == ySpacing))
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
		/*for (dataArray in drawData)
		{
			var len:Int = dataArray.length;
			if (len > 0) dataArray.splice(0, len);
		}*/
		
		for (i in 0...(positionData.length))
		{
			positionData[i] = 0;
		}
	}
	
	public function render(numCameras:Int):Void
	{
		var cameraGraphics:Graphics;
		var data:Array<Float>;
		var dataLen:Int;
		var position:Int;
		var camera:FlxCamera;
		var tempFlags:Int;
		for (i in 0...(numCameras))
		{
			tempFlags = flags;
			
			data = drawData[i];
			dataLen = data.length;
			position = positionData[i];
			if (dataLen > 0)
			{
				if (dataLen != position)
				{
					data.splice(position, (dataLen - position));
				}
				
				camera = FlxG.cameras[i];
				
				if (camera.isColored)
				{
					tempFlags |= Graphics.TILE_RGB;
				}
				
				cameraGraphics = camera._canvas.graphics;
				tileSheet.drawTiles(cameraGraphics, data, (antialiasing || camera.antialiasing), tempFlags);
			}
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
		positionData = null;
		
		for (spriteData in flxSpriteFrames)
		{
			spriteData.destroy();
		}
		flxSpriteFrames = null;
	}
	
	public var isTilemap(get_isTilemap, set_isTilemap):Bool;
	
	private function get_isTilemap():Bool 
	{
		return _isTilemap;
	}
	
	private function set_isTilemap(value:Bool):Bool 
	{
		_isTilemap = value;
		updateFlags();
		return value;
	}
	
	public var isColored(get_isColored, set_isColored):Bool;
	
	private function get_isColored():Bool
	{
		return _isColored;
	}
	
	private function set_isColored(value:Bool):Bool
	{
		_isColored = value;
		updateFlags();
		return value;
	}
	
	// TODO: Check this method
	private function updateFlags():Void
	{
		flags = 0;
		
		if (_isTilemap == true && _isColored == true)
		{
			flags = Graphics.TILE_RGB;
		}
		else if (_isTilemap == false && _isColored == true)
		{
			flags = Graphics.TILE_TRANS_2x2 | Graphics.TILE_ALPHA | Graphics.TILE_RGB;
		}
		else if (_isTilemap == false && _isColored == false)
		{
			flags = Graphics.TILE_TRANS_2x2 | Graphics.TILE_ALPHA;
		}
	}
	
}

class FlxSpriteFrames
{
	
	public var width:Int;
	public var height:Int;
	public var frameIDs:Array<Int>;
	public var halfFrameNumber:Int;
	
	public var startX:Int;
	public var startY:Int;
	public var endX:Int;
	public var endY:Int;
	public var xSpacing:Int;
	public var ySpacing:Int;
	
	public function new(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int)
	{
		this.width = width;
		this.height = height;
		
		this.startX = startX;
		this.startY = startY;
		this.endX = endX;
		this.endY = endY;
		this.xSpacing = xSpacing;
		this.ySpacing = ySpacing;
		
		frameIDs = [];
		halfFrameNumber = 0;
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