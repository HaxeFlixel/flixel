package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.layer.TileSheetExt;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import openfl.filters.BitmapFilter;

/**
 * Single-frame filter collection.
 * Could be useful for non-animated sprites.
 */
class FilterFrame extends FlxFramesCollection
{
	/**
	 * Single frame of this frame collection.
	 * Added this var for faster access, so you don't need to type something like: filterFrame.frames[0]
	 */
	public var frame:FlxFrame;
	
	public var sourceFrame:FlxFrame;
	
	public var widthInc:Int = 0;
	
	public var heightInc:Int = 0;
	
	private function new(parent:FlxGraphic)
	{
		super(parent, FrameCollectionType.FILTER);
	}
	
	/**
	 * Generates FilterFrame object for specified FlxFrame.
	 * 
	 * @param	source	FlxFrame to generate ImageFrame from.
	 * @return	Created FilterFrame object.
	 */
	public static function fromFrame(source:FlxFrame, filters:Array<BitmapFilter>, widthInc:Int, heightInc:Int):FilterFrame
	{
		var sourceBitmap:BitmapData = source.getBitmap();
		var filterBitmap:BitmapData = new BitmapData(sourceBitmap.width + widthInc, sourceBitmap.height + heightInc, true, FlxColor.TRANSPARENT);
		filterBitmap = applyFilters(filterBitmap, sourceBitmap, filters, Std.int(widthInc / 2), Std.int(heightInc / 2));
		var graphic:FlxGraphic = FlxGraphic.createNonCached(filterBitmap);
		var rect:FlxRect = new FlxRect(0, 0, graphic.width, graphic.height);
		var filterFrame:FilterFrame = new FilterFrame(graphic);
		filterFrame.sourceFrame = source;
		filterFrame.frame = filterFrame.addSpriteSheetFrame(rect);
		filterFrame.widthInc;
		filterFrame.heightInc;
		return filterFrame;
	}
	
	// TODO: document it...
	/**
	 * 
	 * 
	 * @param	canvas
	 * @param	source
	 * @param	filters
	 * @param	offsetX
	 * @param	offsetY
	 * @return
	 */
	private static function applyFilters(canvas:BitmapData, source:BitmapData, filters:Array<BitmapFilter>, offsetX:Int = 0, offsetY:Int = 0):BitmapData
	{
		var rect:Rectangle = FlxRect.RECT;
		rect.setTo(0, 0, canvas.width, canvas.height);
		var point:Point = FlxPoint.POINT;
		point.setTo(offsetX, offsetY);
		
		canvas.fillRect(rect, FlxColor.TRANSPARENT);
		canvas.copyPixels(source, rect, point);
		
		point.setTo(0, 0);
		
		for (filter in filters)
		{
			canvas.applyFilter(canvas, rect, point, filter);
		}
		
		return canvas;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		frame = FlxDestroyUtil.destroy(frame);
		sourceFrame = null;
	}
}