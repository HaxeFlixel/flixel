package flixel.graphics.frames;

import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;

/**
 * Single-frame collection.
 * Could be useful for non-animated sprites.
 */
class FlxImageFrame extends FlxFramesCollection
{
	/**
	 * Single frame of this frame collection.
	 * Added this var for faster access, so you don't need to type something like: imageFrame.frames[0]
	 */
	public var frame:FlxFrame;
	
	private function new(parent:FlxGraphic) 
	{
		super(parent, FlxFrameCollectionType.IMAGE);
	}
	
	/**
	 * Generates ImageFrame object with empty frame of specified size.
	 * 
	 * @param	graphic		graphic for ImageFrame.
	 * @param	frameRect	the size of the empty frame to generate (only width and height of the frameRect are need to be set properly).
	 * @return	Newly created ImageFrame object with empty frame of specified size.
	 */
	public static function fromEmptyFrame(graphic:FlxGraphic, frameRect:FlxRect):FlxImageFrame
	{
		if (graphic == null || frameRect == null)	return null;
		
		// find ImageFrame, if there is one already
		var imageFrame:FlxImageFrame = FlxImageFrame.findEmptyFrame(graphic, frameRect);
		if (imageFrame != null)
		{
			return imageFrame;
		}
		
		// or create it, if there is no such object
		imageFrame = new FlxImageFrame(graphic);
		imageFrame.frame = imageFrame.addEmptyFrame(frameRect);
		return imageFrame;
	}
	
	/**
	 * Generates ImageFrame object for specified FlxFrame.
	 * 
	 * @param	source	FlxFrame to generate ImageFrame from.
	 * @return	Created ImageFrame object.
	 */
	public static function fromFrame(source:FlxFrame):FlxImageFrame
	{
		var graphic:FlxGraphic = source.parent;
		var rect:FlxRect = source.frame;
		
		var imageFrame:FlxImageFrame = FlxImageFrame.findFrame(graphic, rect);
		if (imageFrame != null)
		{
			return imageFrame;
		}
		
		imageFrame = new FlxImageFrame(graphic);
		imageFrame.frame = imageFrame.addSpriteSheetFrame(rect.copyTo(new FlxRect()));
		return imageFrame;
	}
	
	/**
	 * Creates ImageFrame object for the whole image.
	 * 
	 * @param	source	image graphic for ImageFrame. It could be String, BitmapData or FlxGraphic.
	 * @return	Newly created ImageFrame object for specified graphic.
	 */
	public static function fromImage(source:FlxGraphicAsset):FlxImageFrame
	{
		return fromRectangle(source, null);
	}
	
	/**
	 * Creates ImageFrame for specified region of FlxGraphic.
	 * 
	 * @param	graphic	graphic for ImageFrame.
	 * @param	region	region of image to create ImageFrame for.
	 * @return	Newly created ImageFrame object for specified region of FlxGraphic object.
	 */
	public static function fromGraphic(graphic:FlxGraphic, region:FlxRect = null):FlxImageFrame
	{
		if (graphic == null)	return null;
		
		// find ImageFrame, if there is one already
		var checkRegion:FlxRect = region;
		
		if (checkRegion == null)
		{
			checkRegion = FlxRect.flxRect;
			checkRegion.set(0, 0, graphic.width, graphic.height);
		}
		
		var imageFrame:FlxImageFrame = FlxImageFrame.findFrame(graphic, checkRegion);
		if (imageFrame != null)
		{
			return imageFrame;
		}
		
		// or create it, if there is no such object
		imageFrame = new FlxImageFrame(graphic);
		
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
		
		imageFrame.frame = imageFrame.addSpriteSheetFrame(region);
		return imageFrame;
	}
	
	/**
	 * Creates ImageFrame object for specified region of image.
	 * 
	 * @param	source	image graphic for ImageFrame. It could be String, BitmapData or FlxGraphic.
	 * @param	region	region of image to create ImageFrame for.
	 * @return	Newly created ImageFrame object for specified region of image.
	 */
	public static function fromRectangle(source:FlxGraphicAsset, region:FlxRect = null):FlxImageFrame
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		return fromGraphic(graphic, region);
	}
	
	/**
	 * Searches ImageFrame object for specified FlxGraphic object which have the same frame rectangle.
	 * 
	 * @param	graphic		FlxGraphic object to search ImageFrame for.
	 * @param	frameRect	ImageFrame object should have frame with the same position and dimensions as specified with this argument.
	 * @return	ImageFrame object which corresponds to specified rectangle. Could be null if there is no such ImageFrame.
	 */
	public static function findFrame(graphic:FlxGraphic, frameRect:FlxRect):FlxImageFrame
	{
		var imageFrames:Array<FlxImageFrame> = cast graphic.getFramesCollections(FlxFrameCollectionType.IMAGE);
		var imageFrame:FlxImageFrame;
		for (imageFrame in imageFrames)
		{
			if (imageFrame.equals(frameRect) && imageFrame.frame.type != FlxFrameType.EMPTY)
			{
				return imageFrame;
			}
		}
		
		return null;
	}
	
	/**
	 * Searches ImageFrame object with the empty frame which have specified size.
	 * 
	 * @param	graphic		FlxGraphic object to search ImageFrame for.
	 * @param	frameRect	The size of empty frame to search for.
	 * @return	ImageFrame with empty frame.
	 */
	public static function findEmptyFrame(graphic:FlxGraphic, frameRect:FlxRect):FlxImageFrame
	{
		var imageFrames:Array<FlxImageFrame> = cast graphic.getFramesCollections(FlxFrameCollectionType.IMAGE);
		var imageFrame:FlxImageFrame;
		var frame:FlxFrame;
		
		for (imageFrame in imageFrames)
		{
			frame = imageFrame.frame;
			
			if (frame.sourceSize.x == frameRect.width && frame.sourceSize.y == frameRect.height && frame.type == FlxFrameType.EMPTY)
			{
				return imageFrame;
			}
		}
		
		return null;
	}
	
	/**
	 * ImageFrame comparison method. For internal use.
	 */
	public inline function equals(rect:FlxRect = null):Bool
	{
		return rect.equals(frame.frame);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		frame = FlxDestroyUtil.destroy(frame);
	}
}