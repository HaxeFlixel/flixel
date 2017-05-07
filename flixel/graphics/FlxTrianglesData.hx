package flixel.graphics;

import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.ds.StringMap;
import haxe.xml.Fast;
import openfl.Assets;
import openfl.Vector;
import openfl.display.BitmapData;
import openfl.display.Sprite;

#if FLX_RENDER_GL
import lime.graphics.GLRenderContext;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import flixel.system.render.gl.GLUtils;
#end

// TODO: restrict direct modifications of vertices/uvs/colors/indices arrays...

class FlxTrianglesData implements IFlxDestroyable
{
	public static inline var MAX_VERTICES:Int = 65536;
	
	public static inline var MAX_INDICES:Int = 65536;
	
	/**
	 * Helper variables for bounding box calculations.
	 */
	private static var tempBounds:FlxRect = new FlxRect();
	private static var tempPoint:FlxPoint = new FlxPoint();
	
	private static var sprite:Sprite = new Sprite();
	private static var matrix:FlxMatrix = new FlxMatrix();
	
	/**
	 * Loads all the sprites packed by TexturePacker with polygon algorithm.
	 * Export format: XML (generic) with Algorithm: Polygon
	 * @author loudo (see https://github.com/loudoweb/AtlasTriangle)
	 * 
	 * @param	Description		Path to Xml file or its contents.
	 * @param	TextureSize		The size of texture for atlas (required for uv calculations).
	 * @return	Collection of `FlxTrianglesData` objects for each of packed sprite.
	 */
	public static function fromTexturePackerXml(Description:String, TextureSize:FlxPoint):StringMap<FlxTrianglesData>
	{
		if (Assets.exists(Description))
			Description = Assets.getText(Description);
		
		var map:StringMap<FlxTrianglesData> = new StringMap<FlxTrianglesData>();
		var fast:Fast = new Fast(Xml.parse(Description).firstElement());
		
		for (sprite in fast.nodes.sprite)
		{
			var indices:Array<Int> = sprite.node.triangles.innerData.toString().split(' ').map(function (str:String) return Std.parseInt(str));
			var uv:Array<Int> = sprite.node.verticesUV.innerData.toString().split(' ').map(function (str:String) return Std.parseInt(str));
			var vertices:Array<Float> = sprite.node.vertices.innerData.toString().split(' ').map(function (str:String) return Std.parseFloat(str));
			
			var drawIndices:Vector<Int> = new Vector<Int>();
			for (i in 0...indices.length)
				drawIndices[i] = indices[i];
			
			var drawUV:Vector<Float> = new Vector<Float>();
			var uvCoord:Float;
			for (i in 0...uv.length)
			{
				uvCoord = uv[i];
				uvCoord /= (i % 2 == 0) ? TextureSize.x : TextureSize.y;
				drawUV[i] = uvCoord;
			}
			
			var drawVertices:Vector<Float> = new Vector<Float>();
			for (i in 0...vertices.length)
				drawVertices[i] = vertices[i];
			
			var data:FlxTrianglesData = new FlxTrianglesData();
			data.vertices = drawVertices;
			data.uvs = drawUV;
			data.indices = drawIndices;
			
			map.set(sprite.att.n, data);
		}
		
		return map;
	}
	
	/**
	 * Loads all the sprites packed by SpriteUV2.
	 * @author loudo (see https://github.com/loudoweb/AtlasTriangle)
	 * 
	 * @param	Description		Path to Json file or its contents.
	 * @param	TopLeft 		Fix origin to topleft by default (SpriteUV set it to bottom left).
	 * @return	Collection of `FlxTrianglesData` objects for each of packed sprite.
	 */
	public static function fromSpriteUV2(Description:String, TopLeft:Bool = true):StringMap<FlxTrianglesData>
	{
		if (Assets.exists(Description))
			Description = Assets.getText(Description);
		
		var data:SpriteUV = haxe.Json.parse(Description);
		var map:StringMap<FlxTrianglesData> = new StringMap<FlxTrianglesData>();
		
		for (i in 0...data.mesh.length)
		{
			var mesh = data.mesh[i];
			
			if (TopLeft)
			{
				for (j in 0...mesh.uv.length)
				{
					if(j % 2 != 0)
						mesh.uv[j] = 1 - mesh.uv[j];
				}
				for (j in 0...mesh.v2.length)
				{
					if(j % 2 != 0)
						mesh.v2[j] = 1 - mesh.v2[j];
				}
			}
			
			var drawVertices:Vector<Float> = new Vector<Float>();
			for (i in 0...mesh.v2.length)
				drawVertices[i] = mesh.v2[i];
			
			var drawUV:Vector<Float> = new Vector<Float>();
			for (i in 0...mesh.uv.length)
				drawUV[i] = mesh.uv[i];
			
			var drawIndices:Vector<Int> = new Vector<Int>();
			for (i in 0...mesh.tri.length)
				drawIndices[i] = mesh.tri[i];
			
			var data:FlxTrianglesData = new FlxTrianglesData();
			data.vertices = drawVertices;
			data.uvs = drawUV;
			data.indices = drawIndices;
			
			map.set(mesh.name, data);
		}
		
		return map;
	}
	
