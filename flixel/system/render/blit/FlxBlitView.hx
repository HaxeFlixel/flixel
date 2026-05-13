package flixel.system.render.blit;

import openfl.Vector;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.quad.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.render.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

class FlxBlitView extends FlxCameraView
{
	/**
	 * Used to render buffer to screen space.
	 * NOTE: We don't recommend modifying this directly unless you are fairly experienced.
	 * Uses include 3D projection, advanced display list modification, and more.
	 * This is container for everything else that is used by camera and rendered to the camera.
	 *
	 * Its position is modified by `updateFlashSpritePosition()` which is called every frame.
	 */
	public var flashSprite:Sprite = new Sprite();
	
	/**
	 * Sometimes it's easier to just work with a `FlxSprite`, than it is to work directly with the `BitmapData` buffer.
	 * This sprite reference will allow you to do exactly that.
	 * Basically, this sprite's `pixels` property is the camera's `BitmapData` buffer.
	 *
	 * **NOTE:** This field is only used in blit render mode.
	 */
	public var screen:FlxSprite;
	
	/**
	 * The actual `BitmapData` of the camera display itself.
	 * Used in blit render mode, where you can manipulate its pixels for achieving some visual effects.
	 */
	public var buffer:BitmapData;
	
	#if FLX_DEBUG
	/**
	 * Sprite for drawDebug information
	 */
	public var debugSprite:Sprite = new Sprite();
	#end
	
	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of `flashSprite`.
	 * Its position is modified by `updateScrollRect()` method, which is called on camera's resize and scale events.
	 */
	var _scrollRect:Sprite = new Sprite();
	
	/**
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation.
	 * It represents the size of buffer `BitmapData`
	 * (the area of camera's buffer which should be filled with `bgColor`).
	 * Do not modify it unless you know what are you doing.
	 */
	var _flashRect:Rectangle;
	
	/**
	 * Internal, used to render buffer to screen space. Used it blit render mode only.
	 * This Bitmap used for rendering camera's buffer (`_flashBitmap.bitmapData = buffer;`)
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 * It is a child of the `_scrollRect` `Sprite`.
	 */
	var _flashBitmap:Bitmap;
	
	/**
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation:
	 * Its coordinates are always `(0,0)`, where camera's buffer filling should start.
	 * Do not modify it unless you know what are you doing.
	 */
	var _flashPoint:Point = new Point();
	
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 * Used it blit render mode only (in `fill()` method).
	 */
	var _fill:BitmapData;
	
	/**
	 * Logical flag for tracking whether to apply _blitMatrix transformation to objects or not.
	 */
	var _useBlitMatrix:Bool = false;
	
	/**
	 * Helper matrix object. Used in blit render mode when camera's zoom is less than initialZoom
	 * (it is applied to all objects rendered on the camera at such circumstances).
	 */
	var _blitMatrix:FlxMatrix = new FlxMatrix();
	
	var _flashOffset:FlxPoint = FlxPoint.get();
	
	var _renderer(get, never):FlxBlitRenderer;
	inline function get__renderer() return cast (FlxG.renderer, FlxBlitRenderer);
	
	@:allow(flixel.system.render.FlxCameraView)
	function new(camera:FlxCamera)
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		_flashRect = new Rectangle(0, 0, camera.width, camera.height);
		
