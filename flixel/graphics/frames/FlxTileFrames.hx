package flixel.graphics.frames;

import openfl.display.BitmapData;
import openfl.geom.Point;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

/**
 * Spritesheet frame collection. It is used for tilemaps and animated sprites.
 */
class FlxTileFrames extends FlxFramesCollection
{
	/**
	 * Atlas frame from which this frame collection had been generated.
	 * Could be `null` if this collection generated from rectangle.
	 */
	var atlasFrame:FlxFrame;

	/**
	 * Image region of the image from which this frame collection had been generated.
	 */
	var region:FlxRect;

	/**
	 * The size of frame in this spritesheet.
	 */
	public var tileSize:FlxPoint;

	/**
	 * Offsets between frames in this spritesheet.
	 */
	var tileSpacing:FlxPoint;

	public var numRows:Int = 0;

	public var numCols:Int = 0;

	function new(parent:FlxGraphic, ?border:FlxPoint)
	{
		super(parent, FlxFrameCollectionType.TILES, border);
	}

	/**
	 * Gets frame by its "position" in spritesheet.
	 */
	public inline function getByTilePosition(column:Int, row:Int):FlxFrame
	{
		return frames[row * numCols + column];
	}

	/**
	 * Gets source `BitmapData`, generates new `BitmapData` with spaces between frames
	 * (if there is no such `BitmapData` in the cache already) and creates `FlxTileFrames` collection.
	 *
	 * @param   source        The source of graphic for frame collection.
	 * @param   tileSize      The size of tiles in spritesheet.
	 * @param   tileSpacing   Desired offsets between frames in spritesheet
	 *                        (this method takes spritesheet bitmap without offsets between frames and adds them).
	 * @param   tileBorder    Border to add around tiles (helps to avoid "tearing" problem).
	 * @param   region        Region of image to generate spritesheet from. Default value is `null`, which means that
	 *                        the whole image will be used for spritesheet generation.
	 * @return   Newly created spritesheet.
	 */
	public static function fromBitmapAddSpacesAndBorders(source:FlxGraphicAsset, tileSize:FlxPoint, ?tileSpacing:FlxPoint, ?tileBorder:FlxPoint,
			?region:FlxRect):FlxTileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)
			return null;

		var key:String = FlxG.bitmap.getKeyWithSpacesAndBorders(graphic.key, tileSize, tileSpacing, tileBorder, region);
		var result:FlxGraphic = FlxG.bitmap.get(key);
		if (result == null)
		{
			var bitmap:BitmapData = FlxBitmapDataUtil.addSpacesAndBorders(graphic.bitmap, tileSize, tileSpacing, tileBorder, region);
			result = FlxG.bitmap.add(bitmap, false, key);
		}

		var borderX:Int = 0;
		var borderY:Int = 0;

		if (tileBorder != null)
		{
			borderX = Std.int(tileBorder.x);
			borderY = Std.int(tileBorder.y);
		}

		var tileFrames:FlxTileFrames = FlxTileFrames.fromGraphic(result, FlxPoint.get().addPoint(tileSize).add(2 * borderX, 2 * borderY), null, tileSpacing);

		if (tileBorder == null)
			return tileFrames;

		return tileFrames.addBorder(tileBorder);
	}

	/**
	 * Gets `FlxFrame` object, generates new `BitmapData` with spaces between tiles in the frame
	 * (if there is no such `BitmapData` in the cache already) and creates a `FlxTileFrames` collection.
	 *
	 * @param   frame         Frame to generate tiles from.
	 * @param   tileSize      the size of tiles in spritesheet.
	 * @param   tileSpacing   desired offsets between frames in spritesheet.
	 *                        (this method takes spritesheet bitmap without offsets between frames and adds them).
	 * @param   tileBorder    Border to add around tiles (helps to avoid "tearing" problem).
	 * @return  Newly created spritesheet.
	 */
	public static function fromFrameAddSpacesAndBorders(frame:FlxFrame, tileSize:FlxPoint, ?tileSpacing:FlxPoint, ?tileBorder:FlxPoint):FlxTileFrames
	{
		var bitmap:BitmapData = frame.paint();
		return FlxTileFrames.fromBitmapAddSpacesAndBorders(bitmap, tileSize, tileSpacing, tileBorder);
	}

	/**
	 * Generates spritesheet frame collection from provided frame. Can be useful for spritesheets packed into atlases.
	 * It can generate spritesheets from rotated and cropped frames also,
	 * which is important for devices with limited memory.
	 *
	 * @param   frame         Frame, containing spritesheet image
	 * @param   tileSize      The size of tiles in spritesheet
	 * @param   tileSpacing   Offsets between frames in spritesheet.
	 *                        Default value is `null`, which means no offsets between tiles.
	 * @return  Newly created spritesheet frame collection.
	 */
	public static function fromFrame(frame:FlxFrame, tileSize:FlxPoint, ?tileSpacing:FlxPoint):FlxTileFrames
	{
		var graphic:FlxGraphic = frame.parent;
		// find TileFrames object, if there is one already
		var tileFrames:FlxTileFrames = FlxTileFrames.findFrame(graphic, tileSize, null, frame, tileSpacing);
		if (tileFrames != null)
			return tileFrames;

		// or create it, if there is no such object
		tileSpacing = (tileSpacing != null) ? tileSpacing : FlxPoint.get(0, 0);

		tileFrames = new FlxTileFrames(graphic);
		tileFrames.atlasFrame = frame;
		tileFrames.region = frame.frame;
		tileFrames.tileSize = tileSize;
		tileFrames.tileSpacing = tileSpacing;

		tileSpacing.floor();
		tileSize.floor();

		var spacedWidth:Float = tileSize.x + tileSpacing.x;
		var spacedHeight:Float = tileSize.y + tileSpacing.y;

		var numRows:Int = (tileSize.y == 0) ? 1 : Std.int((frame.sourceSize.y + tileSpacing.y) / spacedHeight);
		var numCols:Int = (tileSize.x == 0) ? 1 : Std.int((frame.sourceSize.x + tileSpacing.x) / spacedWidth);

		var helperRect:FlxRect = FlxRect.get(0, 0, tileSize.x, tileSize.y);

		for (j in 0...numRows)
		{
			for (i in 0...numCols)
			{
				helperRect.x = spacedWidth * i;
				helperRect.y = spacedHeight * j;
				tileFrames.pushFrame(frame.subFrameTo(helperRect));
			}
		}

		helperRect = FlxDestroyUtil.put(helperRect);

		tileFrames.numCols = numCols;
		tileFrames.numRows = numRows;
		return tileFrames;
	}

	/**
	 * Just generates tile frames collection from specified array of frames.
	 *
	 * @param   Frames   `Array` of frames to generate tile frames from.
	 *                   They all should have the same source size and parent graphic.
	 *                   If not then `null` will be returned.
	 * @return  Generated collection of frames.
	 */
	public static function fromFrames(Frames:Array<FlxFrame>):FlxTileFrames
	{
		var firstFrame:FlxFrame = Frames[0];
		var graphic:FlxGraphic = firstFrame.parent;

		for (frame in Frames)
		{
			if (frame.parent != firstFrame.parent || !frame.sourceSize.equals(firstFrame.sourceSize))
			{
				// frames doesn't have the same size and parent graphic
				return null;
			}
		}

		var tileFrames:FlxTileFrames = new FlxTileFrames(graphic);

		tileFrames.region = null;
		tileFrames.atlasFrame = null;
		tileFrames.tileSize = FlxPoint.get().copyFrom(firstFrame.sourceSize);
		tileFrames.tileSpacing = FlxPoint.get(0, 0);
		tileFrames.numCols = Frames.length;
		tileFrames.numRows = 1;

		for (frame in Frames)
		{
			tileFrames.frames.push(frame);

			if (frame.name != null)
				tileFrames.framesByName.set(frame.name, frame);
		}

		return tileFrames;
	}

	/**
	 * Creates new a `FlxTileFrames` collection from atlas frames which begin with
	 * a common name (e.g. `"tiles-"`) and differ in indices (e.g. `"001"`, `"002"`, etc.).
	 * This method is similar to `FlxAnimationController`'s `addByPrefix()`.
	 *
	 * @param    Frames   Collection of atlas frames to generate tiles from.
	 * @param    Prefix   Common beginning of image names in atlas (e.g. `"tiles-"`).
	 * @return   Generated tile frames collection.
	 */
	public static function fromAtlasByPrefix(Frames:FlxAtlasFrames, Prefix:String):FlxTileFrames
	{
		var framesToAdd = new Array<FlxFrame>();

		for (frame in Frames.frames)
		{
			if (StringTools.startsWith(frame.name, Prefix))
				framesToAdd.push(frame);
		}

		if (framesToAdd.length > 0)
		{
			var name:String = framesToAdd[0].name;
			var postIndex:Int = name.indexOf(".", Prefix.length);
			var postFix:String = name.substring(postIndex == -1 ? name.length : postIndex, name.length);

			FlxFrame.sort(framesToAdd, Prefix.length, postFix.length);
			return FlxTileFrames.fromFrames(framesToAdd);
		}

		return null;
	}

	/**
	 * Generates spritesheet frame collection from provided region of image.
	 *
	 * @param   graphic       Source graphic for spritesheet.
	 * @param   tileSize      The size of tiles in spritesheet.
	 * @param   region        Region of image to use for spritesheet generation. Default value is `null`,
	 *                        which means that the whole image will be used for it.
	 * @param   tileSpacing   Offsets between frames in spritesheet.
	 *                        Default value is `null`, which means no offsets between tiles.
	 * @return  Newly created spritesheet frame collection.
	 */
	public static function fromGraphic(graphic:FlxGraphic, tileSize:FlxPoint, ?region:FlxRect, ?tileSpacing:FlxPoint):FlxTileFrames
	{
		// find TileFrames object, if there is one already
		var tileFrames:FlxTileFrames = FlxTileFrames.findFrame(graphic, tileSize, region, null, tileSpacing);
		if (tileFrames != null)
			return tileFrames;

		// or create it, if there is no such object
		if (region == null)
		{
			region = FlxRect.get(0, 0, graphic.width, graphic.height);
		}
		else
		{
			if (region.width == 0)
				region.width = graphic.width - region.x;

			if (region.height == 0)
				region.height = graphic.height - region.y;
		}

		tileSpacing = (tileSpacing != null) ? tileSpacing : FlxPoint.get(0, 0);

		tileFrames = new FlxTileFrames(graphic);
		tileFrames.region = region;
		tileFrames.atlasFrame = null;
		tileFrames.tileSize = tileSize;
		tileFrames.tileSpacing = tileSpacing;

		region.floor();
		tileSpacing.floor();
		tileSize.floor();

		var spacedWidth:Float = tileSize.x + tileSpacing.x;
		var spacedHeight:Float = tileSize.y + tileSpacing.y;

		var numRows:Int = (tileSize.y == 0) ? 1 : Std.int((region.height + tileSpacing.y) / spacedHeight);
		var numCols:Int = (tileSize.x == 0) ? 1 : Std.int((region.width + tileSpacing.x) / spacedWidth);

		var tileRect:FlxRect;

		for (j in 0...numRows)
		{
			for (i in 0...numCols)
			{
				tileRect = FlxRect.get(region.x + i * spacedWidth, region.y + j * spacedHeight, tileSize.x, tileSize.y);
				tileFrames.addSpriteSheetFrame(tileRect);
			}
		}

		tileFrames.numCols = numCols;
		tileFrames.numRows = numRows;
		return tileFrames;
	}

	/**
	 * Generates a spritesheet frame collection from the provided image region.
	 *
	 * @param   source        Source graphic for the spritesheet.
	 * @param   tileSize      The size of tiles in spritesheet.
	 * @param   region        Region of image to use for spritesheet generation. Default value is `null`,
	 *                        which means that whole image will be used for it.
	 * @param   tileSpacing   Offsets between frames in spritesheet.
	 *                        Default value is `null`, which means no offsets between tiles.
	 * @return  Newly created spritesheet frame collection.
	 */
	public static function fromRectangle(source:FlxGraphicAsset, tileSize:FlxPoint, ?region:FlxRect, ?tileSpacing:FlxPoint):FlxTileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)
			return null;
		return fromGraphic(graphic, tileSize, region, tileSpacing);
	}

	/**
	 * This method takes array of tileset bitmaps and the size of
	 * tiles in them and then combine them in one big tileset.
	 * The order of bitmaps in the array is important.
	 *
	 * ```haxe
	 * var combinedFrames = FlxTileFrames.combineTileSets(bitmaps, FlxPoint.get(16, 16));
	 * tilemap.loadMapFromCSV(mapData, combinedFrames);
	 * ```
	 *
	 * or
	 *
	 * ```haxe
	 * sprite.frames = combinedFrames;
	 * ```
	 *
	 * @param   bitmaps    tilesets
	 * @param   tileSize   The size of tiles (tilesets should have tiles of the same size).
	 * @return  Atlas frames collection, which you can load in tilemaps or sprites:
	 */
	public static function combineTileSets(bitmaps:Array<BitmapData>, tileSize:FlxPoint, ?spacing:FlxPoint, ?border:FlxPoint):FlxTileFrames
	{
		var framesCollections:Array<FlxTileFrames> = [];

		for (bitmap in bitmaps)
			framesCollections.push(FlxTileFrames.fromRectangle(bitmap, tileSize));

		return combineTileFrames(framesCollections, spacing, border);
	}

	/**
	 * This method takes array of tile frames collections and then combine them in one big tileset.
	 * The order of bitmaps in array is important.
	 *
	 *
	 * ```haxe
	 * var combinedFrames = FlxTileFrames.combineTileFrames(tileframes);
	 * tilemap.loadMapFromCSV(mapData, combinedFrames);
	 * ```
	 *
	 * or
	 *
	 * ```haxe
	 * sprite.frames = combinedFrames;
	 * ```
	 *
	 * @param   tileframes   Tile frames collection to combine tiles from.
	 * @return  Atlas frames collection, which you can load in tilemaps or sprites:
	 */
	public static function combineTileFrames(tileframes:Array<FlxTileFrames>, ?spacing:FlxPoint, ?border:FlxPoint):FlxTileFrames
	{
		// we need to calculate the size of result bitmap first
		var totalArea:Int = 0;
		var rows:Int = 0;
		var cols:Int = 0;

		var tileWidth:Int = Std.int(tileframes[0].frames[0].sourceSize.x);
		var tileHeight:Int = Std.int(tileframes[0].frames[0].sourceSize.y);

		var spaceX:Int = 0;
		var spaceY:Int = 0;

		if (spacing != null)
		{
			spaceX = Std.int(spacing.x);
			spaceY = Std.int(spacing.y);
		}

		var borderX:Int = 0;
		var borderY:Int = 0;

		if (border != null)
		{
			borderX = Std.int(border.x);
			borderY = Std.int(border.y);
		}

		for (collection in tileframes)
		{
			cols = collection.numCols;
			rows = collection.numRows;
			totalArea += Std.int(cols * (tileWidth + 2 * borderX) * rows * (tileHeight + 2 * borderY));
		}

		var side:Float = Math.sqrt(totalArea);
		cols = Std.int(side / (tileWidth + 2 * borderX));
		rows = Math.ceil(totalArea / (cols * (tileWidth + 2 * borderX) * (tileHeight + 2 * borderY)));
		var width:Int = Std.int(cols * (tileWidth + 2 * borderX)) + (cols - 1) * spaceX;
		var height:Int = Std.int(rows * (tileHeight + 2 * borderY)) + (rows - 1) * spaceY;

		// now we'll create result atlas and will blit every tile on it.
		var combined:BitmapData = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		var graphic:FlxGraphic = FlxG.bitmap.add(combined);
		var result:FlxTileFrames = new FlxTileFrames(graphic);
		var destPoint:Point = new Point(borderX, borderY);

		result.region = FlxRect.get(0, 0, width, height);
		result.atlasFrame = null;
		result.tileSize = FlxPoint.get(tileWidth, tileHeight);
		result.tileSpacing = FlxPoint.get(spaceX, spaceY);
		result.numCols = cols;
		result.numRows = rows;
		// paint frames on result canvas with spaces between frames
		for (collection in tileframes)
		{
			for (frame in collection.frames)
			{
				frame.paint(combined, destPoint, true);

				result.addAtlasFrame(FlxRect.get(destPoint.x, destPoint.y, tileWidth, tileHeight), FlxPoint.get(tileWidth, tileHeight), FlxPoint.get(0, 0));
				destPoint.x += tileWidth + 2 * borderX + spaceX;

				if (destPoint.x >= combined.width)
				{
					destPoint.x = borderX;
					destPoint.y += tileHeight + 2 * borderY + spaceY;
				}
			}
		}
		// and copy pixels around frames
		FlxBitmapDataUtil.copyBorderPixels(combined, tileWidth, tileHeight, spaceX, spaceY, borderX, borderY, cols, rows);
		return result;
	}

	/**
	 * Searches `FlxTileFrames` object for a specified `FlxGraphic` object
	 * which has the same parameters (frame size, frame spacings, region of image, etc.).
	 *
	 * @param   graphic       `FlxGraphic` object to search `FlxTileFrames` for.
	 * @param   tileSize      The size of tiles in TileFrames.
	 * @param   region        The region of source image used for spritesheet generation.
	 * @param   atlasFrame    Optional `FlxFrame` object used for spritesheet generation.
	 * @param   tileSpacing   Spaces between tiles in spritesheet.
	 * @return  `FlxTileFrames` object which corresponds to specified arguments.
	 *          Could be null if there is no such `FlxTileFrames`.
	 */
	public static function findFrame(graphic:FlxGraphic, tileSize:FlxPoint, ?region:FlxRect, ?atlasFrame:FlxFrame, ?tileSpacing:FlxPoint,
			?border:FlxPoint):FlxTileFrames
	{
		var tileFrames:Array<FlxTileFrames> = cast graphic.getFramesCollections(FlxFrameCollectionType.TILES);

		for (sheet in tileFrames)
		{
			if (sheet.equals(tileSize, region, null, tileSpacing, border))
				return sheet;
		}

		return null;
	}

	/**
	 * TileFrames comparison method. For internal use.
	 */
	public function equals(tileSize:FlxPoint, ?region:FlxRect, ?atlasFrame:FlxFrame, ?tileSpacing:FlxPoint, ?border:FlxPoint):Bool
	{
		if (this.region == null && this.atlasFrame == null)
		{
			return false;
		}

		if (atlasFrame != null)
		{
			region = atlasFrame.frame;
		}

		if (region == null)
			region = FlxRect.weak(0, 0, parent.width, parent.height);

		if (tileSpacing == null)
			tileSpacing = FlxPoint.weak();

		if (border == null)
			border = FlxPoint.weak();

		return this.atlasFrame == atlasFrame
			&& this.region.equals(region)
			&& this.tileSize.equals(tileSize)
			&& this.tileSpacing.equals(tileSpacing)
			&& this.border.equals(border);
	}

	override public function addBorder(border:FlxPoint):FlxTileFrames
	{
		var resultBorder:FlxPoint = FlxPoint.get().addPoint(this.border).addPoint(border);
		var resultSize:FlxPoint = FlxPoint.get().copyFrom(tileSize).subtract(2 * border.x, 2 * border.y);
		var tileFrames:FlxTileFrames = FlxTileFrames.findFrame(parent, resultSize, region, atlasFrame, tileSpacing, resultBorder);
		if (tileFrames != null)
		{
			resultSize = FlxDestroyUtil.put(resultSize);
			return tileFrames;
		}

		tileFrames = new FlxTileFrames(parent, resultBorder);
		tileFrames.region = FlxRect.get().copyFrom(region);
		tileFrames.atlasFrame = atlasFrame;
		tileFrames.tileSize = resultSize;
		tileFrames.tileSpacing = FlxPoint.get().copyFrom(tileSpacing);

		for (frame in frames)
		{
			tileFrames.pushFrame(frame.setBorderTo(border));
		}

		return tileFrames;
	}

	override public function destroy():Void
	{
		super.destroy();
		atlasFrame = null;
		region = FlxDestroyUtil.put(region);
		tileSize = FlxDestroyUtil.put(tileSize);
		tileSpacing = FlxDestroyUtil.put(tileSpacing);
	}
}
