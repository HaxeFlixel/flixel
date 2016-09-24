package flixel.graphics.shaders;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import openfl.Assets;
import openfl.display.Shader;

#if FLX_RENDER_GL
import openfl.display.ShaderInput;
import openfl.display.ShaderParameter;
import openfl.display.ShaderParameterType;
import openfl.gl.GL;

// TODO: try to make shaders easier to use (see openfl._internal.renderer.opengl.shaders2.Shader class from openfl 3.6.1):

/*
 * TODO: add shader general constants (see openfl 3.6.1):
 * uObjectSize
 * uTextureSize
 * uTime
 * uDeltaTime
 * 
 * Possible shader constants list from ShaderToy:
 * vec3			iResolution	image	The viewport resolution (z is pixel aspect ratio, usually 1.0)
 * float		iGlobalTime	image/sound	Current time in seconds
 * float		iTimeDelta	image	Time it takes to render a frame, in seconds
 * int	iFrame	image	Current frame
 * float		iFrameRate	image	Number of frames rendered per second
 * float		iChannelTime[4]	image	Time for channel (if video or sound), in seconds
 * vec3			iChannelResolution[4]	image/sound	Input texture resolution for each channel
 * vec4			iMouse	image	xy = current pixel coords (if LMB is down). zw = click pixel
 * sampler2D	iChannel{i}	image/sound	Sampler for input textures i
 * vec4			iDate	image/sound	Year, month, day, time in seconds in .xyzw
 * float		iSampleRate	image/sound	The sound sample rate (typically 44100) 
 */

/**
 * ...
 * @author Zaphod
 */
class FlxShader extends Shader implements IFlxDestroyable
{
	public function new(vertexSource:String, fragmentSource:String)
	{
		if (vertexSource != null && Assets.exists(vertexSource))
		{
			vertexSource = Assets.getText(vertexSource);
		}
		
		if (fragmentSource != null && Assets.exists(fragmentSource))
		{
			fragmentSource = Assets.getText(fragmentSource);
		}
		
		glVertexSource = vertexSource;
		glFragmentSource = fragmentSource;
		
		super();
	}
	
	// TODO: use this method...
	public function destroy():Void
	{
		if (glProgram != null)
		{
			GL.deleteProgram(this.glProgram);
			this.glProgram = null;
		}
		
		data = null;
		byteCode = null;
		glVertexSource = null;
		glFragmentSource = null;
		gl = null;
	}
}

#else

class FlxShader implements Dynamic
{
	public function new(vertexSource:String, fragmentSource:String) {}
}

#end