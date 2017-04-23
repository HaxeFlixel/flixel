package flixel.system.render.hardware.gl;

import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.FlxDrawBaseCommand;
import flixel.system.render.hardware.gl.RenderTexture;
import lime.graphics.GLRenderContext;
import openfl.gl.GL;

#if FLX_RENDER_GL
import flixel.system.render.hardware.gl.GLContextHelper;
import lime.math.Matrix4;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawHardwareCommand<T> extends FlxDrawBaseCommand<T>
{
	public static var currentShader:FlxShader = null; // TODO: move this var to context helper...
	
	public static var currentBuffer:RenderTexture = null; // TODO: move this var to context helper...
	
	public static function resetFrameBuffer():Void // TODO: move this method to context helper...
	{
		if (currentBuffer != null)
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);
			GL.disable(GL.SCISSOR_TEST);
		}
		
		currentBuffer = null;
		currentShader = null;
	}
	
	private var uniformMatrix:Matrix4;
	
	private var context:GLContextHelper;
	
	private var gl:GLRenderContext;
	
	private var buffer:RenderTexture;
	
	public function new() 
	{
		super();
	}
	
	public function prepare(uniformMatrix:Matrix4, context:GLContextHelper, buffer:RenderTexture):Void 
	{
		this.uniformMatrix = uniformMatrix;
		this.context = context;
		this.buffer = buffer;
		
		FlxDrawHardwareCommand.currentBuffer = null;
	}
	
	public function checkRenderTarget():Void
	{
		if (FlxDrawHardwareCommand.currentBuffer != buffer)
		{
			FlxDrawHardwareCommand.currentBuffer = buffer;
			
			// set render target and configure viewport.
			gl.bindFramebuffer(gl.FRAMEBUFFER, buffer.frameBuffer);
			gl.viewport(0, 0, buffer.width, buffer.height);
		}
	}
	
	public function flush():Void {}
	
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
#else
class FlxDrawHardwareCommand<T> extends FlxDrawBaseCommand<T>
{
	public static var currentShader:FlxShader = null;
	
	public function new() 
	{
		super();
	}
	
	public function prepare(uniformMatrix:Dynamic, context:Dynamic, buffer:Dynamic):Void {}
	
	public function flush():Void {}
	
}
#end