		screen = new FlxSprite();
		buffer = new BitmapData(camera.width, camera.height, true, 0);
		screen.pixels = buffer;
		screen.origin.zero();
		_flashBitmap = new Bitmap(buffer);
		_scrollRect.addChild(_flashBitmap);
		_fill = new BitmapData(camera.width, camera.height, true, FlxColor.TRANSPARENT);
	}
	
	override function destroy():Void
	{
		super.destroy();
		
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		FlxDestroyUtil.removeChild(_scrollRect, _flashBitmap);
		screen = FlxDestroyUtil.destroy(screen);
		buffer = null;
		_flashBitmap = null;
		_fill = FlxDestroyUtil.dispose(_fill);
		flashSprite = null;
		_scrollRect = null;
		_flashRect = null;
		_flashOffset = FlxDestroyUtil.put(_flashOffset);
	}
	
	// =============================================================================
	//{ region                             RENDERING
	// =============================================================================
	
	override function render()
	{
		// super.render();
		
		camera.drawFX();
		
		if (_renderer.useBufferLocking)
		{
			buffer.unlock();
		}
		
		screen.dirty = true;
	}
	
	override function clear()
	{
		// super.clear();
		
		checkResize();
		
		if (_renderer.useBufferLocking)
		{
			buffer.lock();
		}
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
		screen.dirty = true;
	}
	
	@:haxe.warning("-WDeprecated")
	override function fill(color:FlxColor, blendAlpha:Bool = true)
	{
		// super.fill(color, blendAlpha);
		
		if (blendAlpha)
		{
			_fill.fillRect(_flashRect, color);
			buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, blendAlpha);
		}
		else
		{
			buffer.fillRect(_flashRect, color);
		}
	}
	
	@:noCompletion
	static final _helperMatrix = new FlxMatrix();
	override function drawPixels(pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		// super.drawPixels(pixels, matrix, transform, blend, smoothing, shader);
		
		_helperMatrix.copyFrom(matrix);
		
		if (_useBlitMatrix)
		{
			_helperMatrix.concat(_blitMatrix);
			buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || antialiasing));
		}
		else
		{
			_helperMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
			buffer.draw(pixels, _helperMatrix, null, blend, null, (smoothing || antialiasing));
		}
	}
	
	@:noCompletion
	static final _helperPoint:Point = new Point();
	override function copyPixels(pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader)
	{
		// super.copyPixels(pixels, sourceRect, destPoint, transform, blend, smoothing);
		
		if (_useBlitMatrix)
		{
			_helperMatrix.identity();
			_helperMatrix.translate(destPoint.x, destPoint.y);
			_helperMatrix.concat(_blitMatrix);
			buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || antialiasing));
		}
		else
		{
			_helperPoint.x = destPoint.x - Std.int(camera.viewMarginLeft);
			_helperPoint.y = destPoint.y - Std.int(camera.viewMarginTop);
			buffer.copyPixels(pixels, sourceRect, _helperPoint, null, null, true);
		}
	}
	
	override function drawFrame(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		throw "Not Implemented on blit";
	}
	
	override function copyFrame(frame:FlxFrame, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, smoothing = false, ?shader:FlxShader)
	{
		// TODO: fix this case for zoom less than initial zoom...
		frame.paint(buffer, destPoint, true);
	}
	
	@:noCompletion
	static final _trianglesSprite = new Sprite();
	
	@:noCompletion
	static final drawVertices = new FlxVector2d<Float>();
	override function drawTriangles(graphic:FlxGraphic, vertices:FlxVector2d<Float>, indices:Vector<Int>, uvtData:FlxVector2d<Float>, ?colors:Vector<Int>,
			?position, ?blend, repeat = false, smoothing = false, ?transform, ?shader)
	{
		// super.drawTriangles(graphic, vertices, indices, uvtData, colors, position, blend, repeat, smoothing, transform, shader);
		
		final cameraBounds = FlxRect.weak(camera.viewMarginLeft, camera.viewMarginTop, camera.viewWidth, camera.viewHeight);
		
		if (position == null)
			position = FlxPoint.weak();
		
		final bounds = FlxRect.get();
		drawVertices.clear();
		
		for (i in 0...vertices.length)
		{
			final tempX = position.x + vertices.getX(i);
			final tempY = position.y + vertices.getY(i);
			
			drawVertices.push(tempX, tempY);
			
			if (i == 0)
			{
				bounds.set(tempX, tempY, 0, 0);
			}
			else
			{
				FlxDrawTrianglesItem.inflateBounds(bounds, tempX, tempY);
			}
		}
		
		position.putWeak();
		
		final overlaps = cameraBounds.overlaps(bounds);
		bounds.put();
		
		if (!overlaps)
		{
			drawVertices.clear();
			return;
		}
		
		_trianglesSprite.graphics.clear();
		_trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, repeat, smoothing);
		_trianglesSprite.graphics.drawTriangles(drawVertices, indices, uvtData);
		_trianglesSprite.graphics.endFill();
		
		// TODO: check this block of code for cases, when zoom < 1 (or initial zoom?)...
		if (_useBlitMatrix)
			_helperMatrix.copyFrom(_blitMatrix);
		else
		{
			_helperMatrix.identity();
			_helperMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
		}
		
		buffer.draw(_trianglesSprite, _helperMatrix, transform);
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			// TODO: add a drawDebugTriangles method
			var gfx:Graphics = FlxSpriteUtil.flashGfx;
			gfx.clear();
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(drawVertices, indices);
			buffer.draw(FlxSpriteUtil.flashGfxSprite, _helperMatrix);
		}
		#end
		// End of TODO...
	}
	
	// =============================================================================
	//} endregion                          RENDERING
	// =============================================================================
	
	// =============================================================================
	//{ region                             INTERNALS
	// =============================================================================
	
	function offsetView(x:Float, y:Float)
	{
		flashSprite.x += x;
		flashSprite.y += y;
	}
	
	function updatePosition()
	{
		if (flashSprite != null)
		{
			flashSprite.x = camera.x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = camera.y * FlxG.scaleMode.scale.y + _flashOffset.y;
		}
	}
	
	function updateOffset()
	{
		_flashOffset.x = camera.width * 0.5 * FlxG.scaleMode.scale.x * camera.initialZoom;
		_flashOffset.y = camera.height * 0.5 * FlxG.scaleMode.scale.y * camera.initialZoom;
	}
	
	function updateScrollRect()
	{
		final rect:Rectangle = (_scrollRect != null) ? _scrollRect.scrollRect : null;
		
		if (rect != null)
		{
			rect.x = rect.y = 0;
			
			rect.width = camera.width * camera.initialZoom * FlxG.scaleMode.scale.x;
			rect.height = camera.height * camera.initialZoom * FlxG.scaleMode.scale.y;
			
			_scrollRect.scrollRect = rect;
			
			_scrollRect.x = -0.5 * rect.width;
			_scrollRect.y = -0.5 * rect.height;
		}
	}
	
	function updateScale()
	{
		updateBlitMatrix();
		
		if (_useBlitMatrix)
		{
			_flashBitmap.scaleX = camera.initialZoom * FlxG.scaleMode.scale.x;
			_flashBitmap.scaleY = camera.initialZoom * FlxG.scaleMode.scale.y;
		}
		else
		{
			_flashBitmap.scaleX = camera.totalScaleX;
			_flashBitmap.scaleY = camera.totalScaleY;
		}
	}
	
	function updateInternals()
	{
		if (_flashBitmap != null)
		{
			_flashBitmap.x = 0;
			_flashBitmap.y = 0;
		}
	}
	
	// =============================================================================
	//} endregion                          INTERNALS
	// =============================================================================
	
	// =============================================================================
	//{ region                            DEBUG DRAW
	// =============================================================================
	
	function beginDrawDebug()
	{
		#if FLX_DEBUG
		debugSprite.graphics.clear();
		#end
	}
	
	function endDrawDebug():Void
	{
		#if FLX_DEBUG
		buffer.draw(debugSprite);
		#end
	}
	
	#if FLX_DEBUG
	
	function getDebugBuffer():FlxCanvas
	{
		return debugSprite.graphics;
	}
	
	static final toDebugHelper = new openfl.geom.Point();
	function worldToDebugX(worldX:Float)//TODO: rename
	{
		toDebugHelper.setTo(worldX, 0);
		return _flashBitmap.localToGlobal(toDebugHelper).x;
	}
	
	function worldToDebugY(worldY:Float)//TODO: rename
	{
		toDebugHelper.setTo(0, worldY);
		return _flashBitmap.localToGlobal(toDebugHelper).y;
	}
	#end
	
	//} endregion                         DEBUG DRAW
	// =============================================================================
	
	// =============================================================================
	//{ region                             HELPERS
	// =============================================================================
	
	function checkResize():Void
	{
		if (camera.width != buffer.width || camera.height != buffer.height)
		{
			var oldBuffer:FlxGraphic = screen.graphic;
			buffer = new BitmapData(camera.width, camera.height, true, 0);
			screen.pixels = buffer;
			screen.origin.zero();
			_flashBitmap.bitmapData = buffer;
			_flashRect.width = camera.width;
			_flashRect.height = camera.height;
			_fill = FlxDestroyUtil.dispose(_fill);
			_fill = new BitmapData(camera.width, camera.height, true, FlxColor.TRANSPARENT);
			FlxG.bitmap.removeIfNoUse(oldBuffer);
		}
		
		updateBlitMatrix();
	}
	
	inline function updateBlitMatrix():Void
	{
		_blitMatrix.identity();
		_blitMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
		_blitMatrix.scale(camera.scaleX, camera.scaleY);
		
		_useBlitMatrix = (camera.scaleX < camera.initialZoom) || (camera.scaleY < camera.initialZoom);
	}
	
	override function transformRect(rect:FlxRect):FlxRect
	{
		rect.offset(-camera.viewMarginLeft, -camera.viewMarginTop);
		
		if (_useBlitMatrix)
		{
			rect.x *= camera.zoom;
			rect.y *= camera.zoom;
			rect.width *= camera.zoom;
			rect.height *= camera.zoom;
		}
		
		return rect;
	}
	
	override function transformPoint(point:FlxPoint):FlxPoint
	{
		point.subtract(camera.viewMarginLeft, camera.viewMarginTop);
		
		if (_useBlitMatrix)
			point.scale(camera.zoom);
			
		return point;
	}
	
	override function transformVector(vector:FlxPoint):FlxPoint
	{
		if (_useBlitMatrix)
			vector.scale(camera.zoom);
			
		return vector;
	}
	
	//} endregion                          HELPERS
	// =============================================================================
	
	// =============================================================================
	//{ region                             GETTERS
	// =============================================================================
	
	override function set_color(value:FlxColor):FlxColor
	{
		if (_flashBitmap != null)
		{
			final colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
			
			colorTransform.redMultiplier = value.redFloat;
			colorTransform.greenMultiplier = value.greenFloat;
			colorTransform.blueMultiplier = value.blueFloat;
			
			_flashBitmap.transform.colorTransform = colorTransform;
		}
		
		return super.set_color(value);
	}
	
	override function set_antialiasing(value:Bool):Bool
	{
		_flashBitmap.smoothing = value;
		return super.set_antialiasing(value);
	}
	
	override function set_alpha(value:Float):Float
	{
		_flashBitmap.alpha = value;
		return super.set_alpha(value);
	}
	
	override function set_angle(value:Float):Float
	{
		flashSprite.rotation = value;
		return super.set_angle(value);
	}
	
	override function set_visible(value:Bool):Bool
	{
		flashSprite.visible = value;
		return super.set_visible(value);
	}
	
	//} endregion                          GETTERS
	// =============================================================================
}
