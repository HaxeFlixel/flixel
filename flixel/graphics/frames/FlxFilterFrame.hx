package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxG;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.math.FlxAngle;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;

/**
 * Base class for all frame types
 */
class FlxFilterFrame extends FlxFrame
{	
	/**
	 * Original frame
	 */
	public var sourceFrame(default, null):FlxFrame;
	
	/**
	 * Frames collection which this frame belongs to.
	 */
	public var filterFrames(default, null):FlxFilterFrames;
	
	@:allow(flixel)
	private function new(parent:FlxGraphic, sourceFrame:FlxFrame, filterFrames:FlxFilterFrames)
	{
		super(parent);
		
		type = FlxFrameType.FILTER;
		this.sourceFrame = sourceFrame;
		this.filterFrames = filterFrames;
	}
	
	override public function paintOnBitmap(bmd:BitmapData = null):BitmapData
	{
		var result:BitmapData = null;
		
		if (bmd != null && (bmd.width == sourceSize.x && bmd.height == sourceSize.y))
		{
			result = bmd;
			var rect:Rectangle = FlxRect.rect;
			rect.setTo(0, 0, bmd.width, bmd.height);
			bmd.fillRect(rect, FlxColor.TRANSPARENT);
		}
		else if (bmd != null)
		{
			bmd.dispose();
		}
		
		if (result == null)
		{
			result = new BitmapData(Std.int(sourceSize.x), Std.int(sourceSize.y), true, FlxColor.TRANSPARENT);
		}
		
		var point:Point = FlxPoint.point;
		point.setTo(0.5 * filterFrames.widthInc, 0.5 * filterFrames.heightInc);
		
		var rect:Rectangle = FlxRect.rect;
		rect.setTo(0, 0, sourceFrame.sourceSize.x, sourceFrame.sourceSize.y);
		
		result.copyPixels(sourceFrame.getBitmap(), rect, point);
		
		// apply filters
		point.setTo(0, 0);
		rect.setTo(0, 0, sourceSize.x, sourceSize.y);
		
		for (filter in filterFrames.filters)
		{
			result.applyFilter(result, rect, point, filter);
		}
		
		return result;
	}
	
	override public function destroy():Void
	{
		sourceFrame = null;
		filterFrames = null;
		super.destroy();
	}
}