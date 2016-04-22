package ;
 
/**
 * Note: BitmapFilters can only be used on 'OpenFL next'
 */
class MosaicEffect
{
	/**
	 * The instance of the actual shader class
	 */
	private var shader:MosaicShader;
	
	/**
	 * The effect's "start-value" on the x/y-axes (the effect is not visible with this value).
	 */
	public static inline var DEFAULT_VALUE:Float = 1;
	
	/**
	 * The effect's strength on the x-axis.
	 */
	private var strengthX:Float = DEFAULT_VALUE;
	
	/**
	 * The effect's strength on the y-axis.
	 */
	private var strengthY:Float = DEFAULT_VALUE;
	
	public function new():Void
	{
		shader = new MosaicShader();
		shader.uBlocksize = [strengthX, strengthY];
	}
	
	/**
	 * @return Returns the shader instance.
	 */
	public function getShader():MosaicShader
	{
		return shader;
	}
	
	/**
	 * @return Returns the shader's X-axis (horizontal) strength.
	 */
	public function getStrenghtX():Float
	{
		return strengthX;
	}
	
	/**
	 * @return Returns the shader's Y-axis (vertical) strength.
	 */
	public function getStrenghtY():Float
	{
		return strengthY;
	}
	
	/**
	 * Sets the size of the inflated pixels on the X-axis (horizontally).
	 * @param	StrengthX Desired effect strength on the X-axis.
	 */
	public function setEffectStrengthX(strengthX:Float):Void
	{
		setEffectStrengthXY(strengthX, this.strengthY);
	}
	
	/**
	 * Sets the size of the inflated pixels on the Y-axis (vertically).
	 * @param	StrengthY Desired effect strength on the Y-axis.
	 */
	public function setEffectStrengthY(strengthY:Float):Void
	{
		setEffectStrengthXY(this.strengthX, strengthY);
	}
	
	/**
	 * Sets the size of the inflated pixels on both the x/y-axes.
	 * @param	StrengthX Desired effect strength on the X-axis (horizontally).
	 * @param	StrengthY Desired effect strength on the Y-axis (vertically).
	 */
	public function setEffectStrengthXY(strengthX:Float, strengthY:Float):Void
	{
		this.strengthX = strengthX;
		this.strengthY = strengthY;
		shader.uBlocksize = [this.strengthX, this.strengthY];
	}
}
