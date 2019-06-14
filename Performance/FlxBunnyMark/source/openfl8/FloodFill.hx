package openfl8;

import flixel.system.FlxAssets.FlxShader;

class FloodFill extends FlxShader
{
	@:glFragmentSource('
		#pragma header
		uniform float uFloodFillY;

		void main()
		{
			vec2 border = vec2(openfl_TextureCoordv.x, uFloodFillY);
			vec4 color;

			if (openfl_TextureCoordv.y > uFloodFillY)
			{
				color = flixel_texture2D(bitmap, border);
			}
			else
			{
				color = flixel_texture2D(bitmap, openfl_TextureCoordv);
			}

			gl_FragColor = color;
		}')
	public function new()
	{
		super();
	}
}
