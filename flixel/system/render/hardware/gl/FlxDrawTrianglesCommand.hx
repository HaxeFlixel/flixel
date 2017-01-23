package flixel.system.render.hardware.gl;

import flixel.FlxCamera;
import flixel.graphics.TrianglesData;
import flixel.math.FlxMatrix;
import flixel.math.FlxRect;
import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.DrawItem.FlxDrawItemType;
import flixel.system.render.common.FlxCameraView;
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
import openfl._internal.renderer.RenderSession;

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
	
	public var blendMode:BlendMode;
	
	private var uniformMatrix:Matrix4;
	
	public var data:TrianglesData;
	
	/**
	 * Transformation matrix for this item on camera.
	 */
	public var matrix(default, set):Matrix;
	
	private var matrix4:Matrix4 = new Matrix4();
	
	private var renderSession:RenderSession;
	
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
		uniformMatrix = null;
		
		shader = null;
		blendMode = null;
		renderSession = null;
		
		data = null;
		matrix4 = null;
		matrix = null;
		color = null;
	}
	
	override public function renderGL(uniformMatrix:Matrix4, renderSession:RenderSession):Void
	{
		this.uniformMatrix = uniformMatrix;
		this.renderSession = renderSession;
		
		// init! init!
		setContext(renderSession.gl);
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
			renderSession.shaderManager.setShader(shader);
			FlxDrawHardwareCommand.currentShader = shader;
		}
		
		return shader;
	}
	
	private function renderStrip():Void
	{
		if (textured)
		{
			GL.activeTexture(GL.TEXTURE0);
			GL.bindTexture(GL.TEXTURE_2D, graphics.bitmap.getTexture(renderSession.gl));
			
			GLUtils.setTextureSmoothing(smoothing);
			GLUtils.setTextureWrapping(repeat);
			
			GL.uniform2f(shader.data.uTextureSize.index, graphics.width, graphics.height);
		}
		else
		{
			GL.activeTexture(GL.TEXTURE0);
			GL.bindTexture(GL.TEXTURE_2D, null);
		}
		
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
		GL.uniform4f(shader.data.uColor.index, red, green, blue, alpha);
		GL.uniform4f(shader.data.uColorOffset.index, redOffset, greenOffset, blueOffset, alphaOffset);
		
		GL.uniformMatrix4fv(shader.data.uMatrix.index, false, uniformMatrix);
		
		// set transform matrix for all triangles in this item:
		GL.uniformMatrix4fv(shader.data.uModel.index, false, matrix4);
		
		renderSession.blendModeManager.setBlendMode(blendMode);
		
		data.updateVertices();
		GL.vertexAttribPointer(shader.data.aPosition.index, 2, GL.FLOAT, false, 0, 0);
		
		if (textured)
		{
			// update the uvs
			data.updateUV();
			GL.vertexAttribPointer(shader.data.aTexCoord.index, 2, GL.FLOAT, false, 0, 0);
		}
		
		if (colored)
		{
			// update the colors
			data.updateColors();
			GL.vertexAttribPointer(shader.data.aColor.index, 4, GL.UNSIGNED_BYTE, true, 0, 0);
		}
		
		data.updateIndices();
		data.dirty = false;
		
		GL.drawElements(GL.TRIANGLES, data.numIndices, GL.UNSIGNED_SHORT, 0);
		
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
	public var data:TrianglesData;
	public var matrix:Matrix;
	public var color:ColorTransform;
	
	public function canAddTriangles(numTriangles:Int):Bool
	{
		return true;
	}
	
	public function addTriangles(data:TrianglesData, ?matrix:FlxMatrix, ?transform:ColorTransform):Void {}
	
	public function addColorQuad(rect:FlxRect, matrix:FlxMatrix, color:FlxColor, alpha:Float = 1.0, ?blend:BlendMode, ?smoothing:Bool, ?shader:FlxShader):Void {}
	
}
#end