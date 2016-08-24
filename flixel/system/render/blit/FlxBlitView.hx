package flixel.system.render.blit;

import flixel.FlxCamera;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxGeom;
import flixel.util.FlxSpriteUtil;
import openfl.Vector;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.filters.BitmapFilter;
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
	 * Used to render buffer to screen space. NOTE: We don't recommend modifying this directly unless you are fairly experienced. 
	 * Uses include 3D projection, advanced display list modification, and more.
	 * This is container for everything else that is used by camera and rendered to the camera.
	 * 
	 * Its position is modified by updateFlashSpritePosition() method which is called every frame.
	 */
	public var flashSprite:Sprite = new Sprite();
	
	/**
	 * The actual bitmap data of the camera display itself. 
	 * Used in blit render mode, where you can manipulate its pixels for achieving some visual effects.
	 */
	public var buffer:BitmapData;
	
	/**
	 * Sometimes it's easier to just work with a FlxSprite than it is to work directly with the BitmapData buffer. 
	 * This sprite reference will allow you to do exactly that.
	 * Basically this sprite's `pixels` property is camera's BitmapData buffer.
	 * NOTE: This varible is used only in blit render mode.
	 * 
	 * FlxBloom demo shows how you can use this variable in blit render mode:
	 * @see http://haxeflixel.com/demos/FlxBloom/
	 */
	public var screen:FlxSprite;
	
	/**
	 * Internal, used in blit render mode in camera's fill() method for less garbage creation.
	 * It represents the size of buffer BitmapData (the area of camera's buffer which should be filled with bgColor).
	 * Do not modify it unless you know what are you doing.
	 */
	private var _flashRect:Rectangle;
	
	/**
	 * Internal, used in blit render mode in camera's fill() method for less garbage creation:
	 * Its coordinates are always (0, 0), where camera's buffer filling should start.
	 * Do not modify it unless you know what are you doing.
	 */
	private var _flashPoint:Point = new Point();
	
	/**
	 * Internal helper variable for doing better wipes/fills between renders.
	 * Used it blit render mode only (in fill() method).
	 */
	private var _fill:BitmapData;
	
	/**
	 * Internal, used to render buffer to screen space. Used it blit render mode only.
	 * This Bitmap used for rendering camera's buffer (_flashBitmap.bitmapData = buffer;)
	 * Its position is modified by updateInternalSpritePositions() method, which is called on camera's resize and scale events.
	 * It is a child of _scrollRect Sprite.
	 */
	private var _flashBitmap:Bitmap;
	
	/**
	 * Internal sprite, used for correct trimming of camera viewport.
	 * It is a child of flashSprite.
	 * Its position is modified by updateScrollRect() method, which is called on camera's resize and scale events.
	 */
	private var _scrollRect:Sprite = new Sprite();
	
	/**
	 * Internal variable, used in blit render mode to render triangles (drawTriangles) on camera's buffer.
	 */
	private static var trianglesSprite:Sprite = new Sprite();
	
	// TODO: try to avoid using this variable.
	// need to move functionality related to this var into FlxStrip
	/**
	 * Internal variable, used for visibility checks to minimize drawTriangles() calls.
	 */
	private static var drawVertices:Vector<Float> = new Vector<Float>();
	
	/**
	 * Whether checkResize checks if the camera dimensions have changed to update the buffer dimensions.
	 */
	private var regen:Bool = false;
	
	/**
	 * Internal variables, used in blit render mode to draw trianglesSprite on camera's buffer. 
	 * Added for less garbage creation.
	 */
	private static var renderPoint:FlxPoint = FlxPoint.get();
	private static var renderRect:FlxRect = FlxRect.get();
	
	public function new(camera:FlxCamera) 
	{
		super(camera);
		
		flashSprite.addChild(_scrollRect);
		_scrollRect.scrollRect = new Rectangle();
		
		screen = new FlxSprite();
		buffer = new BitmapData(camera.width, camera.height, true, 0);
		_flashRect = new Rectangle(0, 0, camera.width, camera.height);
		screen.pixels = buffer;
		screen.origin.set();
		_flashBitmap = new Bitmap(buffer);
		_scrollRect.addChild(_flashBitmap);
		_fill = new BitmapData(camera.width, camera.height, true, FlxColor.TRANSPARENT);
	}
	
	override public function destroy():Void 
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
	}
	
	override public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		buffer.draw(pixels, matrix, null, blend, null, (smoothing || antialiasing));
	}
	
	override public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
		destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		if (pixels != null)
		{
			buffer.copyPixels(pixels, sourceRect, destPoint, null, null, true);
		}
		else if (frame != null)
		{
			frame.paint(buffer, destPoint, true);
		}
	}
	
	override public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>,
		uvtData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, 
		repeat:Bool = false, smoothing:Bool = false):Void 
	{
		// TODO: fix this...
		/*
		if (position == null)
			position = renderPoint.set();
		
		var viewBounds:FlxRect = this.bounds;
		
		var verticesLength:Int = vertices.length;
		var currentVertexPosition:Int = 0;
		
		var tempX:Float, tempY:Float;
		var i:Int = 0;
		var triBounds = renderRect.set();
		
		drawVertices.splice(0, drawVertices.length);
		
		while (i < verticesLength)
		{
			tempX = position.x + vertices[i]; 
			tempY = position.y + vertices[i + 1];
			
			drawVertices[currentVertexPosition++] = tempX;
			drawVertices[currentVertexPosition++] = tempY;
			
			if (i == 0)
			{
				triBounds.set(tempX, tempY, 0, 0);
			}
			else
			{
				FlxGeom.inflateBounds(triBounds, tempX, tempY);
			}
			
			i += 2;
		}
		
		position.putWeak();
		
		if (!viewBounds.overlaps(triBounds))
		{
			drawVertices.splice(drawVertices.length - verticesLength, verticesLength);
		}
		else
		{
			trianglesSprite.graphics.clear();
			trianglesSprite.graphics.beginBitmapFill(graphic.bitmap, null, repeat, smoothing);
			trianglesSprite.graphics.drawTriangles(drawVertices, indices, uvtData);
			trianglesSprite.graphics.endFill();
			buffer.draw(trianglesSprite);
			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug)
			{
				var gfx:Graphics = FlxSpriteUtil.flashGfx;
				gfx.clear();
				gfx.lineStyle(1, FlxColor.BLUE, 0.5);
				gfx.drawTriangles(drawVertices, indices);
				buffer.draw(FlxSpriteUtil.flashGfxSprite);
			}
			#end
		}
		
		triBounds.put();
		*/
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
		if (_flashBitmap != null)
		{
			regen = regen || (camera.width != buffer.width) || (camera.height != buffer.height);
			
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
		
		if (camera.width != buffer.width || camera.height != buffer.height)
		{
			var oldBuffer:FlxGraphic = screen.graphic;
			buffer = new BitmapData(camera.width, camera.height, true, 0);
			screen.pixels = buffer;
			screen.origin.set();
			_flashBitmap.bitmapData = buffer;
			_flashRect.width = camera.width;
			_flashRect.height = camera.height;
			_fill = FlxDestroyUtil.dispose(_fill);
			_fill = new BitmapData(camera.width, camera.height, true, FlxColor.TRANSPARENT);
			FlxG.bitmap.removeIfNoUse(oldBuffer);
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
			buffer.copyPixels(_fill, _flashRect, _flashPoint, null, null, BlendAlpha);
		}
		else
		{
			buffer.fillRect(_flashRect, Color);
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
		{
			buffer.lock();
		}
		
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
		{
			buffer.unlock();
		}
		
		screen.dirty = true;
	}
	
	override public function beginDrawDebug():Graphics 
	{
		FlxSpriteUtil.flashGfx.clear();
		return FlxSpriteUtil.flashGfx;
	}
	
	override public function endDrawDebug():Void 
	{
		buffer.draw(FlxSpriteUtil.flashGfxSprite);
	}
	
	override private function set_angle(Angle:Float):Float 
	{
		if (flashSprite != null)
		{
			flashSprite.rotation = Angle;
		}
		
		return Angle;
	}
	
	override public function set_antialiasing(Antialiasing:Bool):Bool 
	{
		return _flashBitmap.smoothing = Antialiasing;
	}
	
	override private function set_visible(visible:Bool):Bool 
	{
		if (flashSprite != null)
		{
			flashSprite.visible = visible;
		}
		
		return visible;
	}
	
	override function get_display():DisplayObject 
	{
		return flashSprite;
	}
	
}