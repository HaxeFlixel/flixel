package flixel.system.render.gl;

import flixel.graphics.FlxMaterial;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawCommand.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.geom.ColorTransform;
import flixel.graphics.shaders.FlxShader;

#if FLX_RENDER_GL
import flixel.graphics.shaders.quads.FlxColoredShader;
import flixel.graphics.shaders.quads.FlxTexturedShader;
import lime.graphics.opengl.GLBuffer;
import lime.utils.UInt16Array;
import lime.utils.UInt32Array;
import lime.utils.ArrayBuffer;
import lime.utils.Float32Array;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawQuadsCommand extends FlxDrawHardwareCommand<FlxDrawQuadsCommand>
{
	private static inline var ELEMENTS_PER_VERTEX:Int = 6;
	
	private static inline var BYTES_PER_INDEX:Int = 2;
	
	/**
	 * Default tile shaders.
	 */
	public static var defaultTexturedShader:FlxTexturedShader = new FlxTexturedShader();
	public static var defaultColoredShader:FlxColoredShader = new FlxColoredShader();
	
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
	private var verticesNumBytes(get, null):Int;
	
	/**
	 * View on the vertices as a Float32Array
	 */
	private var positions:Float32Array;
	
	/**
	 * View on the vertices as a UInt32Array
	 */
	private var colors:UInt32Array;
	
	private var vertexBuffer:GLBuffer;
	
	/**
	 * Holds the indices
	 */
	private var indices:UInt16Array;
	
	private var indexBuffer:GLBuffer;
	
	/**
	 * Current number of quads in our batch.
	 */
	public var numQuads(default, null):Int = 0;
	
	private var vertexIndex:Int = 0;
	
	public var canAddQuad(get, null):Bool;
	
	private var dirty:Bool = true;
	
	/**
	 * Array for holding render states in our batch...
	 */
	private var states:Array<RenderState> = [];
	
	public function new(size:Int = 0)
	{
		super();
		type = FlxDrawItemType.QUADS;
		
		if (size <= 0)
			size = FlxCameraView.QUADS_PER_BATCH;
		
		this.size = size;
		
		vertices = new ArrayBuffer(verticesNumBytes);
		positions = new Float32Array(vertices);
		colors = new UInt32Array(vertices);
		
		// The total number of indices in our batch
		var numIndices:Int = size * FlxCameraView.INDICES_PER_QUAD;
		indices = new UInt16Array(numIndices);
		
		var indexPos:Int = 0;
		var index:Int = 0;
		
		while (indexPos < numIndices)
		{
			indices[indexPos + 0] = index + 0;
			indices[indexPos + 1] = index + 1;
			indices[indexPos + 2] = index + 2;
			indices[indexPos + 3] = index + 1;
			indices[indexPos + 4] = index + 3;
			indices[indexPos + 5] = index + 2;
			
			indexPos += FlxCameraView.INDICES_PER_QUAD;
			index += FlxCameraView.VERTICES_PER_QUAD;
		}
		
		for (i in 0...size)
			states[i] = new RenderState();
	}
	
	override private function setContext(context:GLContextHelper):Void
	{
		if (this.gl == null || this.gl != context.gl)
		{
			super.setContext(context);
			
			// create a couple of buffers
			indexBuffer = gl.createBuffer();
			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
			
			var indicesNumBytes:Int = size * FlxCameraView.INDICES_PER_QUAD * UInt16Array.BYTES_PER_ELEMENT;
			gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, indicesNumBytes, indices, gl.STATIC_DRAW);
			
			vertexBuffer = gl.createBuffer();
			gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
			gl.bufferData(gl.ARRAY_BUFFER, verticesNumBytes, positions, gl.DYNAMIC_DRAW);
		}
		
		this.context = context;
	}
	
	override public function prepare(context:GLContextHelper, buffer:FlxRenderTexture, ?transform:FlxMatrix):Void
	{
		setContext(context);
		super.prepare(context, buffer, transform);
		reset();
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, material:FlxMaterial):Void
	{
		var i = numQuads * Float32Array.BYTES_PER_ELEMENT * elementsPerVertex;
		
		var w:Float = rect.width;
		var h:Float = rect.height;
		
		var a:Float = matrix.a;
		var b:Float = matrix.b;
		var c:Float = matrix.c;
		var d:Float = matrix.d;
		var tx:Float = matrix.tx;
		var ty:Float = matrix.ty;
		
		var intX:Int, intY:Int;
		
		var x1:Float, y1:Float,
			x2:Float, y2:Float,
			x3:Float, y3:Float,
			x4:Float, y4:Float;
		
		if (roundPixels)
		{
			intX = Std.int(tx);
			intY = Std.int(ty);
			
			// xy
			x1 = intX; 						// 0 * a + 0 * c + tx | 0;
			y1 = intY; 						// 0 * b + 0 * d + ty | 0;
			
			// xy
			x2 = w * a + intX;				// w * a + 0 * c + tx | 0;
			y2 = w * b + intY;				// w * b + 0 * d + ty | 0;
			
			// xy
			x3 = h * c + intX;				// 0 * a + h * c + tx | 0;
			y3 = h * d + intY;				// 0 * b + h * d + ty | 0;
			
			// xy
			x4 = w * a + h * c + intX;
			y4 = w * b + h * d + intY;
		}
		else
		{
			// xy
			x1 = tx;
			y1 = ty;
			
			// xy
			x2 = w * a + tx;
			y2 = w * b + ty;
			
			// xy
			x3 = h * c + tx;
			y3 = h * d + ty;
			
			// xy
			x4 = w * a + h * c + tx;
			y4 = w * b + h * d + ty;
		}
		
		color.alphaFloat = alpha;
		
		startQuad(null, material);
		addVertex(x1, y1, 0.0, 0.0, color);
		addVertex(x2, y2, 0.0, 0.0, color);
		addVertex(x3, y3, 0.0, 0.0, color);
		addVertex(x4, y4, 0.0, 0.0, color);
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
		
		var w:Float = rect.width;
		var h:Float = rect.height;
		
		var a:Float = matrix.a;
		var b:Float = matrix.b;
		var c:Float = matrix.c;
		var d:Float = matrix.d;
		var tx:Float = matrix.tx;
		var ty:Float = matrix.ty;
		
		var intX:Int, intY:Int;
		
		var x1:Float, y1:Float,
			x2:Float, y2:Float,
			x3:Float, y3:Float,
			x4:Float, y4:Float;
		
		if (roundPixels)
		{
			intX = Std.int(tx);
			intY = Std.int(ty);
			
			// xy
			x1 = intX; 						// 0 * a + 0 * c + tx | 0;
			y1 = intY; 						// 0 * b + 0 * d + ty | 0;
			
			// xy
			x2 = w * a + intX;				// w * a + 0 * c + tx | 0;
			y2 = w * b + intY;				// w * b + 0 * d + ty | 0;
			
			// xy
			x3 = h * c + intX;				// 0 * a + h * c + tx | 0;
			y3 = h * d + intY;				// 0 * b + h * d + ty | 0;
			
			// xy
			x4 = w * a + h * c + intX;
			y4 = w * b + h * d + intY;
		}
		else
		{
			// xy
			x1 = tx;
			y1 = ty;
			
			// xy
			x2 = w * a + tx;
			y2 = w * b + ty;
			
			// xy
			x3 = h * c + tx;
			y3 = h * d + ty;
			
			// xy
			x4 = w * a + h * c + tx;
			y4 = w * b + h * d + ty;
		}
		
		var tint = 0xFFFFFF, color = 0xFFFFFFFF;
		
		if (transform != null)
		{
			tint = Std.int(transform.redMultiplier * 255) << 16 | Std.int(transform.greenMultiplier * 255) << 8 | Std.int(transform.blueMultiplier * 255);
			color = (Std.int(transform.alphaMultiplier * 255) & 0xFF) << 24 | tint;
		}
		
		tint = 0x000000;
		var colorOffset = 0x00000000;
		
		// update color offsets
		if (transform != null)
		{
			tint = Std.int(transform.redOffset) << 16 | Std.int(transform.greenOffset) << 8 | Std.int(transform.blueOffset);
			colorOffset = (Std.int(transform.alphaOffset) & 0xFF) << 24 | tint;
		}
		
		startQuad(bitmap, material);
		addVertex(x1, y1, uvx, uvy, color, colorOffset);
		addVertex(x2, y2, uvx2, uvy, color, colorOffset);
		addVertex(x3, y3, uvx, uvy2, color, colorOffset);
		addVertex(x4, y4, uvx2, uvy2, color, colorOffset);
	}
	
	public inline function startQuad(bitmap:BitmapData, material:FlxMaterial):Void
	{
		if (!canAddQuad)
		{
			flush();
		}
		else if (numQuads > 0)
		{
			var sameMaterial:Bool = (this.material == material);
			var bothNullShaders:Bool = (material.shader == null && shader == null);
			var sameTextured:Bool = (this.textured == (bitmap != null));
			
			if (!(sameMaterial || bothNullShaders || sameTextured))
				flush();
		}
		
		set(bitmap, true, (bitmap != null), material);
		var state:RenderState = states[numQuads];
		state.set(bitmap, material);
		numQuads++;
	}
	
	public inline function addVertex(x:Float = 0, y:Float = 0, u:Float = 0, v:Float = 0, color:Int = FlxColor.WHITE, colorOffset:FlxColor = FlxColor.TRANSPARENT):Void
	{
		if (roundPixels)
		{
			positions[vertexIndex++] = Std.int(x);
			positions[vertexIndex++] = Std.int(y);
		}
		else
		{
			positions[vertexIndex++] = x;
			positions[vertexIndex++] = y;
		}
		
		positions[vertexIndex++] = u;
		positions[vertexIndex++] = v;
		colors[vertexIndex++] = color;
		colors[vertexIndex++] = colorOffset;
	}
	
	override public function flush():Void
	{
		if (numQuads == 0)
			return;
		
		context.checkRenderTarget(buffer);
		
		var batchSize:Int = 0;
		var startIndex:Int = 0;
		
		var state:RenderState = states[0];
		var currentMaterial:FlxMaterial = state.material;
		var nextMaterial:FlxMaterial;
		
		shader = setShader(currentMaterial);
		uploadData();
		
		currentMaterial.apply(gl);
		
		var currentTexture:BitmapData = state.bitmap;
		var nextTexture:BitmapData = currentTexture;
		
		var currentBlendMode:BlendMode = currentMaterial.blendMode;
		var nextBlendMode:BlendMode = currentBlendMode;
		context.setBlendMode(currentBlendMode);
		
		var currentSmoothing:Bool = currentMaterial.smoothing;
		var nextSmoothing:Bool = currentSmoothing;
		
		if (numQuads == 1)
		{
			renderBatch(currentTexture, 1, 0, currentMaterial);
			reset();
			return;
		}
		
		var blendSwap:Bool = false;
		var textureSwap:Bool = false;
		var smoothingSwap:Bool = false;
		
		for (i in 0...numQuads)
		{
			state = states[i];
			nextMaterial = state.material;
			
			nextTexture = state.bitmap;
			nextBlendMode = nextMaterial.blendMode;
			nextSmoothing = nextMaterial.smoothing;
			
			blendSwap = (currentBlendMode != nextBlendMode);
			textureSwap = (currentTexture != nextTexture);
			smoothingSwap = (currentSmoothing != nextSmoothing);
			
			if (textureSwap || blendSwap || smoothingSwap)
			{
				renderBatch(currentTexture, batchSize, startIndex, currentMaterial);
				
				startIndex = i;
				batchSize = 0;
				currentTexture = nextTexture;
				currentSmoothing = nextSmoothing;
				
				if (blendSwap)
				{
					currentBlendMode = nextBlendMode;
					context.setBlendMode(currentBlendMode);
				}
			}
			
			currentMaterial = nextMaterial;
			batchSize++;
		}
		
		renderBatch(currentTexture, batchSize, startIndex, currentMaterial);
		
		// then reset the batch!
		reset();
	}
	
	override public function reset():Void 
	{
		super.reset();
		
		dirty = true;
		numQuads = 0;
		vertexIndex = 0;
	}
	
	override private inline function setShader(material:FlxMaterial):FlxShader
	{
		var shader = material.shader;
		
		if (shader == null)
			shader = (textured) ? defaultTexturedShader : defaultColoredShader;
		
		if (context.setShader(shader))
			context.gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, indexBuffer);
		
		return shader;
	}
	
	private function uploadData():Void
	{
		if (dirty)
		{
			dirty = false;
			
			gl.bindBuffer(gl.ARRAY_BUFFER, vertexBuffer);
			
			var stride:Int = Float32Array.BYTES_PER_ELEMENT * elementsPerVertex;
			var offset:Int = 0;
			
			gl.vertexAttribPointer(shader.data.aPosition.index, 2, gl.FLOAT, false, stride, offset);
			offset += 2 * 4;
			
			if (textured)
				gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, stride, offset);
			
			offset += 2 * 4;
			
			// color attributes will be interpreted as unsigned bytes and normalized
			gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.UNSIGNED_BYTE, true, stride, offset);
			offset += 4;
			
			// quads also have color offset attribute, so we'll need to activate it also...
			if (textured)
				gl.vertexAttribPointer(shader.data.aColorOffset.index, 4, gl.UNSIGNED_BYTE, true, stride, offset);
		}
		
		// upload the verts to the buffer  
		if (numQuads > 0.5 * size)
		{
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, verticesNumBytes, positions);
		}
		else
		{
			var viewLen:Int = numQuads * FlxCameraView.VERTICES_PER_QUAD * elementsPerVertex;
			var view = positions.subarray(0, viewLen);
			
			var numBytes:Int = viewLen * Float32Array.BYTES_PER_ELEMENT;
			gl.bufferSubData(gl.ARRAY_BUFFER, 0, numBytes, view);
		}
		
		gl.uniformMatrix4fv(shader.data.uMatrix.index, 1, false, uniformMatrix);
	}
	
	private function renderBatch(bitmap:BitmapData, size:Int, startIndex:Int, material:FlxMaterial):Void
	{
		if (size == 0)
			return;
		
		context.setBitmap(bitmap, material.smoothing, material.repeat);
		
		// now draw those suckas!
		gl.drawElements(gl.TRIANGLES, size * FlxCameraView.INDICES_PER_QUAD, gl.UNSIGNED_SHORT, startIndex * FlxCameraView.INDICES_PER_QUAD * BYTES_PER_INDEX);
		FlxCameraView.drawCalls++;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		vertices = null;
		positions = null;
		colors = null;
		shader = null;
		
		vertexBuffer = GLUtils.destroyBuffer(vertexBuffer);
		indexBuffer = GLUtils.destroyBuffer(indexBuffer);
		states = FlxDestroyUtil.destroyArray(states);
	}
	
	override public function equals(type:FlxDrawItemType, bitmap:BitmapData, colored:Bool, hasColorOffsets:Bool = false,
		material:FlxMaterial):Bool
	{
		if (this.material == material && this.bitmap == bitmap)
			return true;
		
		var bothNullShaders:Bool = (material.shader == null && shader == null);
		var hasGraphic:Bool = (bitmap != null);
		var sameHasGraphic:Bool = (hasGraphic == textured);
		
		return bothNullShaders && sameHasGraphic;
	}
	
	private function get_canAddQuad():Bool
	{
		return numQuads < size;
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
		return FlxDrawQuadsCommand.ELEMENTS_PER_VERTEX;
	}
	
	private inline function get_verticesNumBytes():Int
	{
		return size * Float32Array.BYTES_PER_ELEMENT * FlxCameraView.VERTICES_PER_QUAD * elementsPerVertex;
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
#end