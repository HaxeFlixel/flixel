package flixel.graphics;
import flixel.util.FlxColor;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import openfl.Vector;
import openfl.gl.GL;
import openfl.utils.Float32Array;

// TODO: merge it with FlxTrianglesData
// TODO: document it...

/**
 * ...
 * @author Zaphod
 */
class FlxTrianglesBatchData extends FlxTrianglesData 
{
	public static inline var MAX_VERTICES:Int = 65536;
	
	public static inline var MAX_INDICES:Int = 65536;
	
	public var maxVertices(default, null):Int; // TODO: add setter...
	
	public var maxIndices(default, null):Int; // TODO: add setter...
	
	private var vertexCount:Int = 0;
	private var indexCount:Int = 0;
	
	private var trianglesOffset:Int = 0;
	
	public function new(maxVertices:Int = 4092, maxIndices:Int = 4092) 
	{
		super();
		
		this.maxVertices = (maxVertices < MAX_VERTICES) ? maxVertices : MAX_VERTICES;
		this.maxIndices = (maxIndices < MAX_INDICES) ? maxIndices : MAX_INDICES;
		
		#if FLX_RENDER_GL
		verticesArray = new Float32Array(maxVertices * 2);
		uvsArray = new Float32Array(maxVertices * 2);
		colorsArray = new UInt32Array(maxVertices);
		indicesArray = new UInt16Array(maxIndices);
		#end
	}
	
	/**
	 * 
	 */
	public function start():FlxTrianglesBatchData
	{
		trianglesOffset = vertexCount;
		return this;
	}
	
	/**
	 * 
	 * @param	x
	 * @param	y
	 * @param	u
	 * @param	v
	 * @param	color
	 */
	public function addTexturedVertex(x:Float, y:Float, u:Float, v:Float, color:FlxColor = FlxColor.WHITE):FlxTrianglesBatchData
	{
		if (vertexCount >= maxVertices)
		{
			trace("Can't add new vertex. Max vertex count reached!");
			return this;
		}
		
		var pos:Int = vertexCount << 1;
		
		_vertices[pos] = x;
		_vertices[pos + 1] = y;
		
		_uvs[pos] = u;
		_uvs[pos + 1] = v;
		
		_colors[vertexCount] = color;
		
		#if FLX_RENDER_GL
		verticesArray[pos] = x;
		verticesArray[pos + 1] = y;
		
		uvsArray[pos] = u;
		uvsArray[pos + 1] = v;
		
		colorsArray[vertexCount] = color;
		#end
		
		verticesDirty = uvtDirty = colorsDirty = true;
		vertexCount++;
		
		return this;
	}
	
	/**
	 * 
	 * @param	x
	 * @param	y
	 * @param	color
	 */
	public function addColorVertex(x:Float, y:Float, color:FlxColor = FlxColor.WHITE):FlxTrianglesBatchData
	{
		if (vertexCount >= maxVertices)
		{
			trace("Can't add new vertex. Max vertex count reached!");
			return this;
		}
		
		var pos:Int = vertexCount << 1;
		
		_vertices[pos] = x;
		_vertices[pos + 1] = y;
		
		_colors[vertexCount] = color;
		
		#if FLX_RENDER_GL
		verticesArray[pos] = x;
		verticesArray[pos + 1] = y;
		colorsArray[vertexCount] = color;
		#end
		
		verticesDirty = colorsDirty = true;
		vertexCount++;
		
		return this;
	}
	
	/**
	 * 
	 * @param	index1
	 * @param	index2
	 * @param	index3
	 */
	public function addTriangle(index1:Int, index2:Int, index3:Int):FlxTrianglesBatchData
	{
		if (indexCount >= maxIndices)
		{
			trace("Can't add new triangle. Max index count reached!");
			return this;
		}
		
		var i1:Int = index1 + trianglesOffset;
		var i2:Int = index2 + trianglesOffset;
		var i3:Int = index3 + trianglesOffset;
		
		_indices[indexCount] = i1;
		_indices[indexCount + 1] = i2;
		_indices[indexCount + 2] = i3;
		
		#if FLX_RENDER_GL
		indicesArray[indexCount] = i1;
		indicesArray[indexCount + 1] = i2;
		indicesArray[indexCount + 2] = i3;
		#end
		
		indicesDirty = true;
		indexCount += 3;
		
		return this;
	}
	
	/**
	 * 
	 * @param	vertices
	 * @param	uv
	 * @param	indices
	 * @param	colors
	 */
	public function addTriangles(vertices:Vector<Float>, ?uv:Vector<Float>, indices:Vector<Int>, ?colors:Vector<FlxColor>):FlxTrianglesBatchData
	{
		var numVertices:Int = vertices.length >> 1;
		var numIndices:Int = indices.length;
		
		if (vertexCount + numVertices > maxVertices)
		{
			trace("Can't add new vertices. Max vertex count reached!");
			return this;
		}
		
		if (indexCount + numIndices > maxIndices)
		{
			trace("Can't add new triangles. Max index count reached!");
			return this;
		}
		
		start();
		
		var i1:Int, i2:Int, i3:Int;
		var pos1:Int, pos2:Int;
		var colorPos:Int = vertexCount;
		
		var x:Float, y:Float;
		var u:Float, v:Float;
		var color:FlxColor;
		
		for (i in 0...numVertices)
		{
			i1 = i * 2;
			i2 = i1 + 1;
			
			x = vertices[i1];
			y = vertices[i2];
			
			color = (colors != null) ? color = colors[i] : FlxColor.WHITE;
			
			if (uv != null)
			{
				u = uvs[i1];
				v = uvs[i2];
				
				addTexturedVertex(x, y, u, v, color);
			}
			else
			{
				addColorVertex(x, y, color);
			}
			
		}
		
		var index1:Int, index2:Int, index3:Int;
		var triangles:Int = Std.int(numIndices / 3);
		
		for (i in 0...triangles)
		{
			index1 = indices[i * 3];
			index2 = indices[i * 3 + 1];
			index3 = indices[i * 3 + 2];
			
			addTriangle(index1, index2, index3);
		}
		
		return this;
	}
	
