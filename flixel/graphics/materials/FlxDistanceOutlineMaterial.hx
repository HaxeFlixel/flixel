package flixel.graphics.materials;

import flixel.graphics.FlxMaterial;
import flixel.graphics.shaders.quads.FlxDistanceFieldShader;
import flixel.graphics.shaders.quads.FlxDistanceOutlineShader;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

// TODO: make stub for flash target...

/**
 * Material for distance field font with outline.
 * @author Zaphod
 */
class FlxDistanceOutlineMaterial extends FlxMaterial
{
	private static var outlineShader:FlxDistanceOutlineShader = new FlxDistanceOutlineShader();
	
	/**
	 * Property for tweaking thickness of text outline.
	 * Values should be between 0 and 0.5, 0 = thick outline, 0.5 = no outline
	 */
	public var outlineDistance(default, set):Float;
	
	/**
	 * Color of text outline.
	 */
	public var outlineColor(default, set):FlxColor;
	
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
		
		shader = outlineShader;
		
		outlineDistance = 0.0;
		outlineColor = FlxColor.RED;
		fontSmoothing = FlxDistanceFieldShader.DEFAULT_FONT_SMOOTHING;
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
		var a:Float = value.alphaFloat;
		data.outlineColor.value = [value.redFloat * a, value.greenFloat * a, value.blueFloat * a, value.alphaFloat];
		return value;
	}
	
	private function set_fontSmoothing(value:Float):Float
	{
		data.smoothing.value = [value];
		return value;
	}
}