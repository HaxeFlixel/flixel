package org.flixel.plugin.texturepacker;

import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.TileSheetData;
import nme.display.BitmapData;

class TexturePackerAtlas extends Atlas
{
  public static function getAtlas (key:String, bmData:BitmapData,
      tex : TexturePackerSprites,
      unique:Bool = false) : Atlas
  {
    var alreadyExist : Bool = Atlas.isExists (key);
    if (!unique && alreadyExist)
    {
      return Atlas.getAtlas (key, bmData, unique);
    }

    var atlasKey : String = key;
    if (unique && alreadyExist)
    {
      atlasKey = Atlas.getUniqueKey (key);
    }

    var atlas : Atlas = new TexturePackerAtlas (atlasKey,
        bmData.width, bmData.height,
        1, 1,
        bmData,
        tex);
    return atlas;
  }


  private var _tex : TexturePackerSprites;
  public function new(name:String,
      width:Int, height:Int, borderX:Int = 1, borderY:Int = 1,
      bitmapData = null,
      tex : TexturePackerSprites = null)
  {
    _tex = tex;
    super (name, width, height, borderX, borderY, bitmapData);
  }

  override public function createTileSheetData (bitmapData : BitmapData) : TileSheetData
  {
    return TexturePackerTileSheetData.addTileSheet (bitmapData, _tex);
  }

}

