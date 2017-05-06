package flixel.graphics.shaders.quads;

/**
 * Shader for distance field font with outline
 */
class FlxDistanceOutlineShader extends FlxDistanceFieldShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			uniform float outlineDistance; // Between 0 and 0.5, 0 = thick outline, 0.5 = no outline
			uniform vec4 outlineColor;
			
			uniform float smoothing;
			
			void main(void) 
			{
				float distance = texture2D(uImage0, vTexCoord).a;
				float outlineFactor = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
				vec4 color = mix(outlineColor, vColor, outlineFactor);
				float alpha = smoothstep(outlineDistance - smoothing, outlineDistance + smoothing, distance);
				gl_FragColor = vec4(color.rgb * alpha, color.a * alpha);
			}";
	
	public function new() 
	{
		super(DEFAULT_FRAGMENT_SOURCE);
	}
}