package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxDestroyUtil;

/**
 * Spritesheet frame collection. It is used for tilemaps and animated sprites. 
 */
class FlxTileFrames extends FlxFramesCollection
{
	/**
	 * Atlas frame from which this frame collection had been generated.
	 * Could be null if this collection generated from rectangle.
	 */
	private var atlasFrame:FlxFrame;
	/**
	 * image region of image from which this frame collection had been generated.
	 */
	private var region:FlxRect;
	/**
	 * The size of frame in this spritesheet.
	 */
	public var tileSize:FlxPoint;
	/**
	 * offsets between frames in this spritesheet.
	 */
	private var tileSpacing:FlxPoint;
	
	public var numRows:Int = 0;
	
	public var numCols:Int = 0;
	
	private function new(parent:FlxGraphic) 
	{
		super(parent, FlxFrameCollectionType.TILES);
	}
	
	/**
	 * Gets frame by its "position" in spritesheet
	 */
	public inline function getByTilePosition(column:Int, row:Int):FlxFrame
	{
		return frames[row * numCols + column];
	}
	
	/**
	 * Gets source bitmapdata, generates new bitmapdata with spaces between frames (if there is no such bitmapdata in the cache already) 
	 * and creates TileFrames collection.
	 * 
	 * @param	source			the source of graphic for frame collection (can be String, BitmapData or FlxGraphic).
	 * @param	tileSize		the size of tiles in spritesheet
	 * @param	tileSpacing		desired offsets between frames in spritesheet
	 * 							(this method takes spritesheet bitmap without offsets between frames and adds them).
	 * @param	region			Region of image to generate spritesheet from. Default value is null, which means that
	 * 							whole image will be used for spritesheet generation
	 * @return	Newly created spritesheet
	 */
	public static function fromBitmapWithSpacesAndBorders(source:FlxGraphicAsset, tileSize:FlxPoint, tileSpacing:FlxPoint, tileBorder:FlxPoint = null, region:FlxRect = null):FlxTileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null) return null;
		
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
		
		var spaces:FlxPoint = FlxPoint.get().copyFrom(tileSpacing).add(borderX, borderY);
		
		return FlxTileFrames.fromRectangle(result, tileSize, null, spaces);
	}
	
	/**
	 * Generates spritesheet frame collection from provided frame. Can be useful for spritesheets packed into atlases.
	 * It can generate spritesheets from rotated and cropped frames also, which is important for devices with small amount of memory.
	 * 
	 * @param	frame			frame, containg spritesheet image
	 * @param	tileSize		the size of tiles in spritesheet
	 * @param	tileSpacing		offsets between frames in spritesheet. Default value is null, which means no offsets between tiles
	 * @return	Newly created spritesheet frame collection.
	 */
	public static function fromFrame(frame:FlxFrame, tileSize:FlxPoint, tileSpacing:FlxPoint = null):FlxTileFrames
	{
		var graphic:FlxGraphic = frame.parent;
		// find TileFrames object, if there is one already
		var tileFrames:FlxTileFrames = FlxTileFrames.findFrame(graphic, tileSize, null, frame, tileSpacing);
		if (tileFrames != null)
		{
			return tileFrames;
		}
		
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
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))	
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
	 * @param	Frames	Array of frames to generate tile frames from. They all should have the same source size and parent graphic. If not then null will be returned.
	 * @return	Generated collection of frames.
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
			{
				tileFrames.framesHash.set(frame.name, frame);
			}
		}
		
		return tileFrames;
	}
	
	/**
	 * Creates new TileFrames collection from atlas frames which begin with
	 * a common name (e.g. "tiles-") and differ in indices (e.g. "001", "002", etc.).
	 * This method is similar to FlxAnimationController's addByPrefix().
	 * 
	 * @param	Frames	Collection of atlas frames to generate tiles from.
	 * @param	Prefix	Common beginning of image names in atlas (e.g. "tiles-")
	 * @return	Generated tile frames collection.
	 */
	public static function fromAtlasByPrefix(Frames:FlxAtlasFrames, Prefix:String):FlxTileFrames
	{
		var framesToAdd = new Array<FlxFrame>();
		
		for (frame in Frames.frames)
		{
			if (StringTools.startsWith(frame.name, Prefix))
			{
				framesToAdd.push(frame);
			}
		}
		
		if (framesToAdd.length > 0)
		{
			var name:String = framesToAdd[0].name;
			var postIndex:Int = name.indexOf(".", Prefix.length);
			var postFix:String = name.substring(postIndex == -1 ? name.length : postIndex, name.length);
			
			framesToAdd.sort(FlxFrame.sortByName.bind(_, _, Prefix.length, postFix.length));
			return FlxTileFrames.fromFrames(framesToAdd);
		}
		
		return null;
	}
	
	/**
	 * Generates spritesheet frame collection from provided region of image.
	 * 
	 * @param	graphic			source graphic for spritesheet.
	 * @param	tileSize		the size of tiles in spritesheet.
	 * @param	region			region of image to use for spritesheet generation. Default value is null,
	 * 							which means that the whole image will be used for it.
	 * @param	tileSpacing		offsets between frames in spritesheet. Default value is null, which means no offsets between tiles
	 * @return	Newly created spritesheet frame collection.
	 */
	public static function fromGraphic(graphic:FlxGraphic, tileSize:FlxPoint, region:FlxRect = null, tileSpacing:FlxPoint = null):FlxTileFrames
	{
		// find TileFrames object, if there is one already
		var tileFrames:FlxTileFrames = FlxTileFrames.findFrame(graphic, tileSize, region, null, tileSpacing);
		if (tileFrames != null)
		{
			return tileFrames;
		}
		
		// or create it, if there is no such object
		if (region == null)
		{
			region = FlxRect.get(0, 0, graphic.width, graphic.height);
		}
		else
		{
			if (region.width == 0)
			{
				region.width = graphic.width - region.x;
			}
			
			if (region.height == 0)
			{
				region.height = graphic.height - region.y;
			}
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
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))
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
	 * Generates spritesheet frame collection from provided region of image.
	 * 
	 * @param	source			source graphic for spritesheet.
	 * 							It can be BitmapData, String or FlxGraphic.
	 * @param	tileSize		the size of tiles in spritesheet.
	 * @param	region			region of image to use for spritesheet generation. Default value is null,
	 * 							which means that whole image will be used for it.
	 * @param	tileSpacing		offsets between frames in spritesheet. Default value is null, which means no offsets between tiles
	 * @return	Newly created spritesheet frame collection
	 */
	public static function fromRectangle(source:FlxGraphicAsset, tileSize:FlxPoint, region:FlxRect = null, tileSpacing:FlxPoint = null):FlxTileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null)	return null;
		return fromGraphic(graphic, tileSize, region, tileSpacing);
	}
	
	/**
	 * Searches TileFrames object for specified FlxGraphic object which have the same parameters (frame size, frame spacings, region of image, etc.).
	 * 
	 * @param	graphic			FlxGraphic object to search TileFrames for.
	 * @param	tileSize		The size of tiles in TileFrames.
	 * @param	region			The region of source image used for spritesheet generation.
	 * @param	atlasFrame		Optional FlxFrame object used for spritesheet generation.
	 * @param	tileSpacing		Spaces between tiles in spritesheet.
	 * @return	ImageFrame object which corresponds to specified arguments. Could be null if there is no such TileFrames.
	 */
	public static function findFrame(graphic:FlxGraphic, tileSize:FlxPoint, region:FlxRect = null, atlasFrame:FlxFrame = null, tileSpacing:FlxPoint = null):FlxTileFrames
	{
		var tileFrames:Array<FlxTileFrames> = cast graphic.getFramesCollections(FlxFrameCollectionType.TILES);
		var sheet:FlxTileFrames;
		
		for (sheet in tileFrames)
		{
			if (sheet.equals(tileSize, region, null, tileSpacing))
			{
				return sheet;
			}
		}
		
		return null;
	}
	
	/**
	 * TileFrames comparison method. For internal use.
	 */
	public function equals(tileSize:FlxPoint, region:FlxRect = null, atlasFrame:FlxFrame = null, tileSpacing:FlxPoint = null):Bool
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
		{
			region = FlxRect.flxRect;
			region.set(0, 0, parent.width, parent.height);
		}
		
		if (tileSpacing == null)
		{
			tileSpacing = FlxPoint.flxPoint1;
			tileSpacing.set(0, 0);
		}
		
		return (this.atlasFrame == atlasFrame && this.region.equals(region) && this.tileSize.equals(tileSize) && this.tileSpacing.equals(tileSpacing));
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