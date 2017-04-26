package flixel.graphics.shaders.quads;

/**
 * Default shader used by batcher for rendering textured quads.
 */
class FlxSingleTexturedShader extends FlxTexturedShader
{
	public static inline var DEFAULT_VERTEX_SOURCE:String = 
			"
			attribute vec4 aPosition;
			attribute vec2 aTexCoord;
			
			uniform mat4 uMatrix;
			uniform mat4 uModel;
			uniform vec2 uTextureSize;
			
			uniform vec4 uColor;
			uniform vec4 uColorOffset;
			
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			void main(void)
			{
				vTexCoord = aTexCoord;
				// OpenFl uses textures in bgra format, so we should convert colors...
				vColor = uColor.bgra;
				vColorOffset = uColorOffset.bgra;
				gl_Position = uMatrix * uModel * aPosition;
			}";
	
	public function new(?vertexSource:String, ?fragmentSource:String) 
	{
		vertexSource = (vertexSource == null) ? DEFAULT_VERTEX_SOURCE : vertexSource;
		
		super(vertexSource, fragmentSource);
	}
}