package flixel.system.render.blit;

import flixel.graphics.tile.FlxDrawTrianglesItem;
import openfl.display.Graphics;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.Vector;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;

@:access(flixel.FlxCamera)
@:access(flixel.system.render.blit)
class FlxBlitRenderer extends FlxRenderer
{
    /**
	 * Whether the camera's buffer should be locked and unlocked during render calls.
	 * 
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's draw() call.
	 */
	public static var useBufferLocking:Bool = false;

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

    @:deprecated("temp")
    var buffer(get, never):BitmapData;
    inline function get_buffer() return camera.viewBlit.buffer;

    @:deprecated("temp")
    var _flashPoint(get, never):Point;
    inline function get__flashPoint() return camera.viewBlit._flashPoint;

    @:deprecated("temp")
    var _flashRect(get, never):Rectangle;
    inline function get__flashRect() return camera.viewBlit._flashRect;

    @:deprecated("temp")
    var _fill(get, never):BitmapData;
    inline function get__fill() return camera.viewBlit._fill;

    @:deprecated("temp")
    var screen(get, never):FlxSprite;
    inline function get_screen() return camera.viewBlit.screen;

    @:deprecated("temp")
    var _helperMatrix(get, never):FlxMatrix;
    inline function get__helperMatrix() return camera.viewBlit._helperMatrix;

    @:deprecated("temp")
    var _blitMatrix(get, never):FlxMatrix;
    inline function get__blitMatrix() return camera.viewBlit._blitMatrix;

    @:deprecated("temp")
    var _useBlitMatrix(get, never):Bool;
    inline function get__useBlitMatrix() return camera.viewBlit._useBlitMatrix;

    @:deprecated("temp")
    var _helperPoint(get, never):Point;
    inline function get__helperPoint() return camera.viewBlit._helperPoint;

    @:deprecated("temp")
    var _bounds(get, never):FlxRect;
    inline function get__bounds() return camera.viewBlit._bounds;

    public function new()
    {
        super();
        method = BLITTING;
    }

    override function clear():Void
	{
		camera.viewBlit.checkResize();
		
		if (useBufferLocking)
		{
			buffer.lock();
		}
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
		screen.dirty = true;
	}

    override function render():Void
	{
		camera.drawFX();
		
		if (useBufferLocking)
		{
			buffer.unlock();
		}
		
		screen.dirty = true;
	}

    override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
		?shader:FlxShader):Void
	{
		_helperMatrix.copyFrom(matrix);
		
		if (_useBlitMatrix)
		{
			_helperMatrix.concat(_blitMatrix);
			buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || camera.antialiasing));
		}
		else
		{
			_helperMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
			buffer.draw(pixels, _helperMatrix, null, blend, null, (smoothing || camera.antialiasing));
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
				buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || camera.antialiasing));
			}
			else
			{
				_helperPoint.x = destPoint.x - Std.int(camera.viewMarginLeft);
				_helperPoint.y = destPoint.y - Std.int(camera.viewMarginTop);
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
		final cameraBounds = _bounds.set(camera.viewMarginLeft, camera.viewMarginTop, camera.viewWidth, camera.viewHeight);
		
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
				_helperMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
			}
			
			buffer.draw(trianglesSprite, _helperMatrix, transform);
			
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

    override function beginDrawDebug(?camera:FlxCamera):Void
    {
        super.beginDrawDebug(camera);

        FlxSpriteUtil.flashGfx.clear();
    }

    override function endDrawDebug():Void
    {
        camera.viewBlit.buffer.draw(FlxSpriteUtil.flashGfxSprite);
    }

    #if FLX_DEBUG
    override public function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		final gfx = FlxSpriteUtil.flashGfx;
		gfx.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		gfx.drawRect(x, y, width, height);
	}

	override public function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		final gfx = FlxSpriteUtil.flashGfx;
		gfx.lineStyle();
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.drawRect(x, y, width, height);
		gfx.endFill();
	}

	override public function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void
	{
		final gfx = FlxSpriteUtil.flashGfx;
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.drawCircle(x, y, radius);
		gfx.endFill();
	}

	override public function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		final gfx = FlxSpriteUtil.flashGfx;
		gfx.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		gfx.moveTo(x1, x2);
		gfx.lineTo(x2, y2);
	}
    #end
}
