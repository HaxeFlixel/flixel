package flixel.graphics.shaders;

/**
 * Shader user for applying camera color transform (it there is any).
 * It can be used as a basis for other camera effect shaders.
 */
class FlxCameraColorTransform extends FlxBaseShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
			"
			attribute vec4 aPosition;
			attribute vec2 aTexCoord;
			
			varying vec2 vTexCoord;
			
			uniform mat4 uMatrix;
			uniform vec2 uTextureSize;
			
			void main(void) 
			{
				vTexCoord = aTexCoord;
				gl_Position = uMatrix * aPosition;
			}";
			
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			
			uniform sampler2D uImage0;
			
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
			void main(void) 
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				
				float alpha = color.a * uColor.a;
				vec4 result = vec4(color.rgb * alpha, alpha) *  uColor;
				
				result = result + uColorOffset;
				result = clamp(result, 0.0, 1.0);
				gl_FragColor = result;
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		vertexSource = (vertexSource == null) ? DEFAULT_VERTEX_SOURCE : vertexSource;
		fragmentSource = (fragmentSource == null) ? DEFAULT_FRAGMENT_SOURCE : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}	
}