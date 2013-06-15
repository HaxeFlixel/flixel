/**
 * FlxColor
 * -- Part of the Flixel Power Tools set
 * 
 * v1.5 Added RGBtoWebString
 * v1.4 getHSVColorWheel now supports an alpha value per color
 * v1.3 Added getAlphaFloat
 * v1.2 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.5 - August 4th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 * @see Depends upon FlxPTMath
*/

package org.flixel.plugin.photonstorm;

import flash.errors.Error;
import org.flixel.FlxG;
import org.flixel.util.FlxColor;
import org.flixel.util.FlxMath;

/**
 * <code>FlxColor</code> is a set of fast color manipulation and color harmony methods.<br />
 * Can be used for creating gradient maps or general color translation / conversion.
 */
class FlxPTColor
{	
	/**
	 * Get HSV color wheel values in an array which will be 360 elements in size
	 * 
	 * @param	Alpha	Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * @return	HSV color wheel as Array of Ints
	 */
	static public function getHSVColorWheel(Alpha:Int = 255):Array<Int>
	{
		var colors:Array<Int> = new Array<Int>();
		
		for (c in 0...360)
		{
			colors[c] = HSVtoRGB(c, 1.0, 1.0, Alpha);
		}
		
		return colors;
	}
	
	/**
	 * Returns a Complementary Color Harmony for the given color.
	 * A complementary hue is one directly opposite the color given on the color wheel
	 * Value returned in 0xAARRGGBB format with Alpha set to 255.
	 * 
	 * @param	Color	The color to base the harmony on
	 * @return 0xAARRGGBB format color value
	 */
	inline static public function getComplementHarmony(Color:Int):Int
	{
		var hsv:HSV = RGBtoHSV(Color);
		
		var opposite:Int = FlxMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		return HSVtoRGB(opposite, 1.0, 1.0);
	}
	
	/**
	 * Returns an Analogous Color Harmony for the given color.
	 * An Analogous harmony are hues adjacent to each other on the color wheel
	 * Values returned in 0xAARRGGBB format with Alpha set to 255.
	 * 
	 * @param	color The color to base the harmony on
	 * @param	threshold Control how adjacent the colors will be (default +- 30 degrees)
	 * @return 	Object containing 3 properties: color1 (the original color), color2 (the warmer analogous color) and color3 (the colder analogous color)
	 */
	static public function getAnalogousHarmony(Color:Int, Threshold:Int = 30):Harmony
	{
		var hsv:HSV = RGBtoHSV(Color);
		
		if (Threshold > 359 || Threshold < 0)
		{
			FlxG.warn("FlxColor Warning: Invalid threshold given to getAnalogousHarmony()");
		}
		
		var warmer:Int = FlxMath.wrapValue(Std.int(hsv.hue), 359 - Threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hsv.hue), Threshold, 359);
		
