package flixel.graphics.shaders;

/**
 * ...
 * @author Yanrishatum
 */
class FlxColorShader extends FlxShader
{
	public static inline var defaultVertexSource:String = 
			
			"
		#ifdef GL_ES
			precision mediump float;
		#endif
			attribute vec4 aPosition;
			attribute vec4 aColor;
			
			varying vec4 vColor;
			
			uniform mat4 uMatrix;
			
			void main(void) 
			{
				vColor = aColor;
				gl_Position = uMatrix * aPosition;
			}";
			
	public static inline var defaultFragmentSource:String = 
			
			"varying vec4 vColor;
			
			uniform vec4 uColor;
			
			void main(void) 
			{
				gl_FragColor = vColor * uColor;
			}";
	
	public function new(vertexSource:String = null, fragmentSource:String = null) 
	{
		vertexSource = (vertexSource == null) ? defaultVertexSource : vertexSource;
		fragmentSource = (fragmentSource == null) ? defaultFragmentSource : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}
}