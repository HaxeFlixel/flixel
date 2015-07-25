package com.asliceofcrazypie.flash.jobs;

import flash.Vector;
import flash.display.BlendMode;
import flixel.graphics.tile.FlxTilesheet;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.display.Sprite;
import openfl.display.Tilesheet;
import openfl.display3D.Context3D;
import openfl.display3D.Context3DProgramType;
import openfl.display3D.Context3DVertexBufferFormat;
import openfl.display3D.IndexBuffer3D;
import openfl.display3D.VertexBuffer3D;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import com.asliceofcrazypie.flash.jobs.BaseRenderJob.RenderJobType;

/**
 * ...
 * @author Zaphod
 */
#if flash11
class TextureQuadRenderJob extends QuadRenderJob
{
	static public inline var numRegistersPerQuad:Int = 5;
	
	/**
	 * Max number of quads per draw call for this type of render job
	 */
	static public inline var limit:Int = 24;	// Std.int((128 - 4) / 5); where:
												// - 128 is the max number of vertex constant vectors,
												// - 4 is for mvp, 
												// - 5 vectors for each quad
	
	static private var vertexBuffer:VertexBuffer3D;
	static private var indexBuffer:IndexBuffer3D;
	
	private function new() 
	{
		super();
		type = RenderJobType.TEXTURE_QUAD;
	}
	
	public static function initContextData(context:ContextWrapper):Void
	{
		var vertices:Vector<Float> = new Vector<Float>();
		var indices:Vector<UInt> = new Vector<UInt>();
		var i4:Int;
		var i5:Int;
		for (i in 0...limit) 
		{
			i5 = i * 5;
			vertices.push(0);
			vertices.push(0);
			vertices.push(i5);
			
			vertices.push(0);
			vertices.push(1);
			vertices.push(i5);
			
			vertices.push(1);
			vertices.push(0);
			vertices.push(i5);
			
			vertices.push(1);
			vertices.push(1);
			vertices.push(i5);
			
			i4 = i * 4;
			indices.push(i4);
			indices.push(i4 + 1);
			indices.push(i4 + 2);
			indices.push(i4 + 1);
			indices.push(i4 + 3);
			indices.push(i4 + 2);
		}
		
		var context3D:Context3D = context.context3D;
		
		vertexBuffer = context3D.createVertexBuffer(limit * 4, 3);
		vertexBuffer.uploadFromVector(vertices, 0, limit * 4);
		indexBuffer = context3D.createIndexBuffer(limit * 6);
		indexBuffer.uploadFromVector(indices, 0, limit * 6);
	}
	
	public function addQuad(rect:FlxRect, normalizedOrigin:FlxPoint, uv:FlxRect, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		setVertexConstantsFromNumbers(numConstants++, normalizedOrigin.x, normalizedOrigin.y, rect.width, rect.height);
		setVertexConstantsFromNumbers(numConstants++, matrix.a, matrix.b, matrix.c, matrix.d);
		setVertexConstantsFromNumbers(numConstants++, matrix.tx, matrix.ty, 0, 0);
		setVertexConstantsFromNumbers(numConstants++, uv.width - uv.x, uv.height - uv.y, uv.x, uv.y);
		setVertexConstantsFromNumbers(numConstants++, r, g, b, a);
		numQuads++;
	}
	
	override public function render(context:ContextWrapper = null, colored:Bool = false):Void
	{
		var context3D:Context3D = context.context3D;
		
		context.setBlendMode(blendMode, tilesheet.premultipliedAlpha);
		context.setQuadImageProgram(isSmooth, tilesheet.mipmap, colored);
		context.setTexture(tilesheet.texture);
		
		// Set streams
		context3D.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
		context3D.setVertexBufferAt(1, null);
		context3D.setVertexBufferAt(2, null);
		context3D.setProgramConstantsFromVector(Context3DProgramType.VERTEX, 0, constants, numConstants);
		
		// Set constants
	//	mvp.copyFrom(support.mvpMatrix3D);
	//	context.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 124, context.baseTransformMatrix, true);
		
		context3D.drawTriangles(indexBuffer, 0, numQuads << 1); // numQuads * 2
	}
	
