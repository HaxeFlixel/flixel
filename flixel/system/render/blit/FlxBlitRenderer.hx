package flixel.system.render.blit;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.render.FlxRenderer;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxSpriteUtil;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.Sprite;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

@:access(flixel.FlxCamera)
@:access(flixel.system.render.blit)
class FlxBlitRenderer extends FlxTypedRenderer<FlxBlitView>
{
	/**
	 * Whether the camera's buffer should be locked and unlocked during render calls.
	 * 
	 * Allows you to possibly slightly optimize the rendering process IF
	 * you are not doing any pre-processing in your game state's draw() call.
	 * 
	 * This property only has effects when targeting Flash.
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
	
	/**
	 * Helper rect for `drawTriangles()` visibility checks
	 */
	var _bounds:FlxRect = FlxRect.get();
	
	var _helperMatrix:FlxMatrix = new FlxMatrix();
	var _helperPoint:Point = new Point();
	
	public function new()
	{
		super();
		method = BLITTING;
	}
	
	override function destroy():Void
	{
		super.destroy();
		_bounds = FlxDestroyUtil.put(_bounds);
		_helperMatrix = null;
		_helperPoint = null;
	}
	
	public function createCameraView(camera:FlxCamera)
	{
		return new FlxBlitView(camera);
	}
	
	public function drawPixels(view:FlxBlitView, ?frame:FlxFrame, ?pixels:BitmapData, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, smoothing:Bool = false,
			?shader:FlxShader):Void
	{
		_helperMatrix.copyFrom(matrix);
		
		final camera = view.camera;
		if (view._useBlitMatrix)
		{
			_helperMatrix.concat(view._blitMatrix);
			view.buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || camera.antialiasing));
		}
		else
		{
			_helperMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
			view.buffer.draw(pixels, _helperMatrix, null, blend, null, (smoothing || camera.antialiasing));
		}
	}
	
	public function copyPixels(view:FlxBlitView, ?frame:FlxFrame, ?pixels:BitmapData, ?sourceRect:Rectangle, destPoint:Point, ?transform:ColorTransform, ?blend:BlendMode,
			smoothing:Bool = false, ?shader:FlxShader)
	{
		final camera = view.camera;
		if (pixels != null)
		{
			if (view._useBlitMatrix)
			{
				_helperMatrix.identity();
				_helperMatrix.translate(destPoint.x, destPoint.y);
				_helperMatrix.concat(view._blitMatrix);
				view.buffer.draw(pixels, _helperMatrix, null, null, null, (smoothing || camera.antialiasing));
			}
			else
			{
				_helperPoint.x = destPoint.x - Std.int(camera.viewMarginLeft);
				_helperPoint.y = destPoint.y - Std.int(camera.viewMarginTop);
				view.buffer.copyPixels(pixels, sourceRect, _helperPoint, null, null, true);
			}
		}
		else if (frame != null)
		{
			// TODO: fix this case for zoom less than initial zoom...
			frame.paint(view.buffer, destPoint, true);
		}
	}
	
	public function drawTriangles(view:FlxBlitView, graphic:FlxGraphic, vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>,
			?position:FlxPoint, ?blend:BlendMode, repeat:Bool = false, smoothing:Bool = false, ?transform:ColorTransform, ?shader:FlxShader)
	{
		final camera = view.camera;
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
			if (view._useBlitMatrix)
				_helperMatrix.copyFrom(view._blitMatrix);
			else
			{
				_helperMatrix.identity();
				_helperMatrix.translate(-camera.viewMarginLeft, -camera.viewMarginTop);
			}
			
			view.buffer.draw(trianglesSprite, _helperMatrix, transform);
			
			#if FLX_DEBUG
			if (FlxG.debugger.drawDebug)
			{
				// TODO: add a drawDebugTriangles method
				var gfx:Graphics = FlxSpriteUtil.flashGfx;
				gfx.clear();
				gfx.lineStyle(1, FlxColor.BLUE, 0.5);
				gfx.drawTriangles(drawVertices, indices);
				view.buffer.draw(FlxSpriteUtil.flashGfxSprite, _helperMatrix);
			}
			#end
			// End of TODO...
		}
		
		bounds.put();
	}
}
