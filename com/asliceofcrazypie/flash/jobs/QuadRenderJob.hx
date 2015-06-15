package com.asliceofcrazypie.flash.jobs;

import com.asliceofcrazypie.flash.TilesheetStage3D;
import com.asliceofcrazypie.flash.jobs.BaseRenderJob.RenderJobType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.display.Sprite;
import openfl.display.Tilesheet;

import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * ...
 * @author Zaphod
 */
#if flash11
class QuadRenderJob extends RenderJob
#else
class QuadRenderJob extends BaseRenderJob
#end
{
	private static var renderJobPool:Array<QuadRenderJob>;
	
	public static inline function getJob(tilesheet:TilesheetStage3D, isRGB:Bool, isAlpha:Bool, isSmooth:Bool, blend:BlendMode):QuadRenderJob
	{
		var job:QuadRenderJob = (renderJobPool.length > 0) ? renderJobPool.pop() : new QuadRenderJob();
		job.set(tilesheet, isRGB, isAlpha, isSmooth, blend);
		return job;
	}
	
	public static inline function returnJob(renderJob:QuadRenderJob):Void
	{
		renderJobPool.push(renderJob);
	}
	
	public static function init():Void
	{
		renderJobPool = [];
		for (i in 0...BaseRenderJob.NUM_JOBS_TO_POOL)
		{
			renderJobPool.push(new QuadRenderJob());
		}
	}
	
	#if !flash11
	public var tileData(default, null):Array<Float>;
	#end
	
	public function new() 
	{
		super(true);
		type = RenderJobType.QUAD;
	}
	
	#if !flash11
	override function initData(useBytes:Bool = false):Void 
	{
		tileData = new Array<Float>();
	}
	#end
	
	#if flash11
	override public function addQuad(rect:FlxRect, normalizedOrigin:FlxPoint, uv:FlxRect, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		super.addQuad(rect, normalizedOrigin, uv, matrix, r, g, b, a);
		indexPos += 6;
	}
	
	#else
	public function addQuad(rect:FlxRect, normalizedOrigin:FlxPoint, uv:FlxRect, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		var imgWidth:Int = Std.int(rect.width);
		var imgHeight:Int = Std.int(rect.height);
		
		var centerX:Float = normalizedOrigin.x * imgWidth;
		var centerY:Float = normalizedOrigin.y * imgHeight;
		
		tileData[vertexPos++] = matrix.tx;
		tileData[vertexPos++] = matrix.ty;
		
		tileData[vertexPos++] = rect.x;
		tileData[vertexPos++] = rect.y;
		tileData[vertexPos++] = rect.width;
		tileData[vertexPos++] = rect.height;
		
		tileData[vertexPos++] = centerX;
		tileData[vertexPos++] = centerY;
		
		tileData[vertexPos++] = matrix.a;
		tileData[vertexPos++] = matrix.b;
		tileData[vertexPos++] = matrix.c;
		tileData[vertexPos++] = matrix.d;
		
		if (isRGB)
		{
			tileData[vertexPos++] = r;
			tileData[vertexPos++] = g;
			tileData[vertexPos++] = b;
		}
		
		if (isAlpha)
		{
			tileData[vertexPos++] = a;
		}
		
		numVertices += 4;
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
		
		tilesheet.drawTiles(context.graphics, tileData, isSmooth, flags, vertexPos);
	}
	#end
	
	public function set(tilesheet:TilesheetStage3D, isRGB:Bool, isAlpha:Bool, isSmooth:Bool, blend:BlendMode):Void
	{
		this.tilesheet = tilesheet;
		this.isRGB = isRGB;
		this.isAlpha = isAlpha;
		this.isSmooth = isSmooth;
		this.blendMode = blend;
		
		#if flash11
		var dataPerVertice:Int = 4;
		if (isRGB)
		{
			dataPerVertice += 3;
		}
		if (isAlpha)
		{
			dataPerVertice++;
		}
		
		this.dataPerVertice = dataPerVertice;
		#end
	}
}