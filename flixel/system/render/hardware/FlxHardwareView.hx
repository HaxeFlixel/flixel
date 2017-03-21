package flixel.system.render.hardware;

import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawStack;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObjectContainer;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

#if FLX_RENDER_GL
import flixel.system.render.hardware.gl.FlxDrawHardwareCommand;
import flixel.system.render.hardware.gl.HardwareRenderer;
#end

/**
 * ...
 * @author Zaphod
 */
class FlxHardwareView extends FlxCameraView
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
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of `flashSprite`.
	 * Its position is modified by `updateScrollRect()` method, which is called on camera's resize and scale events.
	 */
	private var _scrollRect:Sprite = new Sprite();
	
	/**
	 * Sprite used for actual rendering in tile render mode (instead of `_flashBitmap` for blitting).
	 * Its graphics is used as a drawing surface for `drawTriangles()` and `drawTiles()` methods.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	#if FLX_RENDER_GL
	// TODO: implement canvas version of this class for js target...
	private var _canvas:HardwareRenderer;
	#else
	private var _canvas:Sprite;
	#end
	
	#if FLX_DEBUG
	/**
	 * Sprite for visual effects (flash and fade) and drawDebug information 
	 * (bounding boxes are drawn on it) for tile render mode.
	 * It is a child of `_scrollRect` `Sprite` (which trims graphics that should be invisible).
	 * Its position is modified by `updateInternalSpritePositions()`, which is called on camera's resize and scale events.
	 */
	public var debugLayer:Sprite;
	#end
	
	public var drawStack:FlxDrawStack;
	
	private static var _fillRect:FlxRect = FlxRect.get();
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		#if FLX_RENDER_GL
		_canvas = new HardwareRenderer(camera.width, camera.height);
		#else
		_canvas = new Sprite();
		#end
		_scrollRect.addChild(_canvas);
		
		#if FLX_DEBUG
		debugLayer = new Sprite();
		_scrollRect.addChild(debugLayer);
		#end
		
		drawStack = new FlxDrawStack(this);
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		FlxDestroyUtil.removeChild(flashSprite, _scrollRect);
		
		#if FLX_DEBUG
		FlxDestroyUtil.removeChild(_scrollRect, debugLayer);
		debugLayer = null;
		#end
		
		FlxDestroyUtil.removeChild(_scrollRect, _canvas);
		
		#if FLX_RENDER_GL
		_canvas = FlxDestroyUtil.destroy(_canvas);
		#else
		if (_canvas != null)
		{
			for (i in 0..._canvas.numChildren)
				_canvas.removeChildAt(0);
			
			_canvas = null;
		}
		#end
		
		drawStack = FlxDestroyUtil.destroy(drawStack);
		
		flashSprite = null;
		_scrollRect = null;
	}
	
	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		drawStack.drawPixels(frame, pixels, material, matrix, transform);
	}
	
	override public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, material:FlxMaterial, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform):Void
	{
		drawStack.copyPixels(frame, pixels, material, sourceRect, destPoint, transform);
	}
	
	override public function drawTriangles(material:FlxMaterial, data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		drawStack.drawTriangles(material, data, matrix, transform);
	}
	
	override public function drawUVQuad(material:FlxMaterial, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix,
		?transform:ColorTransform):Void
	{
		drawStack.drawUVQuad(material, rect, uv, matrix, transform);
	}
	
	override public function drawColorQuad(material:FlxMaterial, rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		drawStack.drawColorQuad(material, rect, matrix, color, alpha);
	}
	
	override public function updateOffset():Void 
	{
		super.updateOffset();
		
		#if FLX_RENDER_GL
		_canvas.resize(camera.width, camera.height);
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
		if (_canvas != null)
		{
			_canvas.x = -0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
			_canvas.y = -0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
			
			_canvas.scaleX = camera.totalScaleX;
			_canvas.scaleY = camera.totalScaleY;
			
			#if FLX_DEBUG
			if (debugLayer != null)
			{
				debugLayer.x = _canvas.x;
				debugLayer.y = _canvas.y;
				
				debugLayer.scaleX = _canvas.scaleX;
				debugLayer.scaleY = _canvas.scaleY;
			}
			#end
		}
	}
	
	override public function updateFilters():Void 
	{
		#if FLX_RENDER_GL
		_canvas.filters = camera.filtersEnabled ? _filters : null;
		#else
		flashSprite.filters = camera.filtersEnabled ? _filters : null;
		#end
	}
	
	override public function fill(Color:FlxColor, BlendAlpha:Bool = true, FxAlpha:Float = 1.0):Void 
	{
		#if openfl_legacy // can't skip this on next, see #1793
		if (FxAlpha == 0)
			return;
		#end
		
		// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
		// which could appear while cameras fading
		_fillRect.set( -1, -1, camera.width + 2, camera.height + 2);
		drawStack.fillRect(_fillRect, Color, FxAlpha);
	}
	
	override public function drawFX(FxColor:FlxColor, FxAlpha:Float = 1.0):Void 
	{
		var alphaComponent:Float = FxColor.alpha;
		fill(FxColor.to24Bit(), true, ((alphaComponent <= 0) ? 0xff : alphaComponent) * FxAlpha / 255);
	}
	
	override public function lock(useBufferLocking:Bool):Void 
	{
		drawStack.clearDrawStack();
		#if FLX_RENDER_GL
		_canvas.clear();
		#else
		_canvas.graphics.clear();
		#end
		
		// Clearing camera's debug sprite
		#if FLX_DEBUG
		debugLayer.graphics.clear();
		#end
		fill(camera.bgColor.to24Bit(), camera.useBgAlphaBlending, camera.bgColor.alphaFloat);
	}
	
	override public function unlock(useBufferLocking:Bool):Void 
	{
		drawStack.render();
	}
	
	override public function offsetView(X:Float, Y:Float):Void 
	{
		flashSprite.x += X;
		flashSprite.y += Y;
	}
	
	override public function beginDrawDebug():Graphics 
	{
		#if FLX_DEBUG
		return debugLayer.graphics;
		#else
		return null;
		#end
	}
	
	override private function set_color(Color:FlxColor):FlxColor 
	{
		var colorTransform:ColorTransform = _canvas.transform.colorTransform;
		colorTransform.redMultiplier = Color.redFloat;
		colorTransform.greenMultiplier = Color.greenFloat;
		colorTransform.blueMultiplier = Color.blueFloat;
		_canvas.transform.colorTransform = colorTransform;
		return Color;
	}
	
	override private function set_alpha(Alpha:Float):Float 
	{
		return _canvas.alpha = Alpha;
	}
	
	override private function set_angle(Angle:Float):Float 
	{
		if (flashSprite != null)
			flashSprite.rotation = Angle;
		
		return Angle;
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
	
	#if FLX_RENDER_GL
	public function drawItem(item:FlxDrawHardwareCommand<Dynamic>):Void
	{
		_canvas.drawItem(item);
	}
	#end
	
	override function get_canvas():DisplayObjectContainer 
	{
		return _canvas;
	}
	
}