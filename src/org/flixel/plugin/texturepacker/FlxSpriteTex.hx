package org.flixel.plugin.texturepacker;

import org.flixel.FlxSprite;
import org.flixel.plugin.texturepacker.TexturePackerSprites;

#if !flash
import org.flixel.plugin.texturepacker.TexturePackerAtlas;
import org.flixel.system.layer.Atlas;
#end

class FlxSpriteTex extends FlxSprite
{
  var _tex : TexturePackerSprites;
  var _spriteId : Int;

  public function new (x, y, spriteName : String, tex)
  {
    _tex = tex;
#if !flash
    var idx = spriteName.lastIndexOf ("/");
    if (idx >= 0)
    {
      spriteName = spriteName.substring (idx + 1, spriteName.length);
    }
    _spriteId = tex.frames.get (spriteName);
    trace ([_spriteId, spriteName]);

    super (x, y, tex.assetName);
    origin = new FlxPoint (0, 0);
#else
    super (x, y, spriteName);
#end
  }

#if !flash
  override public function getAtlas () : Atlas
  {
    var bm = FlxG._cache.get (_bitmapDataKey);
    return TexturePackerAtlas.getAtlas (_bitmapDataKey, bm, _tex);
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

