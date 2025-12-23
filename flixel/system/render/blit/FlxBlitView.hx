package flixel.system.render.blit;

import flixel.math.FlxRect;
import openfl.display.Bitmap;
import openfl.display.DisplayObjectContainer;
import flixel.system.render.FlxCameraView;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.util.FlxDestroyUtil;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxMatrix;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.util.FlxColor;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.Vector;
import openfl.display.Graphics;
import flixel.util.FlxSpriteUtil;

class FlxBlitView extends FlxCameraView
{
	/**
	 * Internal variable, used in blit render mode to render triangles (`drawTriangles()`) on camera's buffer.
	 */
	static var trianglesSprite:Sprite = new Sprite();
	
	/**
	 * Internal variables, used in blit render mode to draw trianglesSprite on camera's buffer.
	 * Added for less garbage creation.
	 */
	static var renderPoint:FlxPoint = FlxPoint.get();
	
	static var renderRect:FlxRect = FlxRect.get();
	
	/**
	 * Internal variable, used for visibility checks to minimize `drawTriangles()` calls.
	 */
	static var drawVertices:Vector<Float> = new Vector<Float>();
	
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
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation:
	 * Its coordinates are always `(0,0)`, where camera's buffer filling should start.
	 * Do not modify it unless you know what are you doing.
	 */
	var _flashPoint:Point = new Point();
	
	/**
	 * Internal, used to render buffer to screen space. Used it blit render mode only.
	 * This Bitmap used for rendering camera's buffer (`_flashBitmap.bitmapData = buffer;`)
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 * It is a child of the `_scrollRect` `Sprite`.
	 */
	var _flashBitmap:Bitmap;
	
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 * Used it blit render mode only (in `fill()` method).
	 */
	var _fill:BitmapData;
	
	/**
	 * Helper rect for `drawTriangles()` visibility checks
	 */
	var _bounds:FlxRect = FlxRect.get();
	
	/**
	 * Logical flag for tracking whether to apply _blitMatrix transformation to objects or not.
	 */
	var _useBlitMatrix:Bool = false;
	
	/**
	 * Helper matrix object. Used in blit render mode when camera's zoom is less than initialZoom
	 * (it is applied to all objects rendered on the camera at such circumstances).
	 */
	var _blitMatrix:FlxMatrix = new FlxMatrix();
	
