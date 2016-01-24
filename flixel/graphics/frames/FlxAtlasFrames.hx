package flixel.graphics.frames;

import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import haxe.Json;
import haxe.xml.Fast;
import openfl.Assets;

/**
 * Atlas frames collection. It makes possible to use texture atlases in flixel. 
 * Plus it contains few packer parser methods for most commonly used atlas formats.
 */
class FlxAtlasFrames extends FlxFramesCollection
{
	public function new(parent:FlxGraphic, border:FlxPoint = null) 
	{
		super(parent, FlxFrameCollectionType.ATLAS, border);
	}
	
	/**
	 * Parsing method for TexturePacker atlases in json format.
	 * @param	Source			the image source (can be FlxGraphic, String, or BitmapData).
	 * @param	Description		contents of json file with atlas description. You can get it with Assets.getText(path/to/description.json).
	 * 							Or you can just pass path to json file in assets directory.
	 * @return	Newly created AtlasFrames collection
	 */
	public static function fromTexturePackerJson(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new FlxAtlasFrames(graphic);
		
		if (Assets.exists(Description))
		{
			Description = Assets.getText(Description);
		}
		
		var data:Dynamic = Json.parse(Description);
		
		// JSON-Array
		if (Std.is(data.frames, Array))
		{
			for (frame in Lambda.array(data.frames))
			{
				texturePackerHelper(frame.filename, frame, frames);
			}
		}
		
		// JSON-Hash
		else
		{
			for (frameName in Reflect.fields(data.frames))
			{
				texturePackerHelper(frameName, Reflect.field(data.frames, frameName), frames);
			}
		}
		
		return frames;
	}
	
	/**
	 * Internal method for TexturePacker parsing. Parses the actual frame data.
	 * @param	FrameName		Name of the frame (filename of the original source image).
	 * @param	FrameData		The TexturePacker data excluding "filename".
	 * @param	Frames			The FlxAtlasFrames to add this frame to.
	 */
	private static function texturePackerHelper(FrameName:String, FrameData:Dynamic, Frames:FlxAtlasFrames):Void
	{
		var rotated:Bool = FrameData.rotated;
		var name:String = FrameName;
		var sourceSize:FlxPoint = FlxPoint.get(FrameData.sourceSize.w, FrameData.sourceSize.h);
		var offset:FlxPoint = FlxPoint.get(FrameData.spriteSourceSize.x, FrameData.spriteSourceSize.y);
		var angle:FlxFrameAngle = FlxFrameAngle.ANGLE_0;
		var frameRect:FlxRect = null;
		
		if (rotated)
		{
			frameRect = FlxRect.get(FrameData.frame.x, FrameData.frame.y, FrameData.frame.h, FrameData.frame.w);
			angle = FlxFrameAngle.ANGLE_NEG_90;
		}
		else
		{
			frameRect = FlxRect.get(FrameData.frame.x, FrameData.frame.y, FrameData.frame.w, FrameData.frame.h);
		}
		
		Frames.addAtlasFrame(frameRect, sourceSize, offset, name, angle);
	}
	
	/**
	 * Parsing method for LibGDX atlases.
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of the file with atlas description. You can get it with Assets.getText(path/to/description/file).
	 * 							Or you can just pass path to description file in assets directory.
	 * @return	Newly created AtlasFrames collection
	 */
	public static function fromLibGdx(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new FlxAtlasFrames(graphic);
		
		if (Assets.exists(Description))
		{
			Description = Assets.getText(Description);
		}
		
		var pack:String = StringTools.trim(Description);
		var lines:Array<String> = pack.split("\n");
		
		// find the "repeat" option and skip unused data
		var repeatLine:Int = (lines[3].indexOf("repeat:") > -1) ? 3 : 4;
		lines.splice(0, repeatLine + 1);
		
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
		var angle:FlxFrameAngle;
		var rect:FlxRect;
		var sourceSize:FlxPoint;
		var offset:FlxPoint;
		
		for (i in 0...numImages)
		{
			curIndex = i * numElementsPerImage;
			
			name = lines[curIndex++];
			rotated = (lines[curIndex++].indexOf("true") >= 0);
			angle = FlxFrameAngle.ANGLE_0;
			
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
				rect = FlxRect.get(imageX, imageY, imageHeight, imageWidth);
				angle = FlxFrameAngle.ANGLE_90;
			}
			else
			{
				rect = FlxRect.get(imageX, imageY, imageWidth, imageHeight);
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
	 * Parsing method for Sparrow texture atlases (they can be generated with Shoebox http://renderhjs.net/shoebox/ for example).
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of xml file with atlas description. You can get it with Assets.getText(path/to/description.xml)
	 * 							Or you can just pass path to xml file in assets directory.
	 * @return	Newly created AtlasFrames collection.
	 */
	public static function fromSparrow(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new FlxAtlasFrames(graphic);
		
		if (Assets.exists(Description))
		{
			Description = Assets.getText(Description);
		}
		
		var data:Fast = new haxe.xml.Fast(Xml.parse(Description).firstElement());
		
		var angle:Int;
		var flipX:Bool;
		var flipY:Bool;
		var name:String;
		var trimmed:Bool;
		var rotated:Bool;
		var rect:FlxRect;
		var size:Rectangle;
		var offset:FlxPoint;
		var sourceSize:FlxPoint;
		
		for (texture in data.nodes.SubTexture)
		{
			name = texture.att.name;
			trimmed = texture.has.frameX;
			rotated = (texture.has.rotated && texture.att.rotated == "true");
			flipX = (texture.has.flipX && texture.att.flipX == "true");
			flipY = (texture.has.flipY && texture.att.flipY == "true");
			
			rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width), Std.parseFloat(texture.att.height));
			
			size = if (trimmed)
			{
				new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth), Std.parseInt(texture.att.frameHeight));
			}
			else
			{
				new Rectangle(0, 0, rect.width, rect.height);
			}
			
			angle = (rotated) ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
			
			offset = FlxPoint.get(-size.left, -size.top);
			sourceSize = FlxPoint.get(size.width, size.height);
			
			if (rotated && !trimmed)
			{
				sourceSize.set(size.height, size.width);
			}
			
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
		}
		
