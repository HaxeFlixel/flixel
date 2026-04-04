package flixel.graphics.frames.slice;

import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.slice.FlxFrameSlices;
import flixel.graphics.frames.slice.FlxSliceSection;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;

/**
 * Applies 9-slicing to a FlxSprite, for an example of use this, look at `FlxSliceSprite`
 * @since 6.2.0
 */
class FlxSpriteSlicer implements IFlxDestroyable
{
	final target:FlxSprite;
	
	var targetFrame(get, never):FlxFrame;
	inline function get_targetFrame() @:privateAccess return target._frame;
	
	var targetFrameWidth(get, never):Int;
	inline function get_targetFrameWidth() @:privateAccess return Std.int(target._frame.sourceSize.x);
	
	var targetFrameHeight(get, never):Int;
	inline function get_targetFrameHeight() @:privateAccess return Std.int(target._frame.sourceSize.y);
	
	/**
	 * The 9-slicing rect to apply to the target where the top, left, bottom and right
	 * Determine where to slice the current frame. A value of `null` means "no slicing",
	 * unless the current frame's `slice` rect is defined, then that rect is used.
	 */
	public var rect:Null<FlxRect> = null;
	
	/**
	 * The current, active slicing rect, used internally to detect changes to `rect`
	 */
	var currentRect = new FlxRect(Math.NaN);
	var frameDirty = false;
	
	/**
	 * Internal frames used to draw each of the 9 sections
	 */
	var subframes:FlxSliceSectionList<FlxFrame>;
	
	/**
	 * Internal rects that define where each section will be drawn
	 */
	var destRects:FlxSliceSectionList<FlxRect>;
	
	/**
	 * Whether to stretch or tile each section, only affects edges and the center
	 */
	final drawModes = new FlxSliceSectionList<FlxSliceDisplayMode>(()->STRETCH);
	
	/**
	 * How large to draw the sliced sprite
	 */
	public var displayWidth:Float = 0.0;
	
	/**
	 * How large to draw the sliced sprite
	 */
	public var displayHeight:Float = 0.0;
	
	var lastDisplayWidth:Float = 0.0;
	var lastDisplayHeight:Float = 0.0;
	
	public function new (target:FlxSprite)
	{
		this.target = target;
		target.onFrameChange.add(()->frameDirty = true); 
		subframes = [for (section in FlxSliceSection) new FlxFrame(null)];
	}
	
	public function destroy()
	{
		currentRect = FlxDestroyUtil.put(currentRect);
		FlxDestroyUtil.putArray(cast destRects);
		FlxDestroyUtil.destroyArray(cast subframes);
		destRects = null;
		subframes = null;
	}
	
	/**
	 * Whether this slicer is needed given the current slice rect and desired display size
	 */
	public function hasValidSlicing()
	{
		// The frame before the clipRect was applied, compared to targetFrame which is clipped
		final rect = target.frame.frame;
		return (rect != null || targetFrame.slice != null)
			&& displayWidth > 0 && displayHeight > 0
			&& (displayWidth != rect.width || displayHeight != rect.height);
	}
	
	public function setDisplaySize(width:Float, height:Float)
	{
		displayWidth = width;
		displayHeight = height;
	}
	
	public function setScaledDisplaySize(width:Float, height:Float)
	{
		displayWidth = width / target.scale.x;
		displayHeight = height / target.scale.y;
	}
	
	function getValidRect(rect:FlxRect)
	{
		return clipValidRect(FlxRect.getCopy(rect));
	}
	
	function clipValidRect(rect:FlxRect)
	{
		rect.left   = FlxMath.bound(rect.left  , 0, targetFrameWidth );
		rect.top    = FlxMath.bound(rect.top   , 0, targetFrameHeight);
		rect.right  = FlxMath.bound(rect.right , rect.left, targetFrameWidth );
		rect.bottom = FlxMath.bound(rect.bottom, rect.top , targetFrameHeight);
		return rect;
	}
	
	/**
	 * similar to sprite.updateHitbox() but accounts for the slicer's displaySize
	 */
	public function updateTargetHitbox()
	{
		target.width = Math.abs(target.scale.x) * displayWidth;
		target.height = Math.abs(target.scale.y) * displayHeight;
		target.offset.set(-0.5 * (target.width - displayWidth), -0.5 * (target.height - displayHeight));
		target.centerOrigin();
	}
	