	/**
	 * Max number of vertices for this data object.
	 */
	public var maxVertices(default, null):Int; // TODO: maybe add setter...
	
	/**
	 * Max number on indices for this data object.
	 */
	public var maxIndices(default, null):Int; // TODO: maybe add setter...
	
	/**
	 * Number of vertex indices in this data object.
	 */
	public var numIndices(get, null):Int;
	
	/**
	 * The number of triangles this data object will draw.
	 */
	public var numTriangles(get, null):Int;
	
	/**
	 * Tells if all GL buffers should be regenerated before rendering this data object.
	 */
	public var dirty(default, set):Bool = true;
	
	/**
	 * Tells if `verticesBuffer` should be regenerated before rendering this data object.
	 * Set it to `true` when you change values in `vertices` vector directly (like `vertices[0] = x;`).
	 */
	public var verticesDirty:Bool = true;
	/**
	 * Tells if `uvsBuffer` should be regenerated before rendering this data object.
	 * Set it to `true` when you change values in `uvs` vector directly (like `uvs[0] = 0.0;`).
	 */
	public var uvtDirty:Bool = true;
	/**
	 * Tells if `colorsBuffer` should be regenerated before rendering this data object.
	 * Set it to `true` when you change values in `colors` vector directly (like `colors[0] = FlxColor.RED;`).
	 */
	public var colorsDirty:Bool = true;
	/**
	 * Tells if `indicesBuffer` should be regenerated before rendering this data object.
	 * Set it to `true` when you change values in `indices` vector directly (like `indices[0] = 0;`).
	 */
	public var indicesDirty:Bool = true;
	
	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 */
	public var vertices(get, set):Vector<Float>;
	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	public var uvs(get, set):Vector<Float>;
	/**
	 * A `Vector` of colors for each vertex.
	 */
	public var colors(get, set):Vector<FlxColor>;
	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices(get, set):Vector<Int>;
	
	/**
	 * Bounding box for all vertices of this data object.
	 */
	public var bounds(default, null):FlxRect = FlxRect.get();
	
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
	
	private var _vertices:Vector<Float> = new Vector<Float>();
	private var _uvs:Vector<Float> = new Vector<Float>();
	private var _colors:Vector<FlxColor> = new Vector<FlxColor>();
	private var _indices:Vector<Int> = new Vector<Int>();
	
	/**
	 * Helper variables, helps to track number of vertices and indices added to this data object.
	 */
	private var vertexCount:Int = 0;
	private var indexCount:Int = 0;
	private var trianglesOffset:Int = 0;
	
	/**
	 * Data object constructor
	 * 
	 * @param	maxVertices	max number of vertices for this object. You'll be able to increase this number later by calling `setMaxVertices()` method
	 * @param	maxIndices	max number of indices for this object. You'll be able to increase this number later by calling `setMaxIndices()` method
	 */
	public function new(maxVertices:Int = 4092, maxIndices:Int = 4092) 
	{
		this.maxVertices = (maxVertices < MAX_VERTICES) ? maxVertices : MAX_VERTICES;
		this.maxIndices = (maxIndices < MAX_INDICES) ? maxIndices : MAX_INDICES;
		
		#if FLX_RENDER_GL
		verticesArray = new Float32Array(maxVertices << 1);
		uvsArray = new Float32Array(maxVertices << 1);
		colorsArray = new UInt32Array(maxVertices);
		indicesArray = new UInt16Array(maxIndices);
		
		for (i in 0...maxVertices)
			colorsArray[i] = FlxColor.WHITE;
		#end
	}
	
