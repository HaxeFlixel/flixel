package flixel.graphics.tile;

import flixel.FlxCamera;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.tile.FlxDrawBaseItem.FlxDrawItemType;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
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
	public var colors:DrawData<Int>;
	
	public var verticesPosition:Int = 0;
	public var indicesPosition:Int = 0;
	public var colorsPosition:Int = 0;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
		
		#if flash
		vertices = new Vector<Float>();
		indices = new Vector<Int>();
		uvt = new Vector<Float>();
		colors = new Vector<Int>();
		#else
		vertices = new Array<Float>();
		indices = new Array<Int>();
		uvt = new Array<Float>();
		colors = new Array<Int>();
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
		#if flash
		camera.canvas.graphics.drawTriangles(vertices, indices, uvt, TriangleCulling.NONE);
		#else
		camera.canvas.graphics.drawTriangles(vertices, indices, uvt, TriangleCulling.NONE, (colored) ? colors : null, blending);
		#end
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
		colors.splice(0, colors.length);
		
		verticesPosition = 0;
		indicesPosition = 0;
		colorsPosition = 0;
	}
	
	override public function dispose():Void 
	{
		super.dispose();
		
		vertices = null;
		indices = null;
		uvt = null;
		colors = null;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix,
		red:Float = 1, green:Float = 1, blue:Float = 1, alpha:Float = 1):Void
	{
		var prevVerticesPos:Int = verticesPosition;
		var prevIndicesPos:Int = indicesPosition;
		var prevColorsPos:Int = colorsPosition;
		var prevNumberOfVertices:Int = numVertices;
		
		var point:FlxPoint = FlxPoint.flxPoint1;
		
		point.set(0, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;
		
		uvt[prevVerticesPos] = frame.uv.x;
		uvt[prevVerticesPos + 1] = frame.uv.y;
		
		point.set(frame.frame.width, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;
		
		uvt[prevVerticesPos + 2] = frame.uv.width;
		uvt[prevVerticesPos + 3] = frame.uv.y;
		
		point.set(frame.frame.width, frame.frame.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;
		
		uvt[prevVerticesPos + 4] = frame.uv.width;
		uvt[prevVerticesPos + 5] = frame.uv.height;
		
		point.set(0, frame.frame.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;
		
		uvt[prevVerticesPos + 6] = frame.uv.x;
		uvt[prevVerticesPos + 7] = frame.uv.height;
		
		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;
		
		if (colored)
		{
			#if neko
			var color:FlxColor = FlxColor.fromRGBFloat(red, green, blue, 1.0);
			#else
			var color:FlxColor = FlxColor.fromRGBFloat(red, green, blue, alpha);
			#end
			
			colors[prevColorsPos] = color;
			colors[prevColorsPos + 1] = color;
			colors[prevColorsPos + 2] = color;
			colors[prevColorsPos + 3] = color;
			
			colorsPosition += 4;
		}
		
		verticesPosition += 8;
		indicesPosition += 6;
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