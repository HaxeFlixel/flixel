package org.flixel.plugin.texturepacker;

import org.flixel.system.layer.TileSheetData;

import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BitmapData;
import nme.display.Tilesheet;

class TexturePackerTileSheetData extends TileSheetData
{
  public static function addTileSheet(bitmapData:BitmapData,
      tex : TexturePackerSprites) : TileSheetData
  {
    var tempTileSheetData:TileSheetData;

    if (TileSheetData.containsTileSheet(bitmapData))
    {
      tempTileSheetData = TileSheetData.getTileSheet(bitmapData);
      return TileSheetData.getTileSheet(bitmapData);
    }

    tempTileSheetData = new TexturePackerTileSheetData (
        new Tilesheet(bitmapData),
        tex);
    TileSheetData.tileSheetData.push(tempTileSheetData);
    return tempTileSheetData;
  }

  private var _tex : TexturePackerSprites;
  public function new (tileSheet : Tilesheet, tex : TexturePackerSprites)
  {
    _tex = tex;
    super (tileSheet);
  }

  override public function addSpriteFramesData(width:Int, height:Int,
      origin:Point = null,
      startX:Int = 0, startY:Int = 0,
      endX:Int = 0, endY:Int = 0,
      xSpacing:Int = 0, ySpacing:Int = 0):FlxSpriteFrames
  {
    var p = new Point (0.5 * width, 0.5 * height);
    var tileId : Int = 0;
    var spriteData = new FlxSpriteFrames (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    for (sprite in _tex.sprites)
    {
      tileId = addTileRect (sprite.frame, p);
      spriteData.frameIDs.push (tileId);
    }

    spriteData.halfFrameNumber = Std.int (spriteData.frameIDs.length / 2);
    flxSpriteFrames.push (spriteData);
    return spriteData;
  }
}

