package flixel.graphics.shaders.quads;

/**
 * Default shader used for rendering distance field fonts.
 * See: https://github.com/libgdx/libgdx/wiki/Distance-field-fonts
 */
class FlxDistanceFieldShader extends FlxTexturedShader
{
	/**
	 * Default font smoothing factor, equals to (1.0 / 16.0).
	 * Right value for smoothing is `0.25f / (spread * scale)`, where
	 * `spread` value is defined at font atlas creation,
	 * and `scale` value is the scale factor of bitmap text.
	 */
	public static inline var DEFAULT_FONT_SMOOTHING:Float = 1.0 / 16.0;
	
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
	
	public function new(?fragment:String) 
	{
		fragment = (fragment == null) ? DEFAULT_FRAGMENT_SOURCE : fragment;
		super(null, fragment);
	}
}