package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.AtlasBase;
import flixel.graphics.atlas.TexturePackerAtlas;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import haxe.xml.Access;
import openfl.Assets;
import openfl.geom.Rectangle;

/**
 * Atlas frames collection. It makes possible to use texture atlases in Flixel.
 * Plus it contains few packer parser methods for most commonly used atlas formats.
 */
class FlxAtlasFrames extends FlxFramesCollection
{
	var usedGraphics:Array<FlxGraphic> = [];
	
	public function new(parent:FlxGraphic, ?border:FlxPoint)
	{
		super(parent, FlxFrameCollectionType.ATLAS, border);
	}
	
	override function destroy()
	{
		while (usedGraphics.length > 0)
			usedGraphics.shift().decrementUseCount();
		
		super.destroy();
	}

	/**
	 * Parsing method for atlases generated from Aseprite's JSON export options. Note that Aseprite
	 * and Texture Packer use the same JSON format, however this method honors frames' `duration`
	 * whereas `fromTexturePackerJson` ignores it by default (for backwrds compatibility reasons).
	 *
	 * @param   source       The image source (can be `FlxGraphic`, `String`, or `BitmapData`).
	 * @param   description  Contents of JSON file with atlas description.
	 *                       You can get it with `Assets.getText(path/to/description.json)`.
	 *                       Or you can just a pass path to the JSON file in the assets directory.
	 *                       You can also directly pass in the parsed object.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 * @see [Exporting texture atlases with Aseprite](https://www.aseprite.org/docs/sprite-sheet/#texture-atlases)
	 */
	public static inline function fromAseprite(source:FlxGraphicAsset, description:FlxAsepriteJsonAsset):FlxAtlasFrames
	{
		return fromTexturePackerJson(source, description, true);
	}

	/**
	 * Parsing method for TexturePacker atlases in JSON format.
	 *
	 * @param   source            The image source (can be `FlxGraphic`, `String`, or `BitmapData`).
	 * @param   description       Contents of JSON file with atlas description.
	 *                            You can get it with `Assets.getText(path/to/description.json)`.
	 *                            Or you can just a pass path to the JSON file in the assets directory.
	 *                            You can also directly pass in the parsed object.
	 * @param   useFrameDuration  If true, any frame durations defined in the JSON will override the
	 *                            frameRate set in you `FlxAnimationController`.
	 *                            Note: You can also use `fromAseprite` which uses duration.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromTexturePackerJson(source:FlxGraphicAsset, description:FlxTexturePackerJsonAsset, useFrameDuration = false):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || description == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		final data:TexturePackerAtlas = description.getData();
		// JSON-Array
		if (data.frames.isArray())
		{
			for (frame in data.frames.toArray())
				texturePackerHelper(frame.filename, frame, frames, useFrameDuration);
		}
		// JSON-Hash
		else
		{
			for (name=>frame in data.frames.toHash())
				texturePackerHelper(name, frame, frames, useFrameDuration);
		}

		return frames;
	}

	/**
	 * Internal method for TexturePacker parsing. Parses the actual frame data.
	 *
	 * @param   frameName   Name of the frame (file name of the original source image).
	 * @param   frameData   The TexturePacker data excluding "filename".
	 * @param   frames      The `FlxAtlasFrames` to add this frame to.
	 */
	static function texturePackerHelper(frameName:String, frameData:TexturePackerAtlasFrame, frames:FlxAtlasFrames, useFrameDuration = false):Void
	{
		final rotated:Bool = frameData.rotated;
		var angle:FlxFrameAngle = FlxFrameAngle.ANGLE_0;
		var frameRect:FlxRect = null;

		final frame = frameData.frame;
		if (rotated)
		{
			frameRect = FlxRect.get(frame.x, frame.y, frame.h, frame.w);
			angle = FlxFrameAngle.ANGLE_NEG_90;
		}
		else
		{
			frameRect = FlxRect.get(frame.x, frame.y, frame.w, frame.h);
		}

		final sourceSize = FlxPoint.get(frameData.sourceSize.w, frameData.sourceSize.h);
		final offset = FlxPoint.get(frameData.spriteSourceSize.x, frameData.spriteSourceSize.y);
		final duration = (useFrameDuration && frameData.duration != null) ? frameData.duration / 1000 : 0;
		frames.addAtlasFrame(frameRect, sourceSize, offset, frameName, angle, false, false, duration);
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
	 * @param   source  The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param   xml     Contents of the XML file with atlas description.
	 *                  Can be a path to the XML asset, an XML string, or an `Xml` object.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromSparrow(source:FlxGraphicAsset, xml:FlxXmlAsset):FlxAtlasFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source);
		if (graphic == null)
			return null;
		// No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || xml == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		var data:Access = new Access(xml.getXml().firstElement());

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
	 * @param   source  The image source (can be `FlxGraphic`, `String` or `BitmapData`).
	 * @param   xml     Contents of the XML file with atlas description.
	 *                  Can be a path to the XML asset, an XML string, or an `Xml` object.
	 * @return  Newly created `FlxAtlasFrames` collection.
	 */
	public static function fromTexturePackerXml(source:FlxGraphicAsset, xml:FlxXmlAsset):FlxAtlasFrames
	{
		final graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)
			return null;

		// No need to parse data again
		var frames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		if (graphic == null || xml == null)
			return null;

		frames = new FlxAtlasFrames(graphic);

		final data = xml.getXml();

		for (sprite in data.firstElement().elements())
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
	
	/**
	 * Adds all ofthe frames from the specified collection
	 * 
	 * @param   collection     The frames to add. Note: calling destroy() on this collection
	 *                         after it has been added can cause crashes.
	 * @param   overwriteHash  If true, any new frames with matching names will replace old ones.
	 * 
	 * @since 5.3.0
	 */
	public function addAtlas(collection:FlxAtlasFrames, overwriteHash = false)
	{
		for (frame in collection.frames)
			pushFrame(frame, overwriteHash);
		
		if (!usedGraphics.contains(collection.parent))
		{
			usedGraphics.push(collection.parent);
			collection.parent.incrementUseCount();
		}
		
		return this;
	}
	
	/**
	 * Creates a new `FlxAtlasFrames` instance with all the frames from this and the desired instance.
	 * 
	 * Note: Calling `destroy` on either of these graphics after concatenating them may cause crashes
	 * @param   collection     The other frames to add.
	 * @param   overwriteHash  If true, any new frames with matching names will replace old ones.
	 * 
	 * @since 5.3.0
	 */
	public function concat(collection:FlxAtlasFrames, overwriteHash = false)
	{
		final newCollection = new FlxAtlasFrames(parent);
		newCollection.addAtlas(this);
		newCollection.addAtlas(this, overwriteHash);
		return this;
	}
}

@:deprecated("Use TexturePackerAtlas instead")// 5.4.0
typedef TexturePackerObject = TexturePackerAtlas;
@:deprecated("Use TexturePackerAtlasFrame instead")// 5.4.0
typedef TexturePackerFrameData = TexturePackerAtlasFrame;
@:deprecated("Use AtlasRect instead")// 5.4.0
typedef TexturePackerFrameRect = AtlasRect;
