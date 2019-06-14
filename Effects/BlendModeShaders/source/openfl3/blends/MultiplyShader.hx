package openfl3.blends;

import openfl.display.Shader;

class MultiplyShader extends Shader
{
	@fragment var code = '
		uniform vec4 uBlendColor;

		vec4 blendMultiply(vec4 base, vec4 blend)
		{
			return base * blend;
		}

		vec4 blendMultiply(vec4 base, vec4 blend, float opacity)
		{
			return (blendMultiply(base, blend) * opacity + base * (1.0 - opacity));
		}

		void main()
		{
			vec4 base = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
			gl_FragColor = blendMultiply(base, uBlendColor, uBlendColor.a);
		}';

	public function new()
	{
		super();
	}
}
