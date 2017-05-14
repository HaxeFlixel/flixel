package flixel.system.render.gl;

import flixel.graphics.shaders.FlxShader;
import flixel.math.FlxMatrix;
import flixel.system.render.common.FlxDrawBaseCommand;
import lime.graphics.GLRenderContext;

#if FLX_RENDER_GL
import lime.math.Matrix4;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawHardwareCommand<T> extends FlxDrawBaseCommand<T>
{
	private var uniformMatrix:Matrix4 = new Matrix4();
	
	private var context:GLContextHelper;
	
	private var gl:GLRenderContext;
	
	private var buffer:FlxRenderTexture;
	
	public function new() 
	{
		super();
	}
	
	public function prepare(context:GLContextHelper, buffer:FlxRenderTexture, ?transform:FlxMatrix):Void 
	{
		if (transform != null)
		{
			uniformMatrix.identity();
			uniformMatrix[0] = transform.a;
			uniformMatrix[1] = transform.b;
			uniformMatrix[4] = transform.c;
			uniformMatrix[5] = transform.d;
			uniformMatrix[12] = transform.tx;
			uniformMatrix[13] = transform.ty;
			uniformMatrix.append(buffer.projection);
		}
		else
		{
			uniformMatrix.copyFrom(buffer.projection);
		}
		
		this.context = context;
		this.buffer = buffer;
		context.currentBuffer = null;
	}
	
	public function flush():Void {}
	
	private function setShader(shader:FlxShader):FlxShader 
	{
		return shader;
	}
	
	override public function destroy():Void 
	{
		uniformMatrix = null;
		context = null;
		gl = null;
		buffer = null;
		
		super.destroy();
	}
	
	private function setContext(context:GLContextHelper):Void 
	{
		this.context = context;
		this.gl = context.gl;
	}
	
}
#end