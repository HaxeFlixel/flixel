package flixel.system.render.hardware.gl;

import flixel.graphics.shaders.FlxFilterShader;
import flixel.graphics.shaders.FlxShader;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import openfl._internal.renderer.RenderSession;
import openfl._internal.renderer.opengl.GLRenderer;
import openfl.display.DisplayObject;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.gl.GLFramebuffer;
import openfl.gl.GLTexture;
import openfl.utils.Float32Array;

// TODO: handle camera resize here...

class GLRenderHelper implements IFlxDestroyable
{
	public static function getObjectNumPasses(object:DisplayObject):Int
	{
		if (object == null || object.filters == null)
			return 0;
		
		var passes:Int = 0;
		var shaderFilter:ShaderFilter;
		
		for (filter in object.filters)
		{
			if (Std.is(filter, ShaderFilter))
			{
				shaderFilter = cast filter;
				
				if (Std.is(shaderFilter.shader, FlxFilterShader))
				{
					passes++;
				}
			}
		}
		
		return passes;
	}
	
	public var width(default, null):Int;
	public var height(default, null):Int;
	
	public var object(default, set):DisplayObject;
	public var numPasses(get, null):Int;
	
	private var _objMatrix:Matrix = new Matrix();
	private var _renderMatrix:Matrix = new Matrix(); // TODO: use this var...
	
	private var _buffer:GLBuffer;
	
	private var _texture:PingPongTexture;
	
	public function new(width:Int, height:Int, smoothing:Bool = true, powerOfTwo:Bool = false)
	{
		this.width = width;
		this.height = height;
		
		_texture = new PingPongTexture(width, height, smoothing, powerOfTwo);
		
		createBuffer();
	}
	
	private function createBuffer():Void
	{
		if (_buffer != null)
			GL.deleteBuffer(_buffer);
			
		var vertices:Float32Array = new Float32Array([
			0.0, 0.0, 0, 0,
			width, 0.0, 1, 0,
			0.0,  height, 0, 1,
			width, 0.0, 1, 0,
			width,  height, 1, 1,
			0.0,  height, 0, 1
		]);	
		
		_buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
		GL.bufferData(GL.ARRAY_BUFFER, vertices, GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}
	
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		createBuffer();
		_texture.resize(width, height);
	}
	
	public function destroy():Void
	{
		_texture = FlxDestroyUtil.destroy(_texture);
		
		object = null;
		_objMatrix = null;
		_renderMatrix = null;
	}
	
	private function set_object(v:DisplayObject):DisplayObject
	{
		return object = v;
	}
	
	private function get_numPasses():Int
	{
		return getObjectNumPasses(object);
	}
	
	public function capture(object:DisplayObject, modifyObjectMatrix:Bool = false):Void
	{
		this.object = object;
		
		if (numPasses <= 0)
			return;
		
		// TODO: what to do with object's matrix???
		var objectTransfrom:Matrix = object.__worldTransform;
		_objMatrix.copyFrom(objectTransfrom);
		
		if (modifyObjectMatrix)
			objectTransfrom.identity();
		
		FrameBufferManager.push(_texture.renderTexture.frameBuffer);
		_texture.clear(0, 0, 0, 0, GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}
	
	public function render(renderSession:RenderSession):Void
	{
		var passes:Int = numPasses;
		if (passes <= 0)	return;
		
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		var textureToUse:GLTexture;
		
		var objectTransfrom:Matrix = object.__worldTransform;
		
		var filters:Array<BitmapFilter> = object.filters;
		var numFilters:Int = filters.length;
		var filter:ShaderFilter;
		var shader:FlxFilterShader = null;
		
		var filterIndex:Int = 0;
		var i:Int = 0;
		
		while (i < passes && filterIndex < numFilters)
		{
			shader = null;
			
			if (Std.is(filters[filterIndex], ShaderFilter))
			{
				filter = cast(filters[filterIndex], ShaderFilter);
				
				if (Std.is(filter.shader, FlxFilterShader))
				{
					shader = cast(filter.shader, FlxFilterShader);
					i++;
				}
			}
			
			filterIndex++;
			
			if (shader == null)
				continue;
			
			FrameBufferManager.pop();
			
			if (i == passes)
			{
				textureToUse = _texture.texture;
				
				if ((passes % 2) != 0) // opengl flips texture on y axis, so last render should be flipped as well
				{
					objectTransfrom.scale(1, -1);
					objectTransfrom.translate(0, height);
				}
			}
			else
			{
				_texture.swap();
				FrameBufferManager.push(_texture.framebuffer);
				_texture.clear();
				textureToUse = _texture.oldRenderTexture.texture;
			}
			
			gl.viewport(0, 0, width, height);
			
			shader.data.uMatrix.value = [renderer.getMatrix(objectTransfrom)];
			
			renderSession.shaderManager.setShader(shader);
			gl.bindTexture(GL.TEXTURE_2D, textureToUse);
			
			gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, _texture.smoothing ? gl.LINEAR : gl.NEAREST);
			gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, _texture.smoothing ? gl.LINEAR : gl.NEAREST);
			gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri (gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			
			gl.bindBuffer(GL.ARRAY_BUFFER, _buffer);
			
			gl.vertexAttribPointer(shader.data.aVertex.index, 2, gl.FLOAT, false, 16, 0);
			gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 16, 8);
			
			gl.drawArrays(GL.TRIANGLES, 0, 6);
			
			// check gl error
			if (gl.getError() == GL.INVALID_FRAMEBUFFER_OPERATION)
			{
				trace("INVALID_FRAMEBUFFER_OPERATION!!");
			}
		}
		
		renderSession.shaderManager.setShader(null);
		
		objectTransfrom.copyFrom(_objMatrix);
		object = null;
	}
	
}