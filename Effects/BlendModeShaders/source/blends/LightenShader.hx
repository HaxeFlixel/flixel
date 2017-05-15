package blends;

import openfl.display.Shader;

class LightenShader extends Shader
{
	@fragment var code = '

	uniform vec4 uBlendColor;
	
	vec4 blendLighten(vec4 base, vec4 blend)
	{
		return max(blend, base);
	}
	
	vec4 blendLighten(vec4 base, vec4 blend, float opacity)
	{
		return (blendLighten(base, blend) * opacity + base * (1.0 - opacity));
	}
	
	void main()
	{
		vec4 base = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
		gl_FragColor = blendLighten(base, uBlendColor, uBlendColor.a);
	}
	';
	
	public function new()
	{
		super();
	}
}