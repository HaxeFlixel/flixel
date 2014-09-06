package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.FrameCollectionType;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.layer.TileSheetExt;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.util.FlxBitmapDataUtil;

/**
 * Spritesheet frame collection. It is used for tilemaps and animated sprites. 
 */
class TileFrames extends FlxFramesCollection
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
		super(parent, FrameCollectionType.TILES);
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
	public static function fromBitmapWithSpacings(source:FlxGraphicAsset, tileSize:FlxPoint, tileSpacing:FlxPoint, region:FlxRect = null):TileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null) return null;
		
		var key:String = FlxG.bitmap.getKeyWithSpacings(graphic.key, tileSize, tileSpacing, region);
		var result:FlxGraphic = FlxG.bitmap.get(key);
		if (result == null)
		{
			var bitmap:BitmapData = FlxBitmapDataUtil.addSpacing(graphic.bitmap, tileSize, tileSpacing, region);
			result = FlxG.bitmap.add(bitmap, false, key);
		}
		
		return TileFrames.fromRectangle(result, tileSize, null, tileSpacing);
	}
	
	/**
	 * Generates spritesheet frame collection from provided frame. Can be usefull for spritesheets packed into atlases.
	 * It can generate spritesheets from rotated and cropped frames also, which is important for devices with small amount of memory.
	 * 
	 * @param	frame			frame, containg spritesheet image
	 * @param	tileSize		the size of tiles in spritesheet
	 * @param	tileSpacing		offsets between frames in spritesheet. Default value is null, which means no offsets between tiles
	 * @return	Newly created spritesheet frame collection.
	 */
	public static function fromFrame(frame:FlxFrame, tileSize:FlxPoint, tileSpacing:FlxPoint = null):TileFrames
	{
		var graphic:FlxGraphic = frame.parent;
		// find TileFrames object, if there is one already
		var tileFrames:TileFrames = TileFrames.findFrame(graphic, tileSize, null, frame, tileSpacing);
		if (tileFrames != null)
		{
			return tileFrames;
		}
		
		// or create it, if there is no such object
		tileSpacing = (tileSpacing != null) ? tileSpacing : new FlxPoint();
		
		tileFrames = new TileFrames(graphic);
		tileFrames.atlasFrame = frame;
		tileFrames.region = frame.frame;
		tileFrames.tileSize = tileSize;
		tileFrames.tileSpacing = tileSpacing;
		
		var bitmapWidth:Int = Std.int(frame.sourceSize.x);
		var bitmapHeight:Int = Std.int(frame.sourceSize.y);
		
		var xSpacing:Int = Std.int(tileSpacing.x);
		var ySpacing:Int = Std.int(tileSpacing.y);
		
		var frameWidth:Int = Std.int(tileSize.x);
		var frameHeight:Int = Std.int(tileSize.y);
		
		var spacedWidth:Int = frameWidth + xSpacing;
		var spacedHeight:Int = frameHeight + ySpacing;
		
		var clippedRect:FlxRect = new FlxRect(frame.offset.x, frame.offset.y, frame.frame.width, frame.frame.height);
		var helperRect:FlxRect = new FlxRect(0, 0, frameWidth, frameHeight);
		var tileRect:FlxRect;
		var frameOffset:FlxPoint;
		
		var numRows:Int = (frameHeight == 0) ? 1 : Std.int((bitmapHeight + ySpacing) / spacedHeight);
		var numCols:Int = (frameWidth == 0) ? 1 : Std.int((bitmapWidth + xSpacing) / spacedWidth);
		
		var x:Float, y:Float, w:Float, h:Float;
		
		var rotated:Bool = (frame.type == FrameType.ROTATED);
		var angle:Float = 0;
		
		if (rotated)
		{
			angle = frame.angle;
			clippedRect.width = frame.frame.height;
			clippedRect.height = frame.frame.width;
		}
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))	
			{
				helperRect.x = spacedWidth * i;
				helperRect.y = spacedHeight * j;
				tileRect = clippedRect.intersection(helperRect);
				
				if (tileRect.width == 0 || tileRect.height == 0)
				{
					tileRect.set(0, 0, frameWidth, frameHeight);
					tileFrames.addEmptyFrame(tileRect);
				}
				else
				{
					frameOffset = FlxPoint.get(tileRect.x - helperRect.x, tileRect.y - helperRect.y);
					
					x = tileRect.x;
					y = tileRect.y;
					w = tileRect.width;
					h = tileRect.height;
					
					if (angle == 0)
					{
						tileRect.x -= clippedRect.x;
						tileRect.y -= clippedRect.y;
					}
					if (angle == -90)
					{
						tileRect.x = clippedRect.bottom - y - h;
						tileRect.y = x - clippedRect.x;
						tileRect.width = h;
						tileRect.height = w;
					}
					else if (angle == 90)
					{
						tileRect.x = y - clippedRect.y;
						tileRect.y = clippedRect.right - x - w;
						tileRect.width = h;
						tileRect.height = w;
					}
					
					tileRect.x += frame.frame.x;
					tileRect.y += frame.frame.y;
					tileFrames.addAtlasFrame(tileRect, FlxPoint.get(frameWidth, frameHeight), frameOffset, null, angle);
				}
			}
		}
		
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
	public static function fromFrames(Frames:Array<FlxFrame>):TileFrames
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
		
		var tileFrames:TileFrames = new TileFrames(graphic);
		
		tileFrames.region = null;
		tileFrames.atlasFrame = null;
		tileFrames.tileSize = new FlxPoint().copyFrom(firstFrame.sourceSize);
		tileFrames.tileSpacing = new FlxPoint();
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
	 * Creates new TileFrames collection from atlas frames, which have common beginnings of name (e.g. "tiles-") and differ in indices (e.g. "001", "002", etc.)
	 * This method is similar to FlxAnimationController's addByPrefix() method.
	 * 
	 * @param	Frames	Collection of atlas frames to generate tiles from.
	 * @param	Prefix	Common beginning of image names in atlas (e.g. "tiles-")
	 * @return	Generated tile frames collection.
	 */
	public static function fromAtlasByPrefix(Frames:AtlasFrames, Prefix:String):TileFrames
	{
		var framesToAdd:Array<FlxFrame> = new Array<FlxFrame>();
		
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
			
			FlxAnimationController.prefixLength = Prefix.length;
			FlxAnimationController.postfixLength = postFix.length;
			framesToAdd.sort(FlxAnimationController.frameSortFunction);
			
			return TileFrames.fromFrames(framesToAdd);
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
	public static function fromGraphic(graphic:FlxGraphic, tileSize:FlxPoint, region:FlxRect = null, tileSpacing:FlxPoint = null):TileFrames
	{
		// find TileFrames object, if there is one already
		var tileFrames:TileFrames = TileFrames.findFrame(graphic, tileSize, region, null, tileSpacing);
		if (tileFrames != null)
		{
			return tileFrames;
		}
		
		// or create it, if there is no such object
		if (region == null)
		{
			region = new FlxRect(0, 0, graphic.width, graphic.height);
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
		
		tileSpacing = (tileSpacing != null) ? tileSpacing : new FlxPoint();
		
		tileFrames = new TileFrames(graphic);
		tileFrames.region = region;
		tileFrames.atlasFrame = null;
		tileFrames.tileSize = tileSize;
		tileFrames.tileSpacing = tileSpacing;
		
		var bitmapWidth:Int = Std.int(region.width);
		var bitmapHeight:Int = Std.int(region.height);
		
		var startX:Int = Std.int(region.x);
		var startY:Int = Std.int(region.y);
		
		var xSpacing:Int = Std.int(tileSpacing.x);
		var ySpacing:Int = Std.int(tileSpacing.y);
		
		var width:Int = Std.int(tileSize.x);
		var height:Int = Std.int(tileSize.y);
		
		var spacedWidth:Int = width + xSpacing;
		var spacedHeight:Int = height + ySpacing;
		
		var numRows:Int = (height == 0) ? 1 : Std.int((bitmapHeight + ySpacing) / spacedHeight);
		var numCols:Int = (width == 0) ? 1 : Std.int((bitmapWidth + xSpacing) / spacedWidth);
		
		var tileRect:FlxRect;
		
		for (j in 0...(numRows))
		{
			for (i in 0...(numCols))
			{
				tileRect = new FlxRect(startX + i * spacedWidth, startY + j * spacedHeight, width, height);
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
	public static function fromRectangle(source:FlxGraphicAsset, tileSize:FlxPoint, region:FlxRect = null, tileSpacing:FlxPoint = null):TileFrames
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
	public static function findFrame(graphic:FlxGraphic, tileSize:FlxPoint, region:FlxRect = null, atlasFrame:FlxFrame = null, tileSpacing:FlxPoint = null):TileFrames
	{
		var tileFrames:Array<TileFrames> = cast graphic.getFramesCollections(FrameCollectionType.TILES);
		var sheet:TileFrames;
		
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
			region = FlxRect.FLX_RECT;
			region.set(0, 0, parent.width, parent.height);
		}
		
		if (tileSpacing == null)
		{
			tileSpacing = FlxPoint.FLX_POINT;
			tileSpacing.set(0, 0);
		}
		
		return (this.atlasFrame == atlasFrame && this.region.equals(region) && this.tileSize.equals(tileSize) && this.tileSpacing.equals(tileSpacing));
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		atlasFrame = null;
		region = null;
		tileSize = null;
		tileSpacing = null;
	}
}