	public function destroy():Void
	{
		_vertices = null;
		_uvs = null;
		_colors = null;
		_indices = null;
		
		bounds = FlxDestroyUtil.put(bounds);
		
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
	
	/**
	 * Clears all data stored in this object.
	 * Nothing will be rendered after you call this method.
	 * You'll need to add new vertices again.
	 */
	public function clear():Void
	{
		_vertices.splice(0, _vertices.length);
		_uvs.splice(0, _uvs.length);
		_colors.splice(0, _colors.length);
		_indices.splice(0, _indices.length);
		
		vertexCount = 0;
		indexCount = 0;
		trianglesOffset = 0;
		
		dirty = true;
	}
	
	/**
	 * Fills this object with data to draw single quad
	 * 
	 * @param	width	width of the quad.
	 * @param	height	height of the quad.
	 * @param	color	color of the quad.
	 * @return	This data object
	 */
	public function generateQuadData(width:Float = 100, height:Float = 100, color:FlxColor = FlxColor.WHITE):FlxTrianglesData
	{
		clear();
		
		_vertices[0] = 0.0;
		_vertices[1] = 0.0;
		_vertices[2] = width;
		_vertices[3] = 0.0;
		_vertices[4] = width;
		_vertices[5] = height;
		_vertices[6] = 0;
		_vertices[7] = height;
		
		_uvs[0] = 0.0;
		_uvs[1] = 0.0;
		_uvs[2] = 1.0;
		_uvs[3] = 0.0;
		_uvs[4] = 1.0;
		_uvs[5] = 1.0;
		_uvs[6] = 0;
		_uvs[7] = 1.0;
		
		_colors[0] = color;
		_colors[1] = color;
		_colors[2] = color;
		_colors[3] = color;
		
		_indices[0] = 0;
		_indices[1] = 1;
		_indices[2] = 2;
		_indices[3] = 2;
		_indices[4] = 3;
		_indices[5] = 0;
		
		return this;
	}
	
	/**
	 * Updates bounding box for this object.
	 */
	public function updateBounds():Void
	{
		if (verticesDirty && _vertices.length >= 6)
		{
			bounds.set(_vertices[0], _vertices[1], 0, 0);
			var numVertices:Int = _vertices.length;
			var i:Int = 2;
			
			while (i < numVertices)
			{
				bounds.inflate(_vertices[i], _vertices[i + 1]);
				i += 2;
			}
		}
	}
	
	/**
	 * Calculates transformed bounding object.
	 * 
	 * @param	matrix	Matrix to apply to bounding box.
	 * @return	Transformed bounding box.
	 */
	public function getTransformedBounds(matrix:FlxMatrix):FlxRect
	{
		var tx:Float = matrix.transformX(bounds.x, bounds.y);
		var ty:Float = matrix.transformY(bounds.x, bounds.y);
		tempBounds.set(tx, ty, 0, 0);
		
		tx = matrix.transformX(bounds.right, bounds.y);
		ty = matrix.transformY(bounds.right, bounds.y);
		tempPoint.set(tx, ty);
		tempBounds.unionWithPoint(tempPoint);
		
		tx = matrix.transformX(bounds.right, bounds.bottom);
		ty = matrix.transformY(bounds.right, bounds.bottom);
		tempPoint.set(tx, ty);
		tempBounds.unionWithPoint(tempPoint);
		
		tx = matrix.transformX(bounds.x, bounds.bottom);
		ty = matrix.transformY(bounds.x, bounds.bottom);
		tempPoint.set(tx, ty);
		tempBounds.unionWithPoint(tempPoint);
		
		return tempBounds;
	}
	
	/**
	 * Updates `pixels` data by drawing data of this object.
	 */
	public function getBitmapData(pixels:BitmapData, texture:FlxGraphic, color:FlxColor):BitmapData
	{
		updateBounds();
		
		var width:Int = Math.ceil(bounds.width);
		var height:Int = Math.ceil(bounds.height);
		
		if (pixels == null || pixels.width != width || pixels.height != height)
		{
			pixels = FlxDestroyUtil.dispose(pixels);
			pixels = new BitmapData(width, height, true, FlxColor.TRANSPARENT);
		}
		else
		{
			pixels.fillRect(pixels.rect, FlxColor.TRANSPARENT);
		}
		
		sprite.graphics.clear();
		
		if (texture != null)
			sprite.graphics.beginBitmapFill(texture.bitmap);
		else
			sprite.graphics.beginFill(color);
		
		sprite.graphics.drawTriangles(_vertices, _indices, _uvs);
		sprite.graphics.endFill();
		
		matrix.identity();
		matrix.translate( -bounds.x, -bounds.y);
		
		pixels.draw(sprite, matrix);
		return pixels;
	}
	
	/**
	 * Starts tracking vertices you'll add to this object.
	 * Call it BEFORE adding new vertices. For example:
	 * ```
	 * var data:FlxTrianglesData = new FlxTrianglesData();
	 * data.start();
	 * data.addColorVertex(0, 0);
	 * data.addColorVertex(100, 0);
	 * data.addColorVertex(0, 100);
	 * data.addTriangle(0, 1, 2);
	 * ```
	 */
	public function start():FlxTrianglesData
	{
		trianglesOffset = vertexCount;
		return this;
	}
	
	/**
	 * Adds textured vertex to this data object
	 * 
	 * @param	x		vertex x posisition
	 * @param	y		vertex y position
	 * @param	u		vertex u texture coordinate
	 * @param	v		vertex v texture coordinate
	 * @param	color	vertex color. `FlxColor.WHITE` is the default value.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public function addTexturedVertex(x:Float, y:Float, u:Float, v:Float, color:FlxColor = FlxColor.WHITE):FlxTrianglesData
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
		
		verticesDirty = uvtDirty = colorsDirty = true;
		vertexCount++;
		
		return this;
	}
	
	/**
	 * Adds non-textured vertex to this data object
	 * 
	 * @param	x		vertex x posisition
	 * @param	y		vertex y position
	 * @param	color	vertex color. `FlxColor.WHITE` is the default value.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public function addColorVertex(x:Float, y:Float, color:FlxColor = FlxColor.WHITE):FlxTrianglesData
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
		
		verticesDirty = colorsDirty = true;
		vertexCount++;
		
		return this;
	}
	
	/**
	 * Adds indices for added vertices.
	 * This way you can modify index buffer.
	 * See `start()` method documentation for usage example.
	 * 
	 * @param	index1	the first index of the triangle
	 * @param	index2	the second index of the triangle
	 * @param	index3	the third index of the triangle
	 * @return	this data object. Might be usefull for chaining.
	 */
	public function addTriangle(index1:Int, index2:Int, index3:Int):FlxTrianglesData
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
		
		indicesDirty = true;
		indexCount += 3;
		
		return this;
	}
	
