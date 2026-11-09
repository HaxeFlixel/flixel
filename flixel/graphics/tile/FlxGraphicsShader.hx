package flixel.graphics.tile;

import openfl.display.GraphicsShader;

class FlxGraphicsShader extends GraphicsShader
{
	@:glVertexHeader("
		const bool hasColorTransform = true; // deprecated
		attribute float alpha;
		attribute vec4 colorMultiplier;
		attribute vec4 colorOffset;
		uniform bool hasColorMults;
		uniform bool hasColorOffsets;
	", true)
	@:glVertexBody("
		openfl_Alphav = openfl_Alpha * alpha;
		
		if (!openfl_HasColorTransform)
		{
			openfl_ColorMultiplierv = vec4(1.0);
			openfl_ColorOffsetv = vec4(0.0);
		}
		
		if (hasColorMults)
			openfl_ColorMultiplierv *= colorMultiplier;
		
		if (hasColorOffsets)
			openfl_ColorOffsetv += (colorOffset / 255.0);
	", true)
	@:glFragmentHeader("
		uniform bool hasColorTransform; // deprecated
		uniform bool hasTransform; // deprecated
		uniform bool hasAlpha; // true on sprite batches, false on camera filters
		uniform bool hasColorMults;
		uniform bool hasColorOffsets;
		vec4 flixel_texture2D(sampler2D bitmap, vec2 coord)
		{
			vec4 color = texture2D(bitmap, coord);
			if (!hasAlpha)
				return color;
			
			if (color.a == 0.0)
				return vec4(0.0, 0.0, 0.0, 0.0);
			
			if (openfl_HasColorTransform || hasColorMults || hasColorOffsets)
			{
				color = vec4 (color.rgb / color.a, color.a);
				vec4 mult = vec4 (openfl_ColorMultiplierv.rgb, 1.0);
				color = clamp (openfl_ColorOffsetv + (color * mult), 0.0, 1.0);
				
				if (color.a == 0.0)
					return vec4 (0.0, 0.0, 0.0, 0.0);
				
				return vec4 (color.rgb * color.a * openfl_Alphav, color.a * openfl_Alphav);
			}
			
			return color * openfl_Alphav;
		}
	", true)
	@:glFragmentSource("
		#pragma header

		void main(void)
		{
			gl_FragColor = flixel_texture2D(bitmap, openfl_TextureCoordv);
		}
	", true)
	public function new()
	{
		super();
	}
}
