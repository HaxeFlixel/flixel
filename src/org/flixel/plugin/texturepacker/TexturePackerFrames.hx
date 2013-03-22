package org.flixel.plugin.texturepacker;

import nme.Assets;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.display.BitmapData;
import haxe.Json;
import org.flixel.system.layer.Atlas;

class TexturePackerFrames
{
	public var frames:Hash<Int>;
	public var sprites:Array<TexturePackerFrame>;

	public var data:Dynamic;
	public var assetName:String;
	public var asset:BitmapData;
	
	public var atlas:Atlas;

	public function new(description:String, assetName:String)
	{
		this.frames = new Hash<Int>();
		this.sprites = new Array<TexturePackerFrame>();
		
		this.assetName = assetName;
		this.asset = Assets.getBitmapData(this.assetName);
		this.data = Json.parse(Assets.getText(description));
		
		for (frame in Lambda.array(data.frames))
		{
			this.sprites.push(new TexturePackerFrame(frame));
			this.frames.set(frame.filename, this.sprites.length - 1);
		}
		
		// TODO: create atlas and add all frames
		atlas = Atlas.getAtlas(assetName, this.asset);
		
	}
	
	public function destroy():Void
	{
		// TODO: implement it
	}
}

class TexturePackerFrame
{
	public var frame:Rectangle;
	public var source:Rectangle;
	public var trimmed:Bool;
	public var rotated:Bool;
	public var offset:FlxPoint;
	public var filename:String;

	public function new(s:Dynamic)
	{
		trimmed = s.trimmed;
		rotated = s.rotated;
		filename = s.filename;
		source = new Rectangle(0, 0, s.sourceSize.w, s.sourceSize.h);
		offset = new FlxPoint(0, 0);
#if !flash
		// we use negative offset because code in FlxSprite.draw
		// use it in such way
		offset.make(-s.spriteSourceSize.x, -s.spriteSourceSize.y);
		if (rotated)
		{
			frame = new Rectangle(s.frame.x, s.frame.y, s.frame.h, s.frame.w);
		}
		else
		{
			frame = new Rectangle(s.frame.x, s.frame.y, s.frame.w, s.frame.h);
		}
#else
		frame = new Rectangle(s.frame.x, s.frame.y, s.frame.w, s.frame.h);
		// we use positive offset because in FlxSpriteTex.new
		// we need to translate a sprite
		offset.make(s.spriteSourceSize.x, s.spriteSourceSize.y);
#end
	}
	
	public function destroy():Void
	{
		// TODO: implement it
	}
}