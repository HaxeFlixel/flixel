package flixel.system.layer;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.interfaces.IFlxDestroyable;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.system.layer.Region;
import flixel.system.layer.TileSheetExt;
import flixel.util.FlxPoint;
import flixel.util.loaders.TextureAtlasFrame;
import flixel.util.loaders.TexturePackerData;

/**
 * Object of this class holds information about single Tilesheet
 */
class TileSheetData implements IFlxDestroyable
{
	#if !flash
	public var tileSheet:TileSheetExt;
	#end
	
	/**
	 * Storage for all groups of FlxFrames.
	 */
	private var flxSpriteFrames:Map<String, FlxSpriteFrames>;
	
	/**
	 * Storage for all FlxFrames in this TileSheetData object.
	 */
	private var flxFrames:Map<String, FlxFrame>;
	
	private var frameNames:Array<String>;
	
	public var bitmap:BitmapData;
	
	public function new(Bitmap:BitmapData)
	{
		bitmap = Bitmap;
		#if !flash
		tileSheet = new TileSheetExt(bitmap);
		#end
		flxSpriteFrames = new Map<String, FlxSpriteFrames>();
		flxFrames = new Map<String, FlxFrame>();
		frameNames = new Array<String>();
	}
	
	public inline function getFrame(name:String):FlxFrame
	{
		return flxFrames.get(name);
	}
	
	public function getSpriteSheetFrames(region:Region, ?origin:Point):FlxSpriteFrames
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
		
		var frame:FlxFrame;
		var tempRect:Rectangle;
		
		var spacedWidth:Int = width + xSpacing;
		var spacedHeight:Int = height + ySpacing;
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))
			{
				tempRect = new Rectangle(startX + i * spacedWidth, startY + j * spacedHeight, width, height);
				frame = addSpriteSheetFrame(tempRect, tempPoint);
				spriteData.addFrame(frame);
			}
		}
		
		flxSpriteFrames.set(key, spriteData);
		return spriteData;
	}
	
	/**
	 * Hashing Functionality - TODO: use numbers as keys!
	 * 
	 * http://stackoverflow.com/questions/892618/create-a-hashcode-of-two-numbers
	 * http://stackoverflow.com/questions/299304/why-does-javas-hashcode-in-string-use-31-as-a-multiplier
	 */
	public inline function getSpriteSheetFrameKey(rect:Rectangle, point:Point):String
	{
		return rect.x + "_" + rect.y + "_" + rect.width + "_" + rect.height + "_" + point.x + "_" + point.y;
	}
	
	public inline function getKeyForSpriteSheetFrames(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int, pointX:Float, pointY:Float):String
	{
		return width + "_" + height + "_" + startX + "_" + startY + "_" + endX + "_" + endY + "_" + xSpacing + "_" + ySpacing + "_" + pointX + "_" + pointY;
	}
	
	public function containsSpriteSheetFrames(width:Int, height:Int, startX:Int, startY:Int, endX:Int, endY:Int, xSpacing:Int, ySpacing:Int, pointX:Float, pointY:Float):Bool
	{
		var key = getKeyForSpriteSheetFrames(width, height, startX, startY, endX, endY, xSpacing, ySpacing, pointX, pointY);
		return flxSpriteFrames.exists(key);
	}
	
	/**
	 * Adds new FlxFrame to this TileSheetData object
	 */
	public function addSpriteSheetFrame(rect:Rectangle, point:Point):FlxFrame
	{
		var key:String = getSpriteSheetFrameKey(rect, point);
		if (containsFrame(key))
		{
			return flxFrames.get(key);
		}
		
		var frame:FlxFrame = new FlxFrame(this);
		#if !flash
		frame.tileID = addTileRect(rect, point);
		#end
		frame.name = key;
		frame.frame = rect;
		
		frame.rotated = false;
		frame.trimmed = false;
		frame.sourceSize.set(rect.width, rect.height);
		frame.offset.set(0, 0);
		
		frame.center.set(0.5 * rect.width, 0.5 * rect.height);
		flxFrames.set(key, frame);
		frameNames.push(key);
		return frame;
	}
	
	public inline function containsFrame(key:String):Bool
	{
		return flxFrames.exists(key);
	}
	
	#if !flash
	public inline function addTileRect(tileRect:Rectangle, ?point:Point):Int
	{
		return tileSheet.addTileRectID(tileRect, point);
	}
	#end
	
	public function destroy():Void
	{
		bitmap = null;
		#if !flash
		tileSheet.destroy();
		tileSheet = null;
		#end
		
		for (spriteData in flxSpriteFrames)
		{
			spriteData.destroy();
		}
		
		for (frames in flxSpriteFrames)
		{
			frames.destroy();
		}
		flxSpriteFrames = null;
		
		for (frame in flxFrames)
		{
			frame.destroy();
		}
		flxFrames = null;
		
		frameNames = null;
	}
	
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
		
		var frame:FlxFrame;
		var packerFrames:FlxSpriteFrames = new FlxSpriteFrames(data.assetName);
		
		var l:Int = data.frames.length;
		for (i in 0...l)
		{
			frame = addTexturePackerFrame(data.frames[i], startX, startY);
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
		texFrame.sourceSize.copyFrom(frameData.sourceSize);
		texFrame.offset.copyFrom(frameData.offset);
		texFrame.center.set(0, 0);
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
		frameNames.push(key);
		return texFrame;
	}
	
	public function destroyFrameBitmapDatas():Void
	{
		var numFrames:Int = frameNames.length;
		for (i in 0...numFrames)
		{
			flxFrames.get(frameNames[i]).destroyBitmapDatas();
		}
		/*for (frame in flxFrames)
		{
			frame.destroyBitmapDatas();
		}*/
	}
}