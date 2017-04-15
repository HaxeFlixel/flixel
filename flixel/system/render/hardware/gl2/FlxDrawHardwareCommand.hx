package flixel.system.render.hardware.gl2;

import flixel.graphics.shaders.FlxShader;
import flixel.system.render.common.FlxDrawBaseCommand;
import flixel.system.render.hardware.gl.RenderTexture;
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
	public static var currentShader:FlxShader = null;
	
	public static var currentBuffer:RenderTexture = null;
	
	public static function resetFrameBuffer():Void
	{
		if (currentBuffer != null)
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		//	gl.viewport(0, 0, buffer.width, buffer.height);
		}
		
		currentBuffer = null;
		currentShader = null;
	}
	
	private var uniformMatrix:Matrix4;
	
	private var context:GLContextHelper;
	
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
			FlxDrawHardwareCommand.currentShader = null;
			
			// set render target and configure viewport.
			var gl = context.gl;
			gl.bindFramebuffer(gl.FRAMEBUFFER, buffer.frameBuffer);
			gl.viewport(0, 0, buffer.width, buffer.height);
		}
	}
	
	public function flush():Void {}
	
	override public function destroy():Void 
	{
		uniformMatrix = null;
		context = null;
		buffer = null;
		
		super.destroy();
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