package flixel.graphics.shaders.tiles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used by batcher for rendering quads without textures.
 */
class FlxColoredShader extends FlxBaseShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
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
			
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec4 vColor;
			
			uniform sampler2D uImage0;
			
			void main(void) 
			{
				gl_FragColor = vColor;
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		vertexSource = (vertexSource == null) ? DEFAULT_VERTEX_SOURCE : vertexSource;
		fragmentSource = (fragmentSource == null) ? DEFAULT_FRAGMENT_SOURCE : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}

}