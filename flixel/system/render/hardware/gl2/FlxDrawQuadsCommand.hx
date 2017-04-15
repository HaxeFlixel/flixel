package flixel.system.render.hardware.gl2;

import flixel.graphics.FlxGraphic;
import flixel.graphics.FlxMaterial;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.hardware.gl.GLContextHelper;
import flixel.system.render.hardware.gl.GLUtils;
import flixel.system.render.hardware.gl.RenderTexture;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
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
	 * Holds the indices
	 */
	private static var indices:UInt16Array;
	
	private static var indicesNumBytes:Int = 0;
	
	private static var indexBuffer:GLBuffer;
	
	private static var gl:GLRenderContext;
	
	/**
	 * Creates index buffer (`GLBuffer` object) general for all `FlxDrawQuadsCommand` objects, if its not been created yet.
	 * @param	gl	rendering context, which will be used for creating buffer.
	 */
	private static function createIndexBuffer(gl:GLRenderContext):Void
	{
		if (FlxDrawQuadsCommand.gl == null || FlxDrawQuadsCommand.gl != gl)
		{
			FlxDrawQuadsCommand.gl = gl;
			
			//upload the index data
			if (indexBuffer == null)
			{
				indexBuffer = gl.createBuffer();
				GL.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
				
				#if (openfl >= "4.9.0")
				gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indicesNumBytes, indices, gl.STATIC_DRAW);
				#else
				gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indices, gl.STATIC_DRAW);
				#end
			}
		}
	}
	
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
	 * The total number of bytes in vertices buffer.
	 */
	private var verticesNumBytes:Int = 0;
	
	/**
	 * View on the vertices as a Float32Array
	 */
	private var positions:Float32Array;
	
	/**
	 * View on the vertices as a UInt32Array
	 */
	private var colors:UInt32Array;
	
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
	
	public function new(textured:Bool = true) 
	{
		super();
		type = FlxDrawItemType.QUADS;
		
		this.size = FlxCameraView.QUADS_PER_BATCH;
		
		var elementsPerVertex:Int = (textured) ? FlxDrawQuadsCommand.ELEMENTS_PER_TEXTURED_VERTEX : FlxDrawQuadsCommand.ELEMENTS_PER_COLORED_VERTEX;
		
		// The total number of bytes in our batch
		verticesNumBytes = size * Float32Array.BYTES_PER_ELEMENT * FlxCameraView.VERTICES_PER_QUAD * elementsPerVertex;
		
		vertices = new ArrayBuffer(verticesNumBytes);
		positions = new Float32Array(vertices);
		colors = new UInt32Array(vertices);
		
		if (FlxDrawQuadsCommand.indices == null)
		{
			// The total number of indices in our batch
			var numIndices:Int = size * FlxCameraView.INDICES_PER_QUAD;
			FlxDrawQuadsCommand.indicesNumBytes = numIndices * UInt16Array.BYTES_PER_ELEMENT;
			FlxDrawQuadsCommand.indices = new UInt16Array(numIndices);
			
			var indexPos:Int = 0;
			var index:Int = 0;
			
			while (indexPos < numIndices)
			{
				FlxDrawQuadsCommand.indices[indexPos + 0] = index + 0;
				FlxDrawQuadsCommand.indices[indexPos + 1] = index + 1;
				FlxDrawQuadsCommand.indices[indexPos + 2] = index + 2;
				FlxDrawQuadsCommand.indices[indexPos + 3] = index + 1;
				FlxDrawQuadsCommand.indices[indexPos + 4] = index + 3;
				FlxDrawQuadsCommand.indices[indexPos + 5] = index + 2;
				
				indexPos += FlxCameraView.INDICES_PER_QUAD;
				index += FlxCameraView.VERTICES_PER_QUAD;
			}
		}
		
		for (i in 0...size)
			states[i] = new RenderState();
	}
	
	private function setContext(context:GLContextHelper):Void
	{
		if (this.context == null || this.context.gl != context.gl)
		{
			var gl:GLRenderContext = context.gl;
			FlxDrawQuadsCommand.createIndexBuffer(gl);
			
			// create a couple of buffers
			vertexBuffer = gl.createBuffer();
			gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
			
			#if (openfl >= "4.9.0")
			gl.bufferData(gl.ARRAY_BUFFER, verticesNumBytes, positions, gl.DYNAMIC_DRAW);
			#else
			gl.bufferData(gl.ARRAY_BUFFER, positions, gl.DYNAMIC_DRAW);
			#end
		}
		
		this.context = context;
	}
	
	override public function prepare(uniformMatrix:Matrix4, context:GLContextHelper, buffer:RenderTexture):Void
	{
		setContext(context);
		
		super.prepare(uniformMatrix, context, buffer);
		
		reset();
		
		start();
		
	//	stop();
	}
	
	public function end():Void
	{
		flush();
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, material:FlxMaterial):Void
	{
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
		
		state.set(null, material);
		
		numQuads++;
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
	{
		addUVQuad(frame.parent.bitmap, frame.frame, frame.uv, matrix, transform, material);
	}
	
	override public function addUVQuad(bitmap:BitmapData, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
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
		state.set(bitmap, material);
		
		numQuads++;
	}
	
	override public function flush():Void
	{
		if (numQuads == 0)
			return;
		
		checkRenderTarget();
		
		var batchSize:Int = 0;
		var startIndex:Int = 0;
		
		var state:RenderState = states[0];
		var material:FlxMaterial = state.material;
		
		setShader();
		uploadData();
		
		material.apply(gl);
		
		var currentTexture:BitmapData;
		var nextTexture:BitmapData;
		currentTexture = nextTexture = state.bitmap;
		
		var currentBlendMode:BlendMode;
		var nextBlendMode:BlendMode;
		currentBlendMode = nextBlendMode = material.blendMode;
		context.blendModeManager.setBlendMode(currentBlendMode);
		
		var currentSmoothing:Bool;
		var nextSmoothing:Bool;
		currentSmoothing = nextSmoothing = material.smoothing;
		
		var blendSwap:Bool = false;
		var textureSwap:Bool = false;
		var smoothingSwap:Bool = false;
		
		for (i in 0...numQuads)
		{
			state = states[i];
			material = state.material;
			
			nextTexture = state.bitmap;
			nextBlendMode = material.blendMode;
			nextSmoothing = material.smoothing;
			
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
					context.blendModeManager.setBlendMode(currentBlendMode);
				}
			}
			
			batchSize++;
		}
		
		renderBatch(currentTexture, batchSize, startIndex, currentSmoothing);
		
		// then reset the batch!
		numQuads = 0;
	}
	
	private inline function setShader():FlxShader
	{
		if (shader == null)
			shader = (textured) ? defaultTexturedShader : defaultColoredShader;
			
		if (shader != FlxDrawHardwareCommand.currentShader)
		{
			context.shaderManager.setShader(shader);
			context.gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, FlxDrawQuadsCommand.indexBuffer);
			FlxDrawHardwareCommand.currentShader = shader;
		}
		
		return shader;
	}
	
	private function uploadData():Void
	{
		var gl:GLRenderContext = context.gl;
		
		if (dirty)
		{
			dirty = false;
			
			gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
			
			// this is the same for each shader?
			var stride:Int = Float32Array.BYTES_PER_ELEMENT * elementsPerVertex;
			var offset:Int = 0;
			
			gl.vertexAttribPointer(shader.data.aPosition.index, 2, gl.FLOAT, false, stride, offset);
			offset += 2 * 4;
			
			if (textured)
			{
				gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, stride, offset);
				offset += 2 * 4;
			}
			
			// color attributes will be interpreted as unsigned bytes and normalized
			gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.UNSIGNED_BYTE, true, stride, offset);
			offset += 4;
			
			// quads also have color offset attribute, so we'll need to activate it also...
			if (textured)
			{
				// color offsets will be interpreted as unsigned bytes and normalized
				gl.vertexAttribPointer(shader.data.aColorOffset.index, 4, gl.UNSIGNED_BYTE, true, stride, offset);
			}
		}
		
		// upload the verts to the buffer  
		if (numQuads > 0.5 * size)
		{
			#if (openfl >= "4.9.0")
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, verticesNumBytes, positions);
			#else
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, positions);
			#end
		}
		else
		{
			var viewLen:Int = numQuads * FlxCameraView.VERTICES_PER_QUAD * elementsPerVertex;
			var numBytes:Int = viewLen * Float32Array.BYTES_PER_ELEMENT;
			var view = positions.subarray(0, viewLen);
			
			#if (openfl >= "4.9.0")
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, numBytes, view);
			#else
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, view);
			#end
		}
		
		#if (openfl >= "4.9.0")
		gl.uniformMatrix4fv(shader.data.uMatrix.index, 1, false, uniformMatrix);
		#else
		gl.uniformMatrix4fv(shader.data.uMatrix.index, false, uniformMatrix);
		#end
	}
	
	private function renderBatch(bitmap:BitmapData, size:Int, startIndex:Int, smoothing:Bool = false):Void
	{
		if (size == 0)
			return;
		
		var gl:GLRenderContext = context.gl;
		
		if (bitmap != null)
		{
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(GL.TEXTURE_2D, bitmap.getTexture(gl));
			
			GLUtils.setTextureSmoothing(material.smoothing);
			GLUtils.setTextureWrapping(material.repeat);
			
			gl.uniform2f(shader.data.uTextureSize.index, bitmap.width, bitmap.height);
		}
		
		// now draw those suckas!
		gl.drawElements(gl.TRIANGLES, size * FlxCameraView.INDICES_PER_QUAD, gl.UNSIGNED_SHORT, startIndex * FlxCameraView.INDICES_PER_QUAD * BYTES_PER_INDEX);
		
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
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		vertices = null;
		positions = null;
		colors = null;
		shader = null;
		
		vertexBuffer = GLUtils.destroyBuffer(vertexBuffer);
		states = FlxDestroyUtil.destroyArray(states);
	}
	
	override public function equals(type:FlxDrawItemType, bitmap:BitmapData, colored:Bool, hasColorOffsets:Bool = false,
		material:FlxMaterial):Bool
	{
		if (this.material == material && this.bitmap == bitmap)
			return true;
		
		var bothShadersAreNull:Bool = (material.shader == null && shader == null);
		var hasGraphic:Bool = (bitmap != null);
		var bothHasGraphicAreSame:Bool = (hasGraphic == textured);
		
		return bothShadersAreNull && bothHasGraphicAreSame;
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
	public var bitmap:BitmapData;
	
	public var material:FlxMaterial;
	
	public function new() {}
	
	public inline function set(bitmap:BitmapData, material:FlxMaterial):Void
	{
		this.bitmap = bitmap;
		this.material = material;
	}
	
	public function destroy():Void
	{
		this.bitmap = null;
		this.material = null;
	}
}

#else
class FlxDrawQuadsCommand extends FlxDrawHardwareCommand<FlxDrawQuadsCommand>
{
	public static var BATCH_SIZE:Int;
	
	public var numQuads(default, null):Int = 0;
	
	public var canAddQuad(default, null):Bool = false;
	
	public function new(textured:Bool = true) 
	{ 
		super();
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, material:FlxMaterial):Void {}
	
}
#end