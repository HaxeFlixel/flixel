package org.flixel.plugin.texturepacker;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.display.BitmapData;
import haxe.Json;
import org.flixel.util.FlxPoint;
import org.flixel.system.layer.Atlas;
import org.flixel.system.layer.frames.FlxFrame;
import org.flixel.system.layer.frames.FlxSpriteFrames;
import org.flixel.system.layer.TileSheetData;

class TexturePackerData
{
	public var frames:Map<String, Int>;
	public var sprites:Array<FlxFrame>;

	public var data:Dynamic;
	public var assetName:String;
	public var asset:BitmapData;

	public function new(description:String, assetName:String)
	{
		this.frames = new Map<String, Int>();
		this.sprites = new Array<FlxFrame>();
		
		this.assetName = assetName;
		this.asset = Assets.getBitmapData(this.assetName);
		this.data = Json.parse(Assets.getText(description));
		
		/*for (frame in Lambda.array(data.frames))
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
		}*/
		
	}
	
	public function destroy():Void
	{
		// TODO: implement it
	}
}