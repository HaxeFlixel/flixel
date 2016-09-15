package flixel.graphics.shaders;

/**
 * ...
 * @author Zaphod
 */
class FlxFilterShader extends FlxShader
{
	public static inline var defaultVertexSource:String = 
			
			"
		#ifdef GL_ES
			precision mediump float;
		#endif
			attribute vec2 aVertex;
			attribute vec2 aTexCoord;
			varying vec2 vTexCoord;
			
			uniform mat4 uMatrix;
			
			void main() {
				vTexCoord = aTexCoord;
				gl_Position = uMatrix * vec4(aVertex, 0.0, 1.0);
			}";
			
	public static inline var defaultFragmentSource:String = 
			
			"varying vec2 vTexCoord;
			
			uniform sampler2D uImage0;
			
			void main(void) 
			{
				gl_FragColor = texture2D(uImage0, vTexCoord);
			}";
	
	public function new(fragmentSource:String = null) 
	{
		fragmentSource = (fragmentSource == null) ? defaultFragmentSource : fragmentSource;
		
		super(defaultVertexSource, fragmentSource);
	}
	
}