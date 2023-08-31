package flixel;

import flixel.graphics.tile.FlxDrawTrianglesItem;
import openfl.Vector;
import openfl.display.Graphics;
import openfl.display.GraphicsPathCommand;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

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
	 * Overriding this will force a specific color to be used when debug drawing triangles
	 */
	public var debugTrianglesColor:FlxColor = FlxColor.BLUE;
	
	/**
	 * If true, draws the triangles of this strip, unless ignoreDrawDebug is true
	 */
	public var drawDebugTriangles:Bool = false;
	
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
		
		if (graphicOnScreen && drawDebugTriangles)
		{
			final pos = getScreenPosition(camera);
			drawDebugTrianglesToBuffer(gfx, pos);
		}
		
		endDrawDebug(camera);
	}
	
	function drawDebugTrianglesToBuffer(gfx:Graphics, screenPos:FlxPoint)
	{
		gfx.lineStyle(1, debugTrianglesColor, 0.5);
		// draw a path for each triangle
		final numTriangles = Std.int(indices.length / 3);
		final commands = new Vector<Int>();
		final data = new Vector<Float>();
		for (i in 0...numTriangles)
		{
			// add triangle vertices 0, 1, 2, 0
			commands.push(MOVE_TO);
			commands.push(LINE_TO);
			commands.push(LINE_TO);
			commands.push(LINE_TO);
			for (j in 0...4)
			{
				final index = indices[i * 3 + (j % 3)];
				data.push(screenPos.x + vertices[index * 2 + 0]);
				data.push(screenPos.y + vertices[index * 2 + 1]);
			}
		}
		gfx.drawPath(commands, data);
	}
	#end
}
