package org.flixel.plugin.texturepacker;

import org.flixel.system.layer.TileSheetData;

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import nme.display.Tilesheet;

class TexturePackerTileSheetData extends TileSheetData
{
	public static function addTileSheet(bitmapData:BitmapData, tex:TexturePackerFrames):TileSheetData
	{
		var tempTileSheetData:TileSheetData;
		
		if (TileSheetData.containsTileSheet(bitmapData))
		{
			tempTileSheetData = TileSheetData.getTileSheet(bitmapData);
			return TileSheetData.getTileSheet(bitmapData);
		}
		
		tempTileSheetData = new TexturePackerTileSheetData(new Tilesheet(bitmapData), tex);
		TileSheetData.tileSheetData.push(tempTileSheetData);
		return tempTileSheetData;
	}

	private var _tex:TexturePackerFrames;
	
	public function new(tileSheet:Tilesheet, tex:TexturePackerFrames)
	{
		_tex = tex;
		super (tileSheet);
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
			frame = new FlxFrame();
			frame.tileID = tileId;
			spriteData.frames.push(frame);
		}
		
		flxSpriteFrames.set(_tex.assetName, spriteData);
		return spriteData;
	}
}