package flixel.graphics.tile;

import openfl.display.GraphicsShader;

class FlxGraphicsShader extends GraphicsShader
{
	@:glVertexHeader("
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorTransform;
	")
	@:glVertexBody("
		openfl_Alphav = openfl_Alpha * alpha;
		
		if (hasColorTransform)
		{
			if (openfl_HasColorTransform)
			{
				// concat transforms
				openfl_ColorOffsetv = (openfl_ColorOffsetv * colorMultiplier) + (colorOffset / 255.0);
				openfl_ColorMultiplierv *= colorMultiplier;
			}
			else
			{
				// overwrite openfl's transform
				openfl_ColorOffsetv = colorOffset / 255.0;
				openfl_ColorMultiplierv = colorMultiplier;
			}
		}
	")
	@:glFragmentHeader("
		// Note: this is being set to false somewhere!
		uniform bool hasTransform;
		uniform bool hasColorTransform;
		
		vec4 transform(vec4 color, vec4 mult, vec4 offset, float alpha)
		{
			color = clamp(offset + (color * mult), 0.0, 1.0);
			return vec4 (color.rgb, 1.0) * color.a * alpha;
		}
		
		vec4 transformIf(bool hasTransform, vec4 color, vec4 mult, vec4 offset, float alpha)
		{
			return mix(color * alpha, transform(color, mult, offset, alpha), float(hasTransform));
		}
		
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			if (!hasTransform && !openfl_HasColorTransform)
				return color;
			
			color = mix(color, vec4(0.0), float(color.a == 0.0));
			
			bool _hasTransform = openfl_HasColorTransform || hasColorTransform;
			return transformIf(_hasTransform, color, openfl_ColorMultiplierv, openfl_ColorOffsetv, openfl_Alphav);
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
