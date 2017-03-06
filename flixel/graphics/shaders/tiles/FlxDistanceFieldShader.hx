package flixel.graphics.shaders.tiles;

import flixel.graphics.shaders.FlxBaseShader;

// TODO: add shaders for bitmap text with outlines or shadows
// see: https://github.com/libgdx/libgdx/wiki/Distance-field-fonts

/*
// text with outline
...
const float outlineDistance; // Between 0 and 0.5, 0 = thick outline, 0.5 = no outline
const vec4 outlineColor;
...
void main() {
    float distance = texture2D(u_texture, v_texCoord).a;
    float outlineFactor = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
    vec4 color = mix(outlineColor, v_color, outlineFactor);
    float alpha = smoothstep(outlineDistance - smoothing, outlineDistance + smoothing, distance);
    gl_FragColor = vec4(color.rgb, color.a * alpha);
}
*/

/*
// text with shadow
...
const vec2 shadowOffset; // Between 0 and spread / textureSize
const float shadowSmoothing; // Between 0 and 0.5
const vec4 shadowColor;
...
void main() {
    float distance = texture2D(u_texture, v_texCoord).a;
    float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
    vec4 text = vec4(v_color.rgb, v_color.a * alpha);

    float shadowDistance = texture2D(u_texture, v_texCoord - shadowOffset).a;
    float shadowAlpha = smoothstep(0.5 - shadowSmoothing, 0.5 + shadowSmoothing, shadowDistance);
    vec4 shadow = vec4(shadowColor.rgb, shadowColor.a * shadowAlpha);

    gl_FragColor = mix(shadow, text, text.a);
}
*/

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
			
			// right value for smoothing is `0.25f / (spread * scale)`
			// so i should add 2 uniforms: 
			// `spread` (should be set by font) 
			// and `spread` (should be set by bitmap text instance)
			const float smoothing = 1.0 / 16.0;
			
			void main(void) 
			{
				float distance = texture2D(uImage0, vTexCoord).a;
				float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
				gl_FragColor = vec4(vColor.rgb * alpha, vColor.a * alpha);
			}";
	
	public function new() 
	{
		super(null, DEFAULT_FRAGMENT_SOURCE);
	}
}