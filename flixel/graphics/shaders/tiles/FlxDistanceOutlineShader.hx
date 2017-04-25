package flixel.graphics.shaders.tiles;

import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * Shader for distance field font with outline
 */
class FlxDistanceOutlineShader extends FlxDistanceFieldShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			uniform float outlineDistance; // Between 0 and 0.5, 0 = thick outline, 0.5 = no outline
			uniform vec4 outlineColor;
			
			uniform float smoothing = 1.0 / 16.0;
			
			void main(void) 
			{
				float distance = texture2D(uImage0, vTexCoord).a;
				float outlineFactor = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
				vec4 color = mix(outlineColor, vColor, outlineFactor);
				float alpha = smoothstep(outlineDistance - smoothing, outlineDistance + smoothing, distance);
				gl_FragColor = vec4(color.rgb * alpha, color.a * alpha);
			}";
	
	/**
	 * Property for tweaking thickness of text outline.
	 * Values should be between 0 and 0.5, 0 = thick outline, 0.5 = no outline
	 */
	public var outlineDistance(default, set):Float;
	
	/**
	 * Color of text outline.
	 */
	public var outlineColor(default, set):FlxColor;
	
	public function new() 
	{
		super(DEFAULT_FRAGMENT_SOURCE);
		
		outlineDistance = 0.0;
		outlineColor = FlxColor.RED;
	}
	
	private function set_outlineDistance(value:Float):Float
	{
		value = FlxMath.bound(value, 0.0, 0.5);
		outlineDistance = value;
		data.outlineDistance.value = [value];
		return value;
	}
	
	private function set_outlineColor(value:FlxColor):FlxColor
	{
		outlineColor = value;
		var a = value.alphaFloat;
		data.outlineColor.value = [value.redFloat * a, value.greenFloat * a, value.blueFloat * a, value.alphaFloat];
		return value;
	}
}