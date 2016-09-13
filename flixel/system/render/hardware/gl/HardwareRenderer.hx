package flixel.system.render.hardware.gl;

import flixel.graphics.FlxGraphic;
import flixel.system.render.common.FlxDrawBaseItem;
import flixel.system.render.hardware.gl.shaders.FlxColorShader;
import flixel.system.render.hardware.gl.shaders.FlxShader;
import flixel.system.render.hardware.gl.shaders.FlxTexturedShader;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.geom.ColorTransform;
import openfl.gl.GL;

#if (openfl >= "4.0.0")
import lime.graphics.GLRenderContext;
import lime.utils.Float32Array;
import lime.utils.UInt32Array;

	#if (!display && !flash)
	import openfl._internal.renderer.RenderSession;
	import openfl._internal.renderer.opengl.GLRenderer;
	#end

#end

import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.DisplayObject;
import openfl.display.Shader;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Yanrishatum
 */
class HardwareRenderer extends DisplayObject implements IFlxDestroyable
{
	#if ((openfl >= "4.0.0") && !flash)
	private static var texturedTileShader:FlxTexturedShader;
	private static var coloredTileShader:FlxColorShader;
	
	private static var uColor:Array<Float> = [];
	private static var uMatrix:Array<Float32Array> = [];

	private var states:Array<FlxDrawHardwareItem<Dynamic>>;
	private var stateNum:Int;
	
	private var __height:Int;
	private var __width:Int;
	
	public function new(width:Int, height:Int)
	{
		super();
		
		__width = width;
		__height = height;
		
		if (texturedTileShader == null) 
			texturedTileShader = new FlxTexturedShader();
		
		if (coloredTileShader == null) 
			coloredTileShader = new FlxColorShader();
		
		states = [];
		stateNum = 0;
	}
	
	public function destroy():Void
	{
		states = null;
	}
	
	public function clear():Void
	{
		stateNum = 0;
	}

	public function drawItem(item:FlxDrawHardwareItem<Dynamic>):Void
	{
		states[stateNum++] = item;
	}
	
	@:access(openfl.geom.Rectangle)
	override private function __getBounds(rect:Rectangle, matrix:Matrix):Void 
	{
		var bounds = Rectangle.__temp;
		bounds.setTo(0, 0, __width, __height);
		bounds.__transform(bounds, matrix);
		rect.__expand(bounds.x, bounds.y, bounds.width, bounds.height);	
	}
	
