package flixel.system.scaleModes.shaders;

import openfl.display.Shader;

class Nearest extends Shader implements IScaleShader
{
	
	@fragment var frag = "
//declare uniforms
uniform sampler2D uImage0;
uniform vec2 uResolution;
varying vec2 vTexCoord;

uniform float uScaleX;
uniform float uScaleY;
uniform float uStrength;

void main()
{
    vec4 c = vec4(0.0,0.0,0.0,0.0);
    
    float a = (uResolution.y - openfl_uObjectSize.y) / openfl_uTextureSize.y;
    c = texture2D(uImage0, vec2(openfl_vTexCoord.x/uScaleX, (92.0/512.0)*(.5+.5/uScaleY)+(openfl_vTexCoord.y-(92.0/512.0))/(uScaleY)));

    gl_FragColor = c;
}";

	public function new() 
	{
		super();
	}
	
}