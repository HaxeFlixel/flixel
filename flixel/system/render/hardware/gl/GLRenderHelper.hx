package flixel.system.render.hardware.gl;

import flixel.graphics.shaders.FlxFilterShader;
import flixel.graphics.shaders.FlxShader;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import lime.graphics.GLRenderContext;
import lime.math.Matrix4;
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
	/**
	 * Helper variables for less object instantiation
	 */
	private static var uMatrix:Array<Float32Array> = [];
	private static var _helperMatrix:Matrix4 = new Matrix4();
	
	/**
	 * Checks how many render passes specified object has.
	 * 
	 * @param	object	display object to check
	 * @return	Number of render passes for specified object
	 */
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
	
	/**
	 * Object which this render helper belongs to.
	 */
	public var object(default, null):DisplayObject;
	
	/**
	 * Number of render passes for object which uses this helper.
	 */
	public var numPasses(get, null):Int;
	
	/**
	 * Temp copy of object's transform matrix. Stored while passes are being rendered.
	 */
	private var _objMatrixCopy:Matrix = new Matrix();
	/**
	 * Whether we need to capture whole screen or only specified area
	 */
	private var _fullscreen:Bool;
	
	/**
	 * Helper variable for applying transformations while rendering passes
	 */
	private var _renderMatrix:Matrix = new Matrix();
	
	private var _buffer:GLBuffer;
	
	private var _texture:PingPongTexture;
	
	/**
	 * Temp copy of scissor rectangle. We store it here to restore it after rendering passes.
	 */
	private var _scissor:Array<Int>;
	/**
	 * Temp copy of viewport. We store it here to restore it after rendering passes.
	 */
	private var _viewport:Array<Int>;
	/**
	 * Do we need to restore scissor rectangle after rendering (actually before last render pass).
	 */
	private var _scissorDisabled:Bool;
	
	/**
	 * Projection matrix used for render passes (excluding last render pass, which uses global projection matrix from GLRenderer)
	 */
	private var _projection:Matrix4; // todo: don't make this matrix static var
	
	public function new(object:DisplayObject, width:Int, height:Int, smoothing:Bool = true, powerOfTwo:Bool = false)
	{
		this.smoothing = smoothing;
		this.powerOfTwo = powerOfTwo;
		this.object = object;
		
		resize(width, height);
	}
	
	public function resize(width:Int, height:Int):Void
	{
		this.width = width;
		this.height = height;
		
		_texture = FlxDestroyUtil.destroy(_texture);
		_texture = new PingPongTexture(width, height, smoothing, powerOfTwo);
		
		_projection = Matrix4.createOrtho(0, width, height, 0, -1000, 1000);
		
		createBuffer();
	}
	
	private function createBuffer():Void
	{
		if (_buffer != null)
			GL.deleteBuffer(_buffer);
		
		var uv = _texture.renderTexture.uvData;
		
		var vertices:Float32Array = new Float32Array([
			-1.0, 	-1.0, 	uv.x, 		uv.y,
			1.0, 	-1.0, 	uv.width, 	uv.y,
			-1.0, 	1.0, 	uv.x, 		uv.height,
			1.0, 	-1.0, 	uv.width, 	uv.y,
			1.0, 	1.0, 	uv.width, 	uv.height,
			-1.0, 	1.0, 	uv.x, 		uv.height
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
		_viewport = null;
		
		if (_buffer != null)
			GL.deleteBuffer(_buffer);
	}
	
	private function get_numPasses():Int
	{
		return getObjectNumPasses(object);
	}
	
	/**
	 * Start capturing graphics to internal buffer
	 * 
	 * @param	fullscreen			Do we need to grab whole screen area?
	 */
	public function capture(fullscreen:Bool = false):Void
	{
		if (numPasses <= 0)
			return;
		
		_scissorDisabled = (GL.getParameter(GL.SCISSOR_TEST) == 1) && !fullscreen;
		
		if (_scissorDisabled)
		{
			_scissor = GL.getParameter(GL.SCISSOR_BOX);
			
			// we need to disable scissor testing while we are drawing effects
			GL.disable(GL.SCISSOR_TEST);
			GL.scissor(0, 0, 0, 0);
		}
		
		if (!fullscreen)
		{
			// we need to resize viewport and store its value
			_viewport = GL.getParameter(GL.VIEWPORT);
			GL.viewport(0, 0, width, height);
		}
		
		var objectTransfrom:Matrix = object.__worldTransform;
		_objMatrixCopy.copyFrom(objectTransfrom);
		_fullscreen = fullscreen;
		
		if (!fullscreen)
		{
			objectTransfrom.identity();
		}
		
		FrameBufferManager.push(_texture.renderTexture.frameBuffer);
		_texture.clear(0, 0, 0, 1.0, GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}
	
	/**
	 * Actual rendering of effects added to display object through FlxShaderFilters
	 * 
	 * @param	renderSession	current render session (see openfl internals for details)
	 */
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
			_renderMatrix.scale(0.5 * width, 0.5 * height);
			
			if (i == passes) // last rendering pass
			{
				textureToUse = _texture.texture;
				
				if ((passes % 2) != 0) // opengl flips texture on y axis, so last render should be flipped as well
				{
					_renderMatrix.scale(1, -1);
				}
				
				// enable scissor testing before last render pass.
				if (_scissorDisabled)
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
			}
			
			_renderMatrix.translate(0.5 * width, 0.5 * height);
			
			if (i == passes && !_fullscreen)
			{
				// restore object matrix before last render pass
				_renderMatrix.concat(_objMatrixCopy);
				// restore viewport before last render pass.
				GL.viewport(_viewport[0], _viewport[1], _viewport[2], _viewport[3]);
			}
			
			uMatrix[0] = getMatrix(_renderMatrix, renderer, passes - i);
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
	}
	
	/**
	 * Gets matrix combined from specified transform matrix and projection matrix for current viewport
	 * 
	 * @param	transform		matrix to combine with projection matrix
	 * @param	renderer		gl renderer to get matrix from (used when passesLeft is 0).	
	 * @param	passesLeft		number of render passes left. If 0 then will be used global projection matrix, if greater than 0 then will be used projection matrix from this helper object
	 * @return	Combined matrix which can be used for rendering as shader uniform.
	 */
	public function getMatrix(transform:Matrix, renderer:GLRenderer, passesLeft:Int = 0):Matrix4 
	{
		if (passesLeft == 0)
		{
			return renderer.getMatrix(transform);
		}
		else if (passesLeft < 0)
		{
			return null;
		}
		
		_helperMatrix.identity();
		_helperMatrix[0] = transform.a;
		_helperMatrix[1] = transform.b;
		_helperMatrix[4] = transform.c;
		_helperMatrix[5] = transform.d;
		_helperMatrix[12] = transform.tx;
		_helperMatrix[13] = transform.ty;
		_helperMatrix.append(_projection);
		return _helperMatrix;
	}
	
}