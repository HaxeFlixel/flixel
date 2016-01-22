package flixel.util;
import flash.geom.ColorTransform;

/**
 * ...
 * @author ...
 */
class FlxColorTransformUtil
{

	/**
	 * Set all the color multipliers at once
	 * @param	c	the ColorTransform you want to modify
	 * @param	r	red multiplier
	 * @param	g	green multiplier
	 * @param	b	blue multiplier
	 * @param	a	alpha multiplier
	 */
	
	public static function setMultipliers(c:ColorTransform, r:Float, g:Float, b:Float, a:Float):Void
	{
		c.redMultiplier   = r;
		c.greenMultiplier = g;
		c.blueMultiplier  = b;
		c.alphaMultiplier = a;
	}
	
	/**
	 * Set all the color offsets at once
	 * @param	c	the ColorTransform you want to modify
	 * @param	r	red offset
	 * @param	g	green offset
	 * @param	b	blue offset
	 * @param	a	alpha offset
	 */
	
	public static function setOffsets(c:ColorTransform, r:Int, g:Int, b:Int, a:Int):Void
	{
		c.redOffset   = r;
		c.greenOffset = g;
		c.blueOffset  = b;
		c.alphaOffset = a;
	}
	
	/**
	 * Returns whether red, green, or blue multipliers are set to anything other than 1
	 * @param	c
	 * @return
	 */
	
	public static function hasRGBMultipliers(c:ColorTransform):Bool
	{
		return c.redMultiplier != 1 || c.greenMultiplier != 1 || c.blueMultiplier != 1;
	}
	
	/**
	 * Returns whether red, greeen, blue, or alpha multipliers are set to anything other than 1
	 * @param	c
	 * @return
	 */
	
	public static function hasRGBAMultipliers(c:ColorTransform):Bool
	{
		return c.redMultiplier != 1 || c.greenMultiplier != 1 || c.blueMultiplier != 1 || c.alphaMultiplier != 1;
	}
	
	/**
	 * Returns whether red, green, or blue offsets are set to anything other than 0
	 * @param	c
	 * @return
	 */
	
	public static function hasRGBOffsets(c:ColorTransform):Bool
	{
		return c.redOffset != 0 || c.greenOffset != 0 || c.blueOffset != 0;
	}
	
	/**
	 * Returns whether red, green, blue, or alpha offsets are set to anything other than 0
	 * @param	c
	 * @return
	 */
	
	public static function hasRGBAOffsets(c:ColorTransform):Bool
	{
		return c.redOffset != 0 || c.greenOffset != 0 || c.blueOffset != 0 || c.alphaOffset != 0;
	}
	
}