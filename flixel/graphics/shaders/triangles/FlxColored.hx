package flixel.graphics.shaders.triangles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used for rendering triangles with colored vertices (each vertice could have inidividual color)
 */
class FlxColored extends FlxBaseShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
			"
			attribute vec4 aPosition;
			attribute vec4 aColor;
			
			uniform mat4 uMatrix;
			uniform mat4 uModel;
			
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
			varying vec4 vColor;
			
			void main(void) 
			{
				vec4 col = aColor.bgra * uColor + uColorOffset;
				col = clamp(col, 0.0, 1.0);
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