package flixel.graphics.frames.slice;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.slice.FlxFrameSlices;
import flixel.graphics.frames.slice.FlxSliceSection;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

/**
 * Controls 9-slicing of FlxFrames, used by `FlxSliceSprite` or other
 * types that have a `FlxSpriteSlicer`
 * @since 6.1.0
 */
class FlxFrameSlices implements IFlxDestroyable
{
	/**
	 * The 9-slicing of this frame
	 */
	public var rect(get, never):Null<FlxRect>;
	function get_rect() return sections != null ? sections[CC] : null;
	
	final parent:FlxFrame;
	var sections:Null<FlxSliceSectionList<FlxRect>> = null;
	
	public function new (parent:FlxFrame)
	{
		this.parent = parent;
	}
	
	public function destroy()
	{
		clear();
	}
	
	public function copyFrom(slice:FlxFrameSlices)
	{
		clear();
		if (slice.sections != null)
			sections = [for (rect in slice.sections) rect.clone()];
	}
	
	/**
	 * Clears any frame data of this frame slice
	 */
	public function clear()
	{
		if (sections == null)
			return;
		
		for (rect in sections)
			rect.put();
		
		sections = null;
	}
	
	/**
	 * Sets the slicing data of this frame slice
	 */
	public function set(rect:FlxRect)
	{
		clear();
		sections = createSourceRects(rect, parent.frame);
	}
	
	/**
	 * Initializes the given frame to match the desired section of this slice data
	 * 
	 * @param   section  The section of the 9 slice
	 * @param   sub      The frame to initialize
	 */
	public function initSectionFrame(section:FlxSliceSection, sub:FlxFrame)
	{
		parent.subFrameTo(sections[section], sub);
	}
	
	// @:arrayAccess
	public inline function getSection(index:FlxSliceSection)
	{
		return sections[index];
	}
	
	public inline function iterator()
	{
		return sections.iterator();
	}
	
	public inline function keys()
	{
		return sections.keys();
	}
	
	public inline function keyValueIterator()
	{
		return sections.keyValueIterator();
	}
	
	static function createSourceRects(rect:FlxRect, parentRect:FlxRect)
	{
		final sections:FlxSliceSectionList<FlxRect> = [for (i in FlxSliceSection) null];
		
		final x = [0, rect.x, rect.right, parentRect.width];
		final y = [0, rect.y, rect.bottom, parentRect.height];
		rect.putWeak();
		
		for (section in FlxSliceSection)
		{
			final col = section.column;
			final row = section.row;
			
			final sectionRect = FlxRect.get();
			sectionRect.setBounds(x[col], y[row], x[col + 1], y[row + 1]);
			sections[section] = sectionRect;
		}
		return sections;
	}
}