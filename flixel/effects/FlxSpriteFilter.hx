package flixel.effects;

import flash.display.BitmapData;
import flash.filters.BitmapFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.animation.FlxAnimationController;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.layer.Region;
import flixel.text.FlxText;
import flixel.util.loaders.CachedGraphics;
import flixel.util.loaders.TextureRegion;

/**
 * This class allows you to add sprite filters to FlxSprites
 * Create a new instance and pass it an FlxSprite then add new bitmapFilters using addFilter()
 * 
 * To refresh the filters applied to a sprite use applyFilters().
 * 
 * @author Zaphod
 */
class FlxSpriteFilter
{
	
	public static var helperRect:Rectangle = new Rectangle();
	public static var helperPoint:Point = new Point();
	
	public var sprite:FlxSprite;
	
	/**
	 * Stores a copy of pixels before any bitmap filter is applied, this is necessary for native targets where bitmap filters only show when applied 
	 * directly to pixels, so a backup is needed to clear filters when removeFilter() is called or when filters are reapplied during calcFrame().
	 */
	public var backupGraphics:CachedGraphics;
	
	public var backupRegion:Region;
	
	/**
	 * An array that contains each filter object currently associated with this sprite.
	 */
	public var filters:Array<BitmapFilter>;
	
	public var frameWidth:Int;
	public var frameHeight:Int;
	
	public var widthInc:Int = 0;
	public var heightInc:Int = 0;
	
	public var width:Int;
	public var height:Int;
	
	public var pixels:BitmapData;
	
	/**
	 * Create a new filter for a FlxSprite.
	 * 
	 * @param   Sprite           The FlxSprite to add the filter to.
	 * @param   WidthIncrease    How much to increase the graphic's width (useful for things like BlurFilter that need space outside the actual graphic).
	 * @param   HeightIncrease   How much to increase the graphic's height (useful for things like BlurFilter that need space outside the actual graphic).
	 */
	public function new(Sprite:FlxSprite, WidthIncrease:Int = 0, HeightIncrease:Int = 0) 
	{
		if (Std.is(Sprite, FlxText))
		{
			throw "FlxText objects aren't supported. Use FlxText's filter functionality";
		}
		
		sprite = Sprite;
		backupGraphics = sprite.cachedGraphics;
		backupRegion = sprite.region;
		
		filters = [];
		
		if (backupGraphics.data != null && (backupRegion.tileWidth == 0 && backupRegion.tileHeight == 0))
		{
			throw "FlxSprites with full atlas animation aren't supported";
		}
		
		var frame:Int = sprite.animation.frameIndex;
		var currAnim:String = sprite.animation.name;
		if (currAnim != null)
		{
			frame = sprite.animation.curAnim.curFrame;
		}
		
		var animator:FlxAnimationController = new FlxAnimationController(sprite);
		animator.copyFrom(sprite.animation);
		
		setClipping((sprite.frameWidth + WidthIncrease), (sprite.frameHeight + HeightIncrease));
		
		sprite.animation.destroy();
		sprite.animation = animator;
		
		if (currAnim != null)
		{
			sprite.animation.play(currAnim, true, frame);
		}
		else
		{
			sprite.animation.frameIndex = frame;
		}
	}
	
	public function destroy():Void
	{
		filters = [];
		sprite = null;
		backupGraphics = null;
		backupRegion = null;
		pixels = null;
	}
	
	/**
	 * Sets this sprite clipping width and height, the current graphic is centered
	 * at the middle.
	 * 
	 * @param	width	The new sprite width.
	 * @param	height	The new sprite height.
	 */
	private function setClipping(Width:Int, Height:Int):Void
	{
		width = Width;
		height = Height;
		
		widthInc = width - backupRegion.tileWidth;
		heightInc = height - backupRegion.tileHeight;
		
		var numRows:Int = backupRegion.numRows;
		var numCols:Int = backupRegion.numCols;
		
		var newWidth:Int = numCols * width + numCols - 1;
		var newHeight:Int = numRows * height + numRows - 1;
		
		pixels = new BitmapData(newWidth, newHeight, true, 0x0);
		regenBitmapData(false);
		
		sprite.x -= Std.int(widthInc / 2);
		sprite.y -= Std.int(heightInc / 2);
		
		var cached:CachedGraphics = FlxG.bitmap.add(pixels);
		var textureReg:TextureRegion = new TextureRegion(cached, 0, 0, width, height, 1, 1, pixels.width, pixels.height);
		sprite.loadGraphic(textureReg, sprite.frames > 1, sprite.flipped > 0, width, height);
	}
	
	private function regenBitmapData(fill:Bool = true):Void
	{
		pixels.lock();
		if (fill)
		{
			pixels.fillRect(pixels.rect, 0x0);
		}
		
		var numRows:Int = backupRegion.numRows;
		var numCols:Int = backupRegion.numCols;
		
		var frameOffsetX:Int = Std.int(widthInc / 2);
		var frameOffsetY:Int = Std.int(heightInc / 2);
		
		helperRect.width = backupRegion.tileWidth;
		helperRect.height = backupRegion.tileHeight;
	
		for (i in 0...numCols)
		{
			helperRect.x = backupRegion.startX + i * (backupRegion.tileWidth + backupRegion.spacingX);
			helperPoint.x = backupRegion.startY + i * (width + 1) + frameOffsetX;
			
			for (j in 0...numRows)
			{
				helperRect.y = j * (backupRegion.tileHeight + backupRegion.spacingY);
				helperPoint.y = j * (height + 1) + frameOffsetY;
				
				pixels.copyPixels(backupGraphics.bitmap, helperRect, helperPoint);
			}
		}
		pixels.unlock();
	}
	
	/**
	 * Adds a filter to this sprite, the sprite becomes unique and won't share its graphics with other sprites.
	 * Note that for effects like outer glow, or drop shadow, updating the sprite clipping
	 * area may be required, use widthInc or heightInc to increase the sprite area.
	 * 
	 * @param	filter		The filter to be added.
	 */
	public function addFilter(filter:BitmapFilter, regenPixels:Bool = true):Void
	{
		filters.push(filter);
		
		if (regenPixels)
		{
			applyFilters();
		}
	}
	
	/**
	 * Use this to update the sprite when filters are changed.
	 * Its also called automatically when adding a new filter.
	 */
	public function applyFilters():Void
	{
		regenBitmapData();
		helperPoint.setTo(0, 0);
		
		for (filter in filters) 
		{
			pixels.applyFilter(pixels, pixels.rect, helperPoint, filter);
		}
		
		sprite.resetFrameBitmapDatas();
		sprite.dirty = true;
	}
	
	/**
	 * Removes a filter from the sprite.
	 * 
	 * @param	filter	The filter to be removed.
	 */
	public function removeFilter(filter:BitmapFilter, regenPixels:Bool = true):Void
	{
		if (filters.length == 0 || filter == null)
		{
			return;
		}
		
		filters.remove(filter);
		
		if (regenPixels)
		{
			applyFilters();
		}
	}
	
	/**
	 * Removes all filters from the sprite, additionally you may call loadGraphic() after removing
	 * the filters to reuse cached graphics/bitmaps and stop this sprite from being unique.
	 */
	public function removeAllFilters(regenPixels:Bool = true):Void
	{
		if (filters.length == 0) 
		{
			return;
		}
		
		while (filters.length != 0) 
		{
			filters.pop();
		}
		
		if (regenPixels)
		{
			applyFilters();
		}
	}
	
}