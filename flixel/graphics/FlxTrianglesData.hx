package flixel.graphics;

import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import haxe.ds.StringMap;
import haxe.xml.Fast;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Sprite;

#if FLX_RENDER_GL
import lime.graphics.GLRenderContext;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import flixel.system.render.hardware.gl.GLUtils;
#end

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
	 * @author loudo
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
			
			var drawIndices:DrawData<Int> = new DrawData<Int>();
			for (i in 0...indices.length)
				drawIndices[i] = indices[i];
			
			var drawUV:DrawData<Float> = new DrawData<Float>();
			var uvCoord:Float;
			for (i in 0...uv.length)
			{
				uvCoord = uv[i];
				uvCoord /= (i % 2 == 0) ? TextureSize.x : TextureSize.y;
				drawUV[i] = uvCoord;
			}
			
			var drawVertices:DrawData<Float> = new DrawData<Float>();
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
	 * The length of `indices` vector.
	 */
	public var numIndices(get, null):Int;
	
	/**
	 * The number of triangles this data object will draw.
	 */
	public var numTriangles(get, null):Int;
	
	/**
	 * Tells if triangles have colors applied to vertices.
	 */
	public var colored(get, null):Bool;
	
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
	public var vertices(default, set):DrawData<Float> = new DrawData<Float>();
	/**
	 * A `Vector` of normalized coordinates used to apply texture mapping.
	 */
	public var uvs(default, set):DrawData<Float> = new DrawData<Float>();
	/**
	 * A `Vector` of colors for each vertex.
	 */
	public var colors(default, set):DrawData<FlxColor> = new DrawData<FlxColor>();
	/**
	 * A `Vector` of integers or indexes, where every three indexes define a triangle.
	 */
	public var indices(default, set):DrawData<Int> = new DrawData<Int>();
	
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
	
	public function new() {}
	
	public function destroy():Void
	{
		vertices = null;
		uvs = null;
		colors = null;
		indices = null;
		
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
	 */
	public function clear():Void
	{
		vertices.splice(0, vertices.length);
		uvs.splice(0, uvs.length);
		colors.splice(0, colors.length);
		indices.splice(0, indices.length);
		
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
	
	/**
	 * Updates bounding box for this object.
	 */
	public function updateBounds():Void
	{
		if (verticesDirty || vertices.length >= 6)
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
		
		sprite.graphics.drawTriangles(vertices, indices, uvs);
		sprite.graphics.endFill();
		
		matrix.identity();
		matrix.translate( -bounds.x, -bounds.y);
		
		pixels.draw(sprite, matrix);
		return pixels;
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
		
		var numCoords:Int = vertices.length;
		#if (openfl >= "4.9.0")
		var numBytes:Int = numCoords * Float32Array.BYTES_PER_ELEMENT;
		#end
		
		if (verticesDirty)
		{
			if (verticesArray == null || verticesArray.length != numCoords)
				verticesArray = new Float32Array(numCoords);
			
			for (i in 0...numCoords)
				verticesArray[i] = vertices[i];
			
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
			
			#if (openfl >= "4.9.0")
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, verticesArray, GL.STATIC_DRAW);
			#else
			GL.bufferData(GL.ARRAY_BUFFER, verticesArray, GL.STATIC_DRAW);
			#end
			verticesDirty = false;
		}
		else
		{
			GL.bindBuffer(GL.ARRAY_BUFFER, verticesBuffer);
			
			#if (openfl >= "4.9.0")
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, numBytes, verticesArray);
			#else
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, verticesArray);
			#end
		}
	}
	
	public function updateUV():Void
	{
		if (uvs == null)
			return;
		
		if (uvtDirty)
		{
			var numUVs:Int = uvs.length;
			
			if (uvsArray == null || uvsArray.length != numUVs)
				uvsArray = new Float32Array(numUVs);
			
			for (i in 0...numUVs)
				uvsArray[i] = uvs[i];
			
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
			
			#if (openfl >= "4.9.0")
			var numBytes:Int = numUVs * Float32Array.BYTES_PER_ELEMENT;
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, uvsArray, GL.STATIC_DRAW);
			#else
			GL.bufferData(GL.ARRAY_BUFFER, uvsArray, GL.STATIC_DRAW);
			#end
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
			var numColors:Int = colors.length;
			
			if (colorsArray == null || colorsArray.length != numColors)
				colorsArray = new UInt32Array(numColors);
			
			for (i in 0...numColors)
				colorsArray[i] = colors[i];
			
			// update the colors
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
			
			#if (openfl >= "4.9.0")
			var numBytes:Int = numColors * UInt32Array.BYTES_PER_ELEMENT;
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, colorsArray, GL.STATIC_DRAW);
			#else
			GL.bufferData(GL.ARRAY_BUFFER, colorsArray, GL.STATIC_DRAW);
			#end
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
			var numIndices:Int = indices.length;
			
			if (indicesArray == null || indicesArray.length != numIndices)
				indicesArray = new UInt16Array(numIndices);
			
			for (i in 0...numIndices)
				indicesArray[i] = indices[i];
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
			
			#if (openfl >= "4.9.0")
			var numBytes:Int = numIndices * UInt16Array.BYTES_PER_ELEMENT;
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, numBytes, indicesArray, GL.STATIC_DRAW);
			#else
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indicesArray, GL.STATIC_DRAW);
			#end
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