		return frames;
	}
	
	/**
	 * Parsing method for TexturePacker atlases in generic xml format
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of xml file with atlas description. You can get it with Assets.getText(path/to/description.xml)
	 * 							Or you can just pass path to xml file in assets directory.
	 * @return	Newly created AtlasFrames collection.
	 */
	public static function fromTexturePackerXml(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new FlxAtlasFrames(graphic);
		
		if (Assets.exists(Description))
		{
			Description = Assets.getText(Description);
		}
		
		var xml = Xml.parse(Description);
		var root = xml.firstElement();
		
		var rotated:Bool;
		var trimmed:Bool;
		var angle:FlxFrameAngle;
		var name:String;
		var offset:FlxPoint;
		var rect:FlxRect;
		var sourceSize:FlxPoint;
		
		for (sprite in root.elements())
		{
			trimmed = (sprite.exists("oX") || sprite.exists("oY"));
			rotated = (sprite.exists("r") && sprite.get("r") == "y");
			angle = (rotated) ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
			name = sprite.get("n");
			offset = FlxPoint.get(0, 0);
			rect = FlxRect.get(Std.parseInt(sprite.get("x")), Std.parseInt(sprite.get("y")), Std.parseInt(sprite.get("w")), Std.parseInt(sprite.get("h")));
			sourceSize = FlxPoint.get(rect.width, rect.height);
			
			if (trimmed)
			{
				offset.set(Std.parseInt(sprite.get("oX")), Std.parseInt(sprite.get("oY")));
				sourceSize.set(Std.parseInt(sprite.get("oW")), Std.parseInt(sprite.get("oH")));
			}
			
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}
		
		return frames;
	}
	
	/**
	 * Parsing method for Sprite Sheet Packer atlases (http://spritesheetpacker.codeplex.com/).
	 * 
	 * @param	Source			the image source (can be FlxGraphic, String or BitmapData).
	 * @param	Description		contents of the file with atlas description. You can get it with Assets.getText(path/to/description/file).
	 * 							Or you can just pass path to description file in assets directory.
	 * @return	Newly created AtlasFrames collection
	 */
	public static function fromSpriteSheetPacker(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)	return null;
		
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;
		
		if ((graphic == null) || (Description == null)) return null;
		
		frames = new FlxAtlasFrames(graphic);
		
		if (Assets.exists(Description))
		{
			Description = Assets.getText(Description);
		}
		
		var pack:String = StringTools.trim(Description);
		var lines:Array<String> = pack.split("\n");
		var numImages:Int = lines.length;
		
		var name:String;
		var angle:FlxFrameAngle = FlxFrameAngle.ANGLE_0;
		var rect:FlxRect;
		var sourceSize:FlxPoint;
		var offset:FlxPoint;
		
		var currImageData:Array<String>;
		var currImageRegion:Array<String>;
		
		for (i in 0...numImages)
		{
			currImageData = lines[i].split("=");
			name = StringTools.trim(currImageData[0]);
			currImageRegion = StringTools.trim(currImageData[1]).split(" ");
			
			rect = FlxRect.get(Std.parseInt(currImageRegion[0]), Std.parseInt(currImageRegion[1]), Std.parseInt(currImageRegion[2]), Std.parseInt(currImageRegion[3]));
			sourceSize = FlxPoint.get(rect.width, rect.height);
			offset = FlxPoint.get();
			
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
	public static function findFrame(graphic:FlxGraphic, border:FlxPoint = null):FlxAtlasFrames
	{
		if (border == null)
			border = FlxPoint.weak();
		
		var atlasFrames:Array<FlxAtlasFrames> = cast graphic.getFramesCollections(FlxFrameCollectionType.ATLAS);
		var atlas:FlxAtlasFrames;
		
		for (atlas in atlasFrames)
		{
			if (atlas.border.equals(border))
			{
				return atlas;
			}
		}
		
		return null;
	}
	
	override public function addBorder(border:FlxPoint):FlxAtlasFrames
	{
		var resultBorder:FlxPoint = FlxPoint.weak().addPoint(this.border).addPoint(border);
		var atlasFrames:FlxAtlasFrames = FlxAtlasFrames.findFrame(parent, resultBorder);
		if (atlasFrames != null)
		{
			return atlasFrames;
		}
		
		atlasFrames = new FlxAtlasFrames(parent, resultBorder);
		
		for (frame in frames)
		{
			atlasFrames.pushFrame(frame.setBorderTo(border));
		}
		
		return atlasFrames;
	}
}
