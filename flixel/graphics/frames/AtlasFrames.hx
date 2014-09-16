package flixel.graphics.frames;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.xml.Fast;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FrameCollectionType;
import flixel.system.layer.TileSheetExt;
import flixel.graphics.FlxGraphic;
import haxe.Json;

/**
 * Atlas frames collection. It makes possible to use texture atlases in flixel. 
 * Plus it contains few packer parser methods for most commonly used atlas formats.
 */
class AtlasFrames extends FlxFramesCollection
{
	public function new(parent:FlxGraphic) 
	{
		super(parent, FrameCollectionType.ATLAS);
		parent.atlasFrames = this;
	}
	
	/**
	 * Parsing method for TexturePacker atlases in json format.
	 * @param	Source			the image source (can be FlxGraphic, String, or BitmapData).
	 * @param	Description		contents of json file with atlas description. You can get it with Assets.getText(path/to/description.json).
	 * @return	Newly created AtlasFrames collection
	 */
	public static function texturePackerJSON(Source:FlxGraphicAsset, Description:String):AtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:AtlasFrames = AtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new AtlasFrames(graphic);
		var data:Dynamic = Json.parse(Description);
		
		var rotated:Bool;
		var name:String;
		var sourceSize:FlxPoint;
		var offset:FlxPoint;
		var angle:Float;
		var frameRect:FlxRect;
		
		for (frame in Lambda.array(data.frames))
		{
			rotated = frame.rotated;
			name = frame.filename;
			sourceSize = FlxPoint.get(frame.sourceSize.w, frame.sourceSize.h);
			offset = FlxPoint.get(frame.spriteSourceSize.x, frame.spriteSourceSize.y);
			angle = 0;
			frameRect = null;
			
			if (rotated)
			{
				frameRect = new FlxRect(frame.frame.x, frame.frame.y, frame.frame.h, frame.frame.w);
				angle = -90;
			}
			else
			{
				frameRect = new FlxRect(frame.frame.x, frame.frame.y, frame.frame.w, frame.frame.h);
			}
			
			frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
		}
		
		return frames;
	}
	
	/**
	 * Parsing method for LibGDX atlases.
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of the file with atlas description. You can get it with Assets.getText(path/to/description/file)
	 * @return	Newly created AtlasFrames collection
	 */
	public static function libGDX(Source:FlxGraphicAsset, Description:String):AtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:AtlasFrames = AtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new AtlasFrames(graphic);
		
		var pack:String = StringTools.trim(Description);
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
		
		var name:String;
		var rotated:Bool;
		var angle:Float;
		var rect:FlxRect;
		var sourceSize:FlxPoint;
		var offset:FlxPoint;
		
		for (i in 0...numImages)
		{
			curIndex = i * numElementsPerImage;
			
			name = lines[curIndex++];
			rotated = (lines[curIndex++].indexOf("true") >= 0);
			angle = 0;
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			imageX = size[0];
			imageY = size[1];
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			imageWidth = size[0];
			imageHeight = size[1];
			
			rect = null;
			if (rotated)
			{
				rect = new FlxRect(imageX, imageY, imageHeight, imageWidth);
				angle = 90;
			}
			else
			{
				rect = new FlxRect(imageX, imageY, imageWidth, imageHeight);
			}
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			sourceSize = FlxPoint.get(size[0], size[1]);
			
			tempString = lines[curIndex++];
			size = getDimensions(tempString, size);
			
			offset = FlxPoint.get(size[0], size[1]);
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}
		
		return frames;
	}
	
	/**
	 * Internal method for LibGDX atlas parsing. It tries to extract dimensions info from specified string.
	 * 
	 * @param	line	String to extract info from.
	 * @param	size	Array to store extracted info to.
	 * @return	Array filled with dimensions info.
	 */
	private static function getDimensions(line:String, size:Array<Int>):Array<Int>
	{
		var colonPosition:Int = line.indexOf(":");
		var comaPosition:Int = line.indexOf(",");
		
		size[0] = Std.parseInt(line.substring(colonPosition + 1, comaPosition));
		size[1] = Std.parseInt(line.substring(comaPosition + 1, line.length));
		
		return size;
	}
	
	/**
	 * Parsing method for Sparrow texture atlases.
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of xml file with atlas description. You can get it with Assets.getText(path/to/description.xml)
	 * @return	Newly created AtlasFrames collection.
	 */
	public static function sparrow(Source:FlxGraphicAsset, Description:String):AtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:AtlasFrames = AtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new AtlasFrames(graphic);
		
		var data:Fast = new haxe.xml.Fast(Xml.parse(Description).firstElement());
		
		var angle:Float;
		var name:String;
		var trimmed:Bool;
		var rect:FlxRect;
		var size:Rectangle;
		var offset:FlxPoint;
		var sourceSize:FlxPoint;
		
		for (texture in data.nodes.SubTexture)
		{
			angle = 0;
			name = texture.att.name;
			trimmed = texture.has.frameX;
			
			rect = new FlxRect(
				Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y),
				Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));
			
			size = if (trimmed)
					new Rectangle(
						Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY),
						Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));
				else 
					new Rectangle(0, 0, rect.width, rect.height);
					
			offset = FlxPoint.get(-size.left, -size.top);
			sourceSize = FlxPoint.get(size.width, size.height);
			
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}
		
		return frames;
	}
	
	/**
	 * Parsing method for TexturePacker atlases in xml format
	 * (trimmed images aren't supported yet for this type of atlas).
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of xml file with atlas description. You can get it with Assets.getText(path/to/description.xml)
	 * @return	Newly created AtlasFrames collection.
	 */
	public static function texturePackerXML(Source:FlxGraphicAsset, Description:String):AtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:AtlasFrames = AtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new AtlasFrames(graphic);
		
		var xml = Xml.parse(Description);
		var root = xml.firstElement();
		
		var rotated:Bool;
		var angle:Float;
		var name:String;
		var offset:FlxPoint;
		var rect:FlxRect;
		var sourceSize:FlxPoint;
		
		for (sprite in root.elements())
		{
			// trimmed images aren't supported yet for this type of atlas
			rotated = (sprite.exists("r") && sprite.get("r") == "y");
			angle = (rotated) ? -90 : 0;
			name = sprite.get("n");
			offset = FlxPoint.get(0, 0);
			
			rect = new FlxRect(	
									Std.parseInt(sprite.get("x")),
									Std.parseInt(sprite.get("y")),
									Std.parseInt(sprite.get("w")),
									Std.parseInt(sprite.get("h"))
								);
			
			sourceSize = FlxPoint.get(rect.width, rect.height);
			
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}
		
		return frames;
	}
	
	/**
	 * Return AtlasFrame of the specified FlxGraphic object.
	 * 
	 * @param	graphic	FlxGraphic object to find AtlasFrames collection for.
	 * @return	AtlasFrames Collection for specified FlxGraphic object. Could be null, if FlxGraphic doesn't have it yet.
	 */
	public static inline function findFrame(graphic:FlxGraphic):AtlasFrames
	{
		return graphic.atlasFrames;
	}
}