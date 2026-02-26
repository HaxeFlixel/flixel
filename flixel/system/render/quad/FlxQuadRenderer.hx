package flixel.system.render.quad;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem;
import flixel.graphics.tile.FlxDrawQuadsItem;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.render.FlxRenderer;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

using flixel.util.FlxColorTransformUtil;
#if FLX_OPENGL_AVAILABLE
import lime.graphics.opengl.GL;
#end


@:access(flixel.FlxCamera)
@:access(flixel.system.render.quad)
class FlxQuadRenderer extends FlxTypedRenderer<FlxQuadView>
{
	var _helperMatrix:FlxMatrix = new FlxMatrix();

	/**
	 * Helper rect for `drawTriangles()` visibility checks
	 */
	var _bounds:FlxRect = FlxRect.get();

    public function new()
    {
        super();
        method = DRAW_TILES;

		#if FLX_OPENGL_AVAILBLE
		if (isGL)
			maxTextureSize = cast GL.getParameter(GL.MAX_TEXTURE_SIZE);
		#end
    }

	override function destroy():Void
	{
		super.destroy();
		_bounds = FlxDestroyUtil.put(_bounds);
		_helperMatrix = null;
	}

	public function drawPixels(view:FlxQuadView, ?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
		?shader:FlxShader)
	{
		var isColored = (transform != null #if !html5 && transform.hasRGBMultipliers() #end);
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		#if FLX_RENDER_TRIANGLE
		final drawItem:FlxDrawTrianglesItem = view.startTrianglesBatch(frame.parent, smoothing, isColored, blend, hasColorOffsets, shader);
		#else
		final drawItem:FlxDrawQuadsItem = view.startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		#end
		drawItem.addQuad(frame, matrix, transform);
	}
	
	public function copyPixels(view:FlxQuadView, ?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
			smoothing:Bool = false, ?shader:FlxShader)
	{
		_helperMatrix.identity();
		_helperMatrix.translate(destPoint.x + frame.offset.x, destPoint.y + frame.offset.y);
		
		var isColored = (transform != null && transform.hasRGBMultipliers());
		var hasColorOffsets:Bool = (transform != null && transform.hasRGBAOffsets());
		
		#if FLX_RENDER_TRIANGLE
		final drawItem:FlxDrawTrianglesItem = view.startTrianglesBatch(frame.parent, smoothing, isColored, blend, hasColorOffsets, shader);
		#else
		final drawItem:FlxDrawQuadsItem = view.startQuadBatch(frame.parent, isColored, hasColorOffsets, blend, smoothing, shader);
		#end
		drawItem.addQuad(frame, _helperMatrix, transform);
	}
	
	public function drawTriangles(view:FlxQuadView, graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		final camera = view.camera;
		final cameraBounds = _bounds.set(camera.viewMarginLeft, camera.viewMarginTop, camera.viewWidth, camera.viewHeight);
		
		final isColored = (colors != null && colors.length != 0) || (transform != null && transform.hasRGBMultipliers());
		final hasColorOffsets = (transform != null && transform.hasRGBAOffsets());
		
		final drawItem = view.startTrianglesBatch(graphic, smoothing, isColored, blend, hasColorOffsets, shader);
		drawItem.addTriangles(vertices, indices, uvtData, colors, position, cameraBounds, transform);
	}
}
