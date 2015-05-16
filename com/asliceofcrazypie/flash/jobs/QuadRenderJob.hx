package com.asliceofcrazypie.flash.jobs;
import com.asliceofcrazypie.flash.TilesheetStage3D;

#if flash11
import com.asliceofcrazypie.flash.jobs.RenderJob.RenderJobType;
import flash.display.BlendMode;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.display3D.textures.Texture;

/**
 * ...
 * @author Zaphod
 */
class QuadRenderJob extends RenderJob
{
	private static var renderJobPool:Array<QuadRenderJob>;
	
	public function new() 
	{
		super(true);
		type = RenderJobType.QUAD;
	}
	
	override public function addQuad(rect:Rectangle, normalizedOrigin:Point, uv:Rectangle, matrix:Matrix, r:Float = 1, g:Float = 1, b:Float = 1, a:Float = 1):Void
	{
		super.addQuad(rect, normalizedOrigin, uv, matrix, r, g, b, a);
		indexPos += 6;
	}
	
	public static inline function getJob(tilesheet:TilesheetStage3D, isRGB:Bool, isAlpha:Bool, isSmooth:Bool, blend:BlendMode, premultiplied:Bool):QuadRenderJob
	{
		var job:QuadRenderJob = (renderJobPool.length > 0) ? renderJobPool.pop() : new QuadRenderJob();
		
		job.tilesheet = tilesheet;
		job.isRGB = isRGB;
		job.isAlpha = isAlpha;
		job.isSmooth = isSmooth;
		job.blendMode = blend;
		job.premultipliedAlpha = premultiplied;
		
		job.dataPerVertice = 4;
		if (isRGB)
		{
			job.dataPerVertice += 3;
		}
		if (isAlpha)
		{
			job.dataPerVertice++;
		}
		
		return job;
	}
	
	public static inline function returnJob(renderJob:QuadRenderJob):Void
	{
		renderJobPool.push(renderJob);
	}
	
	public static function __init__():Void
	{
		renderJobPool = [];
		for (i in 0...RenderJob.NUM_JOBS_TO_POOL)
		{
			renderJobPool.push(new QuadRenderJob());
		}
	}
}
#end