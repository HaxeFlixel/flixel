package flixel.system.render.gl;

import flixel.FlxCamera;
import flixel.graphics.FlxMaterial;
import flixel.graphics.FlxTrianglesData;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.DrawCommand.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
import flixel.util.FlxColor;
import openfl.Vector;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.geom.ColorTransform;
import openfl.geom.Matrix;

#if FLX_RENDER_GL
import flixel.graphics.shaders.triangles.FlxColoredShader;
import flixel.graphics.shaders.triangles.FlxTexturedShader;

import lime.math.Matrix4;
import openfl.gl.GL;
import lime.graphics.GLRenderContext;

class FlxDrawTrianglesCommand extends FlxDrawHardwareCommand<FlxDrawTrianglesCommand>
{
	/**
	 * Default tile shader.
	 */
	private static var defaultTexturedShader:FlxTexturedShader = new FlxTexturedShader();
	private static var defaultColoredShader:FlxColoredShader = new FlxColoredShader();
	
	private var _vertices:Vector<Float> = new Vector<Float>(); // TODO: remove this and implement gl based debug rendering...
	
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
	
	override public function prepare(context:GLContextHelper, buffer:RenderTexture):Void
	{
		reset();
		super.prepare(context, buffer);
	}
	
	override public function flush():Void
	{
		// init! init!
		setContext(context);
		context.checkRenderTarget(buffer);
		shader = setShader(material.shader);
		renderStrip();
	}
	
	override private function setShader(shader:FlxShader):FlxShader
	{
		if (shader == null)
			shader = (textured) ? defaultTexturedShader : defaultColoredShader;
		
		context.setShader(shader);
		return shader;
	}
	
	private function renderStrip():Void
	{
		context.setBitmap(bitmap, material.smoothing, material.repeat);
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
		
		context.setBlendMode(material.blendMode);
		
		data.updateVertices();
		gl.vertexAttribPointer(shader.data.aPosition.index, 2, gl.FLOAT, false, 0, 0);
		
		if (textured)
		{
			// update the uvs
			data.updateUV();
			GL.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, 0, 0);
		}
		
		// update the colors
		data.updateColors();
		gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.UNSIGNED_BYTE, true, 0, 0);
		
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
	
	override private function setContext(context:GLContextHelper):Void 
	{
		super.setContext(context);
		
		if (data != null)
			data.setContext(context.gl);
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
#end