package flixel.util;
import flixel.tweens.FlxEase.EaseFunction;

/**
 * Class representing a color, based on Int. Provides a variety of methods for creating and converting colors.
 * 
 * FlxColor's can be written as Ints. This means you can pass a hex value such as
 * 0xff123456 to a function expecting a FlxColor, and it will automatically become a FlxColor object.
 * Similarly, FlxColors may be treated as Ints.
 */
abstract FlxColor(Int) from Int to Int
{
	/**
	 * A collection of preset colors. You may change the values of these colors.
	 */
	public static inline var preset = FlxColorPreset;
	
	public var red(get, set):Int;
	public var blue(get, set):Int;
	public var green(get, set):Int;
	public var alpha(get, set):Int;
	
	public var redFloat(get, set):Float;
	public var blueFloat(get, set):Float;
	public var greenFloat(get, set):Float;
	public var alphaFloat(get, set):Float;
	
	/** The hue of the color in degrees (from 0 to 359) **/
	public var hue(get, set):Float;
	/** The saturation of the color (from 0 to 1) **/
	public var saturation(get, set):Float;
	/** The brightness (aka value) of the color (from 0 to 1) **/
	public var brightness(get, set):Float;
	/** The lightness of the color (from 0 to 1) **/
	public var lightness (get, set):Float;
	
	/**
	 * Create a color from the lest significant four bytes of an Int
	 * 
	 * @param	Value And Int with bytes in the format 0xAARRGGBB
	 * @return	The color as a FlxColor
	 */
	public static inline function fromInt(Value:Int):FlxColor
	{
		return new FlxColor(Value);
	}
	/**
	 * Generate a color from integer RGB values (0 to 255)
	 * 
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255.
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
	{
		var color = new FlxColor();
		return color.setRGB(Red, Green, Blue, Alpha);
	}
	
	/**
	 * Generate a color from float RGB values (0 to 1)
	 * 
	 * @param Red	The red value of the color from 0 to 1
	 * @param Green	The green value of the color from 0 to 1
	 * @param Blue	The green value of the color from 0 to 1
	 * @param Alpha	How opaque the color should be, from 0 to 1.
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setRGBFloat(Red, Green, Blue, Alpha);
	}
	
	/**
	 * Generate a color from HSB (aka HSV) components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	(aka Value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a FlxColor
	 */
	public static function fromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setHSB(Hue, Saturation, Brightness, Alpha);
	}
	/**
	 * Generate a color from HSL components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a FlxColor
	 */
	public static inline function fromHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setHSL(Hue, Saturation, Lightness, Alpha);
	}
	
	/**
	 * Get HSB color wheel values in an array which will be 360 elements in size
	 * 
	 * @param	Alpha Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * @return	HSB color wheel as Array of FlxColors
	 */
	public static function getHSBColorWheel(Alpha:Int = 255):Array<FlxColor>
	{
		var colors:Array<FlxColor> = new Array<FlxColor>();
		
		for (c in 0...360)
		{
			colors[c] = fromHSB(c, 1.0, 1.0, Alpha);
		}
		
		return colors;
	}
	
	/**
	 * Get an interpolated color based on two different colors.
	 * 
	 * @param 	Color1 The first color
	 * @param 	Color2 The second color
	 * @param 	Factor Value from 0 to 1 representing how much to shift Color1 toward Color2
	 * @return	The interpolated color
	 */
	public static function interpolate(Color1:FlxColor, Color2:FlxColor, Factor:Float):FlxColor
	{
		var r:Int = Std.int((Color2.red - Color1.red) * Factor + Color1.red);
		var g:Int = Std.int((Color2.green - Color1.green) * Factor + Color1.green);
		var b:Int = Std.int((Color2.blue - Color1.blue) * Factor + Color1.blue);
		var a:Int = Std.int((Color2.alpha - Color1.alpha) * Factor + Color1.alpha);
		
		return fromRGB(r, g, b, a);
	}
	
	/**
	 * Create a gradient from one color to another
	 * 
	 * @param Color1 The color to shift from
	 * @param Color2 The color to shift to
	 * @param Steps How many colors the gradient should have
	 * @param Ease An optional easing function, such as those provided in FlxEase
	 * @return An array of colors of length Steps, shifting from Color1 to Color2
	 */
	public static function gradient(Color1:FlxColor, Color2:FlxColor, Steps:Int, ?Ease:Float->Float):Array<FlxColor>
	{
		var output = new Array<FlxColor>();
		
		if (Ease == null)
		{
			Ease = inline function(t:Float):Float
			{
				return t;
			}
		}
		
		for (step in 0...Steps)
		{
			output[step] = interpolate(Color1, Color2, Ease(step / (Steps - 1)));
		}
		
		return output;
	}
	
	/**
	 * Returns a Complementary Color Harmony of this color.
	 * A complementary hue is one directly opposite the color given on the color wheel
	 * 
	 * @return	The complimentary color
	 */
	public inline function getComplementHarmony():FlxColor
	{		
		return fromHSB(FlxMath.wrapValue(Std.int(hue), 180, 359), brightness, saturation, alpha);
	}
	
	/**
	 * Returns an Analogous Color Harmony for the given color.
	 * An Analogous harmony are hues adjacent to each other on the color wheel
	 * 
	 * @param	Threshold Control how adjacent the colors will be (default +- 30 degrees)
	 * @return 	Object containing 3 properties: original (the original color), warmer (the warmer analogous color) and colder (the colder analogous color)
	 */
	public inline function getAnalogousHarmony(Color:Int, Threshold:Int = 30):{original:FlxColor, warmer:FlxColor, colder:FlxColor}
	{
		var warmer:Int = FlxMath.wrapValue(Std.int(hue), 359 - Threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hue), Threshold, 359);
		
		return {original: this, warmer: warmer, colder: colder};
	}
	
	/**
	 * Returns an Split Complement Color Harmony for this color.
	 * A Split Complement harmony are the two hues on either side of the color's Complement
	 * 
	 * @param	Threshold Control how adjacent the colors will be to the Complement (default +- 30 degrees)
	 * @return 	Object containing 3 properties: original (the original color), warmer (the warmer analogous color) and colder (the colder analogous color)
	 */
	public inline function getSplitComplementHarmony(Threshold:Int = 30):{original:FlxColor, warmer:FlxColor, colder:FlxColor}
	{
		var oppositeHue:Int = FlxMath.wrapValue(Std.int(hue), 180, 359);
		var warmer:FlxColor = fromHSB(FlxMath.wrapValue(oppositeHue, - Threshold, 359), saturation, brightness, alpha);
		var colder:FlxColor = fromHSB(FlxMath.wrapValue(oppositeHue, Threshold, 359), saturation, brightness, alpha);
		
		return {original: this, warmer: warmer, colder: colder};
	}
	
	/**
	 * Returns a Triadic Color Harmony for this color. A Triadic harmony are 3 hues equidistant 
	 * from each other on the color wheel.
	 * 
	 * @return 	Object containing 3 properties: color1 (the original color), color2 and color3 (the equidistant colors)
	 */
	public inline function getTriadicHarmony():{color1:FlxColor, color2:FlxColor, color3:FlxColor}
	{
		var triadic1:FlxColor = fromHSB(FlxMath.wrapValue(Std.int(hue), 120, 359), saturation, brightness, alpha);
		var triadic2:FlxColor = fromHSB(FlxMath.wrapValue(Std.int(triadic1.hue), 120, 359), saturation, brightness, alpha);
		
		return {color1: this, color2: triadic1, color3: triadic2};
	}
	
	/**
	 * Create a copy of this FlxColor
	 * @return A copy of this FlxColor
	 */
	public inline function copy():FlxColor {
		return fromInt(this);
	}
	
	/**
	 * Return a String representation of the color in the format
	 * 
	 * @param Alpha Whether to include the alpha value in the hes string
	 * @param Prefix Whether to include "0x" prefix at start of string
	 * @return	A string of length 10 in the format 0xAARRGGBB
	 */
	public inline function toHexString(Alpha:Bool = true, Prefix:Bool = true):String
	{
		return (Prefix ? "0x" : "") + (Alpha ? StringTools.hex(alpha, 2) : "") +
			StringTools.hex(red, 2) + StringTools.hex(green, 2) + StringTools.hex(blue, 2);
	}
	
	/**
	 * Return a String representation of the color in the format #RRGGBB
	 * @return	A string of length 7 in the format #RRGGBB
	 */
	public inline function toWebString():String
	{
		return "#" + toHexString(false, false);
	}
	
	/**
	 * Get a string of color information about this color
	 * 
	 * @return A string containing information about this color
	 */
	public function getColorInfo():String
	{
		var result:String = "";
		
		// Hex format
		var result:String = toHexString() + "\n";
		// RGB format
		result += "Alpha: " + alpha + " Red: " + red + " Green: " + green + " Blue: " + blue + "\n";
		// HSB/HSL info
		result += "Hue: " + FlxMath.roundDecimal(hue, 2) + " Saturation: " + FlxMath.roundDecimal(saturation, 2) + 
			" Brightness: " + FlxMath.roundDecimal(brightness, 2) + " Lightnes: " + FlxMath.roundDecimal(lightness, 2);
		
		return result;
	}
	
	/**
	 * Darken this color.
	 * 
	 * @param	Factor Value from 0 to 1 of how much to progress toward black.
	 * @return 	This color, darkened
	 */
	public function darken(Factor:Float = 0.2):FlxColor
	{
		FlxMath.bound(Factor, 0, 1);
		brightness *= (1 - Factor);
		return this;
	}
	/**
	 * Lighten this color.
	 * 
	 * @param	Factor Value from 0 to 1 of how much to progress toward white.
	 * @return 	This color, brightened
	 */
	public inline function lighten(Factor:Float = 0.2):FlxColor
	{
		FlxMath.bound(Factor, 0, 1);
		lightness += (1 - lightness) * Factor;
		return this;
	}
	/**
	 * Set RGB values as integers (0 to 255)
	 * 
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255.
	 * @return This color
	 */
	public inline function setRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):FlxColor
	{
		red = Red;
		green = Green;
		blue = Blue;
		alpha = Alpha;
		return this;
	}
	/**
	 * Set RGB values as floats (0 to 1)
	 * 
	 * @param Red	The red value of the color from 0 to 1
	 * @param Green	The green value of the color from 0 to 1
	 * @param Blue	The green value of the color from 0 to 1
	 * @param Alpha	How opaque the color should be, from 0 to 1.
	 * @return This color
	 */
	public inline function setRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor
	{
		redFloat = Red;
		greenFloat = Green;
		blueFloat = Blue;
		alphaFloat = Alpha;
		return this;
	}
	/**
	 * Set HSB (aka HSV) components
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	(aka Value) A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	This color
	 */
	public inline function setHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float):FlxColor
	{
		Hue %= 360;
		
		var slice:Int = Std.int(Hue / 60);
		var hf:Float = Hue / 60 - slice; // Real part of hue slice
		var aa:Float = Brightness * (1 - Saturation);
		var bb:Float = Brightness * (1 - Saturation * hf);
		var cc:Float = Brightness * (1 - Saturation * (1.0 - hf));
		
		switch (slice)
		{
			case 0: setRGBFloat(Brightness, cc, aa);
			case 1: setRGBFloat(bb, Brightness, aa);
			case 2: setRGBFloat(aa, Brightness, cc);
			case 3: setRGBFloat(aa, bb, Brightness);
			case 4:	setRGBFloat(cc, aa, Brightness);
			case 5: setRGBFloat(Brightness, aa, bb);
			default: setRGBFloat(0, 0, 0);
		}
		alphaFloat = Alpha;
		
		return this;
	}
	/**
	 * Set HSL components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	This color
	 */
	public inline function setHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float):FlxColor
	{
		return setHSB(Hue, Saturation, 1 - Math.abs(2 * Lightness - 1), Alpha);
	}
	
	public function new(Value:Int = 0)
	{
		this = Value;
	}
	
	private inline function get_red():Int
	{
		return (this >> 16) & 0xff;
	}
	private inline function get_green():Int
	{
		return (this >> 8) & 0xff;
	}
	private inline function get_blue():Int
	{
		return this & 0xff;
	}
	private inline function get_alpha():Int
	{
		return (this >> 24) & 0xff;
	}
	private inline function get_redFloat():Float
	{
		return red / 255;
	}
	private inline function get_greenFloat():Float
	{
		return green / 255;
	}
	private inline function get_blueFloat():Float
	{
		return blue / 255;
	}
	private inline function get_alphaFloat():Float
	{
		return alpha / 255;
	}
	private inline function set_red(Value:Int):Int
	{
		this &= 0xff00ffff;
		this |= Value << 16;
		return Value;
	}
	private inline function set_green(Value:Int):Int
	{
		this &= 0xffff00ff;
		this |= Value << 8;
		return Value;
	}
	private inline function set_blue(Value:Int):Int
	{
		this &= 0xffffff00;
		this |= Value;
		return Value;
	}
	private inline function set_alpha(Value:Int):Int
	{
		this &= 0x00ffffff;
		this |= Value << 24;
		return Value;
	}
	private inline function set_redFloat(Value:Float):Float
	{
		red = Math.round(Value * 255);
		return Value;
	}
	private inline function set_greenFloat(Value:Float):Float
	{
		green = Math.round(Value * 255);
		return Value;
	}
	private inline function set_blueFloat(Value:Float):Float
	{
		blue = Math.round(Value * 255);
		return Value;
	}
	private inline function set_alphaFloat(Value:Float):Float
	{
		trace(Value);
		alpha = Math.round(Value * 255);
		trace(alpha);
		return Value;
	}
	private function get_hue():Float
	{
		var hueRad = Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
		var hue:Float = 0;
		if (hueRad != 0)
		{
			hue = 180 / Math.PI * Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
		}		
			
		return hue < 0 ? hue + 360 : hue;
	}
	private inline function get_brightness():Float
	{
		return maxColor();
	}
	private inline function get_saturation():Float
	{
		return (maxColor() - minColor()) / brightness;
	}
	private inline function get_lightness():Float
	{
		return (maxColor() + minColor()) / 2;
	}
	private inline function set_hue(Value:Float):Float
	{
		setHSB(Value, saturation, brightness, alphaFloat);
		return Value;
	}
	private inline function set_saturation(Value:Float):Float
	{
		setHSB(hue, Value, brightness, alphaFloat);
		return Value;
	}
	private inline function set_brightness(Value:Float):Float
	{
		setHSB(hue, saturation, Value, alphaFloat);
		return Value;
	}
	private inline function set_lightness(Value:Float):Float
	{
		setHSL(hue, saturation, Value, alphaFloat);
		return Value;
	}
	
	private inline function maxColor():Float
	{
		return Math.max(redFloat, Math.max(greenFloat, blueFloat));
	}
	private inline function minColor():Float
	{
		return Math.min(redFloat, Math.min(greenFloat, blueFloat));
	}
}

