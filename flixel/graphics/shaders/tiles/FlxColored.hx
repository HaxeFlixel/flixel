package flixel.graphics.shaders.tiles;

import flixel.graphics.shaders.FlxBaseShader;
import flixel.graphics.shaders.FlxShader;

/**
 * Default shader used by batcher for rendering quads without textures.
 */
class FlxColored extends FlxBaseShader
{
	public static inline var defaultVertexSource:String = 
			"
			attribute vec4 aPosition;
			attribute vec4 aColor;
			
			uniform mat4 uMatrix;
			
			varying vec4 vColor;
			
			void main(void) 
			{
				vColor = aColor.bgra;
				gl_Position = uMatrix * aPosition;
			}";
			
	public static inline var defaultFragmentSource:String = 
			"
			varying vec4 vColor;
			
			uniform sampler2D uImage0;
			
			void main(void) 
			{
				gl_FragColor = vColor;
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		vertexSource = (vertexSource == null) ? defaultVertexSource : vertexSource;
		fragmentSource = (fragmentSource == null) ? defaultFragmentSource : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}

}