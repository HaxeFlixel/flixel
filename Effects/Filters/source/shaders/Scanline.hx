package shaders;

import openfl.display.Shader;

/**
 * ...
 * @author MrCdK
 */
class Scanline extends Shader {

	@fragment var fragment = '
	const float scale = 1.0;

	void main()
	{
		if (mod(floor(${Shader.vTexCoord}.y * ${Shader.uTextureSize}.y / scale), 2.0) == 0.0)
			gl_FragColor = vec4(0.0, 0.0, 0.0, 1.0);
		else
			gl_FragColor = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
	}
	
	';
	
	public function new() {
		super();
	}
	
}