	override public function clear():Void 
	{
		super.clear();
		
		vertexCount = 0;
		indexCount = 0;
		trianglesOffset = 0;
	}
	
	#if FLX_RENDER_GL
	override public function updateVertices():Void 
	{
		if (verticesArray == null)
			return;
		
		var numBytes:Int = (2 * maxVertices) * Float32Array.BYTES_PER_ELEMENT;
		
		if (verticesDirty)
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, verticesArray, GL.STATIC_DRAW);
			verticesDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
		//	GL.bufferSubData(GL.ARRAY_BUFFER, 0, numBytes, verticesArray);
		}
	}
	
	override public function updateUV():Void 
	{
		if (uvsArray == null)
			return;
			
		if (uvtDirty)
		{
			var numBytes:Int = (2 * maxVertices) * Float32Array.BYTES_PER_ELEMENT;
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, uvsArray, GL.STATIC_DRAW);
			uvtDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
		}
	}
	
	override public function updateColors():Void 
	{
		if (colorsArray == null)
			return;
		
		if (colorsDirty)
		{
			var numBytes:Int = maxVertices * UInt32Array.BYTES_PER_ELEMENT;
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, colorsArray, GL.STATIC_DRAW);
			colorsDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
		}
	}
	
	override public function updateIndices():Void 
	{
		if (indicesArray == null)
			return;
		
		if (indicesDirty)
		{
			var numBytes:Int = maxIndices * UInt16Array.BYTES_PER_ELEMENT;
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, numBytes, indicesArray, GL.STATIC_DRAW);
			indicesDirty = false;
		}
		else
		{
			// dont need to upload!
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
		}
	}
	#end
	
	override private function set_vertices(value:Vector<Float>):Vector<Float> 
	{
		super.set_vertices(value);
		
		vertexCount = 0;
		trianglesOffset = 0;
		
		if (value != null)
		{
			updateMaxVertices(value.length >> 1);
			
			#if FLX_RENDER_GL
			for (i in 0...value.length)
			{
				verticesArray[i] = value[i];
			}
			#end
			
			vertexCount = value.length >> 1;
			trianglesOffset = vertexCount;
		}
		
		return value;
	}
	
	override private function set_uvs(value:Vector<Float>):Vector<Float> 
	{
		super.set_uvs(value);
		
		if (value != null)
		{
			updateMaxVertices(value.length >> 1);
			
			#if FLX_RENDER_GL
			for (i in 0...value.length)
			{
				uvsArray[i] = value[i];
			}
			#end
		}
		
		return value;
	}
	
	override private function set_colors(value:Vector<FlxColor>):Vector<FlxColor> 
	{
		super.set_colors(value);
		
		if (value != null)
		{
			var numColors:Int = value.length;
			updateMaxVertices(numColors);
			
			#if FLX_RENDER_GL
			for (i in 0...numColors)
				colorsArray[i] = value[i];
			#end
		}
		
		return value;
	}
	
	private function updateMaxVertices(newVertices:Int):Void
	{
		if (newVertices > maxVertices)
		{
			if (newVertices > MAX_VERTICES)
				throw "Can't draw over " + MAX_VERTICES + " vertices in one draw call!";
			
			#if FLX_RENDER_GL
			verticesArray = new Float32Array(newVertices << 1);
			uvsArray = new Float32Array(newVertices << 1);
			
			var oldColors = colorsArray;
			var oldNumColors:Int = (oldColors != null) ? oldColors.length : 0;
			colorsArray = new UInt32Array(newVertices);
			
			for (i in oldNumColors...newVertices)
				colorsArray[i] = FlxColor.WHITE;
			#end
			
			maxVertices = newVertices;
		}
	}
	
	private function updateMaxIndices(newIndices:Int):Void
	{
		if (newIndices > maxIndices)
		{
			if (numIndices > MAX_INDICES)
				throw "Can't draw over " + MAX_INDICES + " indices in one draw call!";
			
			#if FLX_RENDER_GL
			indicesArray = new UInt16Array(newIndices);
			#end
			
			maxIndices = newIndices;
		}
	}
	
	override private function set_indices(value:Vector<Int>):Vector<Int> 
	{
		super.set_indices(value);
		
		indexCount = 0;
		
		if (value != null)
		{
			var numIndices:Int = value.length;
			updateMaxVertices(numIndices);
			
			#if FLX_RENDER_GL
			for (i in 0...numIndices)
				indicesArray[i] = value[i];
			#end
			
			indexCount = numIndices;
		}
		
		return value;
	}
	
	override private function get_numIndices():Int 
	{
		return indexCount;
	}
	
}