	/**
	 * similar to sprite.updategetGraphicBoundsHitbox() but accounts for the slicer's displaySize
	 */
	public function getTargetGraphicBounds(?rect:FlxRect):FlxRect
	{
		if (!hasValidSlicing())
			return target.getGraphicBounds(rect);
		
		if (rect == null)
			rect = FlxRect.get();
		
		rect.set(target.x, target.y);
		if (target.pixelPerfectPosition)
			rect.floor();
		
		updateCache();
		final sliceOrigin = FlxPoint.get(frameToDisplayXUnsafe(target.origin.x), frameToDisplayYUnsafe(target.origin.y));
		final scaledOrigin = FlxPoint.get(sliceOrigin.x * target.scale.x, sliceOrigin.y * target.scale.y);
		rect.x += sliceOrigin.x - target.offset.x - scaledOrigin.x;
		rect.y += sliceOrigin.y - target.offset.y - scaledOrigin.y;
		final frameWidth = displayWidth > 0 ? displayWidth : targetFrameWidth;
		final frameHeight = displayHeight > 0 ? displayHeight : targetFrameHeight;
		rect.setSize(frameWidth * target.scale.x, frameHeight * target.scale.y);
		
		if (target.angle % 360 != 0)
			rect.getRotatedBounds(target.angle, scaledOrigin, rect);
		scaledOrigin.put();
		sliceOrigin.put();
		
		return rect;
	}
	
	/**
	 * Draws the target according to the slice rect
	 * @param   camera  The camera to which to draw
	 */
	public function drawComplex(camera:FlxCamera)
	{
		updateCache();
		
		for (section in FlxSliceSection)
		{
			drawSectionComplex(section, camera);
		}
	}
	
	/**
	 * Calls `drawFunc` with every valid section
	 * @param   drawFunc  A custom drawing function
	 */
	public function drawCustom(drawFunc:(FlxFrame, FlxRect)->Void)
	{
		updateCache();
		
		for (section=>frame in subframes)
		{
			if (frame.frame.width > 0 && frame.frame.height > 0)
				drawFunc(frame, destRects[section]);
		}
	}
	
	static final globalDrawMatrix = new FlxMatrix();
	@:access(flixel.FlxSprite)
	function drawSectionComplex(section:FlxSliceSection, camera:FlxCamera):Void
	{
		final frame = subframes[section];
		if (frame.frame.width <= 0 || frame.frame.height <= 0)
			return;
		
		final rect = destRects[section];
		final mode = drawModes[section];
		
		final matrix = globalDrawMatrix;
		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, target.checkFlipX(), target.checkFlipY());
		if (target.clipRect != null)
			matrix.translate(-Math.max(0, target.clipRect.x), -Math.max(0, target.clipRect.y));
		
		switch mode
		{
			case STRETCH:
				matrix.scale(rect.width / frame.frame.width, rect.height / frame.frame.height);
			case REPEAT:
				throw "REPEAT is not implemented, yet";
				// TODO: draw one quad with repeat enabled?
		}
		matrix.translate(-target.origin.x, -target.origin.y);
		matrix.translate(rect.x, rect.y);
		matrix.scale(target.scale.x, target.scale.y);
		
		if (target.bakedRotationAngle <= 0)
		{
			target.updateTrig();
			
			if (target.angle != 0)
				matrix.rotateWithTrig(target._cosAngle, target._sinAngle);
		}
		
		final point = target.getScreenPosition(camera).subtract(target.offset);
		point.add(target.origin.x, target.origin.y);
		matrix.translate(point.x, point.y);
		point.put();
		
		if (target.isPixelPerfectRender(camera))
		{
			matrix.tx = Math.floor(matrix.tx);
			matrix.ty = Math.floor(matrix.ty);
		}
		
