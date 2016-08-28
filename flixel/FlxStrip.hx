package flixel;

import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.util.FlxGeom;

/**
 * A very basic rendering component which uses drawTriangles.
 * You have access to vertices, indices and uvtData vectors which are used as data storages for rendering.
 * The whole FlxGraphic object is used as a texture for this sprite.
 * 
 * You must set `dirty` flag to true to make it update its bounds which are used for visibility checks.
 * I had to add this requirement for less calculations every frame.
 * 
 * Use these links for more info about drawTriangles method:
 * @see http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/display/Graphics.html#drawTriangles%28%29
 * @see http://help.adobe.com/en_US/as3/dev/WS84753F1C-5ABE-40b1-A2E4-07D7349976C4.html
 * @see http://www.flashandmath.com/advanced/p10triangles/index.html
 * 
 * WARNING: This class is EXTREMELY slow on flash target!
 */
class FlxStrip extends FlxSprite
{
	/**
	 * A Vector of Floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	public var vertices:DrawData<Float> = new DrawData<Float>();
	/**
	 * A Vector of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:DrawData<Int> = new DrawData<Int>();
	/**
	 * A Vector of normalized coordinates used to apply texture mapping.
	 */
	public var uvtData:DrawData<Float> = new DrawData<Float>();
	
	public var repeat:Bool = false;
	
	private var bounds:FlxRect = FlxRect.get();
	
	override public function destroy():Void 
	{
		vertices = null;
		indices = null;
		uvtData = null;
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (alpha == 0 || graphic == null || vertices == null)
		{
			return;
		}
		
		if (dirty && vertices.length >= 6)
		{
			// calculate bounds in local coordinates
			bounds.set(vertices[0], vertices[1], 0, 0);
			var numVertices:Int = vertices.length;
			var i:Int = 2;
			
			while (i < numVertices)
			{
				FlxGeom.inflateBounds(bounds, vertices[i], vertices[i + 1]);
				i += 2;
			}
		}
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			getScreenPosition(_point, camera);
			
			// TODO: add more complex visibility checks like scaling and rotations...
			
			// TODO: add support for complex transformations for this kind of sprite
			
			bounds.offset(_point.x, _point.y);
			
			if (camera.view.bounds.overlaps(bounds))
			{
				_matrix.identity();
				_matrix.translate(_point.x, _point.y);
				
				camera.drawTriangles(graphic, vertices, indices, uvtData, _matrix, colorTransform, blend, repeat, antialiasing);
			}
			
			bounds.offset( -_point.x, -_point.y);
		}
	}
}