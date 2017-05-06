package flixel.graphics.materials;

import flixel.graphics.FlxMaterial;
import flixel.graphics.shaders.quads.FlxDistanceFieldShader;
import flixel.graphics.shaders.quads.FlxDistanceShadowShader;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * ...
 * @author Zaphod
 */
class FlxDistanceShadowMaterial extends FlxMaterial
{
	private static var shadowShader:FlxDistanceShadowShader = new FlxDistanceShadowShader();
	
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
	
	/**
	 * Font smoothing factor.
	 * Right value for smoothing is `0.25f / (spread * scale)`, where
	 * `spread` value is defined at font atlas creation,
	 * and `scale` value is the scale factor of bitmap text.
	 */
	public var fontSmoothing(default, set):Float;
	
	public function new() 
	{
		super();
		
		shader = shadowShader;
		
		data.shadowOffset.value = [0.0, 0.0];
		
		shadowSmoothing = 0.5;
		shadowColor = FlxColor.RED;
		shadowOffsetX = 0.0;
		shadowOffsetY = 0.0;
		
		fontSmoothing = FlxDistanceFieldShader.DEFAULT_FONT_SMOOTHING;
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
	
	private function set_fontSmoothing(value:Float):Float
	{
		data.smoothing.value = [value];
		return value;
	}
	
}