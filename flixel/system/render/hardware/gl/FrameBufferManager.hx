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
		GL.clear(GL.DEPTH_BUFFER_BIT | GL.COLOR_BUFFER_BIT);
	}
	
	public static function pop():Void
	{
		if (numBuffers > 1)
		{
			frameBuffers.pop();
			numBuffers--;
			GL.bindFramebuffer(GL.FRAMEBUFFER, frameBuffers[numBuffers - 1]);
		}
		
		if (numBuffers == 0)
		{
			GL.bindFramebuffer(GL.FRAMEBUFFER, null);
		}
	}
	
}