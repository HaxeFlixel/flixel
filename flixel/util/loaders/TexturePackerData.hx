package flixel.util.loaders;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.display.BitmapData;
import haxe.Json;
import flixel.util.FlxPoint;
import flixel.system.layer.Atlas;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.frames.FlxSpriteFrames;
import flixel.system.layer.TileSheetData;

class TexturePackerData
{
	public var frames:Array<Frame>;

	public var assetName:String;
	public var description:String;
	public var asset:BitmapData;
	
	/**
	 * Constructor
	 * 
	 * @param	description		name of data file with atlas description
	 * @param	assetName		name of atlas image file
	 */
	public function new(description:String, assetName:String)
	{
		this.assetName = assetName;
		this.description = description;
		
		this.frames = new Array<Frame>();
		
		parseData();
	}
	
	/**
	 * Data parsing method.
	 * Override it in subclasses if you want to implement support for new atlas formats
	 */
	public function parseData():Void
	{
		// No need to parse data again
		if (frames.length != 0)	return;
		
		this.asset = Assets.getBitmapData(this.assetName);
		var data:Dynamic = Json.parse(Assets.getText(description));
		
		for (frame in Lambda.array(data.frames))
		{
			var texFrame:Frame = new Frame();
			texFrame.trimmed = frame.trimmed;
			texFrame.rotated = frame.rotated;
			texFrame.name = frame.filename;
			
			texFrame.sourceSize = new FlxPoint(frame.sourceSize.w, frame.sourceSize.h);
			texFrame.offset = new FlxPoint(0, 0);
			texFrame.offset.make(frame.spriteSourceSize.x, frame.spriteSourceSize.y);
			
			if (frame.rotated)
			{
				texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.h, frame.frame.w);
			}
			else
			{
				texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
			}
			
			frames.push(texFrame);
		}
	}
	
	/**
	 * Memory cleaning method
	 */
	public function destroy():Void
	{
		var l:Int = frames.length;
		for (i in 0...l)
		{
			frames[i].destroy();
		}
		frames = null;
		assetName = null;
		asset = null;
	}
}