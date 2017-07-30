package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;

/**
 * Single-frame collection.
 * Could be useful for non-animated sprites.
 */
class FlxImageFrame extends FlxFramesCollection
{
	/**
	 * Single frame of this frame collection.
	 * Added this var for faster access, so you don't need to type something like: `imageFrame.frames[0]`
	 */
	public var frame(get, null):FlxFrame;
	
	private function new(parent:FlxGraphic, ?border:FlxPoint)
	{
		super(parent, FlxFrameCollectionType.IMAGE, border);
	}
	
	/**
	 * Generates a `FlxImageFrame` object with empty frame of specified size.
	 * 
	 * @param   graphic     Graphic for the `FlxImageFrame`.
	 * @param   frameRect   The size of the empty frame to generate
	 *                      (only `width` and `height` of the `frameRect` need to be set properly).
	 * @return  Newly created `FlxImageFrame` object with empty frame of specified size.
	 */
	public static function fromEmptyFrame(graphic:FlxGraphic, frameRect:FlxRect):FlxImageFrame
	{
		if (graphic == null || frameRect == null)
			return null;
		
		var imageFrame = new FlxImageFrame(graphic);
		imageFrame.addEmptyFrame(frameRect);
		return imageFrame;
	}
	
	/**
	 * Generates a `FlxImageFrame` object from the specified `FlxFrame`.
	 * 
	 * @param   source   `FlxFrame` to generate `FlxImageFrame` from.
	 * @return  Created `FlxImageFrame` object.
	 */
	public static function fromFrame(source:FlxFrame):FlxImageFrame
	{
		var graphic:FlxGraphic = source.parent;
		var rect:FlxRect = source.frame;
		var imageFrame:FlxImageFrame = new FlxImageFrame(graphic);
		imageFrame.addSpriteSheetFrame(rect.copyTo(FlxRect.get()));
		return imageFrame;
	}
	
	/**
	 * Creates a `FlxImageFrame` object for the whole image.
	 * 
	 * @param   source   image graphic for the `FlxImageFrame`.
	 * @return  Newly created `FlxImageFrame` object for specified graphic.
	 */
	public static function fromImage(source:FlxGraphicAsset):FlxImageFrame
	{
		return fromRectangle(source, null);
	}
	
	/**
	 * Creates `FlxImageFrame` for the specified region of `FlxGraphic`.
	 * 
	 * @param   graphic   Graphic for `FlxImageFrame`.
	 * @param   region    Region of image to create the `FlxImageFrame` for.
	 * @return  Newly created `FlxImageFrame` object for the specified region of `FlxGraphic` object.
	 */
	public static function fromGraphic(graphic:FlxGraphic, ?region:FlxRect):FlxImageFrame
	{
		if (graphic == null)
			return null;
		
		var checkRegion:FlxRect = region;
		
		if (checkRegion == null)
			checkRegion = FlxRect.weak(0, 0, graphic.width, graphic.height);
		
		var imageFrame:FlxImageFrame = new FlxImageFrame(graphic);
		
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
		
		imageFrame.addSpriteSheetFrame(region);
		return imageFrame;
	}
	
	/**
	 * Creates a `FlxImageFrame` object for specified region of the image.
	 * 
	 * @param   source   Image graphic for `FlxImageFrame`.
	 * @param   region   Region of the image to create the `FlxImageFrame` for.
	 * @return  Newly created `FlxImageFrame` object for specified region of image.
	 */
	public static function fromRectangle(source:FlxGraphicAsset, ?region:FlxRect):FlxImageFrame
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		return fromGraphic(graphic, region);
	}
	
	/**
	 * Gets source BitmapData, generates new BitmapData (if there is no such BitmapData in the cache already) 
	 * and creates FlxImageFrame collection.
	 * 
	 * @param   source   The source of graphic for frame collection.
	 * @param   border   Border to add around tiles (helps to avoid "tearing" problem).
	 * @param   region   Region of image to generate image frame from. Default value is `null`, which means that
	 *                   whole image will be used for it.
	 * @return  Newly created image frame collection.
	 */
	public static function fromBitmapAddSpacesAndBorders(source:FlxGraphicAsset, border:FlxPoint,
		?region:FlxRect):FlxImageFrame
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(source, false);
		if (graphic == null) return null;
		
		var key:String = FlxG.bitmap.getKeyWithSpacesAndBorders(graphic.key, null, null, border, region);
		var result:FlxGraphic = FlxG.bitmap.get(key);
		if (result == null)
		{
			var bitmap:BitmapData = FlxBitmapDataUtil.addSpacesAndBorders(graphic.bitmap, null, null, border, region);
			result = FlxG.bitmap.add(bitmap, false, key);
		}
		
		var imageFrame:FlxImageFrame = FlxImageFrame.fromGraphic(graphic);
		return imageFrame.addBorder(border);
	}
	
	/**
	 * Gets `FlxFrame` object, generates new `BitmapData` with border pixels around
	 * (if there is no such BitmapData in the cache already) and creates image frame collection.
	 * 
	 * @param   frame    Frame to generate tiles from.
	 * @param   border   Border to add around frame image (helps to avoid "tearing" problem).
	 * @return  Newly created image frame collection.
	 */
	public static function fromFrameAddSpacesAndBorders(frame:FlxFrame, border:FlxPoint):FlxImageFrame
	{
		var bitmap:BitmapData = frame.paint();
		return FlxImageFrame.fromBitmapAddSpacesAndBorders(bitmap, border);
	}
	
	override public function addBorder(border:FlxPoint):FlxImageFrame 
	{
		var resultBorder:FlxPoint = FlxPoint.weak().addPoint(this.border).addPoint(border);
		var imageFrame:FlxImageFrame = new FlxImageFrame(parent, resultBorder);
		imageFrame.pushFrame(frame.setBorderTo(border));
		return imageFrame;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		frame = FlxDestroyUtil.destroy(frame);
	}
	
	private function get_frame():FlxFrame
	{
		return frames[0];
	}
}