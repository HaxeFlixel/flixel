package com.asliceofcrazypie.flash.jobs;

import com.asliceofcrazypie.flash.ContextWrapper;
import com.asliceofcrazypie.flash.jobs.BaseRenderJob.RenderJobType;
import com.asliceofcrazypie.flash.TilesheetStage3D;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.display.BlendMode;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.Program3D;
import openfl.display3D.VertexBuffer3D;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.Vector;

/**
 * ...
 * @author Zaphod
 */
#if flash11
class ColorQuadRenderJob extends QuadRenderJob
{
	public static inline var numRegistersPerQuad:Int = 4;
	
	static private inline var limit:Int = 31;	// Std.int((128 - 4) / 4); where:
												// - 128 is the max number of vertex constant vectors,
												// - 4 is for mvp, 
												// - 4 vectors for each quad
												
	static private var vertexBuffer:VertexBuffer3D;
	static private var indexBuffer:IndexBuffer3D;
	
	private function new() 
	{
		super();
		type = RenderJobType.COLOR_QUAD;
	}
	
	override function initData():Void 
	{
		constants = new Vector<Float>();
	}
	
	public static function initContextData(context:ContextWrapper):Void
	{
		var vertices:Vector<Float> = new Vector<Float>();
		var indices:Vector<UInt> = new Vector<UInt>();
		var i4:Int;
		for (i in 0...limit) 
		{
			i4 = i * 4;
			vertices.push(0);
			vertices.push(0);
			vertices.push(i4);
			
			vertices.push(0);
			vertices.push(1);
			vertices.push(i4);
			
			vertices.push(1);
			vertices.push(0);
			vertices.push(i4);
			
			vertices.push(1);
			vertices.push(1);
			vertices.push(i4);
			
			indices.push(i4);
			indices.push(i4 + 1);
			indices.push(i4 + 2);
			indices.push(i4 + 1);
			indices.push(i4 + 3);
			indices.push(i4 + 2);
		}
		
		vertexBuffer = context.context3D.createVertexBuffer(limit * 4, 3);
		vertexBuffer.uploadFromVector(vertices, 0, limit * 4);
		indexBuffer = context.context3D.createIndexBuffer(limit * 6);
		indexBuffer.uploadFromVector(indices, 0, limit * 6);
	}
	
	override public function render(context:ContextWrapper = null, colored:Bool = false):Void
	{
		var context3D:Context3D = context.context3D;
		
		context.setBlendMode(blendMode, false);
		context.setQuadNoImageProgram(colored);
		context.setTexture(null);
		
		// Set streams
		context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		context.context3D.setVertexBufferAt(1, null);
		context.context3D.setVertexBufferAt(2, null);
		context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, constants, numConstants);
		
		// Set constants
	//	mvp.copyFrom(support.mvpMatrix3D);
	//	context.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 124, context.baseTransformMatrix, true);
		
		context.context3D.drawTriangles(indexBuffer, 0, numQuads << 1); // numQuads * 2
	}
	
	public function addQuad(rect:FlxRect, normalizedOrigin:FlxPoint, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		setVertexConstantsFromNumbers(numConstants++, normalizedOrigin.x, normalizedOrigin.y, rect.width, rect.height);
		setVertexConstantsFromNumbers(numConstants++, matrix.a, matrix.b, matrix.c, matrix.d);
		setVertexConstantsFromNumbers(numConstants++, matrix.tx, matrix.ty, 0, 0);
		setVertexConstantsFromNumbers(numConstants++, r, g, b, a);
		numQuads++;
	}
	
	public function addAAQuad(rect:FlxRect, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		setVertexConstantsFromNumbers(numConstants++, 0, 0, rect.width, rect.height);
		setVertexConstantsFromNumbers(numConstants++, 1, 0, 0, 1);
		setVertexConstantsFromNumbers(numConstants++, rect.x, rect.y, 0, 0);
		setVertexConstantsFromNumbers(numConstants++, r, g, b, a);
		numQuads++;
	}
	
	override public function canAddQuad():Bool
	{
		return (numQuads < limit);
	}
	
	override public function reset():Void 
	{
		super.reset();
		numQuads = 0;
		numConstants = 0;
	}
	
	public function set(blend:BlendMode):Void 
	{
		this.blendMode = blend;
	}
	
	override public function stateChanged(tilesheet:TilesheetStage3D, tint:Bool, alpha:Bool, smooth:Bool, blend:BlendMode):Bool 
	{
		return (this.blendMode != blend);
	}
}
#else
/**
 * Just a stub class...
 */
class ColorQuadRenderJob extends QuadRenderJob
{
	private function new() 
	{
		super();
		type = RenderJobType.COLOR_QUAD;
	}
	
	public function set(blend:BlendMode):Void 
	{
		this.blendMode = blend;
	}
}
#end