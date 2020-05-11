package flixel.util;

import flixel.math.FlxMath;
import flixel.system.macros.FlxMacroUtil;

/**
 * Class representing a color, based on Int. Provides a variety of methods for creating and converting colors.
 *
 * FlxColors can be written as Ints. This means you can pass a hex value such as
 * 0xff123456 to a function expecting a FlxColor, and it will automatically become a FlxColor "object".
 * Similarly, FlxColors may be treated as Ints.
 *
 * Note that when using properties of a FlxColor other than ARGB, the values are ultimately stored as
 * ARGB values, so repeatedly manipulating HSB/HSL/CMYK values may result in a gradual loss of precision.
 *
 * @author Joe Williamson (JoeCreates)
 */
abstract FlxColor(Int) from Int from UInt to Int to UInt
{
	public static inline var TRANSPARENT:FlxColor = 0x00000000;
	public static inline var WHITE:FlxColor = 0xFFFFFFFF;
	public static inline var GRAY:FlxColor = 0xFF808080;
	public static inline var BLACK:FlxColor = 0xFF000000;

	public static inline var GREEN:FlxColor = 0xFF008000;
	public static inline var LIME:FlxColor = 0xFF00FF00;
	public static inline var YELLOW:FlxColor = 0xFFFFFF00;
	public static inline var ORANGE:FlxColor = 0xFFFFA500;
	public static inline var RED:FlxColor = 0xFFFF0000;
	public static inline var PURPLE:FlxColor = 0xFF800080;
	public static inline var BLUE:FlxColor = 0xFF0000FF;
	public static inline var BROWN:FlxColor = 0xFF8B4513;
	public static inline var PINK:FlxColor = 0xFFFFC0CB;
	public static inline var MAGENTA:FlxColor = 0xFFFF00FF;
	public static inline var CYAN:FlxColor = 0xFF00FFFF;

	/**
	 * A `Map<String, Int>` whose values are the static colors of `FlxColor`.
	 * You can add more colors for `FlxColor.fromString(String)` if you need.
	 */
	public static var colorLookup(default, null):Map<String, Int> = FlxMacroUtil.buildMap("flixel.util.FlxColor");

	public var red(get, set):Int;
	public var blue(get, set):Int;
	public var green(get, set):Int;
	public var alpha(get, set):Int;

	public var redFloat(get, set):Float;
	public var blueFloat(get, set):Float;
	public var greenFloat(get, set):Float;
	public var alphaFloat(get, set):Float;

	public var cyan(get, set):Float;
	public var magenta(get, set):Float;
	public var yellow(get, set):Float;
	public var black(get, set):Float;

	/** 
	 * The hue of the color in degrees (from 0 to 359)
	 */
	public var hue(get, set):Float;

	/**
	 * The saturation of the color (from 0 to 1)
	 */
	public var saturation(get, set):Float;

	/**
	 * The brightness (aka value) of the color (from 0 to 1)
	 */
	public var brightness(get, set):Float;

	/**
	 * The lightness of the color (from 0 to 1)
	 */
	public var lightness(get, set):Float;

	static var COLOR_REGEX = ~/^(0x|#)(([A-F0-9]{2}){3,4})$/i;

	/**
	 * Create a color from the least significant four bytes of an Int
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
	 * @param Alpha	How opaque the color should be, from 0 to 255
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
	 * @param Alpha	How opaque the color should be, from 0 to 1
	 * @return The color as a FlxColor
	 */
	public static inline function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setRGBFloat(Red, Green, Blue, Alpha);
	}

	/**
	 * Generate a color from CMYK values (0 to 1)
	 *
	 * @param Cyan		The cyan value of the color from 0 to 1
	 * @param Magenta	The magenta value of the color from 0 to 1
	 * @param Yellow	The yellow value of the color from 0 to 1
	 * @param Black		The black value of the color from 0 to 1
	 * @param Alpha		How opaque the color should be, from 0 to 1
	 * @return The color as a FlxColor
	 */
	public static inline function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):FlxColor
	{
		var color = new FlxColor();
		return color.setCMYK(Cyan, Magenta, Yellow, Black, Alpha);
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
	 * Parses a `String` and returns a `FlxColor` or `null` if the `String` couldn't be parsed.
	 *
	 * Examples (input -> output in hex):
	 *
	 * - `0x00FF00`    -> `0xFF00FF00`
	 * - `0xAA4578C2`  -> `0xAA4578C2`
	 * - `#0000FF`     -> `0xFF0000FF`
	 * - `#3F000011`   -> `0x3F000011`
	 * - `GRAY`        -> `0xFF808080`
	 * - `blue`        -> `0xFF0000FF`
	 *
	 * @param	str 	The string to be parsed
	 * @return	A `FlxColor` or `null` if the `String` couldn't be parsed
	 */
	public static function fromString(str:String):Null<FlxColor>
	{
		var result:Null<FlxColor> = null;
		str = StringTools.trim(str);

		if (COLOR_REGEX.match(str))
		{
			var hexColor:String = "0x" + COLOR_REGEX.matched(2);
			result = new FlxColor(Std.parseInt(hexColor));
			if (hexColor.length == 8)
			{
				result.alphaFloat = 1;
			}
		}
		else
		{
			str = str.toUpperCase();
			for (key in colorLookup.keys())
			{
				if (key.toUpperCase() == str)
				{
					result = new FlxColor(colorLookup.get(key));
					break;
				}
			}
		}

		return result;
	}

	/**
	 * Get HSB color wheel values in an array which will be 360 elements in size
	 *
	 * @param	Alpha Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * @return	HSB color wheel as Array of FlxColors
	 */
	public static function getHSBColorWheel(Alpha:Int = 255):Array<FlxColor>
	{
		return [for (c in 0...360) fromHSB(c, 1.0, 1.0, Alpha)];
	}

	/**
	 * Get an interpolated color based on two different colors.
	 *
	 * @param 	Color1 The first color
	 * @param 	Color2 The second color
	 * @param 	Factor Value from 0 to 1 representing how much to shift Color1 toward Color2
	 * @return	The interpolated color
	 */
	public static inline function interpolate(Color1:FlxColor, Color2:FlxColor, Factor:Float = 0.5):FlxColor
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
			Ease = function(t:Float):Float
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
	 * Multiply the RGB channels of two FlxColors
	 */
	@:op(A * B)
	public static inline function multiply(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGBFloat(lhs.redFloat * rhs.redFloat, lhs.greenFloat * rhs.greenFloat, lhs.blueFloat * rhs.blueFloat);
	}

	/**
	 * Add the RGB channels of two FlxColors
	 */
	@:op(A + B)
	public static inline function add(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGB(lhs.red + rhs.red, lhs.green + rhs.green, lhs.blue + rhs.blue);
	}

	/**
	 * Subtract the RGB channels of one FlxColor from another
	 */
	@:op(A - B)
	public static inline function subtract(lhs:FlxColor, rhs:FlxColor):FlxColor
	{
		return FlxColor.fromRGB(lhs.red - rhs.red, lhs.green - rhs.green, lhs.blue - rhs.blue);
	}

	/**
	 * Returns a Complementary Color Harmony of this color.
	 * A complementary hue is one directly opposite the color given on the color wheel
	 *
	 * @return	The complimentary color
	 */
	public inline function getComplementHarmony():FlxColor
	{
		return fromHSB(FlxMath.wrap(Std.int(hue) + 180, 0, 350), brightness, saturation, alphaFloat);
	}

	/**
	 * Returns an Analogous Color Harmony for the given color.
	 * An Analogous harmony are hues adjacent to each other on the color wheel
	 *
	 * @param	Threshold Control how adjacent the colors will be (default +- 30 degrees)
	 * @return 	Object containing 3 properties: original (the original color), warmer (the warmer analogous color) and colder (the colder analogous color)
	 */
	public inline function getAnalogousHarmony(Threshold:Int = 30):Harmony
	{
		var warmer:Int = fromHSB(FlxMath.wrap(Std.int(hue) - Threshold, 0, 350), saturation, brightness, alphaFloat);
		var colder:Int = fromHSB(FlxMath.wrap(Std.int(hue) + Threshold, 0, 350), saturation, brightness, alphaFloat);

		return {original: this, warmer: warmer, colder: colder};
	}

	/**
	 * Returns an Split Complement Color Harmony for this color.
	 * A Split Complement harmony are the two hues on either side of the color's Complement
	 *
	 * @param	Threshold Control how adjacent the colors will be to the Complement (default +- 30 degrees)
	 * @return 	Object containing 3 properties: original (the original color), warmer (the warmer analogous color) and colder (the colder analogous color)
	 */
	public inline function getSplitComplementHarmony(Threshold:Int = 30):Harmony
	{
		var oppositeHue:Int = FlxMath.wrap(Std.int(hue) + 180, 0, 350);
		var warmer:FlxColor = fromHSB(FlxMath.wrap(oppositeHue - Threshold, 0, 350), saturation, brightness, alphaFloat);
		var colder:FlxColor = fromHSB(FlxMath.wrap(oppositeHue + Threshold, 0, 350), saturation, brightness, alphaFloat);

		return {original: this, warmer: warmer, colder: colder};
	}

	/**
	 * Returns a Triadic Color Harmony for this color. A Triadic harmony are 3 hues equidistant
	 * from each other on the color wheel.
	 *
	 * @return 	Object containing 3 properties: color1 (the original color), color2 and color3 (the equidistant colors)
	 */
	public inline function getTriadicHarmony():TriadicHarmony
	{
		var triadic1:FlxColor = fromHSB(FlxMath.wrap(Std.int(hue) + 120, 0, 359), saturation, brightness, alphaFloat);
		var triadic2:FlxColor = fromHSB(FlxMath.wrap(Std.int(triadic1.hue) + 120, 0, 359), saturation, brightness, alphaFloat);

		return {color1: this, color2: triadic1, color3: triadic2};
	}

	/**
	 * Return a 24 bit version of this color (i.e. without an alpha value)
	 *
	 * @return A 24 bit version of this color
	 */
	public inline function to24Bit():FlxColor
	{
		return this & 0xffffff;
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
		return (Prefix ? "0x" : "") + (Alpha ? StringTools.hex(alpha,
			2) : "") + StringTools.hex(red, 2) + StringTools.hex(green, 2) + StringTools.hex(blue, 2);
	}

	/**
	 * Return a String representation of the color in the format #RRGGBB
	 *
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
		// Hex format
		var result:String = toHexString() + "\n";
		// RGB format
		result += "Alpha: " + alpha + " Red: " + red + " Green: " + green + " Blue: " + blue + "\n";
		// HSB/HSL info
		result += "Hue: " + FlxMath.roundDecimal(hue, 2) + " Saturation: " + FlxMath.roundDecimal(saturation, 2) + " Brightness: "
			+ FlxMath.roundDecimal(brightness, 2) + " Lightness: " + FlxMath.roundDecimal(lightness, 2);

		return result;
	}

	/**
	 * Get a darkened version of this color
	 *
	 * @param	Factor Value from 0 to 1 of how much to progress toward black.
	 * @return 	A darkened version of this color
	 */
	public function getDarkened(Factor:Float = 0.2):FlxColor
	{
		Factor = FlxMath.bound(Factor, 0, 1);
		var output:FlxColor = this;
		output.lightness = output.lightness * (1 - Factor);
		return output;
	}

	/**
	 * Get a lightened version of this color
	 *
	 * @param	Factor Value from 0 to 1 of how much to progress toward white.
	 * @return 	A lightened version of this color
	 */
	public inline function getLightened(Factor:Float = 0.2):FlxColor
	{
		Factor = FlxMath.bound(Factor, 0, 1);
		var output:FlxColor = this;
		output.lightness = output.lightness + (1 - lightness) * Factor;
		return output;
	}

	/**
	 * Get the inversion of this color
	 *
	 * @return The inversion of this color
	 */
	public inline function getInverted():FlxColor
	{
		var oldAlpha = alpha;
		var output:FlxColor = FlxColor.WHITE - this;
		output.alpha = oldAlpha;
		return output;
	}

	/**
	 * Set RGB values as integers (0 to 255)
	 *
	 * @param Red	The red value of the color from 0 to 255
	 * @param Green	The green value of the color from 0 to 255
	 * @param Blue	The green value of the color from 0 to 255
	 * @param Alpha	How opaque the color should be, from 0 to 255
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
	 * @param Alpha	How opaque the color should be, from 0 to 1
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
	 * Set CMYK values as floats (0 to 1)
	 *
	 * @param Cyan		The cyan value of the color from 0 to 1
	 * @param Magenta	The magenta value of the color from 0 to 1
	 * @param Yellow	The yellow value of the color from 0 to 1
	 * @param Black		The black value of the color from 0 to 1
	 * @param Alpha		How opaque the color should be, from 0 to 1
	 * @return This color
	 */
	public inline function setCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):FlxColor
	{
		redFloat = (1 - Cyan) * (1 - Black);
		greenFloat = (1 - Magenta) * (1 - Black);
		blueFloat = (1 - Yellow) * (1 - Black);
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
		var chroma = Brightness * Saturation;
		var match = Brightness - chroma;
		return setHSChromaMatch(Hue, Saturation, chroma, match, Alpha);
	}

	/**
	 * Set HSL components.
	 *
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Lightness	A number between 0 and 1, indicating the lightness of the color
	 * @param	Alpha		How opaque the color should be, either between 0 and 1 or 0 and 255
	 * @return	This color
	 */
	public inline function setHSL(Hue:Float, Saturation:Float, Lightness:Float, Alpha:Float):FlxColor
	{
		var chroma = (1 - Math.abs(2 * Lightness - 1)) * Saturation;
		var match = Lightness - chroma / 2;
		return setHSChromaMatch(Hue, Saturation, chroma, match, Alpha);
	}

	/**
	 * Private utility function to perform common operations between setHSB and setHSL
	 */
	inline function setHSChromaMatch(Hue:Float, Saturation:Float, Chroma:Float, Match:Float, Alpha:Float):FlxColor
	{
		Hue %= 360;
		var hueD = Hue / 60;
		var mid = Chroma * (1 - Math.abs(hueD % 2 - 1)) + Match;
		Chroma += Match;

		switch (Std.int(hueD))
		{
			case 0:
				setRGBFloat(Chroma, mid, Match, Alpha);
			case 1:
				setRGBFloat(mid, Chroma, Match, Alpha);
			case 2:
				setRGBFloat(Match, Chroma, mid, Alpha);
			case 3:
				setRGBFloat(Match, mid, Chroma, Alpha);
			case 4:
				setRGBFloat(mid, Match, Chroma, Alpha);
			case 5:
				setRGBFloat(Chroma, Match, mid, Alpha);
		}

		return this;
	}

	public function new(Value:Int = 0)
	{
		this = Value;
	}

	inline function getThis():Int
	{
		#if neko
		return Std.int(this);
		#else
		return this;
		#end
	}

	inline function validate():Void
	{
		#if neko
		this = Std.int(this);
		#end
	}

	inline function get_red():Int
	{
		return (getThis() >> 16) & 0xff;
	}

	inline function get_green():Int
	{
		return (getThis() >> 8) & 0xff;
	}

	inline function get_blue():Int
	{
		return getThis() & 0xff;
	}

	inline function get_alpha():Int
	{
		return (getThis() >> 24) & 0xff;
	}

	inline function get_redFloat():Float
	{
		return red / 255;
	}

	inline function get_greenFloat():Float
	{
		return green / 255;
	}

	inline function get_blueFloat():Float
	{
		return blue / 255;
	}

	inline function get_alphaFloat():Float
	{
		return alpha / 255;
	}

	inline function set_red(Value:Int):Int
	{
		validate();
		this &= 0xff00ffff;
		this |= boundChannel(Value) << 16;
		return Value;
	}

	inline function set_green(Value:Int):Int
	{
		validate();
		this &= 0xffff00ff;
		this |= boundChannel(Value) << 8;
		return Value;
	}

	inline function set_blue(Value:Int):Int
	{
		validate();
		this &= 0xffffff00;
		this |= boundChannel(Value);
		return Value;
	}

	inline function set_alpha(Value:Int):Int
	{
		validate();
		this &= 0x00ffffff;
		this |= boundChannel(Value) << 24;
		return Value;
	}

	inline function set_redFloat(Value:Float):Float
	{
		red = Math.round(Value * 255);
		return Value;
	}

	inline function set_greenFloat(Value:Float):Float
	{
		green = Math.round(Value * 255);
		return Value;
	}

	inline function set_blueFloat(Value:Float):Float
	{
		blue = Math.round(Value * 255);
		return Value;
	}

	inline function set_alphaFloat(Value:Float):Float
	{
		alpha = Math.round(Value * 255);
		return Value;
	}

	inline function get_cyan():Float
	{
		return (1 - redFloat - black) / brightness;
	}

	inline function get_magenta():Float
	{
		return (1 - greenFloat - black) / brightness;
	}

	inline function get_yellow():Float
	{
		return (1 - blueFloat - black) / brightness;
	}

	inline function get_black():Float
	{
		return 1 - brightness;
	}

	inline function set_cyan(Value:Float):Float
	{
		setCMYK(Value, magenta, yellow, black, alphaFloat);
		return Value;
	}

	inline function set_magenta(Value:Float):Float
	{
		setCMYK(cyan, Value, yellow, black, alphaFloat);
		return Value;
	}

	inline function set_yellow(Value:Float):Float
	{
		setCMYK(cyan, magenta, Value, black, alphaFloat);
		return Value;
	}

	inline function set_black(Value:Float):Float
	{
		setCMYK(cyan, magenta, yellow, Value, alphaFloat);
		return Value;
	}

	function get_hue():Float
	{
		var hueRad = Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
		var hue:Float = 0;
		if (hueRad != 0)
		{
			hue = 180 / Math.PI * Math.atan2(Math.sqrt(3) * (greenFloat - blueFloat), 2 * redFloat - greenFloat - blueFloat);
		}

		return hue < 0 ? hue + 360 : hue;
	}

	inline function get_brightness():Float
	{
		return maxColor();
	}

	inline function get_saturation():Float
	{
		return (maxColor() - minColor()) / brightness;
	}

	inline function get_lightness():Float
	{
		return (maxColor() + minColor()) / 2;
	}

	inline function set_hue(Value:Float):Float
	{
		setHSB(Value, saturation, brightness, alphaFloat);
		return Value;
	}

	inline function set_saturation(Value:Float):Float
	{
		setHSB(hue, Value, brightness, alphaFloat);
		return Value;
	}

	inline function set_brightness(Value:Float):Float
	{
		setHSB(hue, saturation, Value, alphaFloat);
		return Value;
	}

	inline function set_lightness(Value:Float):Float
	{
		setHSL(hue, saturation, Value, alphaFloat);
		return Value;
	}

	inline function maxColor():Float
	{
		return Math.max(redFloat, Math.max(greenFloat, blueFloat));
	}

	inline function minColor():Float
	{
		return Math.min(redFloat, Math.min(greenFloat, blueFloat));
	}

	inline function boundChannel(Value:Int):Int
	{
		return Value > 0xff ? 0xff : Value < 0 ? 0 : Value;
	}
}

typedef Harmony =
{
	original:FlxColor,
	warmer:FlxColor,
	colder:FlxColor
}

typedef TriadicHarmony =
{
	color1:FlxColor,
	color2:FlxColor,
	color3:FlxColor
}
