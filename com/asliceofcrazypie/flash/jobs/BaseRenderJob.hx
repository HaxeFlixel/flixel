package com.asliceofcrazypie.flash.jobs;

import flash.display.BlendMode;
import flash.display.Sprite;

/**
 * ...
 * @author Zaphod
 */
class BaseRenderJob
{
	public static var textureQuads:JobPool<TextureQuadRenderJob>;
	public static var textureTriangles:JobPool<TextureTriangleRenderJob>;
	public static var colorQuads:JobPool<ColorQuadRenderJob>;
	public static var colorTriangles:JobPool<ColorTriangleRenderJob>;
	
	@:allow(com.asliceofcrazypie.flash)
	private static function init(batchSize:Int = 0):Void
	{
		TriangleRenderJob.init(batchSize);
		
		textureQuads = new JobPool<TextureQuadRenderJob>(TextureQuadRenderJob);
		textureTriangles = new JobPool<TextureTriangleRenderJob>(TextureTriangleRenderJob);
		colorQuads = new JobPool<ColorQuadRenderJob>(ColorQuadRenderJob);
		colorTriangles = new JobPool<ColorTriangleRenderJob>(ColorTriangleRenderJob);
	}
	
	public var tilesheet:TilesheetStage3D;
	
	public var isRGB:Bool;
	public var isAlpha:Bool;
	public var isSmooth:Bool;
	
	public var blendMode:BlendMode;
	
	public var type(default, null):RenderJobType;
	
	private function new() 
	{
		initData();
	}
	
	private function initData():Void
	{
		
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
	
	public function canAddQuad():Bool
	{
		return false;
	}
	
	/**
	 * This method should help to decide whether we need start another batch or not
	 * To be overriden in subclasses.
	 * 
	 * @param	tilesheet	Tilesheet to use as a source of graphics for the next draw call.
	 * @param	tint		Whether next draw call should be tinted or not.
	 * @param	alpha		Whether next draw call should have alpha multiplier or not.
	 * @param	smooth		Whether next draw call should have smoothing or not.
	 * @param	blend		Blending mode for the next draw call.
	 * @return	True if we need to start another batch, false in the other case and we can continue current one.
	 */
	public function stateChanged(tilesheet:TilesheetStage3D, tint:Bool, alpha:Bool, smooth:Bool, blend:BlendMode):Bool
	{
		return false;
	}
	
	public function reset():Void
	{
		blendMode = null;
		tilesheet = null;
	}
}

enum RenderJobType
{
	COLOR_QUAD;
	COLOR_TRIANGLE;
	TEXTURE_TRIANGLE;
	TEXTURE_QUAD;
}