	var _helperMatrix:FlxMatrix = new FlxMatrix();
	var _helperPoint:Point = new Point();
	
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
		_flashPoint = null;
		_bounds = FlxDestroyUtil.put(_bounds);
	}
	
	override function lock(?useBufferLocking:Bool)
	{
		checkResize();
		
		if (useBufferLocking)
		{
			buffer.lock();
		}
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
		screen.dirty = true;
	}
	
	override function unlock(?useBufferLocking:Bool):Void
	{
		camera.drawFX();
		
		if (useBufferLocking)
		{
			buffer.unlock();
		}
		
		screen.dirty = true;
	}
	
	override function beginDrawDebug():Void
	{
		FlxSpriteUtil.flashGfx.clear();
	}
	
	override function endDrawDebug(?matrix:FlxMatrix):Void
	{
		buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
			?shader:FlxShader):Void
	{
		_helperMatrix.copyFrom(matrix);
		
		if (_useBlitMatrix)
		{
			_helperMatrix.concat(_blitMatrix);
			buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || antialiasing));
		}
		else
		{
			_helperMatrix.translate(-viewMarginLeft, -viewMarginTop);
			buffer.draw(pixels, _helperMatrix, null, blend, null, (smoothing || antialiasing));
		}
	}
	
	override function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
			smoothing:Bool = false, ?shader:FlxShader)
	{
		if (pixels != null)
		{
			if (_useBlitMatrix)
			{
				_helperMatrix.identity();
				_helperMatrix.translate(destPoint.x, destPoint.y);
				_helperMatrix.concat(_blitMatrix);
				buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || antialiasing));
			}
			else
			{
				_helperPoint.x = destPoint.x - Std.int(viewMarginLeft);
				_helperPoint.y = destPoint.y - Std.int(viewMarginTop);
				buffer.copyPixels(pixels, sourceRect, _helperPoint, null, null, true);
			}
		}
		else if (frame != null)
		{
			// TODO: fix this case for zoom less than initial zoom...
			frame.paint(buffer, destPoint, true);
		}
	}
	
	override function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		final cameraBounds = _bounds.set(viewMarginLeft, viewMarginTop, viewWidth, viewHeight);
		
		if (position == null)
			position = renderPoint.set();
			
		var verticesLength:Int = vertices.length;
		var currentVertexPosition:Int = 0;
		
		var tempX:Float, tempY:Float;
		var i:Int = 0;
		var bounds = renderRect.set();
		drawVertices.splice(0, drawVertices.length);
		
		while (i < verticesLength)
		{
			tempX = position.x + vertices[i];
			tempY = position.y + vertices[i + 1];
			
			drawVertices[currentVertexPosition++] = tempX;
			drawVertices[currentVertexPosition++] = tempY;
			
			if (i == 0)
			{
				bounds.set(tempX, tempY, 0, 0);
			}
			else
			{
				FlxDrawTrianglesItem.inflateBounds(bounds, tempX, tempY);
			}
			
			i += 2;
		}
		
		position.putWeak();
		
		if (!cameraBounds.overlaps(bounds))
		{
			drawVertices.splice(drawVertices.length - verticesLength, verticesLength);
		}
		else
		{
			trianglesSprite.graphics.clear();
			trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, repeat, smoothing);
			trianglesSprite.graphics.drawTriangles(drawVertices, indices, uvtData);
			trianglesSprite.graphics.endFill();
			
			// TODO: check this block of code for cases, when zoom < 1 (or initial zoom?)...
			if (_useBlitMatrix)
				_helperMatrix.copyFrom(_blitMatrix);
			else
			{
				_helperMatrix.identity();
				_helperMatrix.translate(-viewMarginLeft, -viewMarginTop);
			}
			
			buffer.draw(trianglesSprite, _helperMatrix, transform);
			
			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug)
			{
				var gfx:Graphics = FlxSpriteUtil.flashGfx;
				gfx.clear();
				gfx.lineStyle(1, FlxColor.BLUE, 0.5);
				gfx.drawTriangles(drawVertices, indices);
				buffer.draw(FlxSpriteUtil.flashGfxSprite, _helperMatrix);
			}
			#end
			// End of TODO...
		}
		
		bounds.put();
	}
	
	override function fill(color:FlxColor, blendAlpha:Bool = true)
	{
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
	
	override function offsetView(x:Float, y:Float):Void
	{
		flashSprite.x += x;
		flashSprite.y += y;
	}
	
	override function updatePosition():Void
	{
		if (flashSprite != null)
		{
			flashSprite.x = camera.x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = camera.y * FlxG.scaleMode.scale.y + _flashOffset.y;
		}
	}
	
	override function updateScrollRect():Void
	{
		var rect:Rectangle = (_scrollRect != null) ? _scrollRect.scrollRect : null;
		
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
	
	override function updateScale():Void
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
		
		super.updateScale();
	}
	
	override function updateInternals():Void
	{
		if (_flashBitmap != null)
		{
			_flashBitmap.x = 0;
			_flashBitmap.y = 0;
		}
	}
	
	override function checkResize()
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
		_blitMatrix.translate(-viewMarginLeft, -viewMarginTop);
		_blitMatrix.scale(camera.scaleX, camera.scaleY);
		
		_useBlitMatrix = (camera.scaleX < camera.initialZoom) || (camera.scaleY < camera.initialZoom);
	}
	
	override function transformRect(rect:FlxRect):FlxRect
	{
		rect.offset(-viewMarginLeft, -viewMarginTop);
		
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
		point.subtract(viewMarginLeft, viewMarginTop);
		
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
	
	override function get_display():DisplayObjectContainer
	{
		return flashSprite;
	}
	
	override function set_color(color:FlxColor):FlxColor
	{
		if (_flashBitmap != null)
		{
			final colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
			
			colorTransform.redMultiplier = color.redFloat;
			colorTransform.greenMultiplier = color.greenFloat;
			colorTransform.blueMultiplier = color.blueFloat;
			
			_flashBitmap.transform.colorTransform = colorTransform;
		}
		
		return color;
	}
	
	override function set_antialiasing(antialiasing:Bool):Bool
	{
		return _flashBitmap.smoothing = antialiasing;
	}
	
	override function set_alpha(alpha:Float):Float
	{
		return _flashBitmap.alpha = alpha;
	}
	
	override function set_angle(angle:Float):Float
	{
		return flashSprite.rotation = angle;
	}
	
	override function set_visible(visible:Bool):Bool
	{
		flashSprite.visible = visible;
		return visible;
	}
}
