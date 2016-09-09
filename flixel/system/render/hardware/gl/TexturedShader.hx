package flixel.system.render.hardware.gl;

import openfl.display.Shader;
import openfl.gl.GL;

/**
 * ...
 * @author Yanrishatum
 */
// TODO: try to init shader constants and attributes, so i won't need to do it in Hardware renderer (extend base Shader class with such functionality)...
class TexturedShader extends FlxShader
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
			attribute vec2 aTexCoord;
			attribute vec4 aColor;
			
			varying vec2 vTexCoord;
			varying vec4 vColor;
			
			uniform mat4 uMatrix;
			
			void main(void) 
			{
				vTexCoord = aTexCoord;
				vColor = aColor;
				gl_Position = uMatrix * aPosition;
			}";
			
		glFragmentSource = 
			
			"varying vec2 vTexCoord;
			varying vec4 vColor;
			
			uniform sampler2D uImage0;
			uniform vec4 uColor;
			
			void main(void) 
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				
				if (color.a == 0.0) 
				{
					gl_FragColor = vec4(0.0, 0.0, 0.0, 0.0);
				} 
				else 
				{
					gl_FragColor = vec4(color.rgb / color.a, color.a) * vColor * uColor;
				}
			}";
		
		// And call init again.
		__init();
		initShaderData();
	}

}