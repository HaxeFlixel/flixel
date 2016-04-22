package flixel.system.scaleModes.shaders;

import openfl.display.Shader;

class Nearest extends Shader implements IScaleShader
{
	
	@fragment var frag = "
	// varying vec2 openfl_vTexCoord;
//declare uniforms
uniform sampler2D uImage0;
uniform vec2 uResolution;
varying vec2 vTexCoord;


// uniform vec2 objectSize;
uniform float uScaleX;
uniform float uScaleY;
uniform float uStrength;

void main()
{
    // vec2 tc = vec2(vTexCoord.x,vTexCoord.y-(92.0/492.0)/2.0);
    // vec4 c = texture2D(uImage0, vec2(tc.x/2.0,tc.y/2.0));
    // vec4 c = vec4(openfl_vTexCoord.y*2.0-.5,0.0,0.0,1.0);

    vec4 c = vec4(0.0,0.0,0.0,0.0);
    if((openfl_vTexCoord.y-(92.0/492.0))/(1.0-92.0/492.0)*4.0 > .5){//openfl_vTexCoord.y < 1.0-0.0 && openfl_vTexCoord.y > 1.0-0.05){
    	c = vec4(1.0,0.0,0.0,1.0);
    }
    // c = texture2D(uImage0, vec2(openfl_vTexCoord.x/scaleX, openfl_vTexCoord.y/(scaleY)+((objectSize.y-uResolution.y-4.0)/objectSize.y)/2.0));
    // c = texture2D(uImage0, vec2(openfl_vTexCoord.x/scaleX, (openfl_vTexCoord.y/scaleY+((objectSize.y-uResolution.y)/objectSize.y))/(scaleY)));
    
    float a = (uResolution.y - openfl_uObjectSize.y) / openfl_uTextureSize.y;
    c = texture2D(uImage0, vec2(openfl_vTexCoord.x/uScaleX, (92.0/512.0)*(.5+.5/uScaleY)+(openfl_vTexCoord.y-(92.0/512.0))/(uScaleY)));
    // c = texture2D(uImage0, vec2(openfl_vTexCoord.x/uScaleX, a*(.5+.5/uScaleY)+(openfl_vTexCoord.y-a)/(uScaleY)));
    // c = texture2D(uImage0, vec2(openfl_vTexCoord.x/scaleX, (92.0/512.0)*(.5+.5/scaleY)+(openfl_vTexCoord.y-(92.0/512.0))/(scaleY)));

    gl_FragColor = c;
}";

	public function new() 
	{
		super();
	}
	
}