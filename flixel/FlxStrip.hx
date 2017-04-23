package flixel;

import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxTrianglesData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import openfl.Vector;
import openfl.display.BitmapData;

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
 * You could try set `useFramePixels` to `true` in blit render mode to see if it help perfomance 
 * (it should help if don't change object's data (such as vertices, indices, etc.) frequently)
 */
class FlxStrip extends FlxSprite
{
	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	public var vertices(get, set):Vector<Float>;
	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices(get, set):Vector<Int>;
	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	public var uvtData(get, set):Vector<Float>;
	/**
	 * A `Vector` of colors for each vertex.
	 */
	public var colors(get, set):Vector<FlxColor>;
	
	/**
	 * Tells to repeat texture of the sprite if uv coordinates go outside of bounds [0.0-1.0].
	 */
	public var repeat:Bool = true;
	
	/**
	 * Data object which actually stores information about vertex coordinates, uv coordinates (if this sprite have texture applied), indices and vertex colors.
	 * Plus it have some internal logic for rendering with OpenGL.
	 */
	public var data:FlxTrianglesData;
	
	public var verticesDirty(get, set):Bool;
	
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
		useFramePixels = false;
	}
	
	override public function destroy():Void 
	{
		data = FlxDestroyUtil.destroy(data);
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (alpha == 0 || data == null || vertices == null)
			return;
		
		if (FlxG.renderBlit && useFramePixels)
		{
			if (dirty || verticesDirty) //rarely 
			{
				updateFramePixels();
				dirty = false;
			}
			
			super.draw();
			return;
		}
		
		if (verticesDirty)
			data.updateBounds();
		
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
			
			getScreenPosition(_point, camera).subtractPoint(offset);
			tempBounds.offset(_point.x, _point.y);
			
			if (camera.view.bounds.overlaps(tempBounds))
			{
				_matrix.translate(_point.x, _point.y);
				camera.drawTriangles(graphic.bitmap, material, data, _matrix, colorTransform);
				_matrix.translate( -_point.x, -_point.y);
			}
			
			tempBounds.offset( -_point.x, -_point.y);
		}
	}
	
	override public function updateFramePixels():BitmapData 
	{
		if (!(dirty || verticesDirty) || FlxG.renderTile || data == null)
			return framePixels;
		
		var oldX:Float = data.bounds.x;
		var oldY:Float = data.bounds.y;
		
		framePixels = data.getBitmapData(framePixels, graphic, color);
		
		x += (data.bounds.x - oldX);
		y += (data.bounds.y - oldY);
		
		width = data.bounds.width;
		height = data.bounds.height;
		_flashRect.setTo(0, 0, width, height);
		
		if (useColorTransform)
			framePixels.colorTransform(_flashRect, colorTransform);
		
		return framePixels;
	}
	
	private function get_vertices():Vector<Float>
	{
		return data.vertices;
	}
	
	private function set_vertices(value:Vector<Float>):Vector<Float>
	{
		return data.vertices = value;
	}
	
	private function get_indices():Vector<Int>
	{
		return data.indices;
	}
	
	private function set_indices(value:Vector<Int>):Vector<Int>
	{
		return data.indices = value;
	}
	
	private function get_uvtData():Vector<Float>
	{
		return data.uvs;
	}
	
	private function set_uvtData(value:Vector<Float>):Vector<Float>
	{
		return data.uvs = value;
	}
	
	private function get_colors():Vector<FlxColor>
	{
		return data.colors;
	}
	
	private function set_colors(value:Vector<FlxColor>):Vector<FlxColor>
	{
		return data.colors = value;
	}
	
	private function get_verticesDirty():Bool
	{
		return data.verticesDirty;
	}
	
	private function set_verticesDirty(value:Bool):Bool
	{
		return data.verticesDirty = value;
	}
	
	override function set_dirty(value:Bool):Bool 
	{
		if (data != null)
			data.dirty = value;
		
		return super.set_dirty(value);
	}
}