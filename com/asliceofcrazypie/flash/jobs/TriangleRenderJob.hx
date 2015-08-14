package com.asliceofcrazypie.flash.jobs;

import openfl.display.TriangleCulling;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
#if flash11
class TriangleRenderJob extends BaseRenderJob
{
	public static inline var MAX_INDICES_PER_BUFFER:Int = 98298;
	public static inline var MAX_VERTEX_PER_BUFFER:Int = 65532;		// (MAX_INDICES_PER_BUFFER * 4 / 6)
	public static inline var MAX_QUADS_PER_BUFFER:Int = 16383;		// (MAX_VERTEX_PER_BUFFER / 4)
	public static inline var MAX_TRIANGLES_PER_BUFFER:Int = 21844;	// (MAX_VERTEX_PER_BUFFER / 3)
	
	/**
	 * The number of vertices per buffer. Used to decide whether to start new batch or not.
	 * Its value couldn't be less than 0 and more than MAX_INDICES_PER_BUFFER (flash target limit).
	 */
	public static var vertexPerBuffer(default, null):Int;
	/**
	 * The number of quads per buffer. I'm actually not using it.
	 */
	public static var quadsPerBuffer(default, null):Int;
	/**
	 * The number of triangles per buffer. I'm actually not using it.
	 */
	public static var trianglesPerBuffer(default, null):Int;
	/**
	 * The number of indices per buffer. I'm actually not using it.
	 */
	public static var indicesPerBuffer(default, null):Int;
	
	@:allow(com.asliceofcrazypie.flash)
	private static function init(batchSize:Int = 0):Void
	{
		if (batchSize <= 0 || batchSize > MAX_QUADS_PER_BUFFER)
		{
			batchSize = MAX_QUADS_PER_BUFFER;
		}
		
		quadsPerBuffer = batchSize;
		vertexPerBuffer = batchSize * 4;
		trianglesPerBuffer = Std.int(vertexPerBuffer / 3);
		indicesPerBuffer = Std.int(vertexPerBuffer * 6 / 4);	
	}
	
	public var dataPerVertice:Int = 0;
	public var numVertices:Int = 0;
	public var numIndices:Int = 0;
	
	public var vertices(default, null):Vector<Float>;
	public var indices(default, null):Vector<UInt>;
	
	public var vertexPos:Int = 0;
	public var indexPos:Int = 0;
	
	public var culling:TriangleCulling;
	
	public function new() 
	{
		super();
	}
	
	override private function initData():Void
	{
		this.vertices = new Vector<Float>(TriangleRenderJob.vertexPerBuffer >> 2);
		this.indices = new Vector<UInt>();
	}
	
	override public function reset():Void
	{
		super.reset();
		
		culling = null;
		
		vertexPos = 0;
		indexPos = 0;
		numVertices = 0;
		numIndices = 0;
	}
	
	override public function canAddQuad():Bool
	{
		return (numVertices + 4) <= TriangleRenderJob.vertexPerBuffer;
	}
	
	public inline function canAddTriangles(numVertices:Int):Bool
	{
		return (numVertices + this.numVertices) <= TriangleRenderJob.vertexPerBuffer;
	}
	
	public static inline function checkMaxTrianglesCapacity(numVertices:Int):Bool
	{
		return numVertices <= TriangleRenderJob.vertexPerBuffer;
	}
}
#else
class TriangleRenderJob extends BaseRenderJob
{
	private static function init(batchSize:Int = 0):Void
	{
		
	}
	
	#if flash
	public var vertices(default, null):Vector<Float>;
	public var indices(default, null):Vector<UInt>;
	#else
	public var vertices(default, null):Array<Float>;
	public var indices(default, null):Array<Int>;
	public var colors(default, null):Array<Int>;
	#end
	
	public var dataPerVertice:Int = 0;
	public var numVertices:Int = 0;
	public var numIndices:Int = 0;
	
	public var vertexPos:Int = 0;
	public var indexPos:Int = 0;
	
	#if !flash
	public var colorPos:Int = 0;
	#end
	
	public var culling:TriangleCulling;
	
	public function new()
	{
		super();
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		culling = null;
		
		vertices.splice(0, vertices.length);
		indices.splice(0, indices.length);
		#if !flash
		colors.splice(0, colors.length);
		#end
		
		dataPerVertice = 0;
		numVertices = 0;
		numIndices = 0;
		
		vertexPos = 0;
		indexPos = 0;
		#if !flash
		colorPos = 0;
		#end
	}
	
	override function initData():Void 
	{
		#if flash
		vertices = new Vector<Float>();
		indices = new Vector<Int>();
		#else
		vertices = new Array<Float>();
		indices = new Array<Int>();
		colors = new Array<Int>();
		#end
	}
	
	override public function canAddQuad():Bool
	{
		return true;
	}
	
	public inline function canAddTriangles(numVertices:Int):Bool
	{
		return true;
	}
	
	public static inline function checkMaxTrianglesCapacity(numVertices:Int):Bool
	{
		return true;
	}
}
#end