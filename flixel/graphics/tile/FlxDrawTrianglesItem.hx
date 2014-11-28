package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.util.FlxColor;
import openfl.display.Graphics;
import openfl.Vector;
import openfl.display.TriangleCulling;

typedef DrawData<T> = #if flash Vector<T> #else Array<T> #end;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	public var vertices:DrawData<Float>;
	public var indices:DrawData<Int>;
	public var uvt:DrawData<Float>;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
		
		#if flash
		vertices = new Vector<Float>();
		indices = new Vector<Int>();
		uvt = new Vector<Float>();
		#else
		vertices = new Array<Float>();
		indices = new Array<Int>();
		uvt = new Array<Float>();
		#end
	}
	
	override public function render(camera:FlxCamera):Void 
	{
		#if FLX_RENDER_TILE
		if (numTriangles <= 0)
		{
			return;
		}
		
		camera.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (camera.antialiasing || antialiasing));
		camera.canvas.graphics.drawTriangles(vertices, indices, uvt, TriangleCulling.NONE);
		camera.canvas.graphics.endFill();
		#if !FLX_NO_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = camera.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices);
		}
		#end
		
		FlxTilesheet._DRAWCALLS++;
		#end
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
	
	override private function get_numVertices():Int
	{
		return Std.int(vertices.length / 2);
	}
	
	override private function get_numTriangles():Int
	{
		return Std.int(indices.length / 3);
	}
}