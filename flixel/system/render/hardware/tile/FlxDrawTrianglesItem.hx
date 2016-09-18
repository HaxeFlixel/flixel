package flixel.system.render.hardware.tile;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.common.FlxDrawBaseItem;
import flixel.system.render.hardware.FlxHardwareView;
import flixel.util.FlxColor;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.display.TriangleCulling;
import openfl.geom.ColorTransform;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{
	private static var point:FlxPoint = FlxPoint.get();
	private static var rect:FlxRect = FlxRect.get();
	
	public var vertices:DrawData<Float> = new DrawData<Float>();
	public var indices:DrawData<Int> = new DrawData<Int>();
	public var uvtData:DrawData<Float> = new DrawData<Float>();
	public var colors:DrawData<Int> = new DrawData<Int>();
	
	// variables for drawing non-textured triangles:
	public var color:FlxColor;
	public var alpha:Float;
	
	public var vertexPos:Int = 0;
	public var indexPos:Int = 0;
	public var colorPos:Int = 0;
	
	private var bounds:FlxRect = FlxRect.get();
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	override public function render(view:FlxHardwareView):Void 
	{
		if (!FlxG.renderTile)
			return;
		
		if (numTriangles <= 0)
			return;
		
		if (graphics == null)
		{
			view.canvas.graphics.beginFill(color, alpha);
			view.canvas.graphics.drawTriangles(vertices, indices, null, TriangleCulling.NONE);
		}
		else
		{
			view.canvas.graphics.beginBitmapFill(graphics.bitmap, null, true, (view.antialiasing || antialiasing));
			#if !openfl_legacy
			view.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE);
			#else
			view.canvas.graphics.drawTriangles(vertices, indices, uvtData, TriangleCulling.NONE, (colored) ? colors : null, FlxDrawBaseItem.blendToInt(blending));
			#end
		}
		
		view.canvas.graphics.endFill();
		
		#if FLX_DEBUG
		if (FlxG.debugger.drawDebug)
		{
			var gfx:Graphics = view.debugLayer.graphics;
			gfx.lineStyle(1, FlxColor.BLUE, 0.5);
			gfx.drawTriangles(vertices, indices);
		}
		#end
		
		FlxCameraView._DRAWCALLS++;
	}
	
	override public function reset():Void 
	{
		super.reset();
		vertices.splice(0, vertices.length);
		indices.splice(0, indices.length);
		uvtData.splice(0, uvtData.length);
		colors.splice(0, colors.length);
		
		vertexPos = 0;
		indexPos = 0;
		colorPos = 0;
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		vertices = null;
		indices = null;
		uvtData = null;
		colors = null;
		bounds = null;
	}
	
	override public function equals(type:FlxDrawItemType, graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, ?shader:FlxShader):Bool
	{
		return (this.type == type 
			&& this.graphics == graphic 
			&& this.colored == colored
			&& this.blending == blend
			&& this.antialiasing == smooth);
	}
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var drawVertices = this.vertices;
		var verticesLength:Int = vertices.length;
		var numberOfVertices:Int = Std.int(verticesLength / 2);
		var prevUVTDataLength:Int = this.uvtData.length;
		var prevNumberOfVertices:Int = this.numVertices;
		
		var px:Float, py:Float;
		var i:Int = 0;
		
		while (i < verticesLength)
		{
			px = vertices[i]; 
			py = vertices[i + 1];
			
			drawVertices[i] = px * matrix.a + py * matrix.c + matrix.tx;
			drawVertices[i + 1] = px * matrix.b + py * matrix.d + matrix.ty;
			
			vertexPos += 2;
			i += 2;
		}
		
		var uvtDataLength:Int = uvtData.length;
		for (i in 0...uvtDataLength)
		{
			this.uvtData[prevUVTDataLength + i] = uvtData[i];
		}
		
		var indicesLength:Int = numberOfVertices;
		if (indices != null)
		{
			indicesLength = indices.length;
			for (i in 0...indicesLength)
			{
				this.indices[indexPos++] = prevNumberOfVertices + indices[i];
			}
		}
		else
		{
			for (i in 0...indicesLength)
			{
				this.indices[indexPos++] = prevNumberOfVertices + i;
			}
		}
		
		if (colored)
		{
			var color:FlxColor = (transform == null) ? 
								FlxColor.WHITE : 
								FlxColor.fromRGBFloat(transform.redMultiplier, transform.greenMultiplier, transform.blueMultiplier, transform.alphaMultiplier);
			
			for (i in 0...numberOfVertices)
			{
				this.colors[colorPos++] = color;
			}
		}
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		addUVQuad(frame.frame, frame.uv, matrix, transform);
	}
	
	override public function addUVQuad(rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform):Void
	{
		var prevVerticesPos:Int = vertexPos;
		var prevIndicesPos:Int = indexPos;
		var prevColorsPos:Int = colorPos;
		var prevNumberOfVertices:Int = numVertices;
		
		var point = FlxPoint.get();
		point.transform(matrix);
		
		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;
		
		uvtData[prevVerticesPos] = uv.x;
		uvtData[prevVerticesPos + 1] = uv.y;
		
		point.set(rect.width, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;
		
		uvtData[prevVerticesPos + 2] = uv.width;
		uvtData[prevVerticesPos + 3] = uv.y;
		
		point.set(rect.width, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;
		
		uvtData[prevVerticesPos + 4] = uv.width;
		uvtData[prevVerticesPos + 5] = uv.height;
		
		point.set(0, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;
		
		point.put();
		
		uvtData[prevVerticesPos + 6] = uv.x;
		uvtData[prevVerticesPos + 7] = uv.height;
		
		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;
		
		if (colored)
		{
			var red = 1.0;
			var green = 1.0;
			var blue = 1.0;
			var alpha = 1.0;
			
			if (transform != null)
			{
				red  = transform.redMultiplier;
				green = transform.greenMultiplier;
				blue = transform.blueMultiplier;
				
				#if !neko
				alpha = transform.alphaMultiplier;
				#end
			}
			
			var color = FlxColor.fromRGBFloat(red, green, blue, alpha);
			
			colors[prevColorsPos] = color;
			colors[prevColorsPos + 1] = color;
			colors[prevColorsPos + 2] = color;
			colors[prevColorsPos + 3] = color;
			
			colorPos += 4;
		}
		
		vertexPos += 8;
		indexPos += 6;
	}
	
	override private function get_numVertices():Int
	{
		return Std.int(vertexPos / elementsPerVertex);
	}
	
	override private function get_numTriangles():Int
	{
		return Std.int(indexPos / 3);
	}
	
	override function get_elementsPerVertex():Int 
	{
		return 2;
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0):Void
	{
		var prevVerticesPos:Int = vertexPos;
		var prevIndicesPos:Int = indexPos;
		var prevNumberOfVertices:Int = numVertices;
		
		var point = FlxPoint.get();
		point.transform(matrix);
		
		vertices[prevVerticesPos] = point.x;
		vertices[prevVerticesPos + 1] = point.y;
		
		point.set(rect.width, 0);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 2] = point.x;
		vertices[prevVerticesPos + 3] = point.y;
		
		point.set(rect.width, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 4] = point.x;
		vertices[prevVerticesPos + 5] = point.y;
		
		point.set(0, rect.height);
		point.transform(matrix);
		
		vertices[prevVerticesPos + 6] = point.x;
		vertices[prevVerticesPos + 7] = point.y;
		
		point.put();
		
		indices[prevIndicesPos] = prevNumberOfVertices;
		indices[prevIndicesPos + 1] = prevNumberOfVertices + 1;
		indices[prevIndicesPos + 2] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 3] = prevNumberOfVertices + 2;
		indices[prevIndicesPos + 4] = prevNumberOfVertices + 3;
		indices[prevIndicesPos + 5] = prevNumberOfVertices;
		
		this.color = color;
		this.alpha = alpha;
		
		vertexPos += 8;
		indexPos += 6;
	}
}
