package flixel.util.loaders;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPoint;
import haxe.Json;
import openfl.Assets;

class TexturePackerData implements IFlxDestroyable
{
	public var frames:Array<TextureAtlasFrame>;

	public var assetName:String;
	public var description:String;
	public var asset:BitmapData;
	
	/**
	 * Constructor
	 * 
	 * @param	Description		Name of the data file with atlas description
	 * @param	AssetName		Name of the atlas image file
	 */
	public function new(Description:String, AssetName:String)
	{
		assetName = AssetName;
		description = Description;
		
		frames = new Array<TextureAtlasFrame>();
		
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
		
		if ((assetName == null) || (description == null)) return;
		
		asset = FlxG.bitmap.add(assetName).bitmap;
		var data:Dynamic = Json.parse(Assets.getText(description));
		
		for (frame in Lambda.array(data.frames))
		{
			var texFrame:TextureAtlasFrame = new TextureAtlasFrame();
			texFrame.trimmed = frame.trimmed;
			texFrame.rotated = frame.rotated;
			texFrame.name = frame.filename;
			
			texFrame.sourceSize = FlxPoint.get(frame.sourceSize.w, frame.sourceSize.h);
			texFrame.offset = FlxPoint.get(0, 0);
			texFrame.offset.set(frame.spriteSourceSize.x, frame.spriteSourceSize.y);
			
			if (frame.rotated)
			{
				texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.h, frame.frame.w);
				texFrame.additionalAngle = -90;
			}
			else
			{
				texFrame.frame = new Rectangle(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
				texFrame.additionalAngle = 0;
			}
			
			frames.push(texFrame);
		}
	}
	
	/**
	 * Memory cleaning method
	 */
	public function destroy():Void
	{
		frames = FlxDestroyUtil.destroyArray(frames);
		assetName = null;
		description = null;
		asset = null;
	}
}