		camera.drawPixels(frame, target.framePixels, matrix, target.colorTransform, target.blend, target.antialiasing, target.shader);
	}
	
	function updateCache()
	{
		checkSourceRects();
		checkDestRects();
	}
	
	function checkSourceRects()
	{
		if (rect != null)
		{
			if (rectsNotMatch(rect, currentRect) || frameDirty)
				updateSourceRects(rect);
		}
		else if (targetFrame.slice != null)
		{
			if (rectsNotMatch(targetFrame.slice, currentRect) || frameDirty)
			{
				if (target.clipRect == null)
					updateSourceRectsFromFrame(targetFrame);
				else
					updateSourceRects(targetFrame.slice);
			}
		}
		else
		{
			currentRect.set(Math.NaN);
		}
	}
	
	function updateSourceRects(rect:FlxRect)
	{
		currentRect.copyFrom(rect);
		frameDirty = false;
		
		final srcBounds = FlxRect.get(0, 0, targetFrameWidth, targetFrameHeight);
		final srcSlice = getValidRect(rect);
		if (target.clipRect != null)
		{
			srcBounds.copyFrom(target.clipRect);
			clipValidRect(srcBounds);
			clipToSmart(srcSlice, srcBounds);
		}
		
		final x = [srcBounds.x, srcSlice.x, srcSlice.right, srcBounds.right];
		final y = [srcBounds.y, srcSlice.y, srcSlice.bottom, srcBounds.bottom];
		srcBounds.put();
		srcSlice.put();
		final rectHelper = FlxRect.get();
		
		for (section in FlxSliceSection)
		{
			final col = section.column;
			final row = section.row;
			final sub = subframes[section];
			rectHelper.setBounds(x[col], y[row], x[col + 1], y[row + 1]);
			targetFrame.subFrameTo(rectHelper, sub);
			sub.offset.copyFrom(targetFrame.offset);
			sub.cacheFrameMatrix();
		}
		rectHelper.put();
		
		updateDestRects();
	}
	
	function updateSourceRectsFromFrame(frame:FlxFrame)
	{
		currentRect.copyFrom(frame.slice);
		frameDirty = false;
		frame.initSliceSections(subframes);
		updateDestRects();
	}
	
	function checkDestRects()
	{
		if (displayWidth != lastDisplayWidth || displayHeight != lastDisplayHeight)
		{
			lastDisplayWidth = displayWidth;
			lastDisplayHeight = displayHeight;
			
			if (displayWidth > 0 && displayHeight > 0)
				updateDestRects();
		}
	}
	
	function updateDestRects()
	{
		final srcBounds = FlxRect.get(0, 0, targetFrameWidth, targetFrameHeight);
		final srcSlice = getValidRect(currentRect);
		
		if (target.clipRect != null)
		{
			srcBounds.copyFrom(target.clipRect);
			clipValidRect(srcBounds);
			clipToSmart(srcSlice, srcBounds);
		}
		
		final x =
			[ frameToDisplayXUnsafe(srcBounds.x)
			, frameToDisplayXUnsafe(srcSlice.x)
			, frameToDisplayXUnsafe(srcSlice.right)
			, frameToDisplayXUnsafe(srcBounds.right)
			];
		final y =
			[ frameToDisplayYUnsafe(srcBounds.y)
			, frameToDisplayYUnsafe(srcSlice.y)
			, frameToDisplayYUnsafe(srcSlice.bottom)
			, frameToDisplayYUnsafe(srcBounds.bottom)
			];
		
		srcBounds.put();
		srcSlice.put();
		
		FlxDestroyUtil.putArray(cast destRects);
		destRects = [];
		
		for (section in FlxSliceSection)
		{
			final col = section.column;
			final row = section.row;
			
			destRects[section] = FlxRect.get().setBounds(x[col], y[row], x[col + 1], y[row + 1]);
			// destRects[section].x += section.column - 1;
			// destRects[section].y += section.row - 1;
		}
	}
	
	/**
	 * Transforms the given position from the original frame to where it will be
	 * drawn, relative to the target's position
	 * @param   x  A position on the original frame
	 */
	public function frameToDisplayX(x:Float)
	{
		return hasValidSlicing() ? frameToDisplayXUnsafe(x) : x;
	}
	
	/**
	 * Transforms the given position from the original frame to where it will be
	 * drawn, relative to the target's position
	 * @param   y  A position on the original frame
	 */
	public function frameToDisplayY(y:Float)
	{
		return hasValidSlicing() ? frameToDisplayYUnsafe(y) : y;
	}
	
	function frameToDisplayXUnsafe(x:Float)
	{
		if (x < currentRect.x)
			return x;
		
		if (x > currentRect.right)
			return displayWidth - targetFrameWidth + x;
		
		final middleScaleX = (displayWidth - targetFrameWidth + currentRect.width) / currentRect.width;
		return currentRect.x + (x - currentRect.x) * middleScaleX;
	}
	
	function frameToDisplayYUnsafe(y:Float)
	{
		if (y < currentRect.y)
			return y;
		
		if (y > currentRect.bottom)
			return displayHeight - targetFrameHeight + y;
		
		final middleScaleY = (displayHeight - targetFrameHeight + currentRect.height) / currentRect.height;
		return currentRect.y + (y - currentRect.y) * middleScaleY;
	}
	
	overload public inline extern function displayToFrame(display:FlxPoint, ?result:FlxPoint):FlxPoint
	{
		return displayToFrameHelper(display.x, display.y, result);
	}
	
	overload public inline extern function displayToFrame(displayX:Float, displayY:Float, ?result:FlxPoint):FlxPoint
	{
		return displayToFrameHelper(displayX, displayY, result);
	}
	
	function displayToFrameHelper(displayX:Float, displayY:Float, ?result:FlxPoint):FlxPoint
	{
		if (hasValidSlicing())
		{
			result.x = displayToFrameXUnsafe(displayX);
			result.y = displayToFrameYUnsafe(displayY);
		}
		else
		{
			result.x = displayX;
			result.y = displayY;
		}
		
		return result;
	}
	
	/**
	 * Transforms the given position from the stretched display to the original frame
	 * @param   x  A position on the stretched display
	 */
	public function displayToFrameX(x:Float)
	{
		return hasValidSlicing() ? displayToFrameXUnsafe(x) : x;
	}
	
	/**
	 * Transforms the given position from the stretched display to the original frame
	 * @param   y  A position on the stretched display
	 */
	public function displayToFrameY(y:Float)
	{
		return hasValidSlicing() ? displayToFrameYUnsafe(y) : y;
	}
	
	function displayToFrameXUnsafe(x:Float)
	{
		if (x < rect.x)
			return x;
		
		if (x > displayWidth - (targetFrameWidth - rect.right))
			return x - displayWidth + targetFrameWidth;
		
		final middleScaleX = (displayWidth - targetFrameWidth + rect.width) / rect.width;
		return (x - rect.x) / middleScaleX + rect.x;
	}
	
	function displayToFrameYUnsafe(y:Float)
	{
		if (y < rect.y)
			return y;
		
		if (y > displayHeight - (targetFrameHeight - rect.bottom))
			return y - displayHeight + targetFrameHeight;
		
		final middleScaleY = (displayHeight - targetFrameHeight + rect.height) / rect.height;
		return (y - rect.y) / middleScaleY + rect.y;
	}
	
	/**
	 * Similar to clipTo but the result will always be inside b, even if there is no overlap
	 * @param a The rect to clip
	 * @param b The rect to which `a` is clipped
	 */
	function clipToSmart(a:FlxRect, b:FlxRect)
	{
		if (a.left > b.right)
		{
			a.x = b.right;
			a.width = 0;
		}
		else if (a.right < b.left)
		{
			a.x = b.left;
			a.width = 0;
		}
		else
		{
			a.left = a.left < b.left ? b.left : a.left;
			a.right = a.right > b.right ? b.right : a.right;
		}
		
		if (a.top > b.bottom)
		{
			a.y = b.bottom;
			a.height = 0;
		}
		else if (a.bottom < b.top)
		{
			a.y = b.top;
			a.height = 0;
		}
		else
		{
			a.top = a.top < b.y ? b.y : a.y;
			a.bottom = a.bottom > b.bottom ? b.bottom : a.bottom;
		}
		
		return a;
	}
	
	static function rectsMatch(a:FlxRect, b:FlxRect)
	{
		return (a == null && b == null) || (a != null && b != null && a.equals(b));
	}
	
	static function rectsNotMatch(a:FlxRect, b:FlxRect)
	{
		return !rectsMatch(a, b);
	}
}

enum abstract FlxSliceDisplayMode(Int)
{
	/**
	 * The pattern will repeat to fit the destinatio
	 */
	var REPEAT;
	
	/**
	 * The pattern will stretch to fit the destinatio
	 */
	var STRETCH;
}