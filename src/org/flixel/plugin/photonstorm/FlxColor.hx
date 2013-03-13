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
 * @see Depends upon FlxMath
*/

package org.flixel.plugin.photonstorm;

import flash.errors.Error;
import nme.display.BitmapInt32;
import org.flixel.FlxG;


/**
 * <code>FlxColor</code> is a set of fast color manipulation and color harmony methods.<br />
 * Can be used for creating gradient maps or general color translation / conversion.
 */
class FlxColor
{
	public function new() {  }
	
	/**
	 * Get HSV color wheel values in an array which will be 360 elements in size
	 * 
	 * @param	alpha	Alpha value for each color of the color wheel, between 0 (transparent) and 255 (opaque)
	 * 
	 * @return	Array
	 */
	#if flash
	public static function getHSVColorWheel(alpha:UInt = 255):Array<UInt>
	#else
	public static function getHSVColorWheel(alpha:Int = 255):Array<BitmapInt32>
	#end
	{
		#if flash
		var colors:Array<UInt> = new Array<UInt>();
		#else
		var colors:Array<BitmapInt32> = new Array<BitmapInt32>();
		#end
		
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
	#if flash
	public static function getComplementHarmony(color:UInt):UInt
	#else
	public static function getComplementHarmony(color:BitmapInt32):BitmapInt32
	#end
	{
		var hsv:HSV = RGBtoHSV(color);
		
		var opposite:Int = FlxMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
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
	#if flash
	public static function getAnalogousHarmony(color:UInt, threshold:Int = 30):Harmony
	#else
	public static function getAnalogousHarmony(color:BitmapInt32, threshold:Int = 30):Harmony
	#end
	{
		var hsv:HSV = RGBtoHSV(color);
		
		if (threshold > 359 || threshold < 0)
		{
			throw "FlxColor Warning: Invalid threshold given to getAnalogousHarmony()";
		}
		
		var warmer:Int = FlxMath.wrapValue(Std.int(hsv.hue), 359 - threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hsv.hue), threshold, 359);
		
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
	#if flash
	public static function getSplitComplementHarmony(color:UInt, threshold:Int = 30):Harmony
	#else
	public static function getSplitComplementHarmony(color:BitmapInt32, threshold:Int = 30):Harmony
	#end
	{
		var hsv:HSV = RGBtoHSV(color);
		
		if (threshold >= 359 || threshold <= 0)
		{
			throw "FlxColor Warning: Invalid threshold given to getSplitComplementHarmony()";
		}
		
		var opposite:Int = FlxMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		var warmer:Int = FlxMath.wrapValue(Std.int(hsv.hue), opposite - threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hsv.hue), opposite + threshold, 359);
		
		FlxG.log("hue: " + hsv.hue + " opposite: " + opposite + " warmer: " + warmer + " colder: " + colder);
		
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
	#if flash
	public static function getTriadicHarmony(color:UInt):TriadicHarmony
	#else
	public static function getTriadicHarmony(color:BitmapInt32):TriadicHarmony
	#end
	{
		var hsv:HSV = RGBtoHSV(color);
		
		var triadic1:Int = FlxMath.wrapValue(Std.int(hsv.hue), 120, 359);
		var triadic2:Int = FlxMath.wrapValue(triadic1, 120, 359);
		
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
	#if flash
	public static function getColorInfo(color:UInt):String
	#else
	public static function getColorInfo(color:BitmapInt32):String
	#end
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
	#if flash
	public static function RGBtoHexString(color:UInt):String
	#else
	public static function RGBtoHexString(color:BitmapInt32):String
	#end
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
	#if flash
	public static function RGBtoWebString(color:UInt):String
	#else
	public static function RGBtoWebString(color:BitmapInt32):String
	#end
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
	#if flash
	public static function colorToHexString(color:UInt):String
	#else
	public static function colorToHexString(color:Int):String
	#end
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
	#if flash
	public static function HSVtoRGB(h:Float, s:Float, v:Float, alpha:UInt = 255):UInt
	#else
	public static function HSVtoRGB(h:Float, s:Float, v:Float, alpha:Int = 255):BitmapInt32
	#end
	{
		#if flash
		var result:UInt = FlxG.TRANSPARENT;
		#else
		var result:BitmapInt32 = FlxG.TRANSPARENT;
		#end
		
		if (s == 0.0)
		{
			result = getColor32(alpha, Std.int(v * 255), Std.int(v * 255), Std.int(v * 255));
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
					result = getColor32(alpha, Std.int(v * 255), Std.int(t * 255), Std.int(p * 255));
					
				case 1:
					result = getColor32(alpha, Std.int(q * 255), Std.int(v * 255), Std.int(p * 255));
					
				case 2:
					result = getColor32(alpha, Std.int(p * 255), Std.int(v * 255), Std.int(t * 255));
					
				case 3:
					result = getColor32(alpha, Std.int(p * 255), Std.int(q * 255), Std.int(v * 255));
					
				case 4:
					result = getColor32(alpha, Std.int(t * 255), Std.int(p * 255), Std.int(v * 255));
					
				case 5:
					result = getColor32(alpha, Std.int(v * 255), Std.int(p * 255), Std.int(q * 255));
					
				default:
					FlxG.log("FlxColor Error: HSVtoRGB : Unknown color");
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
	#if flash
	public static function RGBtoHSV(color:UInt):HSV
	#else
	public static function RGBtoHSV(color:BitmapInt32):HSV
	#end
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
	
	
	#if flash
	public static function interpolateColor(color1:UInt, color2:UInt, steps:UInt, currentStep:UInt, alpha:UInt = 255):UInt
	{
		var src1:RGBA = getRGB(color1);
		var src2:RGBA = getRGB(color2);
		
		var r:UInt = cast((((src2.red - src1.red) * currentStep) / steps) + src1.red, UInt);
		var g:UInt = cast((((src2.green - src1.green) * currentStep) / steps) + src1.green, UInt);
		var b:UInt = cast((((src2.blue - src1.blue) * currentStep) / steps) + src1.blue, UInt);

		return getColor32(alpha, r, g, b);
	}
	
	public static function interpolateColorWithRGB(color:UInt, r2:UInt, g2:UInt, b2:UInt, steps:UInt, currentStep:UInt):UInt
	{
		var src:RGBA = getRGB(color);
		
		var r:UInt = cast((((r2 - src.red) * currentStep) / steps) + src.red, UInt);
		var g:UInt = cast((((g2 - src.green) * currentStep) / steps) + src.green, UInt);
		var b:UInt = cast((((b2 - src.blue) * currentStep) / steps) + src.blue, UInt);
	
		return getColor24(r, g, b);
	}
	
	public static function interpolateRGB(r1:UInt, g1:UInt, b1:UInt, r2:UInt, g2:UInt, b2:UInt, steps:UInt, currentStep:UInt):UInt
	{
		var r:UInt = cast((((r2 - r1) * currentStep) / steps) + r1, UInt);
		var g:UInt = cast((((g2 - g1) * currentStep) / steps) + g1, UInt);
		var b:UInt = cast((((b2 - b1) * currentStep) / steps) + b1, UInt);
	
		return getColor24(r, g, b);
	}
	#else
	public static function interpolateColor(color1:BitmapInt32, color2:BitmapInt32, steps:Int, currentStep:Int, alpha:Int = 255):BitmapInt32
	{
		var src1:RGBA = getRGB(color1);
		var src2:RGBA = getRGB(color2);
		
		var r:Int = Std.int((((src2.red - src1.red) * currentStep) / steps) + src1.red);
		var g:Int = Std.int((((src2.green - src1.green) * currentStep) / steps) + src1.green);
		var b:Int = Std.int((((src2.blue - src1.blue) * currentStep) / steps) + src1.blue);

		return getColor32(alpha, r, g, b);
	}
	
	public static function interpolateColorWithRGB(color:BitmapInt32, r2:Int, g2:Int, b2:Int, steps:Int, currentStep:Int):BitmapInt32
	{
		var src:RGBA = getRGB(color);
		
		var r:Int = Std.int((((r2 - src.red) * currentStep) / steps) + src.red);
		var g:Int = Std.int((((g2 - src.green) * currentStep) / steps) + src.green);
		var b:Int = Std.int((((b2 - src.blue) * currentStep) / steps) + src.blue);
	
		return getColor24(r, g, b);
	}
	
	public static function interpolateRGB(r1:Int, g1:Int, b1:Int, r2:Int, g2:Int, b2:Int, steps:Int, currentStep:Int):BitmapInt32
	{
		var r:Int = Std.int((((r2 - r1) * currentStep) / steps) + r1);
		var g:Int = Std.int((((g2 - g1) * currentStep) / steps) + g1);
		var b:Int = Std.int((((b2 - b1) * currentStep) / steps) + b1);
	
		return getColor24(r, g, b);
	}
	#end
	
	/**
	 * Returns a random color value between black and white
	 * <p>Set the min value to start each channel from the given offset.</p>
	 * <p>Set the max value to restrict the maximum color used per channel</p>
	 * 
	 * @param	min		The lowest value to use for the color
	 * @param	max 	The highest value to use for the color
	 * @param	alpha	The alpha value of the returning color (default 255 = fully opaque)
	 * 
	 * @return 32-bit color value with alpha
	 */
	#if flash
	public static function getRandomColor(min:UInt = 0, max:UInt = 255, alpha:UInt = 255):UInt
	{
		//	Sanity checks
		if (max > 255)
		{
			FlxG.log("FlxColor Warning: getRandomColor - max value too high");
			return getColor24(255, 255, 255);
		}
		
		if (min > max)
		{
			FlxG.log("FlxColor Warning: getRandomColor - min value higher than max");
			return getColor24(255, 255, 255);
		}
		
		var red:UInt = min + Std.int(Math.random() * (max - min));
		var green:UInt = min + Std.int(Math.random() * (max - min));
		var blue:UInt = min + Std.int(Math.random() * (max - min));
		
		return getColor32(alpha, red, green, blue);
	}
	#else
	public static function getRandomColor(min:Int = 0, max:Int = 255, alpha:Int = 255):BitmapInt32
	{
		//	Sanity checks
		if (max > 255)
		{
			FlxG.log("FlxColor Warning: getRandomColor - max value too high");
			return getColor24(255, 255, 255);
		}
		
		if (min > max)
		{
			FlxG.log("FlxColor Warning: getRandomColor - min value higher than max");
			return getColor24(255, 255, 255);
		}
		
		var red:Int = min + Std.int(Math.random() * (max - min));
		var green:Int = min + Std.int(Math.random() * (max - min));
		var blue:Int = min + Std.int(Math.random() * (max - min));
		
		return getColor32(alpha, red, green, blue);
	}
	#end
	
	/**
	 * Given an alpha and 3 color values this will return an integer representation of it
	 * 
	 * @param	alpha	The Alpha value (between 0 and 255)
	 * @param	red		The Red channel value (between 0 and 255)
	 * @param	green	The Green channel value (between 0 and 255)
	 * @param	blue	The Blue channel value (between 0 and 255)
	 * 
	 * @return	A native color value integer (format: 0xAARRGGBB)
	 */
	#if flash
	public static function getColor32(alpha:UInt, red:UInt, green:UInt, blue:UInt):UInt
	{
		return alpha << 24 | red << 16 | green << 8 | blue;
	}
	#else
	public static function getColor32(alpha:Int, red:Int, green:Int, blue:Int):BitmapInt32
	{
		#if neko
		return {rgb: red << 16 | green << 8 | blue, a: alpha};
		#else
		return alpha << 24 | red << 16 | green << 8 | blue;
		#end
	}
	#end
	
	/**
	 * Given 3 color values this will return an integer representation of it
	 * 
	 * @param	red		The Red channel value (between 0 and 255)
	 * @param	green	The Green channel value (between 0 and 255)
	 * @param	blue	The Blue channel value (between 0 and 255)
	 * 
	 * @return	A native color value integer (format: 0xRRGGBB)
	 */
	#if flash
	public static function getColor24(red:UInt, green:UInt, blue:UInt):UInt
	{
		return red << 16 | green << 8 | blue;
	}
	#else
	public static function getColor24(red:Int, green:Int, blue:Int):BitmapInt32
	{
		#if !neko
		return red << 16 | green << 8 | blue;
		#else
		return {rgb: red << 16 | green << 8 | blue, a: 255};
		#end
	}
	#end
	
	/**
	 * Return the component parts of a color as an Object with the properties alpha, red, green, blue
	 * 
	 * <p>Alpha will only be set if it exist in the given color (0xAARRGGBB)</p>
	 * 
	 * @param	color in RGB (0xRRGGBB) or ARGB format (0xAARRGGBB)
	 * 
	 * @return Object with properties: alpha, red, green, blue
	 */
	#if flash
	public static function getRGB(color:UInt):RGBA
	{
		//var alpha:UInt = color >>> 24;
		var alpha:UInt = (color >> 24) & 0xFF;
		var red:UInt = color >> 16 & 0xFF;
		var green:UInt = color >> 8 & 0xFF;
		var blue:UInt = color & 0xFF;
		
		return { alpha: alpha, red: red, green: green, blue: blue };
	}
	#else
	public static function getRGB(color:BitmapInt32):RGBA
	{
		//var alpha:Int = color >>> 24;
		#if !neko
		var alpha:Int = (color >> 24) & 0xFF;
		var red:Int = color >> 16 & 0xFF;
		var green:Int = color >> 8 & 0xFF;
		var blue:Int = color & 0xFF;
		#else
		var alpha:Int = color.a;
		var red:Int = color.rgb >> 16 & 0xFF;
		var green:Int = color.rgb >> 8 & 0xFF;
		var blue:Int = color.rgb & 0xFF;
		#end
		
		return { alpha: alpha, red: red, green: green, blue: blue };
	}
	#end
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Alpha component, as a value between 0 and 255
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Alpha component of the color, will be between 0 and 255 (0 being no Alpha, 255 full Alpha)
	 */
	#if flash
	public static function getAlpha(color:UInt):UInt
	#else
	public static function getAlpha(color:BitmapInt32):Int
	#end
	{
		//return color >>> 24;
		#if !neko
		return (color >> 24) & 0xFF;
		#else
		return color.a;
		#end
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Alpha component as a value between 0 and 1
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Alpha component of the color, will be between 0 and 1 (0 being no Alpha (opaque), 1 full Alpha (transparent))
	 */
	#if flash
	public static function getAlphaFloat(color:UInt):Float
	{
		//var f:UInt = color >>> 24;
		var f:UInt = (color >> 24) & 0xFF;
	#else
	public static function getAlphaFloat(color:BitmapInt32):Float
	{
		//var f:Int = color >>> 24;
		#if !neko
		var f:Int = (color >> 24) & 0xFF;
		#else
		var f:Int = color.a;
		#end
	#end
		
		return f / 255;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Red component, as a value between 0 and 255
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Red component of the color, will be between 0 and 255 (0 being no color, 255 full Red)
	 */
	#if flash
	public static function getRed(color:UInt):UInt
	#else
	public static function getRed(color:Int):Int
	#end
	{
		return color >> 16 & 0xFF;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Green component, as a value between 0 and 255
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Green component of the color, will be between 0 and 255 (0 being no color, 255 full Green)
	 */
	#if flash
	public static function getGreen(color:UInt):UInt
	#else
	public static function getGreen(color:Int):Int
	#end
	{
		return color >> 8 & 0xFF;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Blue component, as a value between 0 and 255
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Blue component of the color, will be between 0 and 255 (0 being no color, 255 full Blue)
	 */
	#if flash
	public static function getBlue(color:UInt):UInt
	#else
	public static function getBlue(color:Int):Int
	#end
	{
		return color & 0xFF;
	}
	
}

typedef HSV = {
    var hue:Float;
    var saturation:Float;
    var lightness:Float;
    var value:Float;
}

typedef RGBA = {
    #if flash
	var alpha:UInt;
    var red:UInt;
    var green:UInt;
    var blue:UInt;
	#else
	var alpha:Int;
    var red:Int;
    var green:Int;
    var blue:Int;
	#end
}

typedef Harmony = {
    #if flash
	var color1:UInt;
    var color2:UInt;
    var color3:UInt;
	#else
	var color1:BitmapInt32;
    var color2:BitmapInt32;
    var color3:BitmapInt32;
	#end
    var hue1:Int;
    var hue2:Int;
    var hue3:Int;
}

typedef TriadicHarmony = {
    #if flash
	var color1:UInt;
    var color2:UInt;
    var color3:UInt;
	#else
	var color1:BitmapInt32;
    var color2:BitmapInt32;
    var color3:BitmapInt32;
	#end
}