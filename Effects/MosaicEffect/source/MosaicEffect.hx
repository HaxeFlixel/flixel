package;

import openfl.display.Shader;
 
/**
 * Note: BitmapFilters can only be used on 'OpenFL next'
 */
class MosaicEffect
{
	/**
	 * The effect's "start-value" on the x/y-axes (the effect is not visible with this value).
	 */
	public static inline var DEFAULT_STRENGTH:Float = 1;

	/**
	 * The instance of the actual shader class
	 */
	public var shader(default, null):MosaicShader;
	
	/**
	 * The effect's strength on the x-axis.
	 */
	public var strengthX(default, null):Float = DEFAULT_STRENGTH;
	
	/**
	 * The effect's strength on the y-axis.
	 */
	public var strengthY(default, null):Float = DEFAULT_STRENGTH;
	
	public function new(width:Float, height:Float):Void
	{
		shader = new MosaicShader();
		shader.uTextureSize = [width, height];
		shader.uBlocksize = [strengthX, strengthY];
	}
	
	public function setStrength(strengthX:Float, strengthY:Float):Void
	{
		this.strengthX = strengthX;
		this.strengthY = strengthY;
		shader.uBlocksize[0] = strengthX;
		shader.uBlocksize[1] = strengthY;
	}
}

/**
 * A classic mosaic effect, just like in the old days!
 * 
 * Usage notes:
 * - The effect will be applied to the whole screen.
 * - Set the x/y-values on the 'uBlocksize' vector to the desired size (setting this to 0 will make the screen go black)
 */
class MosaicShader extends Shader
{
	@fragment var code = '
	uniform vec2 uTextureSize;
	uniform vec2 uBlocksize;

	void main()
	{
		vec2 blocks = uTextureSize / uBlocksize;
		gl_FragColor = texture2D(${Shader.uSampler}, floor(${Shader.vTexCoord} * blocks) / blocks);
	}';
	
	public function new()
	{
		super();
	}
}