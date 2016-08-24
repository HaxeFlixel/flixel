package flixel.system.render.hardware.gl;

import openfl.display.Shader;
import openfl.gl.GL;

/**
 * ...
 * @author Yanrishatum
 */
class ColorShader extends Shader
{

	public function new() 
	{
		super();
		
		if (glProgram != null)
		{
			GL.deleteProgram(this.glProgram); // Delete what super created
			this.glProgram = null;
		}
		
		this.data = null;
		
		// Then reinit all the data.
		glVertexSource =
			
			"attribute vec4 aPosition;
			attribute vec4 aColor;
			
			varying vec4 vColor;
			
			uniform mat4 uMatrix;
			
			void main(void) 
			{
				vColor = aColor;
				gl_Position = uMatrix * aPosition;
			}";
			
		glFragmentSource = 
			
			"varying vec4 vColor;
			
			uniform float uAlpha;
			
			void main(void) 
			{
				vec4 color = vColor;
				color.a = color.a * uAlpha;
				gl_FragColor = color;
			}";
		
		// And call init again.
		__init();
	}

}