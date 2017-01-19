package flixel.graphics.shaders.triangles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used for rendering textured triangles with applied color transform of the FlxStrip.
 */
class FlxTextured extends FlxBaseShader
{
	public static inline var defaultVertexSource:String = 
			"
			attribute vec4 aPosition;
			attribute vec2 aTexCoord;
			
			uniform mat4 uMatrix;
			uniform mat4 uModel;
			uniform vec2 uTextureSize;
			
			varying vec2 vTexCoord;
			
			void main(void) 
			{
				vTexCoord = aTexCoord;
				gl_Position = uMatrix * uModel * aPosition;
			}";
			
	public static inline var defaultFragmentSource:String = 
			"
			varying vec2 vTexCoord;
			
			uniform sampler2D uImage0;
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
			void main(void) 
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				
				vec4 unmultiply = vec4(color.rgb / color.a, color.a);
				vec4 result = unmultiply * uColor;
				result = result + uColorOffset;
				result = clamp(result, 0.0, 1.0);
				result = vec4(result.rgb * result.a, result.a * color.a);
				gl_FragColor = result;
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		vertexSource = (vertexSource == null) ? defaultVertexSource : vertexSource;
		fragmentSource = (fragmentSource == null) ? defaultFragmentSource : fragmentSource;
		
		super(vertexSource, fragmentSource);
	}

}