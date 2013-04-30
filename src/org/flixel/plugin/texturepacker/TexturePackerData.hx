package org.flixel.plugin.texturepacker;

import nme.Assets;
import nme.geom.Rectangle;
import nme.geom.Point;
import nme.display.BitmapData;
import haxe.Json;
import org.flixel.FlxPoint;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.frames.FlxFrame;
import org.flixel.system.layer.frames.TexturePackerFrame;
import org.flixel.system.layer.TileSheetData;

class TexturePackerData
{
	public var frames:Hash<Int>;
	public var sprites:Array<TexturePackerFrame>;

	public var data:Dynamic;
	public var assetName:String;
	public var asset:BitmapData;
	
	public var atlas:TexturePackerAtlas;

	public function new(description:String, assetName:String)
	{
		this.frames = new Hash<Int>();
		this.sprites = new Array<TexturePackerFrame>();
		
		this.assetName = assetName;
		this.asset = Assets.getBitmapData(this.assetName);
		this.data = Json.parse(Assets.getText(description));
		
		// TODO: create atlas and add all frames
		atlas = cast(TexturePackerAtlas.getAtlas(assetName, this.asset, this), TexturePackerAtlas);
		var tsd:TexturePackerTileSheetData = cast(atlas._tileSheetData, TexturePackerTileSheetData);
		
		for (frame in Lambda.array(data.frames))
		{
			var texFrame:TexturePackerFrame = new TexturePackerFrame(tsd);
			texFrame.trimmed = frame.trimmed;
			texFrame.rotated = frame.rotated;
			texFrame.name = frame.filename;
			texFrame.sourceSize = new FlxPoint(frame.sourceSize.w, frame.sourceSize.h);
			texFrame.offset = new FlxPoint(0, 0);
		#if !flash
			// we use negative offset because code in FlxSprite.draw
			// use it in such way
			texFrame.offset.make(-frame.spriteSourceSize.x, -frame.spriteSourceSize.y);
			if (frame.rotated)
			{
				texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.h, frame.frame.w);
			}
			else
			{
				texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
			}
		#else
			texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
			// we use positive offset because in FlxSpriteTex.new
			// we need to translate a sprite
			texFrame.offset.make(frame.spriteSourceSize.x, frame.spriteSourceSize.y);
		#end
		
			this.sprites.push(texFrame);
			this.frames.set(texFrame.name, this.sprites.length - 1);
		}
		
	}
	
	public function getFrameBitmapData(frameName:String):BitmapData
	{
		// TODO: implement it
		return null;
	}
	
	public function getAnimationBitmapData(animationPrefix:String):BitmapData
	{
		// TODO: implement it
		return null;
	}
	
	public function destroy():Void
	{
		// TODO: implement it
	}
}
/*
class TexturePackerFrame
{
	// TODO: move this to FlxFrame
	public var frame:Rectangle;
	public var source:Rectangle;
	public var trimmed:Bool;
	public var rotated:Bool;
	public var offset:FlxPoint;
	public var filename:String;
	// End of TODO
	
	public var flxFrame:FlxFrame;
	#if flash
	public var bitmapData:BitmapData;
	#end

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
*/