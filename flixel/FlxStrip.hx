package flixel;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import openfl.Vector;

/**
 * A very basic rendering component which uses drawTriangles.
 * You have access to vertices, indices and uvtData vectors which are used as data storages for rendering.
 * The whole FlxGraphic object is used as a texture for this sprite.
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
	public var vertices:Vector<Float>;
	/**
	 * A Vector of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices:Vector<Int>;
	/**
	 * A Vector of normalized coordinates used to apply texture mapping.
	 */
	public var uvtData:Vector<Float>;
	
	public var colors:Vector<Int>;
	
	public function new(X:Float = 0, Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		
		vertices = new Vector<Float>();
		indices = new Vector<Int>();
		uvtData = new Vector<Float>();
		colors = new Vector<Int>();
	}
	
	override public function destroy():Void 
	{
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
		
		super.destroy();
	}
	
	override public function draw():Void 
	{
		if (alpha == 0 || graphic == null || vertices == null)
		{
			return;
		}
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			getScreenPosition(_point, camera);
			camera.drawTriangles(graphic, vertices, indices, uvtData, colors, _point, blend, antialiasing);
		}
	}
}