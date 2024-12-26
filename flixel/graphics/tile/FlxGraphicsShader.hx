package flixel.graphics.tile;

import openfl.display.GraphicsShader;

class FlxGraphicsShader extends GraphicsShader
{
	@:glFragmentHeader("
		uniform float alpha;
		uniform vec4 colorMultiplier;
		uniform vec4 colorOffset;
		uniform bool hasColorTransform;
		
		vec4 transform(bool has, vec4 color, vec4 mult, vec4 offset)
		{
			return mix(color, clamp(offset + (color * mult), 0.0, 1.0), float(has));
		}
		
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			
			color = transform(openfl_HasColorTransform, color, openfl_ColorMultiplierv, openfl_ColorOffsetv);
			color = transform(hasColorTransform, color, colorMultiplier, colorOffset / 255.0);
			
			float _alpha = color.a * openfl_Alphav * alpha;
			return vec4 (color.rgb * _alpha, _alpha);
		}
	")
	@:glFragmentBody("
		gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
	")
	public function new()
	{
		super();
	}
}
