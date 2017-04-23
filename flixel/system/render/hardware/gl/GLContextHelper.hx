package flixel.system.render.hardware.gl;

import lime.graphics.GLRenderContext;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;

#if FLX_RENDER_GL
import flixel.graphics.shaders.FlxShader;

import openfl._internal.renderer.opengl.GLBlendModeManager;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLShaderManager;
import openfl._internal.renderer.opengl.GLRenderer;

import openfl.gl.GL;
import lime.graphics.RenderContext;
import lime.graphics.Renderer;
#end

class GLContextHelper 
{
	#if FLX_RENDER_GL
	public var currentShader:FlxShader = null;
	public var currentBuffer:RenderTexture = null;
	
	public var blendModeManager:GLBlendModeManager;
	public var shaderManager:GLShaderManager;
	public var filterManager:GLFilterManager;
	public var gl:GLRenderContext;
	
	public function new() 
	{
		Lib.current.stage.window.renderer.onContextLost.add(onRenderContextLost.bind(null));
		Lib.current.stage.window.renderer.onContextRestored.add(onRenderContextRestored.bind(null));
		
		createManagers();
	}
	
	private function createManagers():Void
	{
		gl = GL.context;
		
		if (gl != null)
		{
			blendModeManager = new GLBlendModeManager(gl);
			shaderManager = new GLShaderManager(gl);
		}
	}
	
	public inline function checkFilterManager(renderSession:RenderSession):Void
	{
		if (filterManager == null || renderSession.filterManager != filterManager)
		{
			filterManager = new GLFilterManager(cast renderSession.renderer, renderSession);
			renderSession.filterManager = filterManager;
		}
	}
	
	public inline function checkRenderTarget(buffer:RenderTexture):Void
	{
		if (currentBuffer != buffer)
		{
			currentBuffer = buffer;
			// set render target and configure viewport.
			gl.bindFramebuffer(gl.FRAMEBUFFER, buffer.frameBuffer);
			gl.viewport(0, 0, buffer.width, buffer.height);
		}
	}
	
	public inline function resetFrameBuffer():Void
	{
		if (currentBuffer != null)
		{
			gl.bindFramebuffer(gl.FRAMEBUFFER, null);
			gl.disable(gl.SCISSOR_TEST);
		}
		
		currentBuffer = null;
		currentShader = null;
	}
	
	public inline function setShader(shader:FlxShader):Bool
	{
		var result:Bool = false;
		
		if (shader != currentShader)
		{
			shaderManager.setShader(shader);
			currentShader = shader;
			result = true;
		}
		
		return result;
	}
	
	public inline function setBitmap(bitmap:BitmapData, smoothing:Bool, repeat:Bool):Void
	{
		if (bitmap != null)
		{
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(GL.TEXTURE_2D, bitmap.getTexture(gl));
			gl.uniform1i(currentShader.data.uImage0.index, 0);
			
			GLUtils.setTextureSmoothing(smoothing);
			GLUtils.setTextureWrapping(repeat);
			
			gl.uniform2f(currentShader.data.uTextureSize.index, bitmap.width, bitmap.height);
		}
	}
	
	public inline function setBlendMode(blendMode:BlendMode):Void
	{
		blendModeManager.setBlendMode(blendMode);
	}
	
	public function onRenderContextLost(renderer:Renderer):Void 
	{
		blendModeManager = null;
		shaderManager = null;
		filterManager = null;
		gl = null;
	}
	
	public function onRenderContextRestored(renderer:Renderer, context:RenderContext):Void 
	{
		createManagers();
	}
	#else
	
	public function new() {}
	#end
}