class FlxColorPreset
{
	public static inline var RED:FlxColor =				0xffff0000;
	public static inline var YELLOW:FlxColor =			0xffffff00;
	public static inline var GREEN:FlxColor =			0xff008000;
	public static inline var BLUE:FlxColor =			0xff0000ff;
	public static inline var ORANGE:FlxColor =			0xffff8000;
	public static inline var PINK:FlxColor =			0xffffc0cb;
	public static inline var PURPLE:FlxColor =			0xff800080;
	public static inline var WHITE:FlxColor =			0xffffffff;
	public static inline var BLACK:FlxColor =			0xff000000;
	public static inline var GRAY:FlxColor =			0xff808080;
	public static inline var BROWN:FlxColor =			0xff964B00;
	public static inline var TRANSPARENT:FlxColor =		0x00000000;
	public static inline var IVORY:FlxColor =			0xfffffff0;
	public static inline var BEIGE:FlxColor =			0xfff5f5dc;
	public static inline var WHEAT:FlxColor =			0xfff5deb3;
	public static inline var TAN:FlxColor =				0xffd2b48c;
	public static inline var KHAKI:FlxColor =			0xffc3b091;
	public static inline var SILVER:FlxColor =			0xffc0c0c0;
	public static inline var CHARCOAL:FlxColor =		0xff464646;
	public static inline var NAVY_BLUE:FlxColor =		0xff000080;
	public static inline var ROYAL_BLUE:FlxColor =		0xff084c9e;
	public static inline var MEDIUM_BLUE:FlxColor =		0xff0000cd;
	public static inline var AZURE:FlxColor =			0xff007fff;
	public static inline var CYAN:FlxColor =			0xff00ffff;
	public static inline var MAGENTA:FlxColor =			0xffff00ff;
	public static inline var AQUAMARINE:FlxColor =		0xff7fffd4;
	public static inline var TEAL:FlxColor =			0xff008080;
	public static inline var FOREST_GREEN:FlxColor =	0xff228b22;
	public static inline var OLIVE:FlxColor =			0xff808000;
	public static inline var CHARTREUSE:FlxColor =		0xff7fff00;
	public static inline var LIME:FlxColor =			0xffbfff00;
	public static inline var GOLDEN:FlxColor =			0xffffd700;
	public static inline var GOLDENROD:FlxColor =		0xffdaa520;
	public static inline var CORAL:FlxColor =			0xffff7f50;
	public static inline var SALMON:FlxColor =			0xfffa8072;
	public static inline var HOT_PINK:FlxColor =		0xfffc0fc0;
	public static inline var FUCSHIA:FlxColor =			0xffff77ff;
	public static inline var PUCE:FlxColor =			0xffcc8899;
	public static inline var MAUVE:FlxColor =			0xffe0b0ff;
	public static inline var LAVENDER:FlxColor =		0xffb57edc;
	public static inline var PLUM:FlxColor =			0xff843179;
	public static inline var INDIGO:FlxColor =			0xff4b0082;
	public static inline var MAROON:FlxColor =			0xff800000;
	public static inline var CRIMSON:FlxColor =			0xffdc143c;
}
