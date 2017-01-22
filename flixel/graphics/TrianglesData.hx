package flixel.graphics;

import flixel.system.render.common.DrawItem.DrawData;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

#if FLX_RENDER_GL
import lime.graphics.GLRenderContext;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import flixel.system.render.hardware.gl.GLUtils;
#end

class TrianglesData implements IFlxDestroyable
{
	public var numIndices(get, null):Int;
	
	public var numTriangles(get, null):Int;
	
	public var colored(get, null):Bool;
	
	public var dirty(default, set):Bool = true;
	
	public var verticesDirty:Bool = true;
	public var uvtDirty:Bool = true;
	public var colorsDirty:Bool = true;
	public var indicesDirty:Bool = true;
	
	public var vertices(default, set):DrawData<Float> = new DrawData<Float>();
	public var uvs(default, set):DrawData<Float> = new DrawData<Float>();
	public var colors(default, set):DrawData<FlxColor> = new DrawData<FlxColor>();
	public var indices(default, set):DrawData<Int> = new DrawData<Int>();
	
	#if FLX_RENDER_GL
	private var verticesArray:Float32Array;
	private var uvsArray:Float32Array;
	private var colorsArray:UInt32Array;
	private var indicesArray:UInt16Array;
	
	private var verticesBuffer:GLBuffer;
	private var uvsBuffer:GLBuffer;
	private var colorsBuffer:GLBuffer;
	private var indicesBuffer:GLBuffer;
	
	private var gl:GLRenderContext;
	#end
	
	public function new() {}
	
	public function destroy():Void
	{
		vertices = null;
		uvs = null;
		colors = null;
		indices = null;
		
		#if FLX_RENDER_GL
		gl = null;
		verticesArray = null;
		uvsArray = null;
		colorsArray = null;
		indicesArray = null;
		
		verticesBuffer = GLUtils.destroyBuffer(verticesBuffer);
		uvsBuffer = GLUtils.destroyBuffer(uvsBuffer);
		colorsBuffer = GLUtils.destroyBuffer(colorsBuffer);
		indicesBuffer = GLUtils.destroyBuffer(indicesBuffer);
		#end
	}
	
	public function generateQuadData(width:Float = 100, height:Float = 100, color:FlxColor = FlxColor.WHITE):TrianglesData
	{
		vertices[0] = 0.0;
		vertices[1] = 0.0;
		vertices[2] = width;
		vertices[3] = 0.0;
		vertices[4] = width;
		vertices[5] = height;
		vertices[6] = 0;
		vertices[7] = height;
		
		uvs[0] = 0.0;
		uvs[1] = 0.0;
		uvs[2] = 1.0;
		uvs[3] = 0.0;
		uvs[4] = 1.0;
		uvs[5] = 1.0;
		uvs[6] = 0;
		uvs[7] = 1.0;
		
		colors[0] = color;
		colors[1] = color;
		colors[2] = color;
		colors[3] = color;
		
		indices[0] = 0;
		indices[1] = 1;
		indices[2] = 2;
		indices[3] = 2;
		indices[4] = 3;
		indices[5] = 0;
		
		return this;
	}
	
	private function set_vertices(value:DrawData<Float>):DrawData<Float>
	{
		verticesDirty = verticesDirty || (value != null);
		return vertices = value;
	}
	
	private function set_uvs(value:DrawData<Float>):DrawData<Float>
	{
		uvtDirty = uvtDirty || (value != null);
		return uvs = value;
	}
	
	private function set_colors(value:DrawData<FlxColor>):DrawData<FlxColor>
	{
		colorsDirty = colorsDirty || (value != null);
		return colors = value;
	}
	
	private function set_indices(value:DrawData<Int>):DrawData<Int>
	{
		indicesDirty = indicesDirty || (value != null);
		return indices = value;
	}
	
	private function set_dirty(value:Bool):Bool
	{
		verticesDirty = uvtDirty = colorsDirty = indicesDirty = value;
		return dirty = value;
	}
	
	private function get_numIndices():Int
	{
		return (indices != null) ? indices.length : 0;
	}
	
	private function get_numTriangles():Int
	{
		return Std.int(numIndices / 3);
	}
	
	private function get_colored():Bool
	{
		return (colors != null) && (colors.length > 0);
	}
	
	#if FLX_RENDER_GL
	public function setContext(gl:GLRenderContext):Void
	{
		if (this.gl == null || this.gl != gl)
		{
			this.gl = gl;
			
			verticesBuffer = GL.createBuffer();
			uvsBuffer = GL.createBuffer();
			colorsBuffer = GL.createBuffer();
			indicesBuffer = GL.createBuffer();
		}
	}
	
	public function updateVertices():Void
	{
		if (vertices == null)
			return;
		
		if (verticesDirty)
		{
			if (verticesArray == null || verticesArray.length != vertices.length)
				verticesArray = new Float32Array(vertices.length);
			
			for (i in 0...vertices.length)
				verticesArray[i] = vertices[i];
			
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, verticesArray, GL.STATIC_DRAW);
			verticesDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, verticesArray);
		}
	}
	
	public function updateUV():Void
	{
		if (uvs == null)
			return;
		
		if (uvtDirty)
		{
			if (uvsArray == null || uvsArray.length != uvs.length)
				uvsArray = new Float32Array(uvs.length);
			
			for (i in 0...uvs.length)
				uvsArray[i] = uvs[i];
			
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, uvsArray, GL.STATIC_DRAW);
			uvtDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
		}
	}
	
	public function updateColors():Void
	{
		if (colors == null)
			return;
		
		if (colorsDirty)
		{
			if (colorsArray == null || colorsArray.length != colors.length)
				colorsArray = new UInt32Array(colors.length);
			
			for (i in 0...colors.length)
				colorsArray[i] = colors[i];
			
			// update the colors
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, colorsArray, GL.STATIC_DRAW);
			colorsDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
		}
	}
	
	public function updateIndices():Void
	{
		if (indices == null)
			return;
		
		if (indicesDirty)
		{
			if (indicesArray == null || indicesArray.length != indices.length)
				indicesArray = new UInt16Array(indices.length);
			
			for (i in 0...indices.length)
				indicesArray[i] = indices[i];
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indicesArray, GL.STATIC_DRAW);
			indicesDirty = false;
		}
		else
		{
			// dont need to upload!
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
		}
	}
	#end
}