package flixel.system.render.hardware.gl;

import flixel.graphics.FlxMaterial;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;
import lime.graphics.GLRenderContext;
import lime.math.Matrix4;
import openfl.display.BitmapData;
import openfl.gl.GL;
import openfl.gl.GLBuffer;
import openfl.utils.Float32Array;
import openfl._internal.renderer.RenderSession;

#if FLX_RENDER_GL
class FlxDrawSingleQuadCommand extends FlxDrawHardwareCommand<FlxDrawSingleQuadCommand>
{
	private static inline var ELEMENTS_PER_TEXTURED_VERTEX:Int = 4;
	
	private static inline var ELEMENTS_PER_COLORED_VERTEX:Int = 2;
	
	/**
	 * View on the vertices as a Float32Array
	 */
	private var texturedVertices:Float32Array;
	
	private var coloredVertices:Float32Array;
	
	//private var uniformMatrix:Matrix4;
	
	private var modelMatrix:Matrix4;	// TODO: use this matrix...
	
	private var texturedVertexBuffer:GLBuffer;
	
	private var coloredVertexBuffer:GLBuffer;
	
	private var renderSession:RenderSession;
	
	private var uniformMatrix:Matrix4;
	
	private var gl:GLRenderContext;
	
	private var numBytesTextured:Int;
	
	private var numBytesColored:Int;
	
	public function new() 
	{
		super();
		
		type = FlxDrawItemType.SINGLE_QUAD;
		
		var elementsPerVertex:Int = FlxDrawSingleQuadCommand.ELEMENTS_PER_TEXTURED_VERTEX;
		var numElements:Int = elementsPerVertex * FlxCameraView.VERTICES_PER_QUAD;
		numBytesTextured = numElements * Float32Array.BYTES_PER_ELEMENT;
		texturedVertices = new Float32Array(numElements);
		
		elementsPerVertex = FlxDrawSingleQuadCommand.ELEMENTS_PER_COLORED_VERTEX;
		numElements = elementsPerVertex * FlxCameraView.VERTICES_PER_QUAD;
		numBytesColored = numElements * Float32Array.BYTES_PER_ELEMENT;
		coloredVertices = new Float32Array(numBytesColored);
		
		modelMatrix = new Matrix4();
		
		/*
		__bufferData = new Float32Array ([
				width, 	height, 	uvWidth, 	uvHeight,	alpha,
				0, 		height, 	0, 			uvHeight, 	alpha,
				width, 	0, 			uvWidth,	0, 			alpha,
				0, 		0, 			0, 			0, 			alpha
			]);
		*/
	}
	
	private function setContext(gl:GLRenderContext):Void
	{
		if (this.gl == null || this.gl != gl)
		{
			this.gl = gl;
			
			// create buffer
			vertexBuffer = GL.createBuffer();
			GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
			
			#if (openfl >= "4.9.0")
			GL.bufferData(GL.ARRAY_BUFFER, numBytes, vertices, GL.DYNAMIC_DRAW);
			#else
			GL.bufferData(GL.ARRAY_BUFFER, vertices, GL.DYNAMIC_DRAW);
			#end
		}
	}
	
	override public function renderGL(uniformMatrix:Matrix4, renderSession:RenderSession):Void
	{
		setContext(renderSession.gl);
		
		this.uniformMatrix = uniformMatrix;
		this.renderSession = renderSession;
		
		setShader();
		uploadData();
		
		material.apply(gl);
		
		renderSession.blendModeManager.setBlendMode(material.blendMode);
		
		if (textured)
		{
			var glTexture = bitmap.getTexture(gl);
			
			GL.activeTexture(GL.TEXTURE0);
			GL.bindTexture(GL.TEXTURE_2D, glTexture);
			
			GLUtils.setTextureSmoothing(material.smoothing);
			GLUtils.setTextureWrapping(material.repeat);
			
			GL.uniform2f(shader.data.uTextureSize.index, bitmap.width, bitmap.height);
		}
		
		// now draw those suckas!
		GL.drawArrays(GL.TRIANGLE_STRIP, 0, 4);
		
		FlxCameraView.drawCalls++;
	}
	
	private inline function setShader():FlxShader
	{
		if (shader == null)
			shader = (textured) ? defaultTexturedShader : defaultColoredShader;
			
		if (shader != FlxDrawHardwareCommand.currentShader)
		{
			renderSession.shaderManager.setShader(shader);
			GL.bindBuffer(GL.ELEMENT_ARRAY_BUFFER, FlxDrawQuadsCommand.indexBuffer);
			FlxDrawHardwareCommand.currentShader = shader;
		}
		
		return shader;
	}
	
	private function uploadData():Void
	{
		GL.bindBuffer(GL.ARRAY_BUFFER, vertexBuffer);
		
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
		else
		{
			
		}
		
		// upload the verts to the buffer  
		#if (openfl >= "4.9.0")
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, numBytes, vertices);
		GL.uniformMatrix4fv(shader.data.uMatrix.index, 1, false, uniformMatrix);
		#else
		GL.bufferSubData(GL.ARRAY_BUFFER, 0, vertices);
		GL.uniformMatrix4fv(shader.data.uMatrix.index, false, uniformMatrix);
		#end
	}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, material:FlxMaterial):Void
	{
		// xy
		coloredVertices[i] = rect.width;
		coloredVertices[i + 1] = rect.height;
		
		// xy
		coloredVertices[i + 2] = 0;
		coloredVertices[i + 3] = rect.height;
		
		// xy
		coloredVertices[i + 4] = rect.width;
		coloredVertices[i + 5] = 0;
		
		// xy
		coloredVertices[i + 6] = 0;
		coloredVertices[i + 7] = 0;
		
		color.alphaFloat = alpha;
		
		// TODO: set the color...
		
		/*
		
		colors[i + 2] = colors[i + 5] = colors[i + 8] = colors[i + 11] = color;
		
		var state:RenderState = states[numQuads];
		
		state.set(null, material);
		*/
	}
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
	{
		addUVQuad(frame.parent.bitmap, frame.frame, frame.uv, matrix, transform, material);
	}
	
	override public function addUVQuad(bitmap:BitmapData, rect:FlxRect, uv:FlxRect, matrix:FlxMatrix, ?transform:ColorTransform, material:FlxMaterial):Void
	{
		/*
		__bufferData = new Float32Array ([
				width, 	height, 	uvWidth, 	uvHeight,	alpha,
				0, 		height, 	0, 			uvHeight, 	alpha,
				width, 	0, 			uvWidth,	0, 			alpha,
				0, 		0, 			0, 			0, 			alpha
			]);
		*/
		
		/*
		// get the uvs for the texture
		var uvx:Float = uv.x;
		var uvy:Float = uv.y;
		var uvx2:Float = uv.width;
		var uvy2:Float = uv.height;
		
		var w:Float = rect.width;
		var h:Float = rect.height;
		
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
		
		*/
	}
	
	override public function destroy():Void 
	{
		super.destroy();
		
		modelMatrix = null;
	}
	
	override public function equals(type:FlxDrawItemType, bitmap:BitmapData, colored:Bool, hasColorOffsets:Bool = false,
		material:FlxMaterial):Bool
	{
		return false;
	}
}
#else

#end