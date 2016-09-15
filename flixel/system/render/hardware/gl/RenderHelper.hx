package flixel.system.render.hardware.gl;

import flixel.graphics.shaders.FlxFilterShader;
import flixel.graphics.shaders.FlxShader;
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

// TODO: add default filter shader...

class RenderHelper implements IFlxDestroyable
{
	public var renderTexture(get, set):RenderTexture;
	public var oldRenderTexture(get, set):RenderTexture;
	public var framebuffer(get, never):GLFramebuffer;
	public var texture(get, never):GLTexture;
	public var width(default, null):Int;
	public var height(default, null):Int;
	public var powerOfTwo(default, null):Bool = true;
	
	public var object(default, set):DisplayObject;
	public var numPasses(get, null):Int;
	
	private var _objMatrix:Matrix = new Matrix();
	private var _swapped:Bool = false;
	private var _texture0:RenderTexture;
	private var _texture1:RenderTexture;
	
	private var _buffer:GLBuffer;
	
	public function new(width:Int, height:Int, powerOfTwo:Bool = false)
	{
		this.width = width;
		this.height = height;
		this.powerOfTwo = powerOfTwo;
		
		renderTexture = new RenderTexture(width, height, powerOfTwo);
		
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
	
	public function swap():Void
	{
		_swapped = !_swapped;
		
		if (renderTexture == null) 
		{
			renderTexture = new RenderTexture(width, height, powerOfTwo);
		}
	}
	
	public inline function clear(?r:Float = 0, ?g:Float = 0, ?b:Float = 0, ?a:Float = 0, ?mask:Null<Int>):Void 
	{
		renderTexture.clear(r, g, b, a, mask);	
	}
	
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		createBuffer();
		renderTexture.resize(width, height);
	}
	
	public function destroy():Void
	{
		if (_texture0 != null) 
		{
			_texture0.destroy();
			_texture0 = null;
		}
		
		if (_texture1 != null) 
		{
			_texture1.destroy();
			_texture1 = null;
		}
		
		object = null;
		_swapped = false;
		_objMatrix = null;
	}
	
	private inline function get_renderTexture():RenderTexture
	{
		return _swapped ? _texture1 : _texture0;
	}
	
	private inline function set_renderTexture(v:RenderTexture):RenderTexture
	{
		return {
			if (_swapped) 
				_texture1 = v;
			else 
				_texture0 = v;
		};
	}
	
	private inline function get_oldRenderTexture():RenderTexture
	{
		return _swapped ? _texture0 : _texture1;
	}
	
	private inline function set_oldRenderTexture(v:RenderTexture):RenderTexture
	{
		return {
			if (_swapped) 
				_texture0 = v;
			else 
				_texture1 = v;
		};
	}
	
	private inline function get_framebuffer():GLFramebuffer 
	{
		return renderTexture.frameBuffer;
	}
	
	private inline function get_texture():GLTexture
	{
		return renderTexture.texture;
	}
	
	private function set_object(v:DisplayObject):DisplayObject
	{
		return object = v;
	}
	
	private function get_numPasses():Int
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
	
	public function capture(object:DisplayObject, modifyObjectMatrix:Bool = false):Void
	{
		this.object = object;
		
		if (numPasses <= 0)
			return;
		
		var objectTransfrom:Matrix = object.__worldTransform;
		_objMatrix.copyFrom(objectTransfrom);
		
		if (modifyObjectMatrix)
			objectTransfrom.identity();
		
		FrameBufferManager.push(renderTexture.frameBuffer);
		
		clear(0, 0, 0, 0, GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
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
				textureToUse = texture;
				
				if ((passes % 2) != 0) // opengl flips texture on y axis
				{
					objectTransfrom.scale(1, -1);
					objectTransfrom.translate(0, height);
				}
			}
			else
			{
				swap();
				FrameBufferManager.push(framebuffer);
				clear();
				textureToUse = oldRenderTexture.texture;
			}
			
			GL.viewport(0, 0, width, height);
			
			shader.data.uMatrix.value = [renderer.getMatrix(objectTransfrom)];
			
			renderSession.shaderManager.setShader(shader);
			GL.bindTexture(GL.TEXTURE_2D, textureToUse);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
			
			gl.vertexAttribPointer(shader.data.aVertex.index, 2, gl.FLOAT, false, 16, 0);
			gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 16, 8);
			
			GL.drawArrays(GL.TRIANGLES, 0, 6);
			
			// check gl error
			if (GL.getError() == GL.INVALID_FRAMEBUFFER_OPERATION)
			{
				trace("INVALID_FRAMEBUFFER_OPERATION!!");
			}
		}
		
		renderSession.shaderManager.setShader(null);
		
		objectTransfrom.copyFrom(_objMatrix);
		object = null;
	}
	
}