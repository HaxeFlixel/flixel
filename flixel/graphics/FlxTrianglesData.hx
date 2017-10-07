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
import lime.graphics.opengl.GL;
import lime.graphics.opengl.GLBuffer;
import lime.utils.Float32Array;
import flixel.system.render.gl.GLUtils;
#end

/**
 * Utility object class for holding information for drawing 2d meshes (vertex position, uv coordinates, vertex colors, index array).
 */
class FlxTrianglesData implements IFlxDestroyable
{
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
					if (j % 2 != 0)
						mesh.uv[j] = 1 - mesh.uv[j];
				}
				for (j in 0...mesh.v2.length)
				{
					if (j % 2 != 0)
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
	 * The number of triangles this data object will draw.
	 */
	public var numTriangles(get, null):Int;
	
	/**
	 * Tells if all GL buffers should be regenerated before rendering this data object.
	 */
	public var dirty(default, set):Bool = true;
	
	/**
	 * Tells if `verticesBuffer` should be regenerated before rendering this data object.
	 */
	public var verticesDirty(default, set):Bool = true;
	/**
	 * Tells if `uvsBuffer` should be regenerated before rendering this data object.
	 */
	public var uvtDirty(default, set):Bool = true;
	/**
	 * Tells if `colorsBuffer` should be regenerated before rendering this data object.
	 */
	public var colorsDirty(default, set):Bool = true;
	/**
	 * Tells if `indicesBuffer` should be regenerated before rendering this data object.
	 */
	public var indicesDirty(default, set):Bool = true;
	
	/**
	 * A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	 * If you change it's contents directly then you should reset it manually, like:
	 * ```
	 * var vertices = data.vertices;
	 * vertices[0] = 0.0;
	 * data.vertices = vertices;
	 * ```
	 * (if not, then you won't see any changes on native/js targets)
	 */
	public var vertices(default, set):Vector<Float>;
	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 * If you change it's contents directly then you should reset it, like:
	 * ```
	 * var uvs = data.uvs;
	 * uvs[0] = 0.0;
	 * data.uvs = uvs;
	 * (if not, then you won't see any changes on native/js targets)
	 * ```
	 */
	public var uvs(default, set):Vector<Float>;
	/**
	 * A `Vector` of colors for each vertex.
	 * If you change it's contents directly then you should reset it, like:
	 * ```
	 * var colors = data.colors;
	 * colors[0] = FlxColor.RED;
	 * data.colors = colors;
	 * ```
	 * (if not, then you won't see any changes on native/js targets)
	 */
	public var colors(default, set):Vector<FlxColor>;
	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 *  If you change it's contents directly then you should reset it, like:
	 * ```
	 * var indices = data.indices;
	 * indices[0] = 1;
	 * data.indices = indices;
	 * ```
	 * (if not, then you won't see any changes on native/js targets)
	 */
	public var indices(default, set):Vector<Int>;
	
	/**
	 * Bounding box for all vertices of this data object.
	 */
	public var bounds(default, null):FlxRect = FlxRect.get();
	
	/**
	 * Max number of vertices in this object.
	 * It could be higher than the number of actually added vertices to this object.
	 * To increase `vertexCapacity` you should call `extendVertices()` method.
	 */
	public var vertexCapacity(default, null):Int = 0;
	
	/**
	 * Max number of indices in this object.
	 * It could be higher than the number of actually added indices to this object.
	 * To increase `ndexCapacity` you should call `extendIndices()` method.
	 */
	public var indexCapacity(default, null):Int = 0;
	
	#if FLX_RENDER_GL
	/**
	 * Internal typed arrays and buffers used only for OpenGL rendering
	 */
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
	
	/**
	 * Number of actually added vertices to this object.
	 */
	public var vertexCount(default, null):Int = 0;
	/**
	 * Number of actually added indices to this object.
	 */
	public var indexCount(default, null):Int = 0;
	
	/**
	 * Helper variable, helps to track number of previously added vertices to this data object.
	 */
	private var trianglesOffset:Int = 0;
	
	/**
	 * Data object constructor.
	 * 
	 * @param	numVertices	max number of vertices for this object. You'll be able to increase this number later by calling `extendVertices()` method.
	 * @param	numIndices	max number of indices for this object. You'll be able to increase this number later by calling `extendIndices()` method.
	 */
	public function new(numVertices:Int = 0, numIndices:Int = 0) 
	{
		this.vertexCapacity = (numVertices > 0) ? numVertices : 0;
		this.indexCapacity = (numIndices > 0) ? numIndices : 0;
		
		vertices = new Vector<Float>();
		uvs = new Vector<Float>();
		colors = new Vector<FlxColor>();
		indices = new Vector<Int>();
		
		#if FLX_RENDER_GL
		verticesArray = new Float32Array(vertexCapacity << 1);
		uvsArray = new Float32Array(vertexCapacity << 1);
		colorsArray = new UInt32Array(vertexCapacity);
		indicesArray = new UInt16Array(indexCapacity);
		
		for (i in 0...vertexCapacity)
			colorsArray[i] = FlxColor.WHITE;
		#end
	}
	
	public function destroy():Void
	{
		vertices = null;
		uvs = null;
		colors = null;
		indices = null;
		
		bounds = FlxDestroyUtil.put(bounds);
		
		vertexCount = 0;
		indexCount = 0;
		trianglesOffset = 0;
		
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
		vertices.splice(0, vertices.length);
		uvs.splice(0, uvs.length);
		colors.splice(0, colors.length);
		indices.splice(0, indices.length);
		
		vertexCount = 0;
		indexCount = 0;
		trianglesOffset = 0;
		
		dirty = true;
	}
	
	/**
	 * Updates bounding box for this object.
	 */
	public function updateBounds():Void
	{
		if (verticesDirty && vertices.length >= 6)
		{
			bounds.set(vertices[0], vertices[1], 0, 0);
			var numVertices:Int = vertices.length;
			var i:Int = 2;
			
			while (i < numVertices)
			{
				bounds.inflate(vertices[i], vertices[i + 1]);
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
		
		if (pixels == null || pixels.width < width || pixels.height < height)
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
		
		sprite.graphics.drawTriangles(vertices, indices, uvs);
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
	 * data.addVertex(0, 0);
	 * data.addVertex(100, 0);
	 * data.addVertex(0, 100);
	 * data.addTriangle(0, 1, 2);
	 * ```
	 */
	public function start():FlxTrianglesData
	{
		trianglesOffset = vertexCount;
		return this;
	}
	
	/**
	 * Adds vertex information to this data object.
	 * 
	 * @param	x		vertex x posisition
	 * @param	y		vertex y position
	 * @param	u		vertex u texture coordinate. Set it to anything (for example, to `0.0`) if the sprite using this data object doesn't use texture.
	 * @param	v		vertex v texture coordinate. Set it to anything (for example, to `0.0`) if the sprite using this data object doesn't use texture.
	 * @param	color	vertex color. `FlxColor.WHITE` is the default value.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public function addVertex(x:Float, y:Float, u:Float = 0.0, v:Float = 0.0, color:FlxColor = FlxColor.WHITE):FlxTrianglesData
	{
		if (vertexCount >= vertexCapacity)
		{
			trace("Can't add new vertex. Max vertex count reached. Call extendVertices()!");
			return this;
		}
		
		var pos:Int = vertexCount << 1;
		
		vertices[pos] = x;
		vertices[pos + 1] = y;
		
		uvs[pos] = u;
		uvs[pos + 1] = v;
		
		colors[vertexCount] = color;
		
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
		if (indexCount >= indexCapacity)
		{
			trace("Can't add new triangle. Max index count reached. Call extendIndices()!");
			return this;
		}
		
		var i1:Int = index1 + trianglesOffset;
		var i2:Int = index2 + trianglesOffset;
		var i3:Int = index3 + trianglesOffset;
		
		indices[indexCount] = i1;
		indices[indexCount + 1] = i2;
		indices[indexCount + 2] = i3;
		
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
	 * Adds bunch of triangles to this data object.
	 * Previously added triangles will stay in this object as well.
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
		
		extendVertices(vertexCount + numVertices);
		extendIndices(indexCount + numIndices);
		
		start();
		
		var i1:Int, i2:Int, i3:Int;
		var pos1:Int, pos2:Int;
		var colorPos:Int = vertexCount;
		
		var x:Float, y:Float;
		var color:FlxColor;
		var u:Float = 0.0;
		var v:Float = 0.0;
		
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
			}
			
			addVertex(x, y, u, v, color);
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
	 * Modifies information about vertex which had been added previously to this data object.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	x			vertex x posisition
	 * @param	y			vertex y position
	 * @param	u			vertex u texture coordinate. Set it to anything (for example, to `0`) if the sprite using this data object doesn't use texture.
	 * @param	v			vertex v texture coordinate. Set it to anything (for example, to `0`) if the sprite using this data object doesn't use texture.
	 * @param	color		vertex color. `FlxColor.WHITE` is the default value.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public function setVertex(vertexId:Int, x:Float, y:Float, u:Float = 0.0, v:Float = 0.0, color:FlxColor = FlxColor.WHITE):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		setVertexPosition(vertexId, x, y);
		setVertexUV(vertexId, u, v);
		setVertexColor(vertexId, color);
		
		return this;
	}
	
	/**
	 * Modifies positions of the vertex which had been added previously to this data object.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	x			vertex x posisition
	 * @param	y			vertex y position
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexPosition(vertexId:Int, x:Float, y:Float):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		var pos:Int = vertexId << 1;
		vertices[pos] = x;
		vertices[pos + 1] = y;
		
		#if FLX_RENDER_GL
		verticesArray[pos] = x;
		verticesArray[pos + 1] = y;
		#end
		
		verticesDirty = true;
		return this;
	}
	
	/**
	 * Gets local position of previously added vertex.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	point		point which will be filled with vertex coordinates.
	 * @return	local position of vertex with index `vertexId`.
	 */
	public function getVertexPosition(vertexId:Int, ?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return point;
		}
		
		var pos:Int = vertexId << 1;
		return point.set(vertices[pos], vertices[pos + 1]);
	}
	
	/**
	 * Sets vertex `x` coordinate
	 * 
	 * @param	vertexId	vertex index.
	 * @param	x			new value for `x` coordinate of vertex.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexX(vertexId:Int, x:Float):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		var pos:Int = vertexId << 1;
		vertices[pos] = x;
		
		#if FLX_RENDER_GL
		verticesArray[pos] = x;
		#end
		
		verticesDirty = true;
		return this;
	}
	
	/**
	 * Gets vertex `x` coordinate
	 * 
	 * @param	vertexId	vertex index.
	 * @return	`x` coordinate of vertex with `vertexId` index.
	 */
	public function getVertexX(vertexId:Int):Float
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return 0.0;
		}
		
		return vertices[vertexId << 1];
	}
	
	/**
	 * Sets vertex `y` coordinate
	 * 
	 * @param	vertexId	vertex index.
	 * @param	y			new value for `y` coordinate of vertex.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexY(vertexId:Int, y:Float):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		var pos:Int = vertexId << 1;
		vertices[pos + 1] = y;
		
		#if FLX_RENDER_GL
		verticesArray[pos + 1] = y;
		#end
		
		verticesDirty = true;
		return this;
	}
	
	/**
	 * Gets vertex `y` coordinate
	 * 
	 * @param	vertexId	vertex index.
	 * @return	`y` coordinate of vertex with `vertexId` index.
	 */
	public function getVertexY(vertexId:Int):Float
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return 0.0;
		}
		
		return vertices[(vertexId << 1) + 1];
	}
	
	/**
	 * Modifies uv texture coordinates of the vertex which had been added previously to this data object.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	u			vertex u texture coordinate. Set it to anything (for example, to `0`) if the sprite using this data object doesn't use texture.
	 * @param	v			vertex v texture coordinate. Set it to anything (for example, to `0`) if the sprite using this data object doesn't use texture.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexUV(vertexId:Int, u:Float = 0.0, v:Float = 0.0):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		var pos:Int = vertexId << 1;
		uvs[pos] = u;
		uvs[pos + 1] = v;
		
		#if FLX_RENDER_GL
		uvsArray[pos] = u;
		uvsArray[pos + 1] = v;
		#end
		
		uvtDirty = true;
		return this;
	}
	
	/**
	 * Gets texture coordinates for previously added vertex.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	point		point which will be filled with texture coordinates of vertex.
	 * @return	texture coordinates of vertex with `vertexId` index.
	 */
	public function getVertexUV(vertexId:Int, ?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return point;
		}
		
		var pos:Int = vertexId << 1;
		return point.set(uvs[pos], uvs[pos + 1]);
	}
	
	/**
	 * Sets texture `u` coordinate for vertex with `vertexId` index.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	u			new value for `u` texture coordinate of vertex.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexU(vertexId:Int, u:Float = 0.0):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		var pos:Int = vertexId << 1;
		uvs[pos] = u;
		
		#if FLX_RENDER_GL
		uvsArray[pos] = u;
		#end
		
		uvtDirty = true;
		return this;
	}
	
	/**
	 * Gets vertex `u` texture coordinate
	 * 
	 * @param	vertexId	vertex index.
	 * @return	`u` coordinate of vertex with `vertexId` index.
	 */
	public function getVertexU(vertexId:Int):Float
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return 0.0;
		}
		
		return uvs[vertexId << 1];
	}
	
	/**
	 * Sets texture `v` coordinate for vertex with `vertexId` index.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	v			new value for `v` texture coordinate of vertex.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexV(vertexId:Int, v:Float = 0.0):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		var pos:Int = vertexId << 1;
		uvs[pos + 1] = v;
		
		#if FLX_RENDER_GL
		uvsArray[pos + 1] = v;
		#end
		
		uvtDirty = true;
		return this;
	}
	
	/**
	 * Gets vertex `v` texture coordinate
	 * 
	 * @param	vertexId	vertex index.
	 * @return	`v` coordinate of vertex with `vertexId` index.
	 */
	public function getVertexV(vertexId:Int):Float
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return 0.0;
		}
		
		return uvs[(vertexId << 1) + 1];
	}
	
	/**
	 * Modifies color of the vertex which had been added previously to this data object.
	 * 
	 * @param	vertexId	vertex index.
	 * @param	color		vertex color. `FlxColor.WHITE` is the default value.
	 * @return	this data object. Might be usefull for chaining.
	 */
	public inline function setVertexColor(vertexId:Int, color:FlxColor = FlxColor.WHITE):FlxTrianglesData
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return this;
		}
		
		colors[vertexId] = color;
		
		#if FLX_RENDER_GL
		colorsArray[vertexId] = color;
		#end
		
		colorsDirty = true;
		return this;
	}
	
	/**
	 * Gets vertex color
	 * 
	 * @param	vertexId	vertex index.
	 * @return	color of vertex with `vertexId` index.
	 */
	public function getVertexColor(vertexId:Int):FlxColor
	{
		if (vertexId > vertexCount)
		{
			trace("Vertex with id " + vertexId + " hasn't been added yet.");
			return FlxColor.WHITE;
		}
		
		return colors[vertexId];
	}
	
	/**
	 * Sets max vertices number for this data object, so you will be able to draw more vertices, but this object will require more memory.
	 * 
	 * @param	value		new max number of vertices. If you specify number greater than `MAX_VERTICES`, then exception will be thrown.
	 * @param	saveData	Tells if we should copy old data in extended arrays. If false then all the data previosly added to this object will be lost.
	 */
	public function extendVertices(value:Int, saveData:Bool = true):Void
	{
		if (value > vertexCapacity)
		{
			#if FLX_RENDER_GL
			var newVertices = new Float32Array(value << 1);
			var newUVs = new Float32Array(value << 1);
			var newColors = new UInt32Array(value);
			
			if (saveData)
			{
				var oldVertLen = vertexCount << 1;
				for (i in 0...oldVertLen)
				{
					newVertices[i] = verticesArray[i];
					newUVs[i] = uvsArray[i];
				}
				
				for (i in 0...vertexCount)
				{
					newColors[i] = colorsArray[i];
				}
				
				for (i in vertexCount...value)
				{
					newColors[i] = FlxColor.WHITE;
				}
			}
			else
			{
				for (i in 0...value)
				{
					newColors[i] = FlxColor.WHITE;
				}
			}
			
			verticesArray = newVertices;
			uvsArray = newUVs;
			colorsArray = newColors;
			#end
			
			vertexCapacity = value;
		}
	}
	
	/**
	 * Sets max indices number for this data object, so you will be able to draw more triangles, but this object will require more memory.
	 * 
	 * @param	value	new max number of indices. If you specify number greater than `MAX_INDICES`, then exception will be thrown.
	 * @param	saveData	Tells if we should copy old data in extended index array. If false then all the index data previosly added to this object will be lost.
	 */
	public function extendIndices(value:Int, saveData:Bool = true):Void
	{
		if (value > indexCapacity)
		{
			#if FLX_RENDER_GL
			var newIndices = new UInt16Array(value);
			
			if (saveData)
			{
				for (i in 0...indexCount)
				{
					newIndices[i] = indicesArray[i];
				}
			}
			
			indicesArray = newIndices;
			#end
			
			indexCapacity = value;
		}
	}
	
	private function set_vertices(value:Vector<Float>):Vector<Float>
	{
		verticesDirty = verticesDirty || (value != null);
		vertices = value;
		vertexCount = 0;
		trianglesOffset = 0;
		
		if (value != null)
		{
			extendVertices(value.length >> 1, false);
			vertexCount = value.length >> 1;
			trianglesOffset = vertexCount;
			
			if (uvs != null) uvs.length = value.length;
			
			#if FLX_RENDER_GL
			for (i in 0...value.length)
				verticesArray[i] = value[i];
			#end
		}
		
		return value;
	}
	
	private function set_uvs(value:Vector<Float>):Vector<Float>
	{
		uvtDirty = uvtDirty || (value != null);
		uvs = value;
		
		if (value != null)
		{
			extendVertices(value.length >> 1, false);
			
			#if FLX_RENDER_GL
			for (i in 0...value.length)
				uvsArray[i] = value[i];
			#end
		}
		
		return value;
	}
	
	private function set_colors(value:Vector<FlxColor>):Vector<FlxColor>
	{
		colorsDirty = colorsDirty || (value != null);
		colors = value;
		
		if (value != null)
		{
			var numColors:Int = value.length;
			extendVertices(numColors, false);
			
			#if FLX_RENDER_GL
			for (i in 0...value.length)
				colorsArray[i] = value[i];
			#end
		}
		
		return value;
	}
	
	private function set_indices(value:Vector<Int>):Vector<Int>
	{
		indicesDirty = indicesDirty || (value != null);
		indices = value;
		
		indexCount = 0;
		
		if (value != null)
		{
			var numIndices:Int = value.length;
			extendIndices(numIndices, false);
			indexCount = numIndices;
			
			#if FLX_RENDER_GL
			for (i in 0...value.length)
				indicesArray[i] = value[i];
			#end
		}
		
		return value;
	}
	
	private function set_dirty(value:Bool):Bool
	{
		verticesDirty = uvtDirty = colorsDirty = indicesDirty = value;
		return dirty = value;
	}
	
	private function set_verticesDirty(value:Bool):Bool
	{
		return verticesDirty = value;
	}
	
	private function set_uvtDirty(value:Bool):Bool
	{
		return uvtDirty = value;
	}
	
	private function set_colorsDirty(value:Bool):Bool
	{
		return colorsDirty = value;
	}
	
	private function set_indicesDirty(value:Bool):Bool
	{
		return indicesDirty = value;
	}
	
	private function get_numTriangles():Int
	{
		return Std.int(indexCount / 3);
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
	
	/**
	 * Update and upload vertex gl buffer to GPU.
	 */
	public function updateVertices():Void
	{
		if (verticesArray == null || vertices == null)
			return;
		
		var numBytes:Int = (vertexCapacity << 1) * Float32Array.BYTES_PER_ELEMENT;
		
		if (verticesDirty)
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, verticesArray, GL.STATIC_DRAW);
			verticesDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
		}
	}
	
	/**
	 * Update and upload uv gl buffer to GPU.
	 */
	public function updateUV():Void
	{
		if (uvsArray == null)
			return;
			
		if (uvtDirty)
		{
			var numBytes:Int = (vertexCapacity << 1) * Float32Array.BYTES_PER_ELEMENT;
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, uvsArray, GL.STATIC_DRAW);
			uvtDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
		}
	}
	
	/**
	 * Update and upload color gl buffer to GPU.
	 */
	public function updateColors():Void
	{
		if (colorsArray == null)
			return;
		
		if (colorsDirty)
		{
			var numBytes:Int = vertexCapacity * UInt32Array.BYTES_PER_ELEMENT;
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, colorsArray, GL.STATIC_DRAW);
			colorsDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
		}
	}
	
	/**
	 * Update and upload index gl buffer to GPU.
	 */
	public function updateIndices():Void
	{
		if (indicesArray == null || indices == null)
			return;
		
		if (indicesDirty)
		{
			var numBytes:Int = indexCapacity * UInt16Array.BYTES_PER_ELEMENT;
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