	override public function canAddQuad():Bool
	{
		return (numQuads < limit);
	}
	
	public function set(tilesheet:TilesheetStage3D, isRGB:Bool, isAlpha:Bool, isSmooth:Bool, blend:BlendMode):Void 
	{
		this.tilesheet = tilesheet;
		this.blendMode = blend;
		this.isSmooth = isSmooth;
	}
	
	override public function stateChanged(tilesheet:TilesheetStage3D, tint:Bool, alpha:Bool, smooth:Bool, blend:BlendMode):Bool 
	{
		return (this.tilesheet != tilesheet || this.blendMode != blend);
	}
}
#else
class TextureQuadRenderJob extends QuadRenderJob
{
	private function new() 
	{
		super();
		type = RenderJobType.TEXTURE_QUAD;
	}
	
	public function addQuad(rect:FlxRect, normalizedOrigin:FlxPoint, uv:FlxRect, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var imgWidth:Int = Std.int(rect.width);
		var imgHeight:Int = Std.int(rect.height);
		
		var centerX:Float = normalizedOrigin.x * imgWidth;
		var centerY:Float = normalizedOrigin.y * imgHeight;
		
		tileData[dataPosition++] = matrix.tx;
		tileData[dataPosition++] = matrix.ty;
		
		tileData[dataPosition++] = rect.x;
		tileData[dataPosition++] = rect.y;
		tileData[dataPosition++] = rect.width;
		tileData[dataPosition++] = rect.height;
		
		tileData[dataPosition++] = centerX;
		tileData[dataPosition++] = centerY;
		
		tileData[dataPosition++] = matrix.a;
		tileData[dataPosition++] = matrix.b;
		tileData[dataPosition++] = matrix.c;
		tileData[dataPosition++] = matrix.d;
		
		if (isRGB)
		{
			tileData[dataPosition++] = r;
			tileData[dataPosition++] = g;
			tileData[dataPosition++] = b;
		}
		
		if (isAlpha)
		{
			tileData[dataPosition++] = a;
		}
	}
	
	override public function render(context:Sprite = null, colored:Bool = false):Void
	{
		var flags:Int = Tilesheet.TILE_RECT | Tilesheet.TILE_ORIGIN | Tilesheet.TILE_TRANS_2x2;
		
		if (isRGB) flags |= Tilesheet.TILE_RGB;
		if (isAlpha) flags |= Tilesheet.TILE_ALPHA;
		
		if (blendMode == BlendMode.ADD)
		{
			flags |= Tilesheet.TILE_BLEND_ADD;
		}
		else if (blendMode == BlendMode.MULTIPLY)
		{
			flags |= Tilesheet.TILE_BLEND_MULTIPLY;
		}
		else if (blendMode == BlendMode.SCREEN)
		{
			flags |= Tilesheet.TILE_BLEND_SCREEN;
		}
		
		tilesheet.drawTiles(context.graphics, tileData, isSmooth, flags, dataPosition);
		FlxTilesheet._DRAWCALLS++;
	}
	
	public function set(tilesheet:TilesheetStage3D, isRGB:Bool, isAlpha:Bool, isSmooth:Bool, blend:BlendMode):Void
	{
		this.tilesheet = tilesheet;
		this.isRGB = isRGB;
		this.isAlpha = isAlpha;
		this.isSmooth = isSmooth;
		this.blendMode = blend;
	}
	
	override public function stateChanged(tilesheet:TilesheetStage3D, tint:Bool, alpha:Bool, smooth:Bool, blend:BlendMode):Bool 
	{
		return (this.tilesheet != tilesheet || this.blendMode != blend || this.isRGB != tint || this.isAlpha != alpha || this.isSmooth != smooth);
	}
}
#end