package flixel.system.render.hardware.gl;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.graphics.shaders.FlxShader;

#if FLX_RENDER_GL
import flixel.graphics.shaders.tiles.FlxColoredShader;
import flixel.graphics.shaders.tiles.FlxTexturedShader;
import lime.graphics.GLRenderContext;
import lime.math.Matrix4;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import openfl._internal.renderer.RenderSession;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import lime.utils.ArrayBuffer;
import openfl.utils.Float32Array;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawQuadsCommand extends FlxDrawHardwareCommand<FlxDrawQuadsCommand>
{
	private static inline var ELEMENTS_PER_TEXTURED_VERTEX:Int = 6;
	
	private static inline var ELEMENTS_PER_COLORED_VERTEX:Int = 3;
	
	private static inline var BYTES_PER_INDEX:Int = 2;
	
	/**
	 * Default tile shader.
	 */
	private static var defaultTexturedShader:FlxTexturedShader = new FlxTexturedShader();
	
	private static var defaultColoredShader:FlxColoredShader = new FlxColoredShader();
	
	public var roundPixels:Bool = false;
	
	/**
	 * The number of images in the SpriteBatch before it flushes.
	 */
	public var size(default, null):Int = 2000;
	
	/**
	 * Holds the vertices data (positions, uvs, colors)
	 */
	private var vertices:ArrayBuffer;
	
	/**
	 * View on the vertices as a Float32Array
	 */
	private var positions:Float32Array;
	
	/**
	 * View on the vertices as a UInt32Array
	 */
	private var colors:UInt32Array;
	
	/**
	 * Holds the indices
	 */
	private var indices:UInt16Array;
	
	/**
	 * Current number of quads in our batch.
	 */
	public var numQuads(default, null):Int = 0;
	
	public var canAddQuad(get, null):Bool;
	
	private var dirty:Bool = true;
	
	/**
	 * Array for holding render states in our batch...
	 */
	private var states:Array<RenderState> = [];
	
	private var vertexBuffer:GLBuffer;
	private var indexBuffer:GLBuffer;
	
	private var renderSession:RenderSession;
	
	private var uniformMatrix:Matrix4;
	
	private var gl:GLRenderContext;
	
	public function new(size:Int = 2000, textured:Bool = true) 
	{
		super();
		type = FlxDrawItemType.QUADS;
		
		this.size = size;
		
		var elementsPerVertex:Int = (textured) ? FlxDrawQuadsCommand.ELEMENTS_PER_TEXTURED_VERTEX : FlxDrawQuadsCommand.ELEMENTS_PER_COLORED_VERTEX;
		
		// The total number of bytes in our batch
		var numBytes:Int = size * Float32Array.BYTES_PER_ELEMENT * FlxCameraView.VERTICES_PER_QUAD * elementsPerVertex;
		// The total number of indices in our batch
		var numIndices:Int = size * FlxCameraView.INDICES_PER_QUAD;
		
		vertices = new ArrayBuffer(numBytes);
		positions = new Float32Array(vertices);
		colors = new UInt32Array(vertices);
		indices = new UInt16Array(numIndices);
		
		var indexPos:Int = 0;
		var index:Int = 0;
		
		while (indexPos < numIndices)
		{
			this.indices[indexPos + 0] = index + 0;
			this.indices[indexPos + 1] = index + 1;
			this.indices[indexPos + 2] = index + 2;
			this.indices[indexPos + 3] = index + 1;
			this.indices[indexPos + 4] = index + 3;
			this.indices[indexPos + 5] = index + 2;
			
			indexPos += FlxCameraView.INDICES_PER_QUAD;
			index += FlxCameraView.VERTICES_PER_QUAD;
		}
		
		for (i in 0...size)
		{
			states[i] = new RenderState();
		}
	}
	
	private function setContext(gl:GLRenderContext):Void
	{
		if (this.gl == null || this.gl != gl)
		{
			this.gl = gl;
			
			// create a couple of buffers
			vertexBuffer = GL.createBuffer();
			indexBuffer = GL.createBuffer();
			
			// 65535 is max index, so 65535 / 6 = 10922.
			
			//upload the index data
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
			GL.bufferData(GL.ELEMENT_ARRAY_BUFFER, indices, GL.STATIC_DRAW);
			
			GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
			GL.bufferData(GL.ARRAY_BUFFER, positions, GL.DYNAMIC_DRAW);
		}
	}
	
	override public function renderGL(uniformMatrix:Matrix4, renderSession:RenderSession):Void
	{
		setContext(renderSession.gl);
		
		this.uniformMatrix = uniformMatrix;
		this.renderSession = renderSession;
		
		start();
		stop();
	}
	
	public function end():Void
	{
		flush();
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, ?blend:BlendMode, ?smoothing:Bool, ?shader:FlxShader):Void
	{
		// check texture..
	//	if (numQuads > size)
	//	{
	//		flush();
	//		currentTexture = texture;
	//	}
		
		var i = numQuads * Float32Array.BYTES_PER_ELEMENT * FlxDrawQuadsCommand.ELEMENTS_PER_COLORED_VERTEX;
		
		var w:Float = rect.width;
		var h:Float = rect.height;
		
		var a:Float = matrix.a;
		var b:Float = matrix.b;
		var c:Float = matrix.c;
		var d:Float = matrix.d;
		var tx:Float = matrix.tx;
		var ty:Float = matrix.ty;
		
		var intX:Int, intY:Int;
		
		if (roundPixels)
		{
			intX = Std.int(tx);
			intY = Std.int(ty);
			
			// xy
			positions[i] = intX; 							// 0 * a + 0 * c + tx | 0;
			positions[i + 1] = intY; 						// 0 * b + 0 * d + ty | 0;
			
			// xy
			positions[i + 3] = w * a + intX;				// w * a + 0 * c + tx | 0;
			positions[i + 4] = w * b + intY;				// w * b + 0 * d + ty | 0;
			
			// xy
			positions[i + 6] = h * c + intX;				// 0 * a + h * c + tx | 0;
			positions[i + 7] = h * d + intY;				// 0 * b + h * d + ty | 0;
			
			// xy
			positions[i + 9] = w * a + h * c + intX;
			positions[i + 10] = w * b + h * d + intY;
		}
		else
		{
			// xy
			positions[i] = tx;
			positions[i + 1] = ty;
			
			// xy
			positions[i + 3] = w * a + tx;
			positions[i + 4] = w * b + ty;
			
			// xy
			positions[i + 6] = h * c + tx;
			positions[i + 7] = h * d + ty;
			
			// xy
			positions[i + 9] = w * a + h * c + tx;
			positions[i + 10] = w * b + h * d + ty;
		}
		
		color.alphaFloat = alpha;
		colors[i + 2] = colors[i + 5] = colors[i + 8] = colors[i + 11] = color;
		
		var state:RenderState = states[numQuads];
		
		state.set(null, blend, false);
		
		numQuads++;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool):Void
	{
		addUVQuad(frame.parent, frame.frame, frame.uv, matrix, transform, blend, smoothing);
	}
	
	override public function addUVQuad(texture:FlxGraphic, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform, ?blend:BlendMode, ?smoothing:Bool):Void
	{
		// get the uvs for the texture
		var uvx:Float = uv.x;
		var uvy:Float = uv.y;
		var uvx2:Float = uv.width;
		var uvy2:Float = uv.height;
		
		var i = numQuads * Float32Array.BYTES_PER_ELEMENT * FlxDrawQuadsCommand.ELEMENTS_PER_TEXTURED_VERTEX;
		
		var w:Float = rect.width;
		var h:Float = rect.height;
		
		var a:Float = matrix.a;
		var b:Float = matrix.b;
		var c:Float = matrix.c;
		var d:Float = matrix.d;
		var tx:Float = matrix.tx;
		var ty:Float = matrix.ty;
		
		var intX:Int, intY:Int;
		
		if (roundPixels)
		{
			intX = Std.int(tx);
			intY = Std.int(ty);
			
			// xy
			positions[i] = intX; 							// 0 * a + 0 * c + tx | 0;
			positions[i + 1] = intY; 						// 0 * b + 0 * d + ty | 0;
			
			// xy
			positions[i + 6] = w * a + intX;				// w * a + 0 * c + tx | 0;
			positions[i + 7] = w * b + intY;				// w * b + 0 * d + ty | 0;
			
			// xy
			positions[i + 12] = h * c + intX;				// 0 * a + h * c + tx | 0;
			positions[i + 13] = h * d + intY;				// 0 * b + h * d + ty | 0;
			
			// xy
			positions[i + 18] = w * a + h * c + intX;
			positions[i + 19] = w * b + h * d + intY;
		}
		else
		{
			// xy
			positions[i] = tx;
			positions[i + 1] = ty;
			
			// xy
			positions[i + 6] = w * a + tx;
			positions[i + 7] = w * b + ty;
			
			// xy
			positions[i + 12] = h * c + tx;
			positions[i + 13] = h * d + ty;
			
			// xy
			positions[i + 18] = w * a + h * c + tx;
			positions[i + 19] = w * b + h * d + ty;
		}
		
		// uv
		positions[i + 2] = uvx;
		positions[i + 3] = uvy;
		
		// uv
		positions[i + 8] = uvx2;
		positions[i + 9] = uvy;
		
		// uv
		positions[i + 14] = uvx;
		positions[i + 15] = uvy2;
		
		// uv
		positions[i + 20] = uvx2;
		positions[i + 21] = uvy2;
		
		var tint = 0xFFFFFF, color = 0xFFFFFFFF;
		
		if (transform != null)
		{
			tint = Std.int(transform.redMultiplier * 255) << 16 | Std.int(transform.greenMultiplier * 255) << 8 | Std.int(transform.blueMultiplier * 255);
			color = (Std.int(transform.alphaMultiplier * 255) & 0xFF) << 24 | tint;
		}
		
		colors[i + 4] = colors[i + 10] = colors[i + 16] = colors[i + 22] = color;
		
		tint = 0x000000;
		color = 0x00000000;
		
		// update color offsets
		if (transform != null)
		{
			tint = Std.int(transform.redOffset) << 16 | Std.int(transform.greenOffset) << 8 | Std.int(transform.blueOffset);
			color = (Std.int(transform.alphaOffset) & 0xFF) << 24 | tint;
		}
		
		colors[i + 5] = colors[i + 11] = colors[i + 17] = colors[i + 23] = color;
		
		var state:RenderState = states[numQuads];
		state.set(texture, blend, smoothing);
		
		numQuads++;
	}
	
	private function flush():Void
	{
		if (numQuads == 0)
			return;
		
		var batchSize:Int = 0;
		var startIndex:Int = 0;
		
		var state:RenderState = states[0];
		
		shader = getShader();
		renderSession.shaderManager.setShader(shader);
		onShaderSwitch();
		
		var currentTexture:FlxGraphic;
		var nextTexture:FlxGraphic;
		currentTexture = nextTexture = state.texture;
		
		var currentBlendMode:BlendMode;
		var nextBlendMode:BlendMode;
		currentBlendMode = nextBlendMode = state.blend;
		renderSession.blendModeManager.setBlendMode(currentBlendMode);
		
		var currentSmoothing:Bool;
		var nextSmoothing:Bool;
		currentSmoothing = nextSmoothing = state.smoothing;
		
		var blendSwap:Bool = false;
		var textureSwap:Bool = false;
		var smoothingSwap:Bool = false;
		
		for (i in 0...numQuads)
		{
			state = states[i];
			
			nextTexture = state.texture;
			nextBlendMode = state.blend;
			nextSmoothing = state.smoothing;
			
			blendSwap = (currentBlendMode != nextBlendMode);
			textureSwap = (currentTexture != nextTexture);
			smoothingSwap = (currentSmoothing != nextSmoothing);
			
			if (textureSwap || blendSwap || smoothingSwap)
			{
				renderBatch(currentTexture, batchSize, startIndex, nextSmoothing);
				
				startIndex = i;
				batchSize = 0;
				currentTexture = nextTexture;
				currentSmoothing = nextSmoothing;
				
				if (blendSwap)
				{
					currentBlendMode = nextBlendMode;
					this.renderSession.blendModeManager.setBlendMode(currentBlendMode);
				}
			}
			
			batchSize++;
		}
		
		renderBatch(currentTexture, batchSize, startIndex, currentSmoothing);
		
		// then reset the batch!
		numQuads = 0;
	}
	
	private inline function getShader():FlxShader
	{
		if (shader == null)
			shader = (textured) ? defaultTexturedShader : defaultColoredShader;
		
		return shader;
	}
	
	private function onShaderSwitch():Void
	{
		if (dirty)
		{
			dirty = false;
			
			GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, indexBuffer);
			
			// this is the same for each shader?
			var stride:Int = Float32Array.BYTES_PER_ELEMENT * elementsPerVertex;
			var offset:Int = 0;
			
			GL.vertexAttribPointer(shader.data.aPosition.index, 2, GL.FLOAT, false, stride, offset);
			offset += 2 * 4;
			
			if (textured)
			{
				GL.vertexAttribPointer(shader.data.aTexCoord.index, 2, GL.FLOAT, false, stride, offset);
				offset += 2 * 4;
			}
			
			// color attributes will be interpreted as unsigned bytes and normalized
			GL.vertexAttribPointer(shader.data.aColor.index, 4, GL.UNSIGNED_BYTE, true, stride, offset);
			offset += 4;
			
			// quads also have color offset attribute, so we'll need to activate it also...
			if (textured)
			{
				// color offsets will be interpreted as unsigned bytes and normalized
				GL.vertexAttribPointer(shader.data.aColorOffset.index, 4, GL.UNSIGNED_BYTE, true, stride, offset);
			}
		}
		
		// upload the verts to the buffer  
		if (numQuads > 0.5 * size)
		{
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, positions);
		}
		else
		{
			var view = positions.subarray(0, numQuads * Float32Array.BYTES_PER_ELEMENT * elementsPerVertex);
			GL.bufferSubData(GL.ARRAY_BUFFER, 0, view);
		}
	}
	
	private function renderBatch(texture:FlxGraphic, size:Int, startIndex:Int, smoothing:Bool = false):Void
	{
		if (size == 0)
			return;
		
		if (texture != null)
		{
			GL.activeTexture(GL.TEXTURE0);
			GL.bindTexture(GL.TEXTURE_2D, texture.bitmap.getTexture(gl));
			
			GLUtils.setTextureSmoothing(smoothing);
			GLUtils.setTextureWrapping(repeat);
			
			GL.uniform2f(shader.data.uTextureSize.index, texture.width, texture.height);
		}
		else
		{
			GL.activeTexture(GL.TEXTURE0);
			GL.bindTexture(GL.TEXTURE_2D, null);
		}
		
		GL.uniformMatrix4fv(shader.data.uMatrix.index, false, uniformMatrix);
		
		// now draw those suckas!
		GL.drawElements(GL.TRIANGLES, size * FlxCameraView.INDICES_PER_QUAD, GL.UNSIGNED_SHORT, startIndex * FlxCameraView.INDICES_PER_QUAD * BYTES_PER_INDEX);
		
		FlxCameraView.drawCalls++;
	}
	
	public function start():Void
	{
		dirty = true;
	}
	
	public function stop():Void
	{
		flush();
		
		dirty = true;
		renderSession = null;
		uniformMatrix = null;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		vertices = null;
		indices = null;
		positions = null;
		colors = null;
		
		vertexBuffer = GLUtils.destroyBuffer(vertexBuffer);
		indexBuffer = GLUtils.destroyBuffer(indexBuffer);
		
		states = FlxDestroyUtil.destroyArray(states);
		
		renderSession = null;
		uniformMatrix = null;
		gl = null;
		
		shader = null;
	}
	
	override public function equals(type:FlxDrawItemType, graphic:FlxGraphic, colored:Bool, hasColorOffsets:Bool = false,
		?blend:BlendMode, smooth:Bool = false, repeat:Bool = true, ?shader:FlxShader):Bool
	{
		var hasGraphic:Bool = (graphic != null);
		var bothHasGraphic:Bool = (hasGraphic == textured);
		var hasSameShader:Bool = (this.shader == shader);
		
		return bothHasGraphic && hasSameShader;
	}
	
	private function get_canAddQuad():Bool
	{
		return numQuads < FlxCameraView.QUADS_PER_BATCH;
	}
	
	override private function get_numVertices():Int
	{
		return numQuads * FlxCameraView.VERTICES_PER_QUAD;
	}
	
	override private function get_numTriangles():Int
	{
		return numQuads * FlxCameraView.TRIANGLES_PER_QUAD;
	}
	
	override private function get_elementsPerVertex():Int
	{
		return (textured) ? FlxDrawQuadsCommand.ELEMENTS_PER_TEXTURED_VERTEX : FlxDrawQuadsCommand.ELEMENTS_PER_COLORED_VERTEX;
	}
}

class RenderState implements IFlxDestroyable
{
	public var blend:BlendMode;
	public var smoothing:Bool;
	public var texture:FlxGraphic;
	
	public var startIndex:Int = 0;
	public var size:Int = 0;
	
	public function new() {}
	
	public inline function set(texture:FlxGraphic, blend:BlendMode, smooth:Bool = false):Void
	{
		this.texture = texture;
		this.smoothing = smooth;
		this.blend = blend;
	}
	
	public function destroy():Void
	{
		this.texture = null;
		this.blend = null;
	}
}

#else
class FlxDrawQuadsCommand extends FlxDrawHardwareCommand<FlxDrawQuadsCommand>
{
	public static var BATCH_SIZE:Int;
	
	public var numQuads(default, null):Int = 0;
	
	public var canAddQuad(default, null):Bool = false;
	
	public function new(size:Int, textured:Bool = true) 
	{ 
		super();
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, ?blend:BlendMode, ?smoothing:Bool, ?shader:FlxShader):Void {}
	
}
#end