	override private function __hitTest(x:Float, y:Float, shapeFlag:Bool, stack:Array<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool 
	{
		if (!hitObject.visible || __isMask) 
			return false;
		
		if (mask != null && !mask.__hitTestMask(x, y))
			return false;
		
		__getWorldTransform();
		
		var px = __worldTransform.__transformInverseX(x, y);
		var py = __worldTransform.__transformInverseY(x, y);
		
		if (px > 0 && py > 0 && px <= __width && py <= __height) 
		{
			if (stack != null && !interactiveOnly) 
			{
				stack.push (hitObject);	
			}
			
			return true;
		}
		
		return false;
	}
	
	override private function get_height():Float 
	{	
		return __height;	
	}
	
	override private function set_height(value:Float):Float 
	{	
		return __height = Std.int(value);	
	}
	
	override private function get_width():Float 
	{	
		return __width;	
	}
	
	override private function set_width(value:Float):Float 
	{	
		return __width = Std.int(value);	
	}
	
	override public function __renderGL(renderSession:RenderSession):Void 
	{
		var gl:GLRenderContext = renderSession.gl;
		var renderer:GLRenderer = cast renderSession.renderer;
		
		var worldColor:ColorTransform = this.__worldColorTransform;
		
		uColor[0] = worldColor.redMultiplier;
		uColor[1] = worldColor.greenMultiplier;
		uColor[2] = worldColor.blueMultiplier;
		uColor[3] = this.__worldAlpha;
		
		uMatrix[0] = renderer.getMatrix(this.__worldTransform);
		
		var shader:FlxShader = null;
		var nextShader:FlxShader = null;
		var blend:BlendMode = null;
		var texture:FlxGraphic = null;
		
		var i:Int = 0;
		
		while (i < stateNum)
		{
			var state:FlxDrawHardwareItem<Dynamic> = states[i];
			
			nextShader = (state.graphics != null) ? texturedTileShader : coloredTileShader;
			nextShader = (state.shader != null) ? state.shader : nextShader;
			
			if (shader != nextShader || shader == null)
			{
				shader = nextShader;
				
				shader.data.uMatrix.value = uMatrix;
				shader.data.uColor.value = uColor;
				
				renderSession.shaderManager.setShader(shader);
				
			//	gl.uniform4f(shader.data.uColor.index, uColor[0], uColor[1], uColor[2], uColor[3]);
			//	gl.uniformMatrix4fv(shader.data.uMatrix.index, false, uMatrix[0]);
			}
			
			if (blend != state.blending)
			{
				renderSession.blendModeManager.setBlendMode(state.blending);
				blend = state.blending;
			}
			
			if (texture != state.graphics)
			{
				texture = state.graphics;
				
				if (texture != null)
				{
					gl.bindTexture(gl.TEXTURE_2D, texture.bitmap.getTexture(gl));
				}
			}
			
			if (state.glBuffer == null)
			{
				state.glBuffer = gl.createBuffer();
				#if !FLX_RENDER_GL_ARRAYS
				state.glIndexes = gl.createBuffer();
				#end
			}
			
			#if !FLX_RENDER_GL_ARRAYS
			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, state.glIndexes);
			#end
			
			#if !FLX_RENDER_GL_ARRAYS
			if (state.indexBufferDirty)
			{
				state.indexBufferDirty = false;
				gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, state.indexes, gl.DYNAMIC_DRAW);
			}
			#end
			
			gl.bindBuffer(gl.ARRAY_BUFFER, state.glBuffer);
			
			if (state.vertexBufferDirty)
			{
				state.vertexBufferDirty = false;
				gl.bufferData(gl.ARRAY_BUFFER, state.buffer, gl.DYNAMIC_DRAW);
			}
			
			gl.vertexAttribPointer(shader.data.aPosition.index, 2, gl.FLOAT, false, state.elementsPerVertex * Float32Array.BYTES_PER_ELEMENT, 0);
			
			if (texture != null)
			{
				#if !FLX_RENDER_GL_ARRAYS
				// texture smoothing
				if (state.antialiasing) 
				{
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR);	
				} 
				else 
				{
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.NEAREST);
					gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.NEAREST);
				}
				
				// texture repeat
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
				gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
				#end
				
				gl.vertexAttribPointer(shader.data.aTexCoord.index, 2, gl.FLOAT, false, state.elementsPerVertex * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);
				gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.FLOAT, false, state.elementsPerVertex * Float32Array.BYTES_PER_ELEMENT, 4 * Float32Array.BYTES_PER_ELEMENT);
			}
			else
			{
				gl.vertexAttribPointer(shader.data.aColor.index, 4, gl.FLOAT, false, state.elementsPerVertex * Float32Array.BYTES_PER_ELEMENT, 2 * Float32Array.BYTES_PER_ELEMENT);
			}
			
			// TODO: try to use gl.drawArrays()...
			#if FLX_RENDER_GL_ARRAYS
			gl.drawArrays(gl.TRIANGLES, 0 * 6, state.numVertices); 
			#else
			gl.drawElements(gl.TRIANGLES, state.indexPos, gl.UNSIGNED_INT, 0);
			#end
			
			#if !FLX_RENDER_GL_ARRAYS
			gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, null);
			#end
			gl.bindBuffer(gl.ARRAY_BUFFER, null);
			
			i++;
		}
	}
	
	#else
	
	public function destroy():Void
	{
		
	}
	#end
	
}