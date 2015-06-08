package com.asliceofcrazypie.flash.jobs;

import flash.display.BlendMode;
import flash.Vector;
import openfl.display.Sprite;

#if flash11
import flash.utils.ByteArray;
import flash.utils.Endian;
#end

/**
 * ...
 * @author Zaphod
 */
class BaseRenderJob
{
	public static inline var NUM_JOBS_TO_POOL:Int = 25;
	
	public static inline var MAX_INDICES_PER_BUFFER:Int = 98298;
	public static inline var MAX_VERTEX_PER_BUFFER:Int = 65532;		// (MAX_INDICES_PER_BUFFER * 4 / 6)
	public static inline var MAX_QUADS_PER_BUFFER:Int = 16383;		// (MAX_VERTEX_PER_BUFFER / 4)
	public static inline var MAX_TRIANGLES_PER_BUFFER:Int = 21844;	// (MAX_VERTEX_PER_BUFFER / 3)
	
	// TODO: use these static vars (and document them)...
	public static var vertexPerBuffer(default, null):Int;
	public static var quadsPerBuffer(default, null):Int;
	public static var trianglesPerBuffer(default, null):Int;
	public static var indicesPerBuffer(default, null):Int;
	
	public var tilesheet:TilesheetStage3D;
	
	public var isRGB:Bool;
	public var isAlpha:Bool;
	public var isSmooth:Bool;
	
	public var blendMode:BlendMode;
	
	public var type(default, null):RenderJobType;
	
	public var dataPerVertice:Int = 0;
	public var numVertices:Int = 0;
	public var numIndices:Int = 0;
	
	#if flash11
	public var vertices(default, null):Vector<Float>;
	public var indicesVector(default, null):Vector<UInt>;
	public var indicesBytes(default, null):ByteArray;
	#end
	
	public var vertexPos:Int = 0;
	public var indexPos:Int = 0;
	public var colorPos:Int = 0;
	
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
		
		QuadRenderJob.init();
		TriangleRenderJob.init();
		ColorRenderJob.init();
	}
	
	// TODO: use `useBytes` not only in constructor...
	private function new(useBytes:Bool = false) 
	{
		initData(useBytes);
	}
	
	private function initData(useBytes:Bool = false):Void
	{
		#if flash11
		this.vertices = new Vector<Float>(BaseRenderJob.vertexPerBuffer >> 2);
		
		if (useBytes)
		{
			indicesBytes = new ByteArray();
			indicesBytes.endian = Endian.LITTLE_ENDIAN;
			
			for (i in 0...Std.int(BaseRenderJob.vertexPerBuffer / 4))
			{
				indicesBytes.writeShort((i * 4) + 2);
				indicesBytes.writeShort((i * 4) + 1);
				indicesBytes.writeShort((i * 4) + 0);
				indicesBytes.writeShort((i * 4) + 3);
				indicesBytes.writeShort((i * 4) + 2);
				indicesBytes.writeShort((i * 4) + 0);
			}
		}
		else
		{
			indicesVector = new Vector<UInt>();
		}
		#end
	}
	
	#if flash11
	public function render(context:ContextWrapper = null, colored:Bool = false):Void
	{
		
	}
	#else
	public function render(context:Sprite = null, colored:Bool = false):Void
	{
		
	}
	#end
	
	public inline function canAddQuad():Bool
	{
		return (numVertices + 4) <= BaseRenderJob.vertexPerBuffer;
	}
	
	public inline function canAddTriangles(numVertices:Int):Bool
	{
		return (numVertices + this.numVertices) <= BaseRenderJob.vertexPerBuffer;
	}
	
	public static inline function checkMaxTrianglesCapacity(numVertices:Int):Bool
	{
		return numVertices <= BaseRenderJob.vertexPerBuffer;
	}
	
	public function reset():Void
	{
		blendMode = null;
		tilesheet = null;
		vertexPos = 0;
		indexPos = 0;
		colorPos = 0;
		numVertices = 0;
		numIndices = 0;
	}
}

enum RenderJobType
{
	QUAD;
	TRIANGLE;
	NO_IMAGE;
}