package flixel.graphics.shaders.quads;

import flixel.graphics.shaders.FlxBaseShader;

/**
 * Default shader used for rendering distance field fonts.
 * See: https://github.com/libgdx/libgdx/wiki/Distance-field-fonts
 */
class FlxDistanceFieldShader extends FlxTexturedShader
{
	public static inline var DEFAULT_FRAGMENT_SOURCE:String = 
			"
			varying vec2 vTexCoord;
			varying vec4 vColor;
			varying vec4 vColorOffset;
			
			uniform sampler2D uImage0;
			
			uniform float smoothing = 1.0 / 16.0;
			
			void main(void) 
			{
				float distance = texture2D(uImage0, vTexCoord).a;
				float alpha = smoothstep(0.5 - smoothing, 0.5 + smoothing, distance);
				gl_FragColor = vec4(vColor.rgb * alpha, vColor.a * alpha);
			}";
	
	public var smoothing(default, set):Float;
	
	public function new(?fragment:String) 
	{
		fragment = (fragment == null) ? DEFAULT_FRAGMENT_SOURCE : fragment;
		super(null, fragment);
		
		smoothing = 1.0 / 16.0;
	}
	
	/**
	 * Font smoothing factor.
	 * Right value for smoothing is `0.25f / (spread * scale)`, where
	 * `spread` is defined at font atlas creation,
	 * `scale` is the scale of bitmap text.
	 * 
	 * Default value is (1.0 / 16.0).
	 */
	private function set_smoothing(value:Float):Float
	{
		smoothing = value;
		data.smoothing.value = [value];
		return value;
	}
}