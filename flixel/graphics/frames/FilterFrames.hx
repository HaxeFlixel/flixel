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
 * Frames collection which you can apply bitmap filters to.
 * WARNING: this frame collection doesn't use caching, so be carefull or you will "leak" out memory very fast.
 * You should destroy frames collections of this type manually.
 */
class FilterFrames extends FlxFramesCollection
{
	/**
	 * Generates new frames collection from specified frames.
	 * 
	 * @param	frames		frames collection to generate filters for.
	 * @param	widthInc	how much frames should expand horizontally.
	 * @param	heightInc	how much frames should expend vertically.
	 * @return	New frames collection which you can apply filters to.
	 */
	public static function fromFrames(frames:FlxFramesCollection, widthInc:Int = 0, heightInc:Int = 0):FilterFrames
	{
		return new FilterFrames(frames, widthInc, heightInc);
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
	
	private function new(sourceFrames:FlxFramesCollection, widthInc:Int = 0, heightInc:Int = 0)
	{
		super(null, FrameCollectionType.FILTER);
		
		this.sourceFrames = sourceFrames;
		
		widthInc = (widthInc >= 0) ? widthInc : 0;
		heightInc = (heightInc >= 0) ? heightInc : 0;
		
		widthInc = 2 * Math.ceil(0.5 * widthInc);
		heightInc = 2 * Math.ceil(0.5 * heightInc);
		
		this.widthInc = widthInc;
		this.heightInc = heightInc;
		
		filters = [];
		
		genFrames();
	}
	
	private function genFrames():Void
	{
		for (frame in sourceFrames.frames)
		{
			var canvas:BitmapData = new BitmapData(Std.int(frame.sourceSize.x + widthInc), Std.int(frame.sourceSize.y + heightInc), true, FlxColor.TRANSPARENT);
			var graph:FlxGraphic = FlxGraphic.createNonCached(canvas);
			var region:FlxRect = new FlxRect(0, 0, graph.width, graph.height);
			
			var filterFrame:FlxFilterFrame = new FlxFilterFrame(graph, frame, this);
			
			filterFrame.frame = region;
			filterFrame.sourceSize.set(region.width, region.height);
			filterFrame.offset.set(0, 0);
			filterFrame.center.set(0.5 * region.width, 0.5 * region.height);
			filterFrame.angle = 0;
			
			filterFrame.paintOnBitmap(filterFrame.parent.bitmap);
			
			#if FLX_RENDER_TILE
			var flashRect:Rectangle = region.copyToFlash(new Rectangle());
			filterFrame.tileID = graph.tilesheet.addTileRect(flashRect, new Point(0.5 * region.width, 0.5 * region.height));
			#end
			
			frames.push(filterFrame);
			if (frame.name != null)
			{
				filterFrame.name = frame.name;
				framesHash.set(frame.name, filterFrame);
			}
		}
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
			destroyBitmaps();
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
			destroyBitmaps();
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
		
		destroyBitmaps();
	}
	
	override public function destroyBitmaps():Void
	{
		for (frame in frames)
		{
			frame.destroyBitmaps();
			frame.paintOnBitmap(frame.parent.bitmap);
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
		destroyBitmaps();
		return filters = value;
	}
}