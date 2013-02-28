package org.flixel.plugin.texturepacker;

import nme.Assets;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.display.BitmapData;
import haxe.Json;

class TexturePackerSprites
{
  public var frames : Hash <Int>;
  public var sprites : Array <TexturePackerSprite>;

  public var data : Dynamic;
  public var assetName : String;
  public var asset : BitmapData;

  public function new (description : String, assetName : String)
  {
    this.frames = new Hash ();
    this.sprites = new Array ();

    this.assetName = assetName;
    this.asset = Assets.getBitmapData (this.assetName);
    this.data = Json.parse (Assets.getText (description));

    for (frame in Lambda.array (data.frames))
    {
      this.sprites.push (new TexturePackerSprite (frame));
      this.frames.set (frame.filename, this.sprites.length - 1);
    }
  }
}

class TexturePackerSprite
{
  public var frame : Rectangle;
  public var source : Rectangle;
  public var trimmed : Bool;

  public function new (s : Dynamic)
  {
    frame = new Rectangle (s.frame.x, s.frame.y, s.frame.w, s.frame.h);
    source = new Rectangle (0, 0,
        s.sourceSize.w, s.sourceSize.h);
    trimmed = s.trimmed;
  }
}


