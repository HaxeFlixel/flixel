package flixel;

import flixel.graphics.tile.FlxDrawTriangleData;
import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Vector;
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
	 * List of triangles
	 */
	public var triangles:FlxDrawTriangleData;
	
	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	// @:deprecated("FlxStrip's vertices is deprecated, use triangles.vertices, instead") // TODO
	public var vertices(get, set):DrawData<Float>;
	public function get_vertices() return triangles.vertices;
	public function set_vertices(value:DrawData<Float>) return triangles.vertices = value;

	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	// @:deprecated("FlxStrip's indices is deprecated, use triangles.indices, instead") // TODO
	public var indices(get, set):DrawData<Int>;
	public function get_indices() return triangles.indices;
	public function set_indices(value:DrawData<Int>) return triangles.indices = value;

	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	// @:deprecated("FlxStrip's uvtData is deprecated, use triangles.uvs, instead") // TODO
	public var uvtData(get, set):DrawData<Float>;
	public function get_uvtData() return triangles.uvs;
	public function set_uvtData(value:DrawData<Float>) return triangles.uvs = value;

	// @:deprecated("FlxStrip's color is deprecated, use triangles.colors, instead") // TODO
	public var colors(get, set):DrawData<Int>;
	public function get_colors() return triangles.colors;
	public function set_colors(value:DrawData<Int>) return triangles.colors = value;

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
	
	public function new(x = 0.0, y = 0.0, ?graphic)
	{
		triangles = new FlxDrawTriangleData();
		super(x, y, graphic);
	}

	override public function destroy():Void
	{
		triangles = FlxDestroyUtil.destroy(triangles);
		super.destroy();
	}

	// TODO: check this for cases when zoom is less than initial zoom...
	override public function draw():Void
	{
		if (alpha == 0 || graphic == null || triangles.vertices == null)
			return;

		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;

			getScreenPosition(_point, camera).subtractPoint(offset);
			#if !flash
			camera.drawTriangleData(graphic, triangles, _point, blend, repeat, antialiasing, colorTransform, shader);
			#else
			camera.drawTriangleData(graphic, triangles, _point, blend, repeat, antialiasing);
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
		final numTriangles = Std.int(triangles.indices.length / 3);
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
				final index = triangles.indices[i * 3 + (j % 3)];
				data.push(screenPos.x + triangles.vertices[index * 2 + 0]);
				data.push(screenPos.y + triangles.vertices[index * 2 + 1]);
			}
		}
		gfx.drawPath(commands, data);
	}
	#end
}
