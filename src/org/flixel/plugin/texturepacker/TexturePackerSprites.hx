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
  public var rotated : Bool;
  public var offset : FlxPoint;

  public function new (s : Dynamic)
  {
    trimmed = s.trimmed;
    rotated = s.rotated;
    source = new Rectangle (0, 0, s.sourceSize.w, s.sourceSize.h);
    offset = new FlxPoint (0, 0);
#if !flash
    // we use negative offset because code in FlxSprite.draw
    // use it in such way
    offset.make (
        -(s.sourceSize.w - s.frame.w) * 0.5,
        -(s.sourceSize.h - s.frame.h) * 0.5);
    if (rotated)
    {
      frame = new Rectangle (s.frame.x, s.frame.y, s.frame.h, s.frame.w);
    }
    else
    {
      frame = new Rectangle (s.frame.x, s.frame.y, s.frame.w, s.frame.h);
    }
#else
    frame = new Rectangle (s.frame.x, s.frame.y, s.frame.w, s.frame.h);
    // we use positive offset because in FlxSpriteTex.new
    // we need to translate a sprite
    offset.make (
        (s.sourceSize.w - s.frame.w) * 0.5,
        (s.sourceSize.h - s.frame.h) * 0.5);
#end
  }
}


