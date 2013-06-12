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

/**
 * <code>FlxColor</code> is a set of fast color manipulation and color harmony methods.<br />
 * Can be used for creating gradient maps or general color translation / conversion.
 */
class FlxPTColor
{	
	/**
	 * Get HSV color wheel values in an array which will be 360 elements in size
	 * 
	 * @param	alpha	Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * 
	 * @return	Array
	 */
	static public function getHSVColorWheel(alpha:Int = 255):Array<Int>
	{
		var colors:Array<Int> = new Array<Int>();
		
		for (c in 0...360)
		{
			colors[c] = HSVtoRGB(c, 1.0, 1.0, alpha);
		}
		
		return colors;
	}
	
	/**
	 * Returns a Complementary Color Harmony for the given color.
	 * <p>A complementary hue is one directly opposite the color given on the color wheel</p>
	 * <p>Value returned in 0xAARRGGBB format with Alpha set to 255.</p>
	 * 
	 * @param	color The color to base the harmony on
	 * 
	 * @return 0xAARRGGBB format color value
	 */
	static public function getComplementHarmony(color:Int):Int
	{
		var hsv:HSV = RGBtoHSV(color);
		
		var opposite:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		return HSVtoRGB(opposite, 1.0, 1.0);
	}
	
	/**
	 * Returns an Analogous Color Harmony for the given color.
	 * <p>An Analogous harmony are hues adjacent to each other on the color wheel</p>
	 * <p>Values returned in 0xAARRGGBB format with Alpha set to 255.</p>
	 * 
	 * @param	color The color to base the harmony on
	 * @param	threshold Control how adjacent the colors will be (default +- 30 degrees)
	 * 
	 * @return 	Object containing 3 properties: color1 (the original color), color2 (the warmer analogous color) and color3 (the colder analogous color)
	 */
	static public function getAnalogousHarmony(color:Int, threshold:Int = 30):Harmony
	{
		var hsv:HSV = RGBtoHSV(color);
		
		if (threshold > 359 || threshold < 0)
		{
			throw "FlxColor Warning: Invalid threshold given to getAnalogousHarmony()";
		}
		
		var warmer:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), 359 - threshold, 359);
		var colder:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), threshold, 359);
		
		return { color1: color, color2: HSVtoRGB(warmer, 1.0, 1.0), color3: HSVtoRGB(colder, 1.0, 1.0), hue1: Std.int(hsv.hue), hue2: warmer, hue3: colder };
	}
	
	/**
	 * Returns an Split Complement Color Harmony for the given color.
	 * <p>A Split Complement harmony are the two hues on either side of the color's Complement</p>
	 * <p>Values returned in 0xAARRGGBB format with Alpha set to 255.</p>
	 * 
	 * @param	color The color to base the harmony on
	 * @param	threshold Control how adjacent the colors will be to the Complement (default +- 30 degrees)
	 * 
	 * @return 	Object containing 3 properties: color1 (the original color), color2 (the warmer analogous color) and color3 (the colder analogous color)
	 */
	static public function getSplitComplementHarmony(color:Int, threshold:Int = 30):Harmony
	{
		var hsv:HSV = RGBtoHSV(color);
		
		if (threshold >= 359 || threshold <= 0)
		{
			throw "FlxColor Warning: Invalid threshold given to getSplitComplementHarmony()";
		}
		
		var opposite:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		var warmer:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), opposite - threshold, 359);
		var colder:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), opposite + threshold, 359);
		
		FlxG.notice("hue: " + hsv.hue + " opposite: " + opposite + " warmer: " + warmer + " colder: " + colder);
		
		//return { color1: color, color2: HSVtoRGB(warmer, 1.0, 1.0), color3: HSVtoRGB(colder, 1.0, 1.0), hue1: hsv.hue, hue2: warmer, hue3: colder }
		
		return { color1: color, color2: HSVtoRGB(warmer, hsv.saturation, hsv.value), color3: HSVtoRGB(colder, hsv.saturation, hsv.value), hue1: Std.int(hsv.hue), hue2: warmer, hue3: colder };
	}
	
	/**
	 * Returns a Triadic Color Harmony for the given color.
	 * <p>A Triadic harmony are 3 hues equidistant from each other on the color wheel</p>
	 * <p>Values returned in 0xAARRGGBB format with Alpha set to 255.</p>
	 * 
	 * @param	color The color to base the harmony on
	 * 
	 * @return 	Object containing 3 properties: color1 (the original color), color2 and color3 (the equidistant colors)
	 */
	static public function getTriadicHarmony(color:Int):TriadicHarmony
	{
		var hsv:HSV = RGBtoHSV(color);
		
		var triadic1:Int = FlxPTMath.wrapValue(Std.int(hsv.hue), 120, 359);
		var triadic2:Int = FlxPTMath.wrapValue(triadic1, 120, 359);
		
		return { color1: color, color2: HSVtoRGB(triadic1, 1.0, 1.0), color3: HSVtoRGB(triadic2, 1.0, 1.0) };
	}
	
	/**
	 * Returns a String containing handy information about the given color including String hex value,
	 * RGB format information and HSL information. Each section starts on a newline, 3 lines in total.
	 * 
	 * @param	color A color value in the format 0xAARRGGBB
	 * 
	 * @return	String containing the 3 lines of information
	 */
	static public function getColorInfo(color:Int):String
	{
		var argb:RGBA = getRGB(color);
		var hsl:HSV = RGBtoHSV(color);
		
		//	Hex format
		var result:String = RGBtoHexString(color) + "\n";
		
		//	RGB format
		result += "Alpha: " + argb.alpha + " Red: " + argb.red + " Green: " + argb.green + " Blue: " + argb.blue + "\n";
		
		//	HSL info
		result += "Hue: " + hsl.hue + " Saturation: " + hsl.saturation + " Lightnes: " + hsl.lightness;
		
		return result;
	}
	
	/**
	 * Return a String representation of the color in the format 0xAARRGGBB
	 * 
	 * @param	color The color to get the String representation for
	 * 
	 * @return	A string of length 10 characters in the format 0xAARRGGBB
	 */
	static public function RGBtoHexString(color:Int):String
	{
		var argb:RGBA = getRGB(color);
		
		return "0x" + colorToHexString(argb.alpha) + colorToHexString(argb.red) + colorToHexString(argb.green) + colorToHexString(argb.blue);
	}
	
	/**
	 * Return a String representation of the color in the format #RRGGBB
	 * 
	 * @param	color The color to get the String representation for
	 * 
	 * @return	A string of length 10 characters in the format 0xAARRGGBB
	 */
	static public function RGBtoWebString(color:Int):String
	{
		var argb:RGBA = getRGB(color);
		
		return "#" + colorToHexString(argb.red) + colorToHexString(argb.green) + colorToHexString(argb.blue);
	}

	/**
	 * Return a String containing a hex representation of the given color
	 * 
	 * @param	color The color channel to get the hex value for, must be a value between 0 and 255)
	 * 
	 * @return	A string of length 2 characters, i.e. 255 = FF, 0 = 00
	 */
	static public function colorToHexString(color:Int):String
	{
		var digits:String = "0123456789ABCDEF";
		
		var lsd:Float = color % 16;
		var msd:Float = (color - lsd) / 16;
		
		var hexified:String = digits.charAt(Std.int(msd)) + digits.charAt(Std.int(lsd));
		
		return hexified;
	}
	
	/**
	 * Convert a HSV (hue, saturation, lightness) color space value to an RGB color
	 * 
	 * @param	h 		Hue degree, between 0 and 359
	 * @param	s 		Saturation, between 0.0 (grey) and 1.0
	 * @param	v 		Value, between 0.0 (black) and 1.0
	 * @param	alpha	Alpha value to set per color (between 0 and 255)
	 * 
	 * @return 32-bit ARGB color value (0xAARRGGBB)
	 */
	static public function HSVtoRGB(h:Float, s:Float, v:Float, alpha:Int = 255):Int
	{
		var result = FlxColor.TRANSPARENT;
		
		if (s == 0.0)
		{
			result = FlxColor.getColor32(alpha, Std.int(v * 255), Std.int(v * 255), Std.int(v * 255));
		}
		else
		{
			h = h / 60.0;
			var f:Float = h - Std.int(h);
			var p:Float = v * (1.0 - s);
			var q:Float = v * (1.0 - s * f);
			var t:Float = v * (1.0 - s * (1.0 - f));
			
			switch (Std.int(h))
			{
				case 0:
					result = FlxColor.getColor32(alpha, Std.int(v * 255), Std.int(t * 255), Std.int(p * 255));
					
				case 1:
					result = FlxColor.getColor32(alpha, Std.int(q * 255), Std.int(v * 255), Std.int(p * 255));
					
				case 2:
					result = FlxColor.getColor32(alpha, Std.int(p * 255), Std.int(v * 255), Std.int(t * 255));
					
				case 3:
					result = FlxColor.getColor32(alpha, Std.int(p * 255), Std.int(q * 255), Std.int(v * 255));
					
				case 4:
					result = FlxColor.getColor32(alpha, Std.int(t * 255), Std.int(p * 255), Std.int(v * 255));
					
				case 5:
					result = FlxColor.getColor32(alpha, Std.int(v * 255), Std.int(p * 255), Std.int(q * 255));
					
				default:
					FlxG.error("FlxColor: HSVtoRGB : Unknown color");
			}
		}
		
		return result;
	}
	
	/**
	 * Convert an RGB color value to an object containing the HSV color space values: Hue, Saturation and Lightness
	 * 
	 * @param	color In format 0xRRGGBB
	 * 
	 * @return 	Object with the properties hue (from 0 to 360), saturation (from 0 to 1.0) and lightness (from 0 to 1.0, also available under .value)
	 */
	static public function RGBtoHSV(color:Int):HSV
	{
		var rgb:RGBA = getRGB(color);
		
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
	
	static public function interpolateColor(color1:Int, color2:Int, steps:Int, currentStep:Int, alpha:Int = 255):Int
	{
		var src1:RGBA = getRGB(color1);
		var src2:RGBA = getRGB(color2);
		
		var r:Int = Std.int((((src2.red - src1.red) * currentStep) / steps) + src1.red);
		var g:Int = Std.int((((src2.green - src1.green) * currentStep) / steps) + src1.green);
		var b:Int = Std.int((((src2.blue - src1.blue) * currentStep) / steps) + src1.blue);

		return FlxColor.getColor32(alpha, r, g, b);
	}
	
	static public function interpolateColorWithRGB(color:Int, r2:Int, g2:Int, b2:Int, steps:Int, currentStep:Int):Int
	{
		var src:RGBA = getRGB(color);
		
		var r:Int = Std.int((((r2 - src.red) * currentStep) / steps) + src.red);
		var g:Int = Std.int((((g2 - src.green) * currentStep) / steps) + src.green);
		var b:Int = Std.int((((b2 - src.blue) * currentStep) / steps) + src.blue);
	
		return FlxColor.getColor24(r, g, b);
	}
	
	static public function interpolateRGB(r1:Int, g1:Int, b1:Int, r2:Int, g2:Int, b2:Int, steps:Int, currentStep:Int):Int
	{
		var r:Int = Std.int((((r2 - r1) * currentStep) / steps) + r1);
		var g:Int = Std.int((((g2 - g1) * currentStep) / steps) + g1);
		var b:Int = Std.int((((b2 - b1) * currentStep) / steps) + b1);
	
		return FlxColor.getColor24(r, g, b);
	}
	
	/**
	 * Return the component parts of a color as an Object with the properties alpha, red, green, blue
	 * 
	 * <p>Alpha will only be set if it exist in the given color (0xAARRGGBB)</p>
	 * 
	 * @param	color in RGB (0xRRGGBB) or ARGB format (0xAARRGGBB)
	 * 
	 * @return Object with properties: alpha, red, green, blue
	 */
	static public function getRGB(color:Int):RGBA
	{
		//var alpha:Int = color >>> 24;
		var alpha:Int = (color >> 24) & 0xFF;
		var red:Int = color >> 16 & 0xFF;
		var green:Int = color >> 8 & 0xFF;
		var blue:Int = color & 0xFF;
		
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