package flixel.system.render.gl;

import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import openfl._internal.renderer.AbstractFilterManager;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.DisplayObject;
import openfl.display.Shader;
import openfl.geom.Matrix;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl._internal.renderer.opengl.GLRenderer)
@:access(openfl.display.BitmapData)
@:access(openfl.display.DisplayObject)
@:access(openfl.filters.BitmapFilter)
@:keep

class GLFilterManager extends AbstractFilterManager
{
	private var filterDepth:Int;
	private var gl:GLRenderContext;
	private var matrix:Matrix;
	private var renderer:GLRenderer;
	
	public function new(renderer:GLRenderer, renderSession:RenderSession)
	{
		super(renderSession);
		
		this.renderer = renderer;
		this.gl = renderSession.gl;
		
		filterDepth = 0;
		matrix = new Matrix();
	}
	
	private function getNumPasses(object:DisplayObject):Int
	{
		var numPasses:Int = 0;
		
		if (object.__filters != null && object.__filters.length > 0)
		{
			numPasses = object.__filters.length;
			
			for (filter in object.__filters)
				numPasses += (filter.__numPasses > 0) ? (filter.__numPasses - 1) : 0;
		}
		
		return numPasses;
	}
	
	override public function pushObject(object:DisplayObject):Shader 
	{	
		if (object.__filters != null && object.__filters.length > 0)
		{
			renderer.getRenderTarget(true);
			filterDepth++;
		}
		
		return renderSession.shaderManager.defaultShader;
	}
	
	override public function popObject(object:DisplayObject):Void
	{
		if (object.__filters != null && object.__filters.length > 0)
		{
			var numPasses:Int = getNumPasses(object);
			
			if (numPasses > 0)
			{
				var currentTarget, shader;
				
				for (filter in object.__filters)
				{
					var i:Int = 0;
					
					do {
						currentTarget = renderer.currentRenderTarget;
						renderer.getRenderTarget(true);
						shader = filter.__initShader(renderSession, i);
						
						renderPass(currentTarget, shader);
						
						i++;
					}
					while (i < filter.__numPasses);
					
					// TODO: Properly handle filter-within-filter rendering
					
					filterDepth--;
					currentTarget = renderer.currentRenderTarget;
					renderer.getRenderTarget(filterDepth > 0);
					
					renderPass(currentTarget, renderSession.shaderManager.defaultShader);
				}
			}
			else
			{
				filterDepth--;
			}
		}
	}
	
	private function renderPass(target:BitmapData, shader:Shader):Void
	{
		if (target == null || shader == null) 
			return;
		
		shader.data.uImage0.input = target;
		shader.data.uImage0.smoothing = renderSession.allowSmoothing && renderSession.upscaled;
		shader.data.uMatrix.value = renderer.getMatrix(matrix);
		
		renderSession.shaderManager.setShader(shader);
		
	//	gl.bindBuffer(gl.ARRAY_BUFFER, target.getBuffer(gl, 1.0, null)); // TODO: fix this line...
		gl.bindBuffer(gl.ARRAY_BUFFER, target.getBuffer(gl, 1.0)); // TODO: fix this line...
		gl.vertexAttribPointer(shader.data.aPosition.index, 3, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 0);
		gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 3 * Float32Array.BYTES_PER_ELEMENT);
		gl.vertexAttribPointer(shader.data.aAlpha.index, 1, gl.FLOAT, false, 6 * Float32Array.BYTES_PER_ELEMENT, 5 * Float32Array.BYTES_PER_ELEMENT);
		
		gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
	}
}