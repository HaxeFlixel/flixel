package flixel;

import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.util.FlxColor;
import openfl.display.Graphics;
import openfl.display.GraphicsPathCommand;

/**
 * A very basic rendering component which uses `drawTriangles()`.
 * You have access to `vertices`, `indices` and `uvtData` vectors which are used as data storages for rendering.
 * The whole `FlxGraphic` object is used as a texture for this sprite.
 * Use these links for more info about `drawTriangles()`:
 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html#drawTriangles%28%29
 * @see http://help.adobe.com/en_US/as3/dev/WS84753F1C-5ABE-40b1-A2E4-07D7349976C4.html
 * @see http://www.flashandmath.com/advanced/p10triangles/index.html
 *
 * WARNING: This class is EXTREMELY slow on Flash!
 */
class FlxStrip extends FlxSprite
{
	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	public var vertices:DrawData<Float> = new DrawData<Float>();

	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:DrawData<Int> = new DrawData<Int>();

	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	public var uvtData:DrawData<Float> = new DrawData<Float>();

	public var colors:DrawData<Int> = new DrawData<Int>();

	public var repeat:Bool = false;
	
	#if FLX_DEBUG
	/**
	 * Overriding this will force a specific color to be used for debug wireframe
	 */
	public var debugWireframeColor:FlxColor = FlxColor.BLUE;
	
	/**
	 * If true, draws the triangles of this strip, unless ignoreDrawDebug is true
	 */
	public var drawDebugWireframe:Bool = false;
	
	/**
	 * If true, draws the collision bounding box of this strip, unless ignoreDrawDebug is true
	 */
	public var drawDebugCollider:Bool = true;
	#end

	override public function destroy():Void
	{
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;

		super.destroy();
	}

	// TODO: check this for cases when zoom is less than initial zoom...
	override public function draw():Void
	{
		if (alpha == 0 || graphic == null || vertices == null)
			return;

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;

			getScreenPosition(_point, camera).subtractPoint(offset);
			#if !flash
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, repeat, antialiasing, colorTransform, shader);
			#else
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, repeat, antialiasing);
			#end
		}
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
			drawDebug();
		#end
	}
	
	#if FLX_DEBUG
	override function drawDebugOnCamera(camera:FlxCamera)
	{
		final boundsOnScreen = isColliderOnScreen(camera);
		final graphicOnScreen = isOnScreen(camera);
		if (!camera.visible || !camera.exists || !(boundsOnScreen || graphicOnScreen))
			return;
		
		final gfx:Graphics = beginDrawDebug(camera);
		if (boundsOnScreen && drawDebugCollider)
		{
			final rect = getBoundingBox(camera);
			drawDebugBoundingBox(gfx, rect, allowCollisions, immovable);
		}
		
		if (graphicOnScreen && drawDebugWireframe)
		{
			drawDebugWireframeToBuffer(gfx);
		}
		
		endDrawDebug(camera);
	}
	
	function drawDebugWireframeToBuffer(gfx:Graphics)
	{
		gfx.lineStyle(1, debugWireframeColor, 0.5);
		// draw a triangle path for each triangle in the drawitem
		final numTriangles = Std.int(indices.length / 3);
		for (i in 0...numTriangles)
		{
			gfx.drawPath
			(
				DrawData.ofArray([MOVE_TO, LINE_TO, LINE_TO, LINE_TO]),
				DrawData.ofArray(
				[
					getVertexX(i * 3 + 0), getVertexY(i * 3 + 0),
					getVertexX(i * 3 + 1), getVertexY(i * 3 + 1),
					getVertexX(i * 3 + 2), getVertexY(i * 3 + 2),
					getVertexX(i * 3 + 0), getVertexY(i * 3 + 0)
				])
			);
		}
	}
	
	inline function getVertexX(i:Int)
	{
		return x + vertices[indices[i] * 2];
	}
	
	inline function getVertexY(i:Int)
	{
		return y + vertices[indices[i] * 2 + 1];
	}
	#end
}
