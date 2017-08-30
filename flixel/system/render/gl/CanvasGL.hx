package flixel.system.render.gl;

import flixel.graphics.FlxMaterial;
import flixel.graphics.shaders.FlxCameraColorTransform;
import flixel.math.FlxMatrix;
import flixel.util.FlxDestroyUtil;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

#if FLX_RENDER_GL
import lime.graphics.opengl.GL;
import lime.utils.Float32Array;
import lime.graphics.GLRenderContext;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
#end

using flixel.util.FlxColorTransformUtil;

@:access(openfl.geom.ColorTransform)

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
	private var colorShader:FlxCameraColorTransform;
	
	/**
	 * Currently used draw command
	 */
	private var currentCommand:FlxDrawHardwareCommand<Dynamic>;
	
	/**
	 * Draw command used for rendering single quads (for less data upload on GPU)
	 */
	private var singleQuad:FlxDrawQuadsCommand = new FlxDrawQuadsCommand(1);
	
	/**
	 * Draw command used for rendering batches of quads.
	 */
	private var quads:FlxDrawQuadsCommand = new FlxDrawQuadsCommand();
	
	/**
	 * Draw command used for rendering complex meashes, both textured and non-textured.
	 */
	private var triangles:FlxDrawTrianglesCommand = new FlxDrawTrianglesCommand();
	
	public function new(width:Int, height:Int, context:GLContextHelper)
	{
		super(width, height, context);
		
		colorShader = new FlxCameraColorTransform();
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		quads = FlxDestroyUtil.destroy(quads);
		triangles = FlxDestroyUtil.destroy(triangles);
		singleQuad = FlxDestroyUtil.destroy(singleQuad);
		currentCommand = null;
		colorShader = null;
	}
	
	override public function finish():Void 
	{
		if (currentCommand != null)
		{
			currentCommand.flush();
			currentCommand = null;
		}
	}
	
	override public function prepare(?renderTarget:FlxRenderTexture, ?transform:FlxMatrix):Void 
	{
		quads.prepare(context, renderTarget, transform);
		triangles.prepare(context, renderTarget, transform);
		singleQuad.prepare(context, renderTarget, transform);
		currentCommand = null;
	}
	
	public inline function getQuads(material:FlxMaterial):FlxDrawQuadsCommand
	{
		if (currentCommand != null)
		{
			if (material.batchable && currentCommand != quads)
				currentCommand.flush();
			else if (!material.batchable)
				currentCommand.flush();
		}
		
		var result = (material.batchable) ? quads : singleQuad;
		currentCommand = result;
		return result;
	}
	
	// TODO: request drawCommand (optimization for drawing sequence of quads with the same material)...
	
	public inline function getTriangles(material:FlxMaterial):FlxDrawTrianglesCommand
	{
		if (currentCommand != null)
			currentCommand.flush();
		
		currentCommand = null;  // i don't batch triangles...
		return triangles;
	}
	
	override public function __renderGL(renderSession:RenderSession):Void 
	{
		/*
		gl.bindTexture(GL.TEXTURE_2D, buffer.texture);
		GLUtils.setTextureSmoothing(false);
	//	GLUtils.setTextureSmoothing(smoothing);
		GLUtils.setTextureWrapping(false);
		*/
		
		context.setShader(null);
		
		var renderer:GLRenderer = cast renderSession.renderer;
		var gl = renderSession.gl;
		
		renderSession.blendModeManager.setBlendMode(__worldBlendMode);
		renderSession.maskManager.pushObject(this);
		
		renderSession.shaderManager.setShader(null);
		var shader = renderSession.filterManager.pushObject(this);
		renderSession.shaderManager.setShader(shader);
		
		shader.data.uImage0.input = buffer.bitmap;
		shader.data.uImage0.smoothing = false;
		shader.data.uMatrix.value = renderer.getMatrix(__renderTransform);
		
		var useColorTransform = !__worldColorTransform.__isDefault();
		
		if (shader.data.uColorTransform.value == null) 
			shader.data.uColorTransform.value = [];
		
		shader.data.uColorTransform.value[0] = useColorTransform;
		
		renderSession.shaderManager.updateShader(shader);
		
		gl.bindBuffer(gl.ARRAY_BUFFER, buffer.bitmap.getBuffer(gl, __worldAlpha, __worldColorTransform));
		
		gl.vertexAttribPointer(shader.data.aPosition.index,	3, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(shader.data.aTexCoord.index,	2, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aAlpha.index,	1, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		
		if (true || useColorTransform) 
		{
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index,		4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 6 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index + 1,	4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 10 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index + 2,	4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 14 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorMultipliers.index + 3,	4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 18 * Float32Array.BYTES_PER_ELEMENT);
			gl.vertexAttribPointer(shader.data.aColorOffsets.index,			4, gl.FLOAT, false, 26 * Float32Array.BYTES_PER_ELEMENT, 22 * Float32Array.BYTES_PER_ELEMENT);	
		}
		
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
		
		for (child in __children) 
			child.__renderGL(renderSession);
		
		for (orphan in __removedChildren) 
		{	
			if (orphan.stage == null)
				orphan.__cleanup();
		}
		
		__removedChildren.length = 0;
		
		renderSession.filterManager.popObject(this);
		renderSession.maskManager.popObject(this);
	}
	
	#end
}