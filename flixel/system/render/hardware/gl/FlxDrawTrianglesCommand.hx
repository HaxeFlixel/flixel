package flixel.system.render.hardware.gl;

import flixel.FlxCamera;
import flixel.graphics.FlxTrianglesData;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.system.render.hardware.gl.GLContextHelper;
import flixel.system.render.hardware.gl.GLUtils;
import flixel.system.render.hardware.gl.RenderTexture;
import flixel.util.FlxColor;
import openfl.Vector;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

#if FLX_RENDER_GL
import flixel.graphics.shaders.triangles.FlxColoredShader;
import flixel.graphics.shaders.triangles.FlxSingleColoredShader;
import flixel.graphics.shaders.triangles.FlxTexturedShader;
import flixel.graphics.shaders.triangles.FlxTexturedColoredShader;

import lime.math.Matrix4;
import openfl.gl.GL;
import lime.graphics.GLRenderContext;

class FlxDrawTrianglesCommand extends FlxDrawHardwareCommand<FlxDrawTrianglesCommand>
{
	/**
	 * Default tile shader.
	 */
	private static var defaultTextureColoredShader:FlxTexturedColoredShader = new FlxTexturedColoredShader();
	private static var defaultTexturedShader:FlxTexturedShader = new FlxTexturedShader();
	private static var defaultColoredShader:FlxColoredShader = new FlxColoredShader();
	private static var defaultSingleColoredShader:FlxSingleColoredShader = new FlxSingleColoredShader();
	
	private var _vertices:Vector<Float> = new Vector<Float>();
	
	public var data:FlxTrianglesData;
	
	/**
	 * Transformation matrix for this item on camera.
	 */
	public var matrix(default, set):Matrix;
	
	private var matrix4:Matrix4 = new Matrix4();
	
	/**
	 * Color transform for this item.
	 */
	public var color:ColorTransform;
	
	public function new() 
	{
		super();
		type = FlxDrawItemType.TRIANGLES;
	}
	
	override public function destroy():Void
	{
		data = null;
		matrix4 = null;
		matrix = null;
		color = null;
	}
	
	override public function prepare(uniformMatrix:Matrix4, context:GLContextHelper, buffer:RenderTexture):Void
	{
		reset();
		super.prepare(uniformMatrix, context, buffer);
	}
	
	override public function flush():Void
	{
		// init! init!
		setContext(context.gl);
		checkRenderTarget();
		setShader();
		renderStrip();
	}
	
	private function setShader():FlxShader
	{
		if (shader == null)
		{
			if (textured)
				shader = (colored) ? defaultTextureColoredShader : defaultTexturedShader;
			else
				shader = (colored) ? defaultColoredShader : defaultSingleColoredShader;
		}
		
		if (shader != FlxDrawHardwareCommand.currentShader)
		{
			context.shaderManager.setShader(shader);
			FlxDrawHardwareCommand.currentShader = shader;
		}
		
		return shader;
	}
	
