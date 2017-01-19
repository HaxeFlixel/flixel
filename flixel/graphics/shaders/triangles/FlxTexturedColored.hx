package flixel.graphics.shaders.triangles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used for rendering textured triangles with specified color multipliers for each of the vertices, 
 * plus applied color transform of the FlxStrip.
 */
class FlxTexturedColored extends FlxBaseShader
{
	public static inline var defaultVertexSource:String = 
			"
			attribute vec4 aPosition;
			attribute vec2 aTexCoord;
			attribute vec4 aColor;
			
			uniform mat4 uMatrix;
			uniform mat4 uModel;
			uniform vec2 uTextureSize;
			
			varying vec2 vTexCoord;
			varying vec4 vColor;
			
			void main(void) 
			{
				vTexCoord = aTexCoord;
				// OpenFl uses textures in bgra format, so we should convert color...
				vColor = aColor.bgra;
				gl_Position = uMatrix * uModel * aPosition;
			}";
			
	public static inline var defaultFragmentSource:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			
			uniform sampler2D uImage0;
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
			void main(void) 
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				
				vec4 unmultiply = vec4(color.rgb / color.a, color.a);
				vec4 result = unmultiply * vColor * uColor;
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