	/**
	 * Adds bunch of triangles to this data object.
	 * Previously added triangle will stay in this object as well
	 * 
	 * @param	vertices	array of vertex coordinates pairs.
	 * @param	uv			array of vertex texture coordinates pairs. Optional, only required if you add textured vertices.
	 * @param	indices		array of vertex indices.
	 * @param	colors		array of colors for each of the vertices. Optional, `FlxColor.WHITE` color will be used if you skip this parameter.
	 */
	public function addTriangles(vertices:Vector<Float>, ?uv:Vector<Float>, indices:Vector<Int>, ?colors:Vector<FlxColor>):FlxTrianglesData
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
	
	/**
	 * Sets max vertices number for this data object.
	 * Will erase all data previosly added to this object.
	 * 
	 * @param	value	new max number of vertices. If you specify number greater than `MAX_VERTICES`, then exception will be thrown.
	 */
	public function setMaxVertices(value:Int):Void
	{
		if (value > maxVertices)
		{
			if (value > MAX_VERTICES)
				throw "Can't draw over " + MAX_VERTICES + " vertices in one draw call!";
			
			#if FLX_RENDER_GL
			verticesArray = new Float32Array(value << 1);
			uvsArray = new Float32Array(value << 1);
			colorsArray = new UInt32Array(value);
			
			for (i in 0...value)
				colorsArray[i] = FlxColor.WHITE;
			#end
			
			maxVertices = value;
			
			vertexCount = 0;
			trianglesOffset = 0;
		}
	}
	
