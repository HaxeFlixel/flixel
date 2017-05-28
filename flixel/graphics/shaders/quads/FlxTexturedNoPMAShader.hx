package flixel.graphics.shaders.quads;

/**
 * Default shader used by batcher for rendering textured quads without premultiplied alpha.
 */
class FlxTexturedNoPMAShader extends FlxTexturedShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			void main(void) 
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				vec4 unmultiply = vec4(color.rgb / color.a, color.a);
				vec4 result = unmultiply * vColor;
				result = result + vColorOffset;
				result = clamp(result, 0.0, 1.0);
				result = vec4(result.rgb * result.a, result.a * color.a);
				
				gl_FragColor = result;
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		fragmentSource = (fragmentSource == null) ? DEFAULT_FRAGMENT_SOURCE : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}
}