package flixel.graphics.shaders.quads;

/**
 * Shader for distance field font with outline
 */
class FlxDistanceShadowShader extends FlxDistanceFieldShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			uniform vec2 shadowOffset; 		// Between 0 and spread / textureSize
			uniform float shadowSmoothing;	// Between 0 and 0.5
			uniform vec4 shadowColor;
			
			uniform float smoothing;
			
			void main(void) 
			{
				float distance = texture2D(uImage0, vTexCoord).a;
				float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
				vec4 text = vec4(vColor.rgb, vColor.a * alpha);
				
				float shadowDistance = texture2D(uImage0, vTexCoord - shadowOffset).a;
				float shadowAlpha = smoothstep(0.5 - shadowSmoothing, 0.5 + shadowSmoothing, shadowDistance);
				vec4 shadow = vec4(shadowColor.rgb, shadowColor.a * shadowAlpha);
				
				gl_FragColor = mix(shadow, text, text.a);
			}";
	
	public function new() 
	{
		super(DEFAULT_FRAGMENT_SOURCE);
	}
}