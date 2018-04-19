package openfl3;

import openfl.display.Shader;

class FloodFill extends Shader
{
	@fragment var code = '
		uniform float uFloodFillY;
		
		void main() 
		{
			vec2 border = vec2(${Shader.vTexCoord}.x, uFloodFillY);
			vec4 color;
			
			if (${Shader.vTexCoord}.y > uFloodFillY)
			{
				color = texture2D(${Shader.uSampler}, border);
			}
			else
			{
				color = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
			}
			
			gl_FragColor = color;
		}';

	public function new()
	{
		super();
	}
}
