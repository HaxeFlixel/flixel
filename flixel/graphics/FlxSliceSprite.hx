package flixel.graphics;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.slice.FlxSpriteSlicer;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

/**
 * A `FlxSprite` with a 9-slice scaling. The `sliceRect` determines how to divide the 9 sections,
 * and `displayWidth` and `displayHeight` determine how much the frame is stretched when drawn.
 * If `sliceRect` is null, and the curret frame's `slice` is non-null, that slice rect is used
 * 
 * **Note:** All of the slicing functionality is done via `FlxSpriteSlicer`, making it easy to
 * add to any other class that extends FlxSprite
 * 
 * @since 6.1.0
 */
class FlxSliceSprite extends flixel.FlxSprite
{
	/**
	 * Controls the slicing of this sprite, `null` means no slicing
	 */
	public var sliceRect(get, set):Null<FlxRect>;
	inline function get_sliceRect() { return slicer.rect; }
	inline function set_sliceRect(value) { return slicer.rect = value; }
	
	/**
	 * How large to draw the sliced sprite, relative to the `frameWidth`.
	 * If the value is `0` or less, the frameWidth is used
	 */
	public var displayWidth(get, set):Float;
	inline function get_displayWidth() { return slicer.displayWidth; }
	inline function set_displayWidth(value) { return slicer.displayWidth = value; }
	
	/**
	 * How large to draw the sliced sprite, relative to the `frameHeight`
	 * If the value is `0` or less, the frameWidth is used
	 */
	public var displayHeight(get, set):Float;
	inline function get_displayHeight() { return slicer.displayHeight; }
	inline function set_displayHeight(value) { return slicer.displayHeight = value; }
	
	/**
	 * The sprite's 9-slicing data
	 */
	var slicer(default, null):FlxSpriteSlicer;
	
	override function initVars():Void
	{
		super.initVars();
		
		slicer = new FlxSpriteSlicer(this);
	}
	
	override function destroy():Void
	{
		super.destroy();
		
		slicer = FlxDestroyUtil.destroy(slicer);
	}
	
	override function updateHitbox()
	{
		return slicer.hasValidSlicing() ? slicer.updateTargetHitbox() : super.updateHitbox();
	}
	
	override function getGraphicBounds(?rect:FlxRect):FlxRect
	{
		return slicer.hasValidSlicing() ? slicer.getTargetGraphicBounds(rect) : super.getGraphicBounds(rect);
	}
	
	override function drawComplex(camera:FlxCamera):Void
	{
		if (slicer.hasValidSlicing())
			slicer.drawComplex(camera);
		else
			super.drawComplex(camera);
	}
}