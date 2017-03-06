package flixel.graphics.shaders.tiles;

import flixel.graphics.shaders.FlxBaseShader;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * Shader for distance field font with outline
 */
class FlxDistanceShadowShader extends FlxTexturedShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			uniform vec2 shadowOffset; 		// Between 0 and spread / textureSize
			uniform float shadowSmoothing;	// Between 0 and 0.5
			uniform vec4 shadowColor;
			
			// right value for smoothing is `0.25f / (spread * scale)`
			const float smoothing = 1.0 / 16.0;
			
			void main(void) 
			{
				float distance = texture2D(uImage0, vTexCoord).a;
				float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
				vec4 text = vec4(vColor.rgb, vColor.a * alpha);
				
				float shadowDistance = texture2D(uImage0, vTexCoord - shadowOffset).a;
				float shadowAlpha = smoothstep(0.5 - shadowSmoothing, 0.5 + shadowSmoothing, shadowDistance);
				vec4 shadow = vec4(shadowColor.rgb, shadowColor.a * shadowAlpha);
				
				gl_FragColor = mix(shadow, text, text.a);
			//	gl_FragColor = vec4(color.rgb * alpha, color.a * alpha);
			}";
	
	/**
	 * Shadow smoothing.
	 * Values should be between 0 and 0.5.
	 */
	public var shadowSmoothing(default, set):Float;
	
	/**
	 * Color of text outline.
	 */
	public var shadowColor(default, set):FlxColor;
	
	/**
	 * Text shadow offset on X axis.
	 * Should be between 0 and spread / texture width
	 */
	public var shadowOffsetX(default, set):Float;
	
	/**
	 * Text shadow offset on Y axis.
	 * Should be between 0 and spread / texture height
	 */
	public var shadowOffsetY(default, set):Float;
	
	public function new() 
	{
		super(null, DEFAULT_FRAGMENT_SOURCE);
		
		data.shadowOffset.value = [0.0, 0.0];
		
		shadowSmoothing = 0.5;
		shadowColor = FlxColor.RED;
		shadowOffsetX = 0.0;
		shadowOffsetY = 0.0;
	}
	
	private function set_shadowSmoothing(value:Float):Float
	{
		value = FlxMath.bound(value, 0.0, 0.5);
		shadowSmoothing = value;
		data.shadowSmoothing.value = [value];
		return value;
	}
	
	private function set_shadowColor(value:FlxColor):FlxColor
	{
		shadowColor = value;
		data.shadowColor.value = [value.redFloat, value.greenFloat, value.blueFloat, value.alphaFloat];
		return value;
	}
	
	private function set_shadowOffsetX(value:Float):Float
	{
		shadowOffsetX = value;
		data.shadowOffset.value[0] = value;
		return value;
	}
	
	private function set_shadowOffsetY(value:Float):Float
	{
		shadowOffsetY = value;
		data.shadowOffset.value[1] = value;
		return value;
	}
}