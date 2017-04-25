package flixel.system.render.hardware.gl;

import openfl.gl.GL;
import openfl.gl.GLFramebuffer;

/**
 * ...
 * @author Zaphod
 */
class FrameBufferManager
{
	private static var frameBuffers:Array<GLFramebuffer> = [];
	
	private static var numBuffers:Int = 0;
	
	public static function push(frameBuffer:GLFramebuffer):Void
	{
		frameBuffers[numBuffers++] = frameBuffer;
		GL.bindFramebuffer(GL.FRAMEBUFFER, frameBuffer);
	}
	
	public static function pop():Void
	{
		if (numBuffers > 0)
		{
			frameBuffers.pop();
			numBuffers--;
		}
		
		if (numBuffers == 0)
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		}
		else
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, frameBuffers[numBuffers - 1]);
		}
	}
	
}