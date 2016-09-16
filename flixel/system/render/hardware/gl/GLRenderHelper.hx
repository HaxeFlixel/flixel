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

class GLRenderHelper implements IFlxDestroyable
{
	private static var uMatrix:Array<Float32Array> = [];
	private static var stageHeight:Float = 0;
	
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
	public var smoothing(default, null):Bool;
	public var powerOfTwo(default, null):Bool;
	
	public var object(default, set):DisplayObject;
	public var numPasses(get, null):Int;
	
	private var _objMatrixCopy:Matrix = new Matrix();
	private var _objectMatrixModified:Bool;
	
	private var _renderMatrix:Matrix = new Matrix();
	
	private var _buffer:GLBuffer;
	
	private var _texture:PingPongTexture;
	
	private var _scissor:Array<Int>;
	private var _scissorEnabled:Bool;
	
	public function new(width:Int, height:Int, smoothing:Bool = true, powerOfTwo:Bool = false)
	{
		this.smoothing = smoothing;
		this.powerOfTwo = powerOfTwo;
		
		resize(width, height);
	}
	
	public function resize(width:Int, height:Int):Void
	{
		stageHeight = FlxG.stage.stageHeight;
		
		this.width = width;
		this.height = height;
		
		_texture = FlxDestroyUtil.destroy(_texture);
		_texture = new PingPongTexture(width, height, smoothing, powerOfTwo);
		
		createBuffer();
	}
	
	private function createBuffer():Void
	{
		if (_buffer != null)
			GL.deleteBuffer(_buffer);
		
		var uv = _texture.renderTexture.uvData;
		
		var vertices:Float32Array = new Float32Array([
			0.0, 	0.0, 	uv.x, 		uv.y,
			1.0, 	0.0, 	uv.width, 	uv.y,
			0.0, 	1.0, 	uv.x, 		uv.height,
			1.0, 	0.0, 	uv.width, 	uv.y,
			1.0, 	1.0, 	uv.width, 	uv.height,
			0.0, 	1.0, 	uv.x, 		uv.height
		]);	
		
		_buffer = GL.createBuffer();
		GL.bindBuffer(GL.ARRAY_BUFFER, _buffer);
		GL.bufferData(GL.ARRAY_BUFFER, vertices, GL.STATIC_DRAW);
		GL.bindBuffer(GL.ARRAY_BUFFER, null);
	}
	
	public function destroy():Void
	{
		_texture = FlxDestroyUtil.destroy(_texture);
		
		object = null;
		_objMatrixCopy = null;
		_renderMatrix = null;
		_scissor = null;
		
		if (_buffer != null)
			GL.deleteBuffer(_buffer);
	}
	
	private function set_object(v:DisplayObject):DisplayObject
	{
		return object = v;
	}
	
	private function get_numPasses():Int
	{
		return getObjectNumPasses(object);
	}
	
	public function capture(object:DisplayObject, modifyObjectMatrix:Bool = false, disableScissor:Bool = true):Void
	{
		this.object = object;
		
		if (numPasses <= 0)
			return;
		
		_scissorEnabled = (GL.getParameter(GL.SCISSOR_TEST) == 1) && disableScissor;
		
		if (_scissorEnabled)
		{
			_scissor = GL.getParameter(GL.SCISSOR_BOX);
			
			// we need to disable scissor testing while we are drawing effects
			GL.disable(GL.SCISSOR_TEST);
			GL.scissor(0, 0, 0, 0);
		}
		
		var objectTransfrom:Matrix = object.__worldTransform;
		_objMatrixCopy.copyFrom(objectTransfrom);
		_objectMatrixModified = modifyObjectMatrix;
		
		if (modifyObjectMatrix)
		{
			objectTransfrom.identity();
			objectTransfrom.translate(0, (stageHeight - height));
		}
		
		FrameBufferManager.push(_texture.renderTexture.frameBuffer);
		_texture.clear(0, 0, 0, 1.0, GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
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
			
			_renderMatrix.identity();
			_renderMatrix.scale(width, height);
			
			if (i == passes) // last rendering pass
			{
				textureToUse = _texture.texture;
				
				if ((passes % 2) != 0) // opengl flips texture on y axis, so last render should be flipped as well
				{
					_renderMatrix.scale(1, -1);
					_renderMatrix.translate(0, height);
				}
				
				if (_objectMatrixModified)
				{
					_renderMatrix.concat(_objMatrixCopy);
				}
				
				// enable scissor testing before last render pass.
				if (_scissorEnabled)
				{
					gl.enable(gl.SCISSOR_TEST);	
					gl.scissor(_scissor[0], _scissor[1], _scissor[2], _scissor[3]);
				}
			}
			else
			{
				_texture.swap();
				FrameBufferManager.push(_texture.framebuffer);
				_texture.clear();
				textureToUse = _texture.oldRenderTexture.texture;
				
				_renderMatrix.translate(0, (stageHeight - height));
			}
			
			uMatrix[0] = renderer.getMatrix(_renderMatrix);
			shader.data.uMatrix.value = uMatrix;
			
			renderSession.shaderManager.setShader(shader);
			gl.bindTexture(GL.TEXTURE_2D, textureToUse);
			
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, _texture.smoothing ? gl.LINEAR : gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, _texture.smoothing ? gl.LINEAR : gl.NEAREST);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE);
			gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE);
			
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
		
		object.__worldTransform.copyFrom(_objMatrixCopy);
		object = null;
	}
	
}