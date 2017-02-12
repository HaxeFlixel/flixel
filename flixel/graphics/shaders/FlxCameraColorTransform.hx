package flixel.graphics.shaders;
import flixel.graphics.shaders.FlxCameraColorTransform.ColorTransformFilter;
import openfl._internal.renderer.RenderSession;
import openfl.display.Shader;
import openfl.filters.BitmapFilter;
import openfl.geom.ColorTransform;

@:final class ColorTransformFilter extends BitmapFilter
{
	private static var _colorTransformShader:FlxCameraColorTransform = new FlxCameraColorTransform();
	
	public var transform:ColorTransform;
	
	public function new()
	{
		super();
		__numPasses = 1;
	}
	
	override public function clone():BitmapFilter 
	{
		return new ColorTransformFilter();
	}
	
	override private function __initShader(renderSession:RenderSession, pass:Int):Shader 
	{
		_colorTransformShader.init(transform);
		return _colorTransformShader;
	}
}

/**
 * Shader user for applying camera color transform (it there is any).
 * It can be used as a basis for other camera effect shaders.
 */
class FlxCameraColorTransform extends Shader
{
	@:glFragmentSource(
		
		"varying float vAlpha;
		varying vec2 vTexCoord;
		
		uniform sampler2D uImage0;
		
		uniform vec4 uColor;
		uniform vec4 uColorOffset;
		
		void main(void) 
		{
			vec4 color = texture2D(uImage0, vTexCoord);
			
			float alpha = color.a * uColor.a;
			vec4 result = vec4(color.rgb * alpha, alpha) *  uColor;
			
			result = result + uColorOffset;
			result = clamp(result, 0.0, 1.0);
			gl_FragColor = result;
		}"
	)
	
	public function new() 
	{
		super();
		
		#if !macro
		data.uColor.value = [1.0, 1.0, 1.0, 1.0];
		data.uColorOffset.value = [0.0, 0.0, 0.0, 0.0];
		#end
	}
	
	public function init(transform:ColorTransform):Void
	{
		var multipliers = data.uColor.value;
		var offsets = data.uColorOffset.value;
		
		if (transform != null)
		{
			multipliers[0] = transform.redMultiplier;
			multipliers[1] = transform.greenMultiplier;
			multipliers[2] = transform.blueMultiplier;
			multipliers[3] = transform.alphaMultiplier;
			
			offsets[0] = transform.redOffset / 255;
			offsets[1] = transform.greenOffset / 255;
			offsets[2] = transform.blueOffset / 255;
			offsets[3] = transform.alphaOffset / 255;
			
			
		}
		else
		{
			multipliers[0] = 1.0;
			multipliers[1] = 1.0;
			multipliers[2] = 1.0;
			multipliers[3] = 1.0;
			
			offsets[0] = 0.0;
			offsets[1] = 0.0;
			offsets[2] = 0.0;
			offsets[3] = 0.0;
		}
	}
}