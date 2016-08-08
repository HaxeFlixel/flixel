package flixel.system.render.blit;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.FlxCameraView;
import flixel.util.FlxColor;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
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
		buffer = new BitmapData(width, height, true, 0);
		screen.pixels = buffer;
		screen.origin.set();
		_flashBitmap = new Bitmap(buffer);
		_scrollRect.addChild(_flashBitmap);
		_fill = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
	}
	
	override public function init():Void 
	{
		super.init();
		
		
	}
	
	public function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix,
		?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool = false, ?shader:FlxShader):Void
	{
		buffer.draw(pixels, matrix, null, blend, null, (smoothing || antialiasing));
	}
	
	public function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle,
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
	
	public function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>,
		uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?blend:BlendMode,
		repeat:Bool = false, smoothing:Bool = false):Void
	{
		if (position == null)
			position = renderPoint.set();
		
		_bounds.set(0, 0, width, height);
		
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
		
		if (!_bounds.overlaps(bounds))
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
				camera.buffer.draw(FlxSpriteUtil.flashGfxSprite);
			}
			#end
		}
		
		bounds.put();
	}
	
	override public function updatePosition():Void 
	{
		if (flashSprite != null)
		{
			flashSprite.x = camera.x * FlxG.scaleMode.scale.x + camera._flashOffset.x;
			flashSprite.y = camera.y * FlxG.scaleMode.scale.y + camera._flashOffset.y;
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
			var regen = camera.regen || (camera.width != buffer.width) || (camera.height != buffer.height);
			
			_flashBitmap.x = -0.5 * camera.width * (camera.scaleX - camera.initialZoom) * FlxG.scaleMode.scale.x;
			_flashBitmap.y = -0.5 * camera.height * (camera.scaleY - camera.initialZoom) * FlxG.scaleMode.scale.y;
		}
	}
	
	override public function setColor(Color:FlxColor):FlxColor 
	{
		
	}
	
	override function get_display():DisplayObject 
	{
		return flashSprite;
	}
	
}