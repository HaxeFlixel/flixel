package flixel.system.render.blit;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Zaphod
 */
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
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation.
	 * It represents the size of buffer `BitmapData`
	 * (the area of camera's buffer which should be filled with `bgColor`).
	 * Do not modify it unless you know what are you doing.
	 */
	private var _flashRect:Rectangle;
	
	/**
	 * Internal, used in blit render mode in camera's `fill()` method for less garbage creation:
	 * Its coordinates are always `(0,0)`, where camera's buffer filling should start.
	 * Do not modify it unless you know what are you doing.
	 */
	private var _flashPoint:Point = new Point();
	
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 * Used it blit render mode only (in `fill()` method).
	 */
	private var _fill:BitmapData;
	
	/**
	 * Internal, used to render buffer to screen space. Used it blit render mode only.
	 * This Bitmap used for rendering camera's buffer (`_flashBitmap.bitmapData = buffer;`)
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 * It is a child of the `_scrollRect` `Sprite`.
	 */
	private var _flashBitmap:Bitmap;
	
	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of `flashSprite`.
	 * Its position is modified by `updateScrollRect()` method, which is called on camera's resize and scale events.
	 */
	private var _scrollRect:Sprite = new Sprite();
	
	private var _buffer:BitmapData;
	
	/**
	 * Internal variable, used in blit render mode to render triangles (`drawTriangles()`) on camera's buffer.
	 */
	private static var trianglesSprite:Sprite = new Sprite();
	
	/**
	 * Helper variables for drawing UV quads.
	 */
	private static var rectVertices:Vector<Float> = new Vector<Float>();
	private static var rectUVs:Vector<Float> = new Vector<Float>();
	private static var rectIndices:Vector<Int> = new Vector<Int>();
	
	/**
	 * Whether checkResize checks if the camera dimensions have changed to update the buffer dimensions.
	 */
	private var regen:Bool = false;
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		_buffer = new BitmapData(camera.width, camera.height, true, 0);
		_flashRect = new Rectangle(0, 0, camera.width, camera.height);
		
		screen.loadGraphic(FlxGraphic.fromBitmapData(_buffer, false, null, false));
		screen.origin.set();
		_flashBitmap = new Bitmap(_buffer);
		_scrollRect.addChild(_flashBitmap);
		_fill = new BitmapData(camera.width, camera.height, true, FlxColor.TRANSPARENT);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		FlxDestroyUtil.removeChild(_scrollRect, _flashBitmap);
		
		_buffer = FlxDestroyUtil.dispose(_buffer);
		
		_flashBitmap = null;
		_fill = FlxDestroyUtil.dispose(_fill);
		
		flashSprite = null;
		_scrollRect = null;
		_flashRect = null;
		_flashPoint = null;
	}
	
	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		if (pixels != null)
		{
			_buffer.draw(pixels, matrix, transform, material.blendMode, null, (this.smoothing || material.smoothing));
		}
		else
		{
			// TODO: handle the case when pixels == null...
		}
	}
	
	override public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform):Void
	{
		if (pixels != null)
		{
			_buffer.copyPixels(pixels, sourceRect, destPoint, null, null, true);
		}
		else if (frame != null)
		{
			frame.paint(_buffer, destPoint, true);
		}
	}
	
	override public function drawTriangles(graphic:FlxGraphic, material:FlxMaterial, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		if (material == null && transform == null)
			return;
		
		trianglesSprite.graphics.clear();
		
		if (graphic != null)
		{
			trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, material.repeat, (this.smoothing || material.smoothing));
			trianglesSprite.graphics.drawTriangles(data.vertices, data.indices, data.uvs);
		}
		else
		{
			trianglesSprite.graphics.beginFill(0xffffff, 1.0);
			trianglesSprite.graphics.drawTriangles(data.vertices, data.indices);
		}
		
		trianglesSprite.graphics.endFill();
		_buffer.draw(trianglesSprite, matrix, transform, material.blendMode);
		
		drawDebugTriangles(data.vertices, data.indices, matrix);
		data.dirty = false;
	}
	
	override public function drawUVQuad(graphic:FlxGraphic, material:FlxMaterial, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		trianglesSprite.graphics.clear();
		trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, true, smoothing);
		
		rectVertices[0] = 0;
		rectVertices[1] = 0;
		rectVertices[2] = rect.width;
		rectVertices[3] = 0;
		rectVertices[4] = rect.width;
		rectVertices[5] = rect.height;
		rectVertices[6] = 0;
		rectVertices[7] = rect.height;
		
		rectUVs[0] = uv.x;
		rectUVs[1] = uv.y;
		rectUVs[2] = uv.width;
		rectUVs[3] = uv.y;
		rectUVs[4] = uv.width;
		rectUVs[5] = uv.height;
		rectUVs[6] = uv.x;
		rectUVs[7] = uv.height;
		
		rectIndices[0] = 0;
		rectIndices[1] = 1;
		rectIndices[2] = 2;
		rectIndices[3] = 2;
		rectIndices[4] = 3;
		rectIndices[5] = 0;
		
		trianglesSprite.graphics.drawTriangles(rectVertices, rectIndices, rectUVs);
		trianglesSprite.graphics.endFill();
		_buffer.draw(trianglesSprite, matrix, transform, material.blendMode);
		
		drawDebugTriangles(rectVertices, rectIndices, matrix);
	}
	
	override public function drawColorQuad(material:FlxMaterial, rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		trianglesSprite.graphics.clear();
		trianglesSprite.graphics.beginFill(color, alpha);
		
		rectVertices[0] = 0;
		rectVertices[1] = 0;
		rectVertices[2] = rect.width;
		rectVertices[3] = 0;
		rectVertices[4] = rect.width;
		rectVertices[5] = rect.height;
		rectVertices[6] = 0;
		rectVertices[7] = rect.height;
		
		rectIndices[0] = 0;
		rectIndices[1] = 1;
		rectIndices[2] = 2;
		rectIndices[3] = 2;
		rectIndices[4] = 3;
		rectIndices[5] = 0;
		
		trianglesSprite.graphics.drawTriangles(rectVertices, rectIndices);
		trianglesSprite.graphics.endFill();
		_buffer.draw(trianglesSprite, matrix, null, material.blendMode);
		
		drawDebugTriangles(rectVertices, rectIndices, matrix);
	}
	
	private function drawDebugTriangles(rectVertices:Vector<Float>, rectIndices:Vector<Int>, matrix:FlxMatrix):Void
	{
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = FlxSpriteUtil.flashGfx;
			gfx.clear();
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(rectVertices, rectIndices);
			_buffer.draw(FlxSpriteUtil.flashGfxSprite, matrix);
		}
		#end
	}
	
	override public function updatePosition():Void 
	{
		if (flashSprite != null)
		{
			flashSprite.x = camera.x * FlxG.scaleMode.scale.x + _flashOffset.x;
			flashSprite.y = camera.y * FlxG.scaleMode.scale.y + _flashOffset.y;
		}
	}
	
	override public function updateScrollRect():Void 
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
	
	override public function updateInternals():Void 
	{
		if (_flashBitmap != null && _buffer != null)
		{
			regen = regen || (camera.width != _buffer.width) || (camera.height != _buffer.height);
			
			_flashBitmap.x = -0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
			_flashBitmap.y = -0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
		}
	}
	
	override public function updateFilters():Void 
	{
		flashSprite.filters = camera.filtersEnabled ? _filters : null;
	}
	
	override public function checkResize():Void 
	{
		if (!regen)
			return;
		
		if (camera.width != _buffer.width || camera.height != _buffer.height)
		{
			var oldBuffer:FlxGraphic = screen.graphic;
			_buffer = new BitmapData(camera.width, camera.height, true, 0);
			
			screen.loadGraphic(FlxGraphic.fromBitmapData(_buffer, false, null, false));
			oldBuffer.destroy();
			screen.origin.set();
			_flashBitmap.bitmapData = _buffer;
			_flashRect.width = camera.width;
			_flashRect.height = camera.height;
			_fill = FlxDestroyUtil.dispose(_fill);
			_fill = new BitmapData(camera.width, camera.height, true, FlxColor.TRANSPARENT);
			
		}
		
		regen = false;
	}
	
	override public function updateScale():Void 
	{
		_flashBitmap.scaleX = camera.totalScaleX;
		_flashBitmap.scaleY = camera.totalScaleY;
	}
	
	override public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0):Void 
	{
		if (BlendAlpha)
		{
			_fill.fillRect(_flashRect, Color);
			_buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, BlendAlpha);
		}
		else
		{
			_buffer.fillRect(_flashRect, Color);
		}
	}
	
	override public function drawFX(FxColor:FlxColor, FxAlpha:Float = 1.0):Void 
	{
		var alphaComponent:Float = FxColor.alpha;
		fill((Std.int(((alphaComponent <= 0) ? 0xff : alphaComponent) * FxAlpha) << 24) + (FxColor & 0x00ffffff));
	}
	
	override public function lock(useBufferLocking:Bool):Void 
	{
		checkResize();
		if (useBufferLocking)
			_buffer.lock();
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
		screen.dirty = true;
	}
	
	override public function offsetView(X:Float, Y:Float):Void 
	{
		flashSprite.x += X;
		flashSprite.y += Y;
	}
	
	override private function set_color(Color:FlxColor):FlxColor 
	{
		if (_flashBitmap == null)
			return Color;
		
		var colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
		colorTransform.redMultiplier = Color.redFloat;
		colorTransform.greenMultiplier = Color.greenFloat;
		colorTransform.blueMultiplier = Color.blueFloat;
		_flashBitmap.transform.colorTransform = colorTransform;
		return Color;
	}
	
	override private function set_alpha(Alpha:Float):Float 
	{
		if (_flashBitmap == null)
			return Alpha;
		
		var colorTransform:ColorTransform = _flashBitmap.transform.colorTransform;
		colorTransform.alphaMultiplier = Alpha;
		_flashBitmap.transform.colorTransform = colorTransform;
		return Alpha;
	}
	
	override public function unlock(useBufferLocking:Bool):Void 
	{
		if (useBufferLocking)
			_buffer.unlock();
		
		screen.dirty = true;
	}
	
	override public function beginDrawDebug():Graphics 
	{
		FlxSpriteUtil.flashGfx.clear();
		return FlxSpriteUtil.flashGfx;
	}
	
	override public function endDrawDebug():Void 
	{
		_buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	override private function set_angle(Angle:Float):Float 
	{
		if (flashSprite != null)
			flashSprite.rotation = Angle;
		
		return Angle;
	}
	
	override private function set_smoothing(Smoothing:Bool):Bool 
	{
		return _flashBitmap.smoothing = Smoothing;
	}
	
	override private function set_visible(visible:Bool):Bool 
	{
		if (flashSprite != null)
			flashSprite.visible = visible;
		
		return visible;
	}
	
	override function get_display():DisplayObjectContainer 
	{
		return flashSprite;
	}
	
	override function get_buffer():BitmapData 
	{
		return _buffer;
	}
}