	/**
	 * Sets max indices number for this data object.
	 * Will erase all index data previosly added to this object.
	 * 
	 * @param	value	new max number of indices. If you specify number greater than `MAX_INDICES`, then exception will be thrown.
	 */
	public function setMaxIndices(value:Int):Void
	{
		if (value > maxIndices)
		{
			if (value > MAX_INDICES)
				throw "Can't draw over " + MAX_INDICES + " indices in one draw call!";
			
			#if FLX_RENDER_GL
			indicesArray = new UInt16Array(value);
			#end
			
			maxIndices = value;
			indexCount = 0;
		}
	}
	
	private function get_vertices():Vector<Float>
	{
		return _vertices;
	}
	
	private function set_vertices(value:Vector<Float>):Vector<Float>
	{
		verticesDirty = verticesDirty || (value != null);
		_vertices = value;
		
		vertexCount = 0;
		trianglesOffset = 0;
		
		if (value != null)
		{
			setMaxVertices(value.length >> 1);
			vertexCount = value.length >> 1;
			trianglesOffset = vertexCount;
		}
		
		return value;
	}
	
	private function get_uvs():Vector<Float>
	{
		return _uvs;
	}
	
	private function set_uvs(value:Vector<Float>):Vector<Float>
	{
		uvtDirty = uvtDirty || (value != null);
		_uvs = value;
		
		if (value != null)
		{
			setMaxVertices(value.length >> 1);
		}
		
		return value;
	}
	
	private function get_colors():Vector<FlxColor>
	{
		return _colors;
	}
	
	private function set_colors(value:Vector<FlxColor>):Vector<FlxColor>
	{
		colorsDirty = colorsDirty || (value != null);
		_colors = value;
		
		if (value != null)
		{
			var numColors:Int = value.length;
			setMaxVertices(numColors);
		}
		
		return value;
	}
	
	private function get_indices():Vector<Int>
	{
		return _indices;
	}
	
	private function set_indices(value:Vector<Int>):Vector<Int>
	{
		indicesDirty = indicesDirty || (value != null);
		_indices = value;
		
		indexCount = 0;
		
		if (value != null)
		{
			var numIndices:Int = value.length;
			setMaxIndices(numIndices);
			indexCount = numIndices;
		}
		
		return value;
	}
	
	private function set_dirty(value:Bool):Bool
	{
		verticesDirty = uvtDirty = colorsDirty = indicesDirty = value;
		return dirty = value;
	}
	
	private function get_numIndices():Int
	{
		return indexCount;
	}
	
	private function get_numTriangles():Int
	{
		return Std.int(numIndices / 3);
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
		if (verticesArray == null || _vertices == null)
			return;
		
		var numBytes:Int = (maxVertices << 1) * Float32Array.BYTES_PER_ELEMENT;
		
		if (verticesDirty)
		{
			vertexCount = _vertices.length >> 1;
			
			for (i in 0..._vertices.length)
				verticesArray[i] = _vertices[i];
			
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
	
	public function updateUV():Void
	{
		if (uvsArray == null)
			return;
			
		if (uvtDirty)
		{
			for (i in 0..._uvs.length)
				uvsArray[i] = _uvs[i];
			
			var numBytes:Int = (maxVertices << 1) * Float32Array.BYTES_PER_ELEMENT;
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, uvsArray, GL.STATIC_DRAW);
			uvtDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
		}
	}
	
	public function updateColors():Void
	{
		if (colorsArray == null)
			return;
		
		if (colorsDirty)
		{
			for (i in 0..._colors.length)
				colorsArray[i] = _colors[i];
			
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
	
	public function updateIndices():Void
	{
		if (indicesArray == null || indices == null)
			return;
		
		if (indicesDirty)
		{
			indexCount = _indices.length;
			
			for (i in 0...indexCount)
				indicesArray[i] = _indices[i];
			
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
}

typedef SpriteUV = {
  var mat:Material;
  var mesh:Array<Mesh>;
}
typedef Material = {
  var name:String;
  var txName:Array<String>;
}
typedef Mesh = {
  var mat:String;
  var name:String;
  var pos:MeshPos;
  var tri:Array<Int>;
  var uv:Array<Float>;
  var v2:Array<Float>;
}
typedef MeshPos = {
	var x:Float;
	var y:Float;
	var z:Float;
}