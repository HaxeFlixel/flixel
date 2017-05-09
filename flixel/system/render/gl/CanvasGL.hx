package flixel.system.render.gl;

import flixel.graphics.FlxMaterial;
import flixel.util.FlxDestroyUtil;
import openfl.display.BitmapData;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;

#if FLX_RENDER_GL
import openfl.gl.GL;
import openfl.utils.Float32Array;
import lime.graphics.GLRenderContext;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
import flixel.graphics.shaders.FlxCameraColorTransform.ColorTransformFilter;
#end

using flixel.util.FlxColorTransformUtil;

/**
 * Display object for actual rendering for openfl 4 in tile render mode.
 * Huge part of it is taken from HaxePunk fork by @Yanrishatum. 
 * Original class can be found here https://github.com/Yanrishatum/HaxePunk/blob/ofl4/com/haxepunk/graphics/atlas/HardwareRenderer.hx
 * @author Pavel Alexandrov aka Yanrishatum https://github.com/Yanrishatum
 * @author Zaphod
 */
class CanvasGL extends GLDisplayObject
{
	#if FLX_RENDER_GL
	private var colorFilter:ColorTransformFilter;
	private var filtersArray:Array<BitmapFilter>;
	
	/**
	 * Currently used draw command
	 */
	private var currentCommand:FlxDrawHardwareCommand<Dynamic>;
	
	/**
	 * Draw command used for rendering single textured quad (for less data upload on GPU)
	 */
	private var singleTextureQuad:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(true, 1);
	
	/**
	 * Draw command used for rendering single colored (non-textured) quad.
	 * Used for quads with materials without batching.
	 */
	private var singleColorQuad:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(false, 1);
	
	/**
	 * Draw command used for rendering batches of textured quads.
	 */
	private var textureQuads:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(true);
	
	/**
	 * Draw command used for rendering batches of non-textured quads.
	 */
	private var colorQuads:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(false);
	
	/**
	 * Draw command used for rendering complex meashes, both textured and non-textured.
	 */
	private var triangles:FlxDrawTrianglesCommand = new FlxDrawTrianglesCommand();
	
	public function new(width:Int, height:Int, context:GLContextHelper)
	{
		super(width, height, context);
		
		colorFilter = new ColorTransformFilter();
		filtersArray = [colorFilter];
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		colorFilter = null;
		filtersArray = null;
		
		textureQuads = FlxDestroyUtil.destroy(textureQuads);
		colorQuads = FlxDestroyUtil.destroy(colorQuads);
		triangles = FlxDestroyUtil.destroy(triangles);
		singleTextureQuad = FlxDestroyUtil.destroy(singleTextureQuad);
		singleColorQuad = FlxDestroyUtil.destroy(singleColorQuad);
		currentCommand = null;
	}
	
	override public function finish():Void 
	{
		if (currentCommand != null)
		{
			currentCommand.flush();
			currentCommand = null;
		}
	}
	
	override public function prepare(?renderTarget:FlxRenderTexture):Void 
	{
		textureQuads.prepare(context, renderTarget);
		colorQuads.prepare(context, renderTarget);
		triangles.prepare(context, renderTarget);
		singleTextureQuad.prepare(context, renderTarget);
		singleColorQuad.prepare(context, renderTarget);
		currentCommand = null;
	}
	
	public inline function getTextureQuads(material:FlxMaterial):FlxDrawQuadsCommand
	{
		if (currentCommand != null)
		{
			if (material.batchable && currentCommand != textureQuads)
				currentCommand.flush();
			else if (!material.batchable)
				currentCommand.flush();
		}
		
		var result = (material.batchable) ? textureQuads : singleTextureQuad;
		currentCommand = result;
		return result;
	}
	
	// TODO: request drawCommand (optimization for drawing sequence of quads with the same material)...
	
	public inline function getColorQuads(material:FlxMaterial):FlxDrawQuadsCommand
	{
		if (currentCommand != null)
		{
			if (material.batchable && currentCommand != textureQuads)
				currentCommand.flush();
			else if (!material.batchable)
				currentCommand.flush();
		}
		
		var result = (material.batchable) ? colorQuads : singleColorQuad;
		currentCommand = result;
		return result;
	}
	
	public inline function getTriangles(material:FlxMaterial):FlxDrawTrianglesCommand
	{
		if (currentCommand != null)
			currentCommand.flush();
		
		currentCommand = null;  // i don't batch triangles...
		return triangles;
	}
	
	override public function __renderGL(renderSession:RenderSession):Void 
	{
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		var useColorTransform:Bool = false;
		var hasNoFilters:Bool = (__filters == null);
		
		var color:ColorTransform = __worldColorTransform;
		colorFilter.transform = color;
		
		if (color != null)
			useColorTransform = color.hasAnyTransformation();
		
		if (useColorTransform)
		{
			colorFilter.transform = color;
			
			if (hasNoFilters)
				__filters = filtersArray;
			else
				__filters.unshift(colorFilter);
		}
		
		// code from GLBitmap
		renderSession.blendModeManager.setBlendMode(blendMode);
	//	renderSession.maskManager.pushObject(this);
		
	//	GL.enable(GL.SCISSOR_TEST);
	//	GL.scissor(0, 0, Std.int(FlxG.stage.stageWidth * 0.5), Std.int(FlxG.stage.stageHeight * 0.5));
		
		var shader = renderSession.filterManager.pushObject(this);
		shader.data.uMatrix.value = renderer.getMatrix(__renderTransform);
		renderSession.shaderManager.setShader(shader);
		
		gl.bindTexture(GL.TEXTURE_2D, buffer.texture);
		GLUtils.setTextureSmoothing(smoothing);
		GLUtils.setTextureWrapping(false);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer.buffer);
		
		gl.vertexAttribPointer(shader.data.aPosition.index, 3, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aAlpha.index, 1, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		
		renderSession.filterManager.popObject(this);
	//	renderSession.maskManager.popObject(this);
		// end of code from GLBitmap
		
	//	GL.disable(GL.SCISSOR_TEST);
		
		context.currentShader = null;
		
		for (child in __children) 
			child.__renderGL(renderSession);
		
		for (orphan in __removedChildren) 
		{	
			if (orphan.stage == null)
				orphan.__cleanup();
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject(this);
		
		if (useColorTransform)
		{
			if (hasNoFilters)
				__filters = null;
			else
				__filters.shift();
		}
	}
	#end
}