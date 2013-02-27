package org.flixel.plugin.texturepacker;

import org.flixel.FlxSprite;
import org.flixel.plugin.texturepacker.TexturePackerSprites;

#if !flash
import org.flixel.plugin.texturepacker.TexturePackerAtlas;
import org.flixel.system.layer.Atlas;
#end

import nme.geom.Point;
import nme.display.BitmapData;

class FlxSpriteTex extends FlxSprite
{
  var _tex : TexturePackerSprites;
  var _spriteId : Int;

  public function new (x, y, spriteName : String, tex)
  {
    _tex = tex;
    _spriteId = tex.frames.get (spriteName);
#if !flash
    super (x, y, tex.assetName);
    origin = new FlxPoint (0, 0);
    width = tex.sprites[_spriteId].frame.width;
    height = tex.sprites[_spriteId].frame.height;
#else
    var spriteInfo = _tex.sprites[_spriteId];
    var bm : BitmapData = new BitmapData (Std.int (spriteInfo.frame.width),
        Std.int (spriteInfo.frame.height));
    bm.copyPixels (_tex.asset, spriteInfo.frame, new Point (0, 0));
    super (x, y, bm);
#end
  }

#if !flash
  override public function getAtlas () : Atlas
  {
    var bm : BitmapData = FlxG._cache.get (_bitmapDataKey);
    if (bm != null)
    {
      return TexturePackerAtlas.getAtlas (_bitmapDataKey, bm, _tex);
    }
    else
    {
#if !FLX_NO_DEBUG
      throw "There isn't bitmapdata in cache with key: " + _bitmapDataKey;
#end
    }

    return null;
  }
#end

  override public function updateFrameData () : Void
  {
#if !flash
    _framesData = _node.addSpriteFramesData (50, 50);
    _frameID = _framesData.frameIDs[_spriteId];
#else
    super.updateFrameData ();
#end
  }
}

