package flixel.graphics.frames;

import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames.TexturePackerObject;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTexturePackerSource;
import openfl.Assets;
import haxe.Json;
import haxe.xml.Access;

/**
 * Atlas frames collection. It makes possible to use texture atlases in Flixel.
 * Plus it contains few packer parser methods for most commonly used atlas formats.
 */
class FlxAtlasFrames extends FlxFramesCollection
{
	public function new(parent:FlxGraphic, ?border:FlxPoint)
	{
		super(parent, FlxFrameCollectionType.ATLAS, border);
	}

	/**
	 * Parsing method for TexturePacker atlases in JSON format.
	 *
	 * @param   Source        The image source (can be `FlxGraphic`, `String`, or `BitmapData`).
	 * @param   Description   Contents of JSON file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description.json)`.
	 *                        Or you can just a pass path to the JSON file in the assets directory.
	 *                        You can also directly pass in the parsed object.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromTexturePackerJson(Source:FlxGraphicAsset, Description:FlxTexturePackerSource):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		var data:TexturePackerObject;

		if ((Description is String))
		{
			var json:String = Description;

			if (Assets.exists(json))
				json = Assets.getText(json);

			data = Json.parse(json);
		}
		else
		{
			data = Description;
		}

		// JSON-Array
		if ((data.frames is Array))
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
	 *
	 * @param   FrameName   Name of the frame (file name of the original source image).
	 * @param   FrameData   The TexturePacker data excluding "filename".
	 * @param   Frames      The `FlxAtlasFrames` to add this frame to.
	 */
	static function texturePackerHelper(FrameName:String, FrameData:Dynamic, Frames:FlxAtlasFrames):Void
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
	 * @param   source        The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param   description   Contents of the file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description/file)`.
	 *                        Or you can just pass path to the description file in the assets directory.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromLibGdx(source:FlxGraphicAsset, description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if ((graphic == null) || (description == null))
			return null;

		frames = new FlxAtlasFrames(graphic);

		if (Assets.exists(description))
			description = Assets.getText(description);

		var pack:String = StringTools.trim(description);
		var lines:Array<String> = pack.split("\n");

		// find the "repeat" option and skip unused data
		var repeatLine:Int = (lines[3].indexOf("repeat:") > -1) ? 3 : 4;
		lines.splice(0, repeatLine + 1);

		var numElementsPerImage:Int = 7;
		var numImages:Int = Std.int(lines.length / numElementsPerImage);

		for (i in 0...numImages)
		{
			var curIndex = i * numElementsPerImage;

			var name = lines[curIndex++];
			var rotated = (lines[curIndex++].indexOf("true") >= 0);
			var angle = rotated ? FlxFrameAngle.ANGLE_90 : FlxFrameAngle.ANGLE_0;

			var tempString = lines[curIndex++];
			var size = getDimensions(tempString);

			var imageX = size.x;
			var imageY = size.y;

			tempString = lines[curIndex++];
			size = getDimensions(tempString);

			var imageWidth = size.x;
			var imageHeight = size.y;

			var rect = FlxRect.get(imageX, imageY, imageWidth, imageHeight);

			tempString = lines[curIndex++];
			size = getDimensions(tempString);

			var sourceSize = FlxPoint.get(size.x, size.y);

			tempString = lines[curIndex++];
			size = getDimensions(tempString);

			tempString = lines[curIndex++];
			var index = Std.parseInt(tempString.split(':')[1]);

			if (index != -1)
				name += '_$index';

			// this should be how it is, but libgdx's texture packer tool
			// currently outputs the offset from the bottom left, instead:
			// var offset = FlxPoint.get(size.x, size.y);
			// workaround for https://github.com/libgdx/libgdx/issues/4288
			var offset = FlxPoint.get(size.x, sourceSize.y - size.y - imageHeight);
			frames.addAtlasFrame(rect, sourceSize, offset, name, angle);
		}

		return frames;
	}

	/**
	 * Internal method for LibGDX atlas parsing. It tries to extract dimensions info from the specified string.
	 */
	static function getDimensions(line:String):{x:Int, y:Int}
	{
		var colonPosition:Int = line.indexOf(":");
		var comaPosition:Int = line.indexOf(",");

		return {
			x: Std.parseInt(line.substring(colonPosition + 1, comaPosition)),
			y: Std.parseInt(line.substring(comaPosition + 1, line.length))
		};
	}

	/**
	 * Parsing method for Sparrow texture atlases
	 * (they can be generated with Shoebox http://renderhjs.net/shoebox/ for example).
	 *
	 * @param   Source        The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param   Description   Contents of the XML file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description.xml)`.
	 *                        Or you can just pass a path to the XML file in the assets directory.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromSparrow(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		var data:Access = new Access(Xml.parse(Description).firstElement());

		for (texture in data.nodes.SubTexture)
		{
			var name = texture.att.name;
			var trimmed = texture.has.frameX;
			var rotated = (texture.has.rotated && texture.att.rotated == "true");
			var flipX = (texture.has.flipX && texture.att.flipX == "true");
			var flipY = (texture.has.flipY && texture.att.flipY == "true");

			var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width),
				Std.parseFloat(texture.att.height));

			var size = if (trimmed)
			{
				new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth),
					Std.parseInt(texture.att.frameHeight));
			}
			else
			{
				new Rectangle(0, 0, rect.width, rect.height);
			}

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var sourceSize = FlxPoint.get(size.width, size.height);

			if (rotated && !trimmed)
				sourceSize.set(size.height, size.width);

			frames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
		}

		return frames;
	}

	/**
	 * Parsing method for TexturePacker atlases in generic XML format.
	 *
	 * @param   Source        The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param   Description   Contents of the XML file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description.xml)`.
	 *                        Or you can just pass a path to the XML file in the assets directory.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromTexturePackerXml(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		var xml = Xml.parse(Description);

		for (sprite in xml.firstElement().elements())
		{
			var trimmed = (sprite.exists("oX") || sprite.exists("oY"));
			var rotated = (sprite.exists("r") && sprite.get("r") == "y");
			var angle = (rotated) ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;
			var name = sprite.get("n");
			var offset = FlxPoint.get(0, 0);
			var rect = FlxRect.get(Std.parseInt(sprite.get("x")), Std.parseInt(sprite.get("y")), Std.parseInt(sprite.get("w")), Std.parseInt(sprite.get("h")));
			var sourceSize = FlxPoint.get(rect.width, rect.height);

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
	 * @param   Source        The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param   Description   Contents of the file with atlas description.
	 *                        You can get it with `Assets.getText(path/to/description/file)`.
	 *                        Or you can just pass a path to the description file in the assets directory.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromSpriteSheetPacker(Source:FlxGraphicAsset, Description:String):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(Source);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || Description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		if (Assets.exists(Description))
			Description = Assets.getText(Description);

		var pack = StringTools.trim(Description);
		var lines:Array<String> = pack.split("\n");

		for (i in 0...lines.length)
		{
			var currImageData = lines[i].split("=");
			var name = StringTools.trim(currImageData[0]);
			var currImageRegion = StringTools.trim(currImageData[1]).split(" ");

			var rect = FlxRect.get(Std.parseInt(currImageRegion[0]), Std.parseInt(currImageRegion[1]), Std.parseInt(currImageRegion[2]),
				Std.parseInt(currImageRegion[3]));
			var sourceSize = FlxPoint.get(rect.width, rect.height);
			var offset = FlxPoint.get();

			frames.addAtlasFrame(rect, sourceSize, offset, name, FlxFrameAngle.ANGLE_0);
		}

		return frames;
	}

	/**
	 * Returns the `FlxAtlasFrame` of the specified `FlxGraphic` object.
	 *
	 * @param   graphic   `FlxGraphic` object to find the `FlxAtlasFrames` collection for.
	 * @return  `FlxAtlasFrames` collection for the specified `FlxGraphic` object
	 *          Could be `null` if `FlxGraphic` doesn't have it yet.
	 */
	public static function findFrame(graphic:FlxGraphic, ?border:FlxPoint):FlxAtlasFrames
	{
		if (border == null)
			border = FlxPoint.weak();

		var atlasFrames:Array<FlxAtlasFrames> = cast graphic.getFramesCollections(FlxFrameCollectionType.ATLAS);

		for (atlas in atlasFrames)
			if (atlas.border.equals(border))
				return atlas;

		return null;
	}

	override public function addBorder(border:FlxPoint):FlxAtlasFrames
	{
		var resultBorder = FlxPoint.weak().addPoint(this.border).addPoint(border);
		var atlasFrames = FlxAtlasFrames.findFrame(parent, resultBorder);
		if (atlasFrames != null)
			return atlasFrames;

		atlasFrames = new FlxAtlasFrames(parent, resultBorder);

		for (frame in frames)
			atlasFrames.pushFrame(frame.setBorderTo(border));

		return atlasFrames;
	}
}

typedef TexturePackerObject =
{
	frames:Dynamic
}
