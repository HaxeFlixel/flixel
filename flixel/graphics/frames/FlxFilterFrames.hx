package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxBitmapDataUtil;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import openfl.filters.BitmapFilter;
	
/**
 * Frames collection which you can apply bitmap filters to.
 * WARNING: this frame collection doesn't use caching, so be carefull or you will "leak" out memory very fast.
 * You should destroy frames collections of this type manually.
 */
class FlxFilterFrames extends FlxFramesCollection
{
	/**
	 * Generates new frames collection from specified frames.
	 * 
	 * @param	frames		frames collection to generate filters for.
	 * @param	widthInc	how much frames should expand horizontally.
	 * @param	heightInc	how much frames should expend vertically.
	 * @param	filters		optional filters array to apply
	 * @return	New frames collection which you can apply filters to.
	 */
	public static inline function fromFrames(frames:FlxFramesCollection, widthInc:Int = 0, heightInc:Int = 0, filters:Array<BitmapFilter> = null):FlxFilterFrames
	{
		return new FlxFilterFrames(frames, widthInc, heightInc, filters);
	}
	
	/**
	 * Original frames collection
	 */
	public var sourceFrames(default, null):FlxFramesCollection;
	
	/**
	 * How much frames should expand horizontally
	 */
	public var widthInc(default, null):Int = 0;
	
	/**
	 * How much frames should expand vertically
	 */
	public var heightInc(default, null):Int = 0;
	
	/**
	 * Filters applied to these frames
	 */
	public var filters(default, set):Array<BitmapFilter>;
	
	private function new(sourceFrames:FlxFramesCollection, widthInc:Int = 0, heightInc:Int = 0, filters:Array<BitmapFilter> = null)
	{
		super(null, FlxFrameCollectionType.FILTER);
		
		this.sourceFrames = sourceFrames;
		
		widthInc = (widthInc >= 0) ? widthInc : 0;
		heightInc = (heightInc >= 0) ? heightInc : 0;
		
		widthInc = 2 * Math.ceil(0.5 * widthInc);
		heightInc = 2 * Math.ceil(0.5 * heightInc);
		
		this.widthInc = widthInc;
		this.heightInc = heightInc;
		
		this.filters = (filters == null) ? [] : filters;
		
		genFrames();
		applyFilters();
	}
	
	/**
	 * Just helper method which "centers" sprite offsets
	 * 
	 * @param	spr					sprite to apply this frame collection.
	 * @param	saveAnimations		whether to save sprite's animations or not.
	 * @param	updateFrames		whether to regenerate frame bitmapdatas or not.
	 */
	public function applyToSprite(spr:FlxSprite, saveAnimations:Bool = false, updateFrames:Bool = false):Void
	{
		if (updateFrames)
		{
			set_filters(filters);
		}
		
		var w:Float = spr.width;
		var h:Float = spr.height;
		spr.setFrames(this, saveAnimations);
		spr.offset.set(0.5 * widthInc, 0.5 * heightInc);
		spr.setSize(w, h);
	}
	
	private function genFrames():Void
	{
		var canvas:BitmapData;
		var graph:FlxGraphic;
		var region:FlxRect;
		var filterFrame:FlxFrame;
		
		for (frame in sourceFrames.frames)
		{
			canvas = new BitmapData(Std.int(frame.sourceSize.x + widthInc), Std.int(frame.sourceSize.y + heightInc), true, FlxColor.TRANSPARENT);
			graph = FlxGraphic.fromBitmapData(canvas, false, null, false);
			
			filterFrame = graph.imageFrame.frame;
			
			frames.push(filterFrame);
			if (frame.name != null)
			{
				filterFrame.name = frame.name;
				framesHash.set(frame.name, filterFrame);
			}
		}
		
		regenBitmaps(false);
	}
	
	/**
	 * Adds a filter to this frames collection.
	 * 
	 * @param	filter		The filter to be added.
	 */
	public inline function addFilter(filter:BitmapFilter):Void
	{
		if (filter != null)
		{
			filters.push(filter);
			applyFilter(filter);
		}
	}
	
	/**
	 * Removes a filter from this frames collection.
	 * 
	 * @param	filter	The filter to be removed.
	 */
	public function removeFilter(filter:BitmapFilter):Void
	{
		if (filters.length == 0 || filter == null)
		{
			return;
		}
		
		if (filters.remove(filter))
		{
			regenAndApplyFilters();
		}
	}
	
	/**
	 * Removes all filters from the frames.
	 */
	public function clearFilters():Void
	{
		if (filters.length == 0) 
		{
			return;
		}
		
		while (filters.length != 0) 
		{
			filters.pop();
		}
		
		regenBitmaps();
	}
	
	private function regenAndApplyFilters():Void
	{
		regenBitmaps();
		applyFilters();
	}
	
	private function regenBitmaps(fill:Bool = true):Void
	{
		var numFrames:Int = frames.length;
		var frame:FlxFrame;
		var sourceFrame:FlxFrame;
		var frameOffset:Point;
		
		for (i in 0...numFrames)
		{
			sourceFrame = sourceFrames.frames[i];
			frame = frames[i];
			
			if (fill)
				frame.parent.bitmap.fillRect(frame.parent.bitmap.rect, FlxColor.TRANSPARENT);
			
			frameOffset = FlxPoint.point1;
			frameOffset.setTo(widthInc, heightInc);
			
			sourceFrame.paint(frame.parent.bitmap, frameOffset, true);
		}
	}
	
	function applyFilter(filter:BitmapFilter) 
	{
		var point:Point = FlxPoint.point1;
		var rect:Rectangle = FlxRect.rect;
		var bitmap:BitmapData;
		
		for (frame in frames)
		{
			point.setTo(0, 0);
			rect.setTo(0, 0, frame.sourceSize.x, frame.sourceSize.y);
			bitmap = frame.parent.bitmap;
			bitmap.applyFilter(bitmap, rect, point, filter);
		}
	}
	
	private function applyFilters():Void
	{
		for (filter in filters)
		{
			applyFilter(filter);
		}
	}
	
	override public function destroy():Void 
	{
		sourceFrames = null;
		filters = null;
		
		for (frame in frames)
		{
			frame.parent.destroy();
		}
		
		super.destroy();
	}
	
	private function set_filters(value:Array<BitmapFilter>):Array<BitmapFilter>
	{
		filters = value;
		
		if (value != null)
			regenAndApplyFilters();
		
		return filters;
	}
}