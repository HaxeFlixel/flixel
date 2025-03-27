package flixel.util;

import openfl.geom.ColorTransform;

class FlxColorTransformUtil
{
	/**
	 * Resets the transform to default values, multipliers become `1.0` and offsets become `0.0`
	 * @since 6.1.0
	 */
	public static inline function reset(transform:ColorTransform):ColorTransform
	{
		return set(transform, 1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0);
	}
	
	/**
	 * Quick way to set all of a transform's values
	 * 
	 * @param   rMult    The value for the red multiplier, ranges from 0 to 1
	 * @param   gMult    The value for the green multiplier, ranges from 0 to 1
	 * @param   bMult    The value for the blue multiplier, ranges from 0 to 1
	 * @param   aMult    The value for the alpha transparency multiplier, ranges from 0 to 1
	 * @param   rOffset  The offset value for the red color channel, ranges from -255 to 255
	 * @param   gOffset  The offset value for the green color channel, ranges from -255 to 255
	 * @param   bOffset  The offset for the blue color channel value, ranges from -255 to 255
	 * @param   aOffset  The offset for alpha transparency channel value, ranges from -255 to 255
	 * @since 6.1.0
	 */
	overload public static inline extern function set(transform:ColorTransform, 
			rMult, gMult, bMult, aMult,
			rOffset, gOffset, bOffset, aOffset = 0.0):ColorTransform
	{
		setMultipliers(transform, rMult, gMult, bMult, aMult);
		setOffsets(transform, rOffset, gOffset, bOffset, aOffset);
		
		return transform;
	}
	
	/**
	 * Quick way to set all of a transform's values
	 * 
	 * @param   rMult    The value for the red multiplier, ranges from 0 to 1
	 * @param   gMult    The value for the green multiplier, ranges from 0 to 1
	 * @param   bMult    The value for the blue multiplier, ranges from 0 to 1
	 * @param   rOffset  The offset value for the red color channel, ranges from -255 to 255
	 * @param   gOffset  The offset value for the green color channel, ranges from -255 to 255
	 * @param   bOffset  The offset for the blue color channel value, ranges from -255 to 255
	 * @since 6.1.0
	 */
	overload public static inline extern function set(transform:ColorTransform, 
			rMult, gMult, bMult,
			rOffset, gOffset, bOffset):ColorTransform
	{
		return set(transform, rMult, gMult, bMult, 1.0, rOffset, gOffset, bOffset);
	}
	
	/**
	 * Quick way to set all of a transform's values
	 * 
	 * @param   colorMult  A `FlxColor` whos `redFloat`, `greenFloat`, `blueFloat` and
	 *                    `alphaFloat` values determine the multipliers of this transform
	 * @param   color      A `FlxColor` whos `red`, `green`, `blue` and `alpha` values
	 *                     determine the offsets of this transform
	 * @since 6.1.0
	 */
	overload public static inline extern function set(transform:ColorTransform, colorMult = FlxColor.WHITE, colorOffset:FlxColor = 0x0):ColorTransform
	{
		return set(transform,
			colorMult.redFloat, colorMult.greenFloat, colorMult.blueFloat, colorMult.alphaFloat,
			colorOffset.red, colorOffset.green, colorOffset.blue, colorOffset.alpha
		);
	}
	
	/**
	 * Scales each color's multiplier by the specifified amount
	 * 
	 * @param   rMult  The amount to scale the red multiplier
	 * @param   gMult  The amount to scale the green multiplier
	 * @param   bMult  The amount to scale the blue multiplier
	 * @param   aMult  The amount to scale the alpha transparency multiplier
	 * @return ColorTransform
	 * @since 6.1.0
	 */
	overload public static inline extern function scaleMultipliers(transform:ColorTransform, rMult:Float, gMult:Float, bMult:Float, aMult = 1.0):ColorTransform
	{
		transform.redMultiplier *= rMult;
		transform.greenMultiplier *= gMult;
		transform.blueMultiplier *= bMult;
		transform.alphaMultiplier *= aMult;
		
		return transform;
	}
	
	/**
	 * Scales each color's multiplier by the color's specifified normal values
	 * 
	 * @param   color   A `FlxColor` whos `redFloat`, `greenFloat`, `blueFloat` and
	 *                  `alphaFloat` values scale the multipliers of this transform
	 * @since 6.1.0
	 */
	overload public static inline extern function scaleMultipliers(transform:ColorTransform, color:FlxColor):ColorTransform
	{
		transform.redMultiplier *= color.redFloat;
		transform.greenMultiplier *= color.greenFloat;
		transform.blueMultiplier *= color.blueFloat;
		transform.alphaMultiplier *= color.alphaFloat;
		
		return transform;
	}
	
	/**
	 * Quick way to set all of a transform's multipliers
	 * 
	 * @param   rMult  The value for the red multiplier, ranges from 0 to 1
	 * @param   gMult  The value for the green multiplier, ranges from 0 to 1
	 * @param   bMult  The value for the blue multiplier, ranges from 0 to 1
	 * @param   aMult  The value for the alpha transparency multiplier, ranges from 0 to 1
	 */
	overload public static inline extern function setMultipliers(transform:ColorTransform, red:Float, green:Float, blue:Float, alpha = 1.0):ColorTransform
	{
		transform.redMultiplier = red;
		transform.greenMultiplier = green;
		transform.blueMultiplier = blue;
		transform.alphaMultiplier = alpha;
		
		return transform;
	}
	
	/**
	 * Quick way to set all of a transform's multipliers with a single color
	 * 
	 * @param   color   A `FlxColor` whos `redFloat`, `greenFloat`, `blueFloat` and
	 *                  `alphaFloat` values determine the multipliers of this transform
	 * @since 6.1.0
	 */
	overload public static inline extern function setMultipliers(transform:ColorTransform, color:FlxColor):ColorTransform
	{
		transform.redMultiplier = color.redFloat;
		transform.greenMultiplier = color.greenFloat;
		transform.blueMultiplier = color.blueFloat;
		transform.alphaMultiplier = color.alphaFloat;
		
		return transform;
	}
	
	/**
	 * Quick way to set all of a transform's offsets
	 * 
	 * @param   red    The value for the red offset, ranges from 0 to 255
	 * @param   green  The value for the green offset, ranges from 0 to 255
	 * @param   blue   The value for the blue offset, ranges from 0 to 255
	 * @param   alpha  The value for the alpha transparency offset, ranges from 0 to 255
	 */
	overload public static inline extern function setOffsets(transform:ColorTransform, red:Float, green:Float, blue:Float, alpha = 0.0):ColorTransform
	{
		transform.redOffset = red;
		transform.greenOffset = green;
		transform.blueOffset = blue;
		transform.alphaOffset = alpha;
		
		return transform;
	}
	
	/**
	 * Quick way to set all of a transform's offsets with a single color
	 * 
	 * @param   color   A `FlxColor` whos `red`, `green`, `blue` and
	 *                  `alpha` values determine the offsets of this transform
	 * @since 6.1.0
	 */
	overload public static inline extern function setOffsets(transform:ColorTransform, color:FlxColor):ColorTransform
	{
		return setOffsets(transform, color.red, color.green, color.blue, color.alpha);
	}
	/**
	 * Returns whether red, green, or blue multipliers are set to anything other than 1.
	 */
	public static function hasRGBMultipliers(transform:ColorTransform):Bool
	{
		return transform.redMultiplier != 1 || transform.greenMultiplier != 1 || transform.blueMultiplier != 1;
	}

	/**
	 * Returns whether red, green, blue, or alpha multipliers are set to anything other than 1.
	 */
	public static function hasRGBAMultipliers(transform:ColorTransform):Bool
	{
		return hasRGBMultipliers(transform) || transform.alphaMultiplier != 1;
	}

	/**
	 * Returns whether red, green, or blue offsets are set to anything other than 0.
	 */
	public static function hasRGBOffsets(transform:ColorTransform):Bool
	{
		return transform.redOffset != 0 || transform.greenOffset != 0 || transform.blueOffset != 0;
	}

	/**
	 * Returns whether red, green, blue, or alpha offsets are set to anything other than 0.
	 */
	public static function hasRGBAOffsets(transform:ColorTransform):Bool
	{
		return hasRGBOffsets(transform) || transform.alphaOffset != 0;
	}
}
