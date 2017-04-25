package flixel.graphics.shaders.triangles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader for rendering triangles without textures and without vertex colors
 * (each vertex color is defined only by color transform of the FlxStrip).
 */
class FlxSingleColoredShader extends FlxBaseShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
			"
			attribute vec4 aPosition;
			
			uniform mat4 uMatrix;
			uniform mat4 uModel;
			
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
			varying vec4 vColor;
			
			void main(void) 
			{
				vec4 col = uColor + uColorOffset;
				vColor = vec4(col.rgb * col.a, col.a);
				
				gl_Position = uMatrix * uModel * aPosition;
			}";
			
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec4 vColor;
			
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