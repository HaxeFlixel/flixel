package openfl8;

import flixel.system.FlxAssets.FlxShader;

class Hq2x extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		void main()
		{
			float x = 1.0 / openfl_TextureSize.x;
			float y = 1.0 / openfl_TextureSize.y;

			vec4 color1 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(-x, -y));
			vec4 color2 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(0.0, -y));
			vec4 color3 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x, -y));

			vec4 color4 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(-x, 0.0));
			vec4 color5 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(0.0, 0.0));
			vec4 color6 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x, 0.0));

			vec4 color7 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(-x, y));
			vec4 color8 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(0.0, y));
			vec4 color9 = texture2D(bitmap, openfl_TextureCoordv.st + vec2(x, y));
			vec4 avg = color1 + color2 + color3 + color4 + color5 + color6 + color7 + color8 + color9;

			gl_FragColor = avg / 9.0;
		}')
	public function new()
	{
		super();
	}
}
