package flixel;

import flixel.graphics.FlxTrianglesData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;

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
	public var vertices(get, set):DrawData<Float>;
	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices(get, set):DrawData<Int>;
	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	public var uvtData(get, set):DrawData<Float>;
	/**
	 * A `Vector` of colors for each vertex.
	 */
	public var colors(get, set):DrawData<FlxColor>;
	
	/**
	 * Tells to repeat texture of the sprite if uv coordinates go outside of bounds [0.0-1.0].
	 */
	public var repeat:Bool = true;
	
	// TODO: maybe add option to draw triangles on the sprite buffer (for less drawTriangles calls)...
	
	// TODO: maybe optimize FlxStrip, so it will have its own sprite and buffer
	// which will be used for rendering (which means less drawTriangles calls)...
	
	/**
	 * Data object which actually stores information about vertex coordinates, uv coordinates (if this sprite have texture applied), indices and vertex colors.
	 * Plus it have some internal logic for rendering with OpenGL.
	 */
	public var data:FlxTrianglesData;
	
	/**
	 * FlxStrip constructor
	 * 
	 * @param	X				intiial X coordinate of sprite
	 * @param	Y				intiial Y coordinate of sprite
	 * @param	SimpleGraphic	graphic to use as sprite's texture.
	 */
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		
		data = new FlxTrianglesData();
	}
	
	override public function destroy():Void 
	{
		data = FlxDestroyUtil.destroy(data);
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (alpha == 0 || vertices == null)
			return;
		
		if (dirty)
		{
			dirty = false;
			data.updateBounds();
			data.dirty = true;
		}
		
		// update matrix
		_matrix.identity();
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);
		
		updateTrig();
		
		if (angle != 0)
			_matrix.rotateWithTrig(_cosAngle, _sinAngle);
		
		_matrix.translate(origin.x, origin.y);
		
		// now calculate transformed bounds of sprite
		var tempBounds:FlxRect = data.getTransformedBounds(_matrix);
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
				continue;
			
			getScreenPosition(_point, camera);
			tempBounds.offset(_point.x, _point.y);
			
			if (camera.view.bounds.overlaps(tempBounds))
			{
				_matrix.translate(_point.x, _point.y);
				camera.drawTriangles(graphic, data, _matrix, colorTransform, blend, repeat, smoothing);
				_matrix.translate( -_point.x, -_point.y);
			}
			
			tempBounds.offset( -_point.x, -_point.y);
		}
	}
	
	private function get_vertices():DrawData<Float>
	{
		return data.vertices;
	}
	
	private function set_vertices(value:DrawData<Float>):DrawData<Float>
	{
		return data.vertices = value;
	}
	
	private function get_indices():DrawData<Int>
	{
		return data.indices;
	}
	
	private function set_indices(value:DrawData<Int>):DrawData<Int>
	{
		return data.indices = value;
	}
	
	private function get_uvtData():DrawData<Float>
	{
		return data.uvs;
	}
	
	private function set_uvtData(value:DrawData<Float>):DrawData<Float>
	{
		return data.uvs = value;
	}
	
	private function get_colors():DrawData<FlxColor>
	{
		return data.colors;
	}
	
	private function set_colors(value:DrawData<FlxColor>):DrawData<FlxColor>
	{
		return data.colors = value;
	}
}