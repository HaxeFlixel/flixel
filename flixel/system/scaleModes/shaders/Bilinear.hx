package flixel.system.scaleModes.shaders;

import openfl.display.Shader;

class Bilinear extends Shader implements IScaleShader
{

	@fragment var frag = "

varying vec2 vTexCoord;

uniform sampler2D uImage0;
uniform vec2 uResolution;
// varying vec2 vTexCoord;


// uniform vec2 objectSize;
uniform float uScaleX;
uniform float uScaleY;
uniform float uStrength;

void main()
{
  vec2 tc = vec2(openfl_vTexCoord.x, openfl_vTexCoord.y);

  float OneTexelX = uStrength*(1.0/uScaleX)/openfl_uTextureSize.x;
  float OneTexelY = uStrength*(1.0/uScaleY)/openfl_uTextureSize.y;

  vec2 coord1 = vec2(openfl_vTexCoord.x/uScaleX, openfl_vTexCoord.y/uScaleY)+vec2(0.0, OneTexelY);
  vec2 coord2 = vec2(openfl_vTexCoord.x/uScaleX, openfl_vTexCoord.y/uScaleY)+vec2(OneTexelX, 0.0 );
  vec2 coord3 = vec2(openfl_vTexCoord.x/uScaleX, openfl_vTexCoord.y/uScaleY)+vec2(OneTexelX, OneTexelY);
  vec2 coord4 = vec2(openfl_vTexCoord.x/uScaleX, openfl_vTexCoord.y/uScaleY);
  
  vec4 s1 = vec4(texture2D(uImage0, coord1));
  vec4 s2 = vec4(texture2D(uImage0, coord2));
  vec4 s3 = vec4(texture2D(uImage0, coord3));
  vec4 s4 = vec4(texture2D(uImage0, coord4));
  
  vec2 Dimensions = vec2(tc) * openfl_uTextureSize;
  
  float fu = fract(Dimensions.x);
  float fv = fract(Dimensions.y);
  
  vec4 tmp1 = mix(s4, s2, fu);
  vec4 tmp2 = mix(s1, s3, fu);
  
  vec4 t0 = mix(tmp1, tmp2, fv);
    
  gl_FragColor = t0;
}";

	public function new() 
	{
		super();
	}
	
}