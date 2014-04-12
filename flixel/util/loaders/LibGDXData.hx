package flixel.util.loaders;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.interfaces.IFlxDestroyable;
import flixel.util.FlxPoint;
import haxe.Json;
import openfl.Assets;

class LibGDXData extends TexturePackerData
{
	/**
	 * Constructor
	 * 
	 * @param	Description		Name of the data file with atlas description
	 * @param	AssetName		Name of the atlas image file
	 */
	public function new(Description:String, AssetName:String)
	{
		super(Description, AssetName);
	}
	
	/**
	 * Data parsing method.
	 * Override it in subclasses if you want to implement support for new atlas formats
	 */
	override public function parseData():Void
	{
		// No need to parse data again
		if (frames.length != 0)	return;
		
		if ((assetName == null) || (description == null)) return;
		
		asset = FlxG.bitmap.add(assetName).bitmap;
		
		var pack:String = Assets.getText(description);
		pack = StringTools.trim(pack);
		var lines:Array<String> = pack.split("\n");
		lines.splice(0, 4);
		var numElementsPerImage:Int = 7;
		var numImages:Int = Std.int(lines.length / numElementsPerImage);
		
		var curIndex:Int;
		var imageX:Int;
		var imageY:Int;
		
		var imageWidth:Int;
		var imageHeight:Int;
		
		var size:Array<Int> = [];
		var tempString:String;
		
		for (i in 0...numImages)
		{
			curIndex = i * numElementsPerImage;
			
			var texFrame:TextureAtlasFrame = new TextureAtlasFrame();
			texFrame.name = lines[curIndex++];
			texFrame.rotated = (lines[curIndex++].indexOf("true") >= 0);
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			imageX = size[0];
			imageY = size[1];
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			imageWidth = size[0];
			imageHeight = size[1];
			
			if (texFrame.rotated)
			{
				texFrame.frame = new Rectangle(imageX, imageY, imageHeight, imageWidth);
				texFrame.additionalAngle = 90;
			}
			else
			{
				texFrame.frame = new Rectangle(imageX, imageY, imageWidth, imageHeight);
				texFrame.additionalAngle = 0;
			}
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			texFrame.sourceSize = FlxPoint.get(size[0], size[1]);
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			texFrame.offset = FlxPoint.get(size[0], size[1]);
			
			texFrame.trimmed = ((texFrame.frame.width != texFrame.sourceSize.x) || (texFrame.frame.height != texFrame.sourceSize.y));
			
			frames.push(texFrame);
		}
	}
	
	private function getDimensions(line:String, size:Array<Int>):Array<Int>
	{
		var colonPosition:Int = line.indexOf(":");
		var comaPosition:Int = line.indexOf(",");
		
		size[0] = Std.parseInt(line.substring(colonPosition + 1, comaPosition));
		size[1] = Std.parseInt(line.substring(comaPosition + 1, line.length));
		
		return size;
	}
}