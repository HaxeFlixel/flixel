package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import openfl.Vector;
import openfl.display.TriangleCulling;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	public var vertices:Vector<Float>;
	public var indices:Vector<Int>;
	public var uvt:Vector<Float>;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
		
		vertices = new Vector<Float>();
		indices = new Vector<Int>();
		uvt = new Vector<Float>();
	}
	
	override public function render(camera:FlxCamera):Void 
	{
		camera.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (camera.antialiasing || antialiasing));
		camera.canvas.graphics.drawTriangles(vertices, indices, uvt, TriangleCulling.NONE);
		camera.canvas.graphics.endFill();
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		vertices.splice(0, vertices.length);
		indices.splice(0, indices.length);
		uvt.splice(0, uvt.length);
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		vertices = null;
		indices = null;
		uvt = null;
	}
}