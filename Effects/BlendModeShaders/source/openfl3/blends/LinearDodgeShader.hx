package openfl3.blends;

import openfl.display.Shader;

class LinearDodgeShader extends Shader
{
	@fragment var code = '
		uniform vec4 uBlendColor;

		// Note : Same implementation as BlendAddf
		float blendLinearDodge(float base, float blend) {
			return min(base + blend, 1.0);
		}

		vec4 blendLinearDodge(vec4 base, vec4 blend) {
			return vec4(
				blendLinearDodge(base.r, blend.r),
				blendLinearDodge(base.g, blend.g),
				blendLinearDodge(base.b, blend.b),
				blendLinearDodge(base.a, blend.a)
			);
		}

		vec4 blendLinearDodge(vec4 base, vec4 blend, float opacity) {
			return (blendLinearDodge(base, blend) * opacity + base * (1.0 - opacity));
		}

		void main()
		{
			vec4 base = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
			gl_FragColor = blendLinearDodge(base, uBlendColor, uBlendColor[3]);
		}';
	
	public function new()
	{
		super();
	}
}