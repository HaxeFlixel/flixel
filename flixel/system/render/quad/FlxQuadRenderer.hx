package flixel.system.render.quad;

import flixel.graphics.tile.FlxDrawQuadsItem;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.geom.Point;
import openfl.display.BlendMode;
import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import openfl.geom.ColorTransform;
import flixel.system.FlxAssets.FlxShader;
import flixel.graphics.tile.FlxDrawTrianglesItem.DrawData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.tile.FlxDrawBaseItem;
import openfl.display.Graphics;
import flixel.util.FlxColor;
import openfl.display.Sprite;
#if FLX_OPENGL_AVAILABLE
import lime.graphics.opengl.GL;
#end

using flixel.util.FlxColorTransformUtil;

@:access(flixel.FlxCamera)
@:access(flixel.system.render.quad)
class FlxQuadRenderer extends FlxRenderer
{
	@:deprecated("temp")
	var flashSprite(get, never):Sprite;
	function get_flashSprite():Sprite
		return camera.viewQuad.flashSprite;

	@:deprecated("temp")
    var canvas(get, never):Sprite;
    function get_canvas():Sprite
        return camera.viewQuad.canvas;

	@:deprecated("temp")
    var debugLayer(get, never):Sprite;
    function get_debugLayer():Sprite
        return camera.viewQuad.debugLayer;

	@:deprecated("temp")
	var targetGraphics(get, never):Graphics;
	function get_targetGraphics():Graphics
		return camera.viewQuad.targetGraphics;

    public function new()
    {
        super();
        method = DRAW_TILES;
    }

    override function init():Void
    {
		if (isGL)
			maxTextureSize = cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
    }

	override function clear():Void
	{
		camera.viewQuad.clearDrawStack();
		
		canvas.graphics.clear();
		// Clearing camera's debug sprite
		#if FLX_DEBUG
		debugLayer.graphics.clear();
		#end
		
		fill(camera.bgColor, camera.useBgAlphaBlending);
	}

	override function render():Void
	{
		flashSprite.filters = camera.filtersEnabled ? camera.filters : null;
		
		var currItem:FlxDrawBaseItem<Dynamic> = camera.viewQuad._headOfDrawStack;
		while (currItem != null)
		{
			currItem.render(camera);
			currItem = currItem.next;
		}

		camera.drawFX();
	}

		override function drawPixels(?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
			?shader:FlxShader)
	{
		var isColored = (transform != null #if !html5 && transform.hasRGBMultipliers() #end);
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		#if FLX_RENDER_TRIANGLE
		final drawItem:FlxDrawTrianglesItem = camera.viewQuad.startTrianglesBatch(frame.parent, smoothing, isColored, blend, hasColorOffsets, shader);
		#else
		final drawItem:FlxDrawQuadsItem = camera.viewQuad.startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		#end
		drawItem.addQuad(frame, matrix, transform);
	}
	
	override function copyPixels(?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
			smoothing:Bool = false, ?shader:FlxShader)
	{
		camera.viewQuad._helperMatrix.identity();
		camera.viewQuad._helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		#if FLX_RENDER_TRIANGLE
		final drawItem:FlxDrawTrianglesItem = camera.viewQuad.startTrianglesBatch(frame.parent, smoothing, isColored, blend, hasColorOffsets, shader);
		#else
		final drawItem:FlxDrawQuadsItem = camera.viewQuad.startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		#end
		drawItem.addQuad(frame, camera.viewQuad._helperMatrix, transform);
	}
	
	override function drawTriangles(graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		final cameraBounds = camera.viewQuad._bounds.set(camera.viewMarginLeft, camera.viewMarginTop, camera.viewWidth, camera.viewHeight);
		
		final isColored = (colors != null && colors.length != 0) || (transform != null && transform.hasRGBMultipliers());
		final hasColorOffsets = (transform != null && transform.hasRGBAOffsets());
		
		final drawItem = camera.viewQuad.startTrianglesBatch(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
		drawItem.addTriangles(vertices, indices, uvtData, colors, position, cameraBounds, transform);
	}

	override function fill(color:FlxColor, blendAlpha:Bool = true):Void
	{
		targetGraphics.overrideBlendMode(null);
		targetGraphics.beginFill(color.rgb, color.alphaFloat);
		// i'm drawing rect with these parameters to avoid light lines at the top and left of the camera,
		// which could appear while cameras fading
		targetGraphics.drawRect(camera.viewMarginLeft - 1, camera.viewMarginTop - 1, camera.viewWidth + 2, camera.viewHeight + 2);
		targetGraphics.endFill();
	}

    #if FLX_DEBUG
	override function drawDebugRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		final gfx = debugLayer.graphics;
		gfx.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		gfx.drawRect(x, y, width, height);
	}

	override function drawDebugFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		final gfx = debugLayer.graphics;
		gfx.lineStyle();
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.drawRect(x, y, width, height);
		gfx.endFill();
	}

	override function drawDebugFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void
	{
		final gfx = debugLayer.graphics;
		gfx.beginFill(color.rgb, color.alphaFloat);
		gfx.drawCircle(x, y, radius);
		gfx.endFill();
	}

	override function drawDebugLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		final gfx = debugLayer.graphics;
		gfx.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		gfx.moveTo(x1, x2);
		gfx.lineTo(x2, y2);
	}
	#end

	// override function get_currentView<T:FlxCameraView>():T
	// {
	// 	return camera.viewQuad;
	// }
}
