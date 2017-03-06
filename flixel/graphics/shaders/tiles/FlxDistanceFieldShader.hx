package flixel.graphics.shaders.tiles;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used by batcher for rendering textured quads.
 * See: https://github.com/libgdx/libgdx/wiki/Distance-field-fonts
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