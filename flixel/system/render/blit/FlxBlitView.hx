package flixel.system.render.blit;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
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
	}
	
	function render():Void
	{
		camera.drawFX();
		
		if (FlxBlitRenderer.useBufferLocking)
		{
			buffer.unlock();
		}
		
		screen.dirty = true;
	}
	
	public function clear():Void
	{
		checkResize();
		
		if (FlxBlitRenderer.useBufferLocking)
		{
			buffer.lock();
		}
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
		screen.dirty = true;
	}
	
	@:haxe.warning("-WDeprecated")
	public function fill(color:FlxColor, blendAlpha:Bool = true)
	{
		if (blendAlpha)
		{
			_fill.fillRect(_flashRect, color);
			buffer.copyPixels(_fill, _flashRect, camera._flashPoint, null, null, blendAlpha);
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
	
	//{ region ------------------------ DEBUG DRAW ------------------------
	
	public function beginDrawDebug()
	{
		debugSprite.graphics.clear();
		return debugSprite.graphics;
	}
	
	public function getDebugGraphics()
	{
		return debugSprite.graphics;
	}
	
	public function endDrawDebug():Void
	{
		buffer.draw(debugSprite);
	}
	
	#if FLX_DEBUG
	public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		final gfx = debugSprite.graphics;
		gfx.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		gfx.drawRect(x, y, width, height);
	}
	
	public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		final gfx = debugSprite.graphics;
		gfx.lineStyle();
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.drawRect(x, y, width, height);
		gfx.endFill();
	}
	
	public function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void
	{
		final gfx = debugSprite.graphics;
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.drawCircle(x, y, radius);
		gfx.endFill();
	}
	
	public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		final gfx = debugSprite.graphics;
		gfx.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		final offset = thickness / 2;
		gfx.moveTo(x1 + offset, y1 + offset);
		gfx.lineTo(x2 + offset, y2 + offset);
	}
	#end
	
	//} endregion --------------------- DEBUG DRAW ------------------------
	
	//{ region ------------------------ HELPERS ---------------------------
	
	
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
	
	//} endregion --------------------- HELPERS ------------------------
	
	//{ region ------------------------ GETTERS ------------------------
	
	function get_display():DisplayObjectContainer
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
	
	//} endregion --------------------- GETTERS ------------------------
}
