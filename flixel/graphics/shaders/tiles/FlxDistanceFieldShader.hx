package flixel.graphics.shaders.tiles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used by batcher for rendering textured quads.
 */
class FlxDistanceFieldShader extends FlxTexturedShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			// TODO: convert these to uniforms later...
			const float width = 0.5;
			const float edge = 0.1;
			
		//	const float borderWidth = 0.5;
		//	const float borderEdge = 0.4;
			
		//	const vec3 outlineColor = vec3(0.2, 0.2, 0.2);
			
			void main(void) 
			{
				vec4 color = texture2D(uImage0, vTexCoord);
				
				float distance = 1.0 - color.a;
				
				float alpha = 1.0 - smoothstep(width, width + edge, distance);
			//	float outlineAlpha = 1.0 - smoothstep(borderWidth, borderWidth + borderEdge, distance);
			//	float overallAlpha = alpha + (1.0 - alpha) * outlineAlpha;
			//	vec3 overallColor = mix(outlineColor, vColor.rgb, alpha / overallAlpha);
				
				gl_FragColor = vec4(vColor.rgb, alpha);
			//	gl_FragColor = vec4(overallColor, overallAlpha);
			}";
	
	public function new() 
	{
		super(null, DEFAULT_FRAGMENT_SOURCE);
	}
}