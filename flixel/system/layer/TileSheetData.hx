package flixel.system.layer;

<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
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
=======
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.system.layer.TileSheetExt;
import flixel.util.FlxPoint;
import flixel.util.loaders.TextureAtlasFrame;
import flixel.system.layer.Region;
import flixel.util.loaders.TexturePackerData;
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/layer/TileSheetData.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/TileSheetData.hx
>>>>>>> experimental

/**
 * Object of this class holds information about single Tilesheet
 */
class TileSheetData
{
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
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
=======
	#if !flash
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/TileSheetData.hx
	public var tileSheet:TileSheetExt;
	#end
	
	/**
	 * special array to hold frame ids for FlxSprites with different sizes (width and height)
	 */
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
	// TODO: redocument this
	private var flxSpriteFrames:Map<String, FlxSpriteFrames>;
	
	// TODO: document this
	private var flxFrames:Map<String, FlxFrame>;
=======
	private var flxSpriteFrames:Map<String, FlxSpriteFrames>;
	
	/**
	 * Storage for all FlxFrames in this TileSheetData object.
	 */
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/layer/TileSheetData.hx
=======
>>>>>>> experimental
	private var flxFrames:Map<String, FlxFrame>;
	
	public var bitmap:BitmapData;
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/TileSheetData.hx
	
	public function new(bitmap:BitmapData)
	{
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
		this.tileSheet = tileSheet;
		flxSpriteFrames = new Map<String, FlxSpriteFrames>();
<<<<<<< HEAD
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
=======
>>>>>>> experimental
		// TODO: fill this hash later
		flxFrames = new Map<String, FlxFrame>();
=======
		this.bitmap = bitmap;
		#if !flash
		this.tileSheet = new TileSheetExt(bitmap);
		#end
		flxSpriteFrames = new Map<String, FlxSpriteFrames>();
		flxFrames = new Map<String, FlxFrame>();
	}
	
	public function getFrame(name:String):FlxFrame
	{
		return flxFrames.get(name);
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/layer/TileSheetData.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/TileSheetData.hx
>>>>>>> experimental
	}
	
	/**
	 * Adds new ID array for FlxSprite with specific dimensions
	 * @param	width	sprite width
	 * @param	height	sprite height
	 * @return			IDs of tileRectangles for FlxSprite with given dimensions
	 */
	public function getSpriteSheetFrames(region:Region, origin:Point = null):FlxSpriteFrames
	{
		var bitmapWidth:Int = region.width;
		var bitmapHeight:Int = region.height;
		
		var startX:Int = region.startX;
		var startY:Int = region.startY;
		
		var endX:Int = startX + bitmapWidth;
		var endY:Int = startY + bitmapHeight;
		
		var xSpacing:Int = region.spacingX;
		var ySpacing:Int = region.spacingY;
		
		var width:Int = (region.tileWidth == 0) ? bitmapWidth : region.tileWidth;
		var height:Int = (region.tileHeight == 0) ? bitmapHeight : region.tileHeight;
		
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
		
		var numRows:Int = region.numRows;
		var numCols:Int = region.numCols;
		
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
	
	#if !flash
	public function addTileRect(tileRect, point):Int
	{
		return tileSheet.addTileRectID(tileRect, point);
	}
	#end
	
	public function destroy():Void
	{
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
=======
		bitmap = null;
		#if !flash
		tileSheet.destroy();
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/TileSheetData.hx
		tileSheet = null;
		#end
		
		for (spriteData in flxSpriteFrames)
		{
			spriteData.destroy();
		}
		
		// TODO: destroy FlxSpriteFrames in flxSpriteFrames hash
		flxSpriteFrames = null;
		// TODO: destroy FlxFrames in flxFrames hash
		flxFrames = null;
	}
<<<<<<< HEAD:src/org/flixel/system/layer/TileSheetData.hx
}
=======
	
	#if !flash
	public function onContext(bitmap:BitmapData):Void
	{
		this.bitmap = bitmap;
		var newSheet:TileSheetExt = new TileSheetExt(bitmap);
		newSheet.rebuildFromOld(tileSheet);
		tileSheet = newSheet;
	}
	#end
	
	/**
	 * Parses provided TexturePackerData object and returns generated FlxSpriteFrames object
	 */
	public function getTexturePackerFrames(data:TexturePackerData, startX:Int = 0, startY:Int = 0):FlxSpriteFrames
	{
		// No need to parse data again
		if (flxSpriteFrames.exists(data.assetName))	
		{
			return flxSpriteFrames.get(data.assetName);
		}
		
		data.parseData();
		var packerFrames:FlxSpriteFrames = new FlxSpriteFrames(data.assetName);
		
		var l:Int = data.frames.length;
		for (i in 0...l)
		{
			var frame:FlxFrame = addTexturePackerFrame(data.frames[i], startX, startY);
			packerFrames.addFrame(frame);
		}
		
		flxSpriteFrames.set(data.assetName, packerFrames);
		return packerFrames;
	}
	
	/**
	 * Parses frame TexturePacker data object and returns it
	 */
	private function addTexturePackerFrame(frameData:TextureAtlasFrame, startX:Int = 0, startY:Int = 0):FlxFrame
	{
		var key:String = frameData.name;
		if (containsFrame(key))
		{
			return flxFrames.get(key);
		}
		
		var texFrame:FlxFrame = new FlxFrame(this);
		texFrame.trimmed = frameData.trimmed;
		texFrame.rotated = frameData.rotated;
		texFrame.name = key;
		texFrame.sourceSize = new FlxPoint().copyFrom(frameData.sourceSize);
		texFrame.offset = new FlxPoint().copyFrom(frameData.offset);
		texFrame.center = new FlxPoint(0, 0);
		texFrame.frame = frameData.frame.clone();
		
		if (frameData.rotated)
		{
			texFrame.center.set(texFrame.frame.height * 0.5 + texFrame.offset.x, texFrame.frame.width * 0.5 + texFrame.offset.y);
			texFrame.additionalAngle = -90.0;
		}
		else
		{
			texFrame.center.set(texFrame.frame.width * 0.5 + texFrame.offset.x, texFrame.frame.height * 0.5 + texFrame.offset.y);
		}
		#if !flash
		texFrame.tileID = addTileRect(texFrame.frame, new Point(0.5 * texFrame.frame.width, 0.5 * texFrame.frame.height));
		#end
		flxFrames.set(key, texFrame);
		return texFrame;
	}
	
	public function destroyFrameBitmapDatas():Void
	{
		for (frame in flxFrames)
		{
			frame.destroyBitmapDatas();
		}
	}
}
<<<<<<< HEAD
>>>>>>> origin/dev:flixel/system/layer/TileSheetData.hx
=======
>>>>>>> 5a1503ca00e410df1bad6c3cb6c137b33f090265:flixel/system/layer/TileSheetData.hx
>>>>>>> experimental
