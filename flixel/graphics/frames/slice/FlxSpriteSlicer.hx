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
 * @since 6.1.0
 */
class FlxSpriteSlicer implements IFlxDestroyable
{
	final target:FlxSprite;
	var targetFrame(get, never):FlxFrame;
	inline function get_targetFrame() @:privateAccess return target._frame;
	
	/**
	 * The 9-slicing rect to apply to the target where the top, left, bottom and right
	 * Determine where to slice the current frame. A value of `null` means "no slicing",
	 * unless the current frame's `slice` rect is defined, then that rect is used.
	 */
	public var rect:Null<FlxRect> = null;
	
	/**
	 * Used to detect changes to `rect`
	 */
	var lastRect = new FlxRect(Math.NaN);
	var frameDirty = false;
	
	/**
	 * Internal frames used to draw each of the 9 sections
	 */
	var subframes:FlxSectionList<FlxFrame>;
	
	/**
	 * Internal rects that define where each section will be drawn
	 */
	var destRects:FlxSectionList<FlxRect>;
	
	/**
	 * How large to draw the sliced sprite, relative to the frameWidth
	 */
	public var displayWidth:Float = 0.0;
	
	/**
	 * How large to draw the sliced sprite, relative to the frameHeight
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
		lastRect = FlxDestroyUtil.put(lastRect);
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
		return (rect != null || targetFrame.slice != null) && (displayHeight > 0 && displayWidth > 0);
	}
	
	function getValidRect(rect:FlxRect)
	{
		return clipValidRect(FlxRect.getCopy(rect));
	}
	
	function clipValidRect(rect:FlxRect)
	{
		rect.left   = FlxMath.bound(rect.left  , 0, target.frameWidth );
		rect.top    = FlxMath.bound(rect.top   , 0, target.frameHeight);
		rect.right  = FlxMath.bound(rect.right , rect.left, target.frameWidth );
		rect.bottom = FlxMath.bound(rect.bottom, rect.top , target.frameHeight);
		return rect;
	}
	
	/**
	 * similar to sprite.updateHitbox() but accounts for the slicer's displaySize
	 */
	public function updateTargetHitbox()
	{
		final frameWidth = displayWidth > 0 ? displayWidth : target.frameWidth;
		final frameHeight = displayHeight > 0 ? displayHeight : target.frameHeight;
		target.width = Math.abs(target.scale.x) * frameWidth;
		target.height = Math.abs(target.scale.y) * frameHeight;
		target.offset.set(-0.5 * (target.width - frameWidth), -0.5 * (target.height - frameHeight));
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
		final sliceOrigin = FlxPoint.get(transformSourceXUnsafe(target.origin.x), transformSourceYUnsafe(target.origin.y));
		final scaledOrigin = FlxPoint.get(sliceOrigin.x * target.scale.x, sliceOrigin.y * target.scale.y);
		rect.x += sliceOrigin.x - target.offset.x - scaledOrigin.x;
		rect.y += sliceOrigin.y - target.offset.y - scaledOrigin.y;
		final frameWidth = displayWidth > 0 ? displayWidth : target.frameWidth;
		final frameHeight = displayHeight > 0 ? displayHeight : target.frameHeight;
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
		
		for (section=>frame in subframes)
		{
			if (frame.frame.width > 0 && frame.frame.height > 0)
				drawSectionComplex(frame, camera, destRects[section]);
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
	function drawSectionComplex(frame:FlxFrame, camera:FlxCamera, rect:FlxRect):Void
	{
		final matrix = globalDrawMatrix;
		final sliceOrigin = FlxPoint.get(transformSourceXUnsafe(target.origin.x), transformSourceYUnsafe(target.origin.y));
		frame.prepareMatrix(matrix, FlxFrameAngle.ANGLE_0, target.checkFlipX(), target.checkFlipY());
		if (target.clipRect != null)
			matrix.translate(-Math.max(0, target.clipRect.x), -Math.max(0, target.clipRect.y));
		matrix.scale(rect.width / frame.frame.width, rect.height / frame.frame.height);
		matrix.translate(-sliceOrigin.x, -sliceOrigin.y);
		matrix.translate(rect.x, rect.y);
		matrix.scale(target.scale.x, target.scale.y);
		
		if (target.bakedRotationAngle <= 0)
		{
			target.updateTrig();
			
			if (target.angle != 0)
				matrix.rotateWithTrig(target._cosAngle, target._sinAngle);
		}
		
		final point = target.getScreenPosition(camera).subtract(target.offset);
		point.add(sliceOrigin.x, sliceOrigin.y);
		matrix.translate(point.x, point.y);
		sliceOrigin.put();
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
			if (!rectsMatch(rect, lastRect) || frameDirty)
				updateSourceRects(rect);
		}
		else if (targetFrame.slice != null)
		{
			if (!rectsMatch(targetFrame.slice, lastRect) || frameDirty)
			{
				if (target.clipRect == null)
					updateSourceRectsFromFrame(targetFrame);
				else
					updateSourceRects(targetFrame.slice);
			}
		}
		else
		{
			lastRect.set(Math.NaN);
		}
	}
	
	function updateSourceRects(rect:FlxRect)
	{
		lastRect.copyFrom(rect);
		frameDirty = false;
		
		final srcBounds = FlxRect.get(0, 0, target.frameWidth, target.frameHeight);
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
		lastRect.copyFrom(frame.slice);
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
		final srcBounds = FlxRect.get(0, 0, target.frameWidth, target.frameHeight);
		final srcSlice = getValidRect(lastRect);
		
		if (target.clipRect != null)
		{
			srcBounds.copyFrom(target.clipRect);
			clipValidRect(srcBounds);
			clipToSmart(srcSlice, srcBounds);
		}
		
		final x =
			[ transformSourceXUnsafe(srcBounds.x)
			, transformSourceXUnsafe(srcSlice.x)
			, transformSourceXUnsafe(srcSlice.right)
			, transformSourceXUnsafe(srcBounds.right)
			];
		final y =
			[ transformSourceYUnsafe(srcBounds.y)
			, transformSourceYUnsafe(srcSlice.y)
			, transformSourceYUnsafe(srcSlice.bottom)
			, transformSourceYUnsafe(srcBounds.bottom)
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
	 * Transforms the given position from the source frame to where it will be
	 * drawn, relative to the target's position
	 * @param   x  A position on the source frame
	 */
	public function transformSourceX(x:Float)
	{
		return hasValidSlicing() ? transformSourceXUnsafe(x) : x;
	}
	
	/**
	 * Transforms the given position from the source frame to where it will be
	 * drawn, relative to the target's position
	 * @param   y  A position on the source frame
	 */
	public function transformSourceY(y:Float)
	{
		return hasValidSlicing() ? transformSourceYUnsafe(y) : y;
	}
	
	function transformSourceXUnsafe(x:Float)
	{
		if (x < lastRect.x)
			return x;
		
		if (x > lastRect.right)
			return displayWidth - target.frameWidth + x;
		
		final middleScaleX = (displayWidth - target.frameWidth + lastRect.width) / lastRect.width;
		return lastRect.x + (x - lastRect.x) * middleScaleX;
	}
	
	function transformSourceYUnsafe(y:Float)
	{
		if (y < lastRect.y)
			return y;
		
		if (y > lastRect.bottom)
			return displayHeight - target.frameHeight + y;
		
		final middleScaleY = (displayHeight - target.frameHeight + lastRect.height) / lastRect.height;
		return lastRect.y + (y - lastRect.y) * middleScaleY;
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
}