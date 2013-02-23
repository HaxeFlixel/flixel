package org.flixel.plugin.texturepacker;

import nme.Assets;
import nme.geom.Rectangle;
import haxe.Json;

class TexturePackerSprites
{
  public var frames : Hash <Int>;
  public var sprites : Array <TexturePackerSprite>;

  public var data : Dynamic;
  public var assetName : String;

  public function new (description : String, asset : String)
  {
    frames = new Hash ();
    sprites = new Array ();

    assetName = asset;
    data = Json.parse (Assets.getText (description));

    for (frame in Lambda.array (data.frames))
    {
      sprites.push (new TexturePackerSprite (frame));
      frames.set (frame.filename, sprites.length - 1);
    }
  }
}

class TexturePackerSprite
{
  public var frame : Rectangle;
  public var source : Rectangle;

  public function new (s : Dynamic)
  {
    frame = new Rectangle (s.frame.x, s.frame.y, s.frame.w, s.frame.h);
    source = new Rectangle (s.spriteSourceSize.x, s.spriteSourceSize.y,
        s.spriteSourceSize.w, s.spriteSourceSize.h);
  }
}