	private function renderStrip():Void
	{
		var gl:GLRenderContext = context.gl;
		
		if (bitmap != null)
		{
			gl.activeTexture(gl.TEXTURE0);
			gl.bindTexture(gl.TEXTURE_2D, bitmap.getTexture(gl));
			
			GLUtils.setTextureSmoothing(material.smoothing);
			GLUtils.setTextureWrapping(material.repeat);
			
			gl.uniform2f(shader.data.uTextureSize.index, bitmap.width, bitmap.height);
		}
		
		material.apply(gl);
		
		var red:Float = 1.0;
		var green:Float = 1.0;
		var blue:Float = 1.0;
		var alpha:Float = 1.0;
		
		var redOffset:Float = 0.0;
		var greenOffset:Float = 0.0;
		var blueOffset:Float = 0.0;
		var alphaOffset:Float = 0.0;
		
		if (color != null)
		{
			red = color.redMultiplier;
			green = color.greenMultiplier;
			blue = color.blueMultiplier;
			alpha = color.alphaMultiplier;
			
			redOffset = color.redOffset / 255;
			greenOffset = color.greenOffset / 255;
			blueOffset = color.blueOffset / 255;
			alphaOffset = color.alphaOffset / 255;
		}
		
		// set uniforms
		gl.uniform4f(shader.data.uColor.index, red, green, blue, alpha);
		gl.uniform4f(shader.data.uColorOffset.index, redOffset, greenOffset, blueOffset, alphaOffset);
		
		#if (openfl >= "4.9.0")
		gl.uniformMatrix4fv(shader.data.uMatrix.index, 1, false, uniformMatrix);
		// set transform matrix for all triangles in this item:
		gl.uniformMatrix4fv(shader.data.uModel.index, 1, false, matrix4);
		#else
		gl.uniformMatrix4fv(shader.data.uMatrix.index, false, uniformMatrix);
		gl.uniformMatrix4fv(shader.data.uModel.index, false, matrix4);
		#end
		
		context.blendModeManager.setBlendMode(material.blendMode);
		
		data.updateVertices();
		gl.vertexAttribPointer(shader.data.aPosition.index, 2, gl.FLOAT, false, 0, 0);
		
		if (textured)
		{
			// update the uvs
			data.updateUV();
			GL.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 0, 0);
		}
		
		if (colored)
		{
			// update the colors
			data.updateColors();
			gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.UNSIGNED_BYTE, true, 0, 0);
		}
		
		data.updateIndices();
		data.dirty = false;
		
		gl.drawElements(gl.TRIANGLES, data.numIndices, gl.UNSIGNED_SHORT, 0);
		
		FlxCameraView.drawCalls++;
	}
	
	override public function reset():Void 
	{
		super.reset();
		data = null;
		matrix4.identity();
		color = null;
	}
	
	private function setContext(gl:GLRenderContext):Void
	{
		if (data != null)
			data.setContext(gl);
	}
	
	public function drawDebug(camera:FlxCamera):Void
	{
		#if FLX_DEBUG
		if (!FlxG.debugger.drawDebug)
			return;
		
		var verticesLength:Int = data.vertices.length;
		_vertices.splice(0, _vertices.length);
		var px:Float, py:Float;
		var i:Int = 0;
		
		while (i < verticesLength)
		{
			px = data.vertices[i]; 
			py = data.vertices[i + 1];
			
			_vertices[i] = px * matrix.a + py * matrix.c + matrix.tx;
			_vertices[i + 1] = px * matrix.b + py * matrix.d + matrix.ty;
			
			i += 2;
		}
		
		var gfx:Graphics = camera.beginDrawDebug();
		gfx.lineStyle(1, FlxColor.BLUE, 0.5);
		gfx.drawTriangles(_vertices, data.indices);
		camera.endDrawDebug();
		#end
	}
	
	public function canAddTriangles(numTriangles:Int):Bool
	{
		return true;
	}
	
	override private function get_numVertices():Int
	{
		return (data != null) ? data.numIndices : 0;
	}
	
	override private function get_numTriangles():Int 
	{
		return (data != null) ? data.numTriangles : 0;
	}
	
	private function set_matrix(value:Matrix):Matrix
	{
		if (value != null)
		{
			matrix4.identity();
			matrix4[0] = value.a;
			matrix4[1] = value.b;
			matrix4[4] = value.c;
			matrix4[5] = value.d;
			matrix4[12] = value.tx;
			matrix4[13] = value.ty;
		}
		
		return matrix = value;
	}
}

#else
class FlxDrawTrianglesCommand extends FlxDrawHardwareCommand<FlxDrawTrianglesCommand>
{
	public var data:FlxTrianglesData;
	public var matrix:Matrix;
	public var color:ColorTransform;
	
	public function canAddTriangles(numTriangles:Int):Bool
	{
		return true;
	}
	
	public function addTriangles(data:FlxTrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void {}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, ?blend:BlendMode, ?smoothing:Bool, ?shader:FlxShader):Void {}
	
}
#end