		return { color1: Color, color2: HSVtoRGB(warmer, 1.0, 1.0), color3: HSVtoRGB(colder, 1.0, 1.0), hue1: Std.int(hsv.hue), hue2: warmer, hue3: colder };
	}
	
	/**
	 * Returns an Split Complement Color Harmony for the given color.
	 * A Split Complement harmony are the two hues on either side of the color's Complement
	 * Values returned in 0xAARRGGBB format with Alpha set to 255.
	 * 
	 * @param	Color 		The color to base the harmony on
	 * @param	Threshold 	Control how adjacent the colors will be to the Complement (default +- 30 degrees)
	 * @return 	Object containing 3 properties: color1 (the original color), color2 (the warmer analogous color) and color3 (the colder analogous color)
	 */
	static public function getSplitComplementHarmony(Color:Int, Threshold:Int = 30):Harmony
	{
		var hsv:HSV = RGBtoHSV(Color);
		
		if (Threshold >= 359 || Threshold <= 0)
		{
			FlxG.warn("FlxColor: Invalid threshold given to getSplitComplementHarmony()");
		}
		
		var opposite:Int = FlxMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		var warmer:Int = FlxMath.wrapValue(Std.int(hsv.hue), opposite - Threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hsv.hue), opposite + Threshold, 359);
		
		FlxG.notice("hue: " + hsv.hue + " opposite: " + opposite + " warmer: " + warmer + " colder: " + colder);
		
		//return { color1: color, color2: HSVtoRGB(warmer, 1.0, 1.0), color3: HSVtoRGB(colder, 1.0, 1.0), hue1: hsv.hue, hue2: warmer, hue3: colder }
		
		return { color1: Color, color2: HSVtoRGB(warmer, hsv.saturation, hsv.value), color3: HSVtoRGB(colder, hsv.saturation, hsv.value), hue1: Std.int(hsv.hue), hue2: warmer, hue3: colder };
	}
	
	/**
	 * Returns a Triadic Color Harmony for the given color.
	 * A Triadic harmony are 3 hues equidistant from each other on the color wheel
	 * Values returned in 0xAARRGGBB format with Alpha set to 255.
	 * 
	 * @param	Color 	The color to base the harmony on
	 * @return 	Object containing 3 properties: color1 (the original color), color2 and color3 (the equidistant colors)
	 */
	inline static public function getTriadicHarmony(Color:Int):TriadicHarmony
	{
		var hsv:HSV = RGBtoHSV(Color);
		
		var triadic1:Int = FlxMath.wrapValue(Std.int(hsv.hue), 120, 359);
		var triadic2:Int = FlxMath.wrapValue(triadic1, 120, 359);
		
		return { color1: Color, color2: HSVtoRGB(triadic1, 1.0, 1.0), color3: HSVtoRGB(triadic2, 1.0, 1.0) };
	}
	
	/**
	 * Returns a String containing handy information about the given color including String hex value,
	 * RGB format information and HSL information. Each section starts on a newline, 3 lines in total.
	 * 
	 * @param	Color 	A color value in the format 0xAARRGGBB
	 * @return	String containing the 3 lines of information
	 */
	inline static public function getColorInfo(Color:Int):String
	{
		var argb:RGBA = getRGB(Color);
		var hsl:HSV = RGBtoHSV(Color);
		
		//	Hex format
		var result:String = RGBtoHexString(Color) + "\n";
		
		//	RGB format
		result += "Alpha: " + argb.alpha + " Red: " + argb.red + " Green: " + argb.green + " Blue: " + argb.blue + "\n";
		
		//	HSL info
		result += "Hue: " + hsl.hue + " Saturation: " + hsl.saturation + " Lightnes: " + hsl.lightness;
		
		return result;
	}
	
	/**
	 * Return a String representation of the color in the format 0xAARRGGBB
	 * 
	 * @param	Color 	The color to get the String representation for
	 * @return	A string of length 10 characters in the format 0xAARRGGBB
	 */
	inline static public function RGBtoHexString(Color:Int):String
	{
		var argb:RGBA = getRGB(Color);
		
		return "0x" + colorToHexString(argb.alpha) + colorToHexString(argb.red) + colorToHexString(argb.green) + colorToHexString(argb.blue);
	}
	
	/**
	 * Return a String representation of the color in the format #RRGGBB
	 * 
	 * @param	Color 	The color to get the String representation for
	 * @return	A string of length 10 characters in the format 0xAARRGGBB
	 */
	inline static public function RGBtoWebString(Color:Int):String
	{
		var argb:RGBA = getRGB(Color);
		
		return "#" + colorToHexString(argb.red) + colorToHexString(argb.green) + colorToHexString(argb.blue);
	}

	/**
	 * Return a String containing a hex representation of the given color
	 * 
	 * @param	Color	The color channel to get the hex value for, must be a value between 0 and 255)
	 * @return	A string of length 2 characters, i.e. 255 = FF, 0 = 00
	 */
	inline static public function colorToHexString(Color:Int):String
	{
		var digits:String = "0123456789ABCDEF";
		
		var lsd:Float = Color % 16;
		var msd:Float = (Color - lsd) / 16;
		
		return digits.charAt(Std.int(msd)) + digits.charAt(Std.int(lsd));
	}
	
	/**
	 * Convert a HSV (hue, saturation, lightness) color space value to an RGB color
	 * 
	 * @param	H 		Hue degree, between 0 and 359
	 * @param	S 		Saturation, between 0.0 (grey) and 1.0
	 * @param	V 		Value, between 0.0 (black) and 1.0
	 * @param	Alpha	Alpha value to set per color (between 0 and 255)
	 * @return 32-bit ARGB color value (0xAARRGGBB)
	 */
	static public function HSVtoRGB(H:Float, S:Float, V:Float, Alpha:Int = 255):Int
	{
		var result = FlxColor.TRANSPARENT;
		
		if (S == 0.0)
		{
			result = FlxColor.getColor32(Alpha, Std.int(V * 255), Std.int(V * 255), Std.int(V * 255));
		}
		else
		{
			H = H / 60.0;
			var f:Float = H - Std.int(H);
			var p:Float = V * (1.0 - S);
			var q:Float = V * (1.0 - S * f);
			var t:Float = V * (1.0 - S * (1.0 - f));
			
			switch (Std.int(H))
			{
				case 0:
					result = FlxColor.getColor32(Alpha, Std.int(V * 255), Std.int(t * 255), Std.int(p * 255));
				case 1:
					result = FlxColor.getColor32(Alpha, Std.int(q * 255), Std.int(V * 255), Std.int(p * 255));
				case 2:
					result = FlxColor.getColor32(Alpha, Std.int(p * 255), Std.int(V * 255), Std.int(t * 255));
				case 3:
					result = FlxColor.getColor32(Alpha, Std.int(p * 255), Std.int(q * 255), Std.int(V * 255));
				case 4:
					result = FlxColor.getColor32(Alpha, Std.int(t * 255), Std.int(p * 255), Std.int(V * 255));
				case 5:
					result = FlxColor.getColor32(Alpha, Std.int(V * 255), Std.int(p * 255), Std.int(q * 255));
				default:
					FlxG.warn("FlxColor: HSVtoRGB: Unknown color");
			}
		}
		
		return result;
	}
	
	/**
	 * Convert an RGB color value to an object containing the HSV color space values: Hue, Saturation and Lightness
	 * 
	 * @param	Color 	In format 0xRRGGBB
	 * @return 	Object with the properties hue (from 0 to 360), saturation (from 0 to 1.0) and lightness (from 0 to 1.0, also available under .value)
	 */
	static public function RGBtoHSV(Color:Int):HSV
	{
		var rgb:RGBA = getRGB(Color);
		
		var red:Float = rgb.red / 255;
		var green:Float = rgb.green / 255;
		var blue:Float = rgb.blue / 255;
		
		var min:Float = Math.min(red, Math.min(green, blue));
		var max:Float = Math.max(red, Math.max(green, blue));
		var delta:Float = max - min;
		var lightness:Float = (max + min) / 2;
		var hue:Float = 0;
		var saturation:Float;
		
		//  Grey color, no chroma
		if (delta == 0)
		{
			hue = 0;
			saturation = 0;
		}
		else
		{
			if (lightness < 0.5)
			{
				saturation = delta / (max + min);
			}
			else
			{
				saturation = delta / (2 - max - min);
			}
			
			var delta_r:Float = (((max - red) / 6) + (delta / 2)) / delta;
			var delta_g:Float = (((max - green) / 6) + (delta / 2)) / delta;
			var delta_b:Float = (((max - blue) / 6) + (delta / 2)) / delta;
			
			if (red == max)
			{
				hue = delta_b - delta_g;
			}
			else if (green == max)
			{
				hue = (1 / 3) + delta_r - delta_b;
			}
			else if (blue == max)
			{
				hue = (2 / 3) + delta_g - delta_r;
			}
			
			if (hue < 0)
			{
				hue += 1;
			}
			
			if (hue > 1)
			{
				hue -= 1;
			}
		}
		
		//	Keep the value with 0 to 359
		hue *= 360;
		hue = Math.round(hue);
		
		//	Testing
		//saturation *= 100;
		//lightness *= 100;
		
		return { hue: hue, saturation: saturation, lightness: lightness, value: lightness };
	}
	
	inline static public function interpolateColor(Color1:Int, Color2:Int, Steps:Int, CurrentStep:Int, Alpha:Int = 255):Int
	{
		var src1:RGBA = getRGB(Color1);
		var src2:RGBA = getRGB(Color2);
		
		var r:Int = Std.int((((src2.red - src1.red) * CurrentStep) / Steps) + src1.red);
		var g:Int = Std.int((((src2.green - src1.green) * CurrentStep) / Steps) + src1.green);
		var b:Int = Std.int((((src2.blue - src1.blue) * CurrentStep) / Steps) + src1.blue);

		return FlxColor.getColor32(Alpha, r, g, b);
	}
	
	inline static public function interpolateColorWithRGB(Color:Int, R2:Int, G2:Int, B2:Int, Steps:Int, CurrentStep:Int):Int
	{
		var src:RGBA = getRGB(Color);
		
		var r:Int = Std.int((((R2 - src.red) * CurrentStep) / Steps) + src.red);
		var g:Int = Std.int((((G2 - src.green) * CurrentStep) / Steps) + src.green);
		var b:Int = Std.int((((B2 - src.blue) * CurrentStep) / Steps) + src.blue);
	
		return FlxColor.getColor24(r, g, b);
	}
	
	inline static public function interpolateRGB(R1:Int, G1:Int, B1:Int, R2:Int, G2:Int, B2:Int, Steps:Int, CurrentStep:Int):Int
	{
		var r:Int = Std.int((((R2 - R1) * CurrentStep) / Steps) + R1);
		var g:Int = Std.int((((G2 - G1) * CurrentStep) / Steps) + G1);
		var b:Int = Std.int((((B2 - B1) * CurrentStep) / Steps) + B1);
		
		return FlxColor.getColor24(r, g, b);
	}
	
	/**
	 * Return the component parts of a color as an Object with the properties alpha, red, green, blue
	 * Alpha will only be set if it exist in the given color (0xAARRGGBB)
	 * 
	 * @param	color in RGB (0xRRGGBB) or ARGB format (0xAARRGGBB)
	 * @return Object with properties: alpha, red, green, blue
	 */
	inline static public function getRGB(Color:Int):RGBA
	{
		//var alpha:Int = Color >>> 24;
		var alpha:Int = (Color >> 24) & 0xFF;
		var red:Int = Color >> 16 & 0xFF;
		var green:Int = Color >> 8 & 0xFF;
		var blue:Int = Color & 0xFF;
		
		return { alpha: alpha, red: red, green: green, blue: blue };
	}
}

typedef HSV = {
    var hue:Float;
    var saturation:Float;
    var lightness:Float;
    var value:Float;
}

typedef RGBA = {
    var alpha:Int;
    var red:Int;
    var green:Int;
    var blue:Int;
}

typedef Harmony = {
	var color1:Int;
    var color2:Int;
    var color3:Int;
	var hue1:Int;
    var hue2:Int;
    var hue3:Int;
}

typedef TriadicHarmony = {
	var color1:Int;
    var color2:Int;
    var color3:Int;
}