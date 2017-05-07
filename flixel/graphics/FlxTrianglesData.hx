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
	 * The length of `indices` vector.
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
	
	public function new() {}
	
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
	 */
	public function clear():Void
	{
		_vertices.splice(0, _vertices.length);
		_uvs.splice(0, _uvs.length);
		_colors.splice(0, _colors.length);
		_indices.splice(0, _indices.length);
		
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
	
	private function get_vertices():Vector<Float>
	{
		return _vertices;
	}
	
	private function set_vertices(value:Vector<Float>):Vector<Float>
	{
		verticesDirty = verticesDirty || (value != null);
		return _vertices = value;
	}
	
	private function get_uvs():Vector<Float>
	{
		return _uvs;
	}
	
	private function set_uvs(value:Vector<Float>):Vector<Float>
	{
		uvtDirty = uvtDirty || (value != null);
		return _uvs = value;
	}
	
	private function get_colors():Vector<FlxColor>
	{
		return _colors;
	}
	
	private function set_colors(value:Vector<FlxColor>):Vector<FlxColor>
	{
		colorsDirty = colorsDirty || (value != null);
		return _colors = value;
	}
	
	private function get_indices():Vector<Int>
	{
		return _indices;
	}
	
	private function set_indices(value:Vector<Int>):Vector<Int>
	{
		indicesDirty = indicesDirty || (value != null);
		return _indices = value;
	}
	
	private function set_dirty(value:Bool):Bool
	{
		verticesDirty = uvtDirty = colorsDirty = indicesDirty = value;
		return dirty = value;
	}
	
	private function get_numIndices():Int
	{
		return (_indices != null) ? _indices.length : 0;
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
		if (_vertices == null)
			return;
		
		var numCoords:Int = _vertices.length;
		var numBytes:Int = numCoords * Float32Array.BYTES_PER_ELEMENT;
		
		if (verticesDirty)
		{
			if (verticesArray == null || verticesArray.length < numCoords)
				verticesArray = new Float32Array(numCoords);
			
			for (i in 0...numCoords)
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
		if (_uvs == null)
			return;
		
		if (uvtDirty)
		{
			var numUVs:Int = _uvs.length;
			
			if (uvsArray == null || uvsArray.length < numUVs)
				uvsArray = new Float32Array(numUVs);
			
			for (i in 0...numUVs)
				uvsArray[i] = _uvs[i];
			
			GL.bindBuffer(GL.ARRAY_BUFFER, uvsBuffer);
			
			var numBytes:Int = numUVs * Float32Array.BYTES_PER_ELEMENT;
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
		if (colorsDirty)
		{
			var numColors:Int = Std.int(_vertices.length * 0.5);
			var numColorsAvailable:Int = (_colors != null) ? _colors.length : 0;
			
			if (colorsArray == null || colorsArray.length < numColors)
				colorsArray = new UInt32Array(numColors);
			
			for (i in 0...numColors)
			{
				if (i < numColorsAvailable)
					colorsArray[i] = _colors[i];
				else
					colorsArray[i] = FlxColor.WHITE;
			}
			
			// update the colors
			GL.bindBuffer(GL.ARRAY_BUFFER, colorsBuffer);
			
			var numBytes:Int = numColors * UInt32Array.BYTES_PER_ELEMENT;
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
		if (_indices == null)
			return;
		
		if (indicesDirty)
		{
			var numIndices:Int = _indices.length;
			
			if (indicesArray == null || indicesArray.length < numIndices)
				indicesArray = new UInt16Array(numIndices);
			
			for (i in 0...numIndices)
				indicesArray[i] = _indices[i];
			
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indicesBuffer);
			
			var numBytes:Int = numIndices * UInt16Array.BYTES_PER_ELEMENT;
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