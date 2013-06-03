package org.flixel.plugin.texturepacker;

import org.flixel.system.layer.frames.FlxFrame;
import org.flixel.system.layer.frames.FlxSpriteFrames;
import org.flixel.system.layer.TileSheetData;
import org.flixel.system.layer.TileSheetExt;

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import nme.display.Tilesheet;

class TexturePackerTileSheetData extends TileSheetData
{
	public static function addTileSheet(bitmapData:BitmapData, tex:TexturePackerData):TexturePackerTileSheetData
	{
		if (TexturePackerTileSheetData.containsTileSheet(bitmapData))
		{
			return TexturePackerTileSheetData.getTileSheet(bitmapData);
		}
		
		var tilesheet:TileSheetExt = TileSheetExt.addTileSheet(bitmapData);
		var tempTileSheetData:TexturePackerTileSheetData = new TexturePackerTileSheetData(tilesheet, tex);
		TileSheetData.tileSheetData.push(tempTileSheetData);
		return tempTileSheetData;
	}
	
	public static function containsTileSheet(bitmapData:BitmapData):Bool
	{
		for (tsd in TileSheetData.tileSheetData)
		{
			if (tsd.tileSheet.nmeBitmap == bitmapData && Std.is(tsd, TexturePackerTileSheetData))
			{
				return true;
			}
		}
		return false;
	}
	
	public static function getTileSheet(bitmapData:BitmapData):TexturePackerTileSheetData
	{
		for (tsd in TileSheetData.tileSheetData)
		{
			if (tsd.tileSheet.nmeBitmap == bitmapData && Std.is(tsd, TexturePackerTileSheetData))
			{
				return cast(tsd, TexturePackerTileSheetData);
			}
		}
		return null;
	}

	private var _tex:TexturePackerData;
	
	private function new(tileSheet:TileSheetExt, tex:TexturePackerData)
	{
		_tex = tex;
		super(tileSheet);
	}

	override public function getSpriteSheetFrames(width:Int, height:Int, origin:Point = null, startX:Int = 0, startY:Int = 0, endX:Int = 0, endY:Int = 0, xSpacing:Int = 0, ySpacing:Int = 0):FlxSpriteFrames
	{
		var p = new Point(0.5 * width, 0.5 * height);
		var tileId:Int = 0;
		var frame:FlxFrame;
		var spriteData = new FlxSpriteFrames(getKeyForSpriteSheetFrames(0, 0, 0, 0, 0, 0, 0, 0, 0, 0));
		for (sprite in _tex.sprites)
		{
			tileId = addTileRect(sprite.frame, p);
			frame = new FlxFrame(this);
			frame.tileID = tileId;
			spriteData.frames.push(frame);
		}
		
		flxSpriteFrames.set(_tex.assetName, spriteData);
		return spriteData;
	}
	
	public function parseTexturePackerFrames():Void
	{
		
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
}