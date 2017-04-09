package flixel.system.render.hardware.gl;

import lime.graphics.GLRenderContext;
import openfl.Lib;

#if FLX_RENDER_GL
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
	
	public function checkFilterManager(renderSession:RenderSession):Void
	{
		if (filterManager == null || renderSession.filterManager != filterManager)
		{
			filterManager = new GLFilterManager(cast renderSession.renderer, renderSession);
			renderSession.filterManager = filterManager;
		}
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