package org.flixel.util;

import org.flixel.FlxG;

/**
 * Class containing a set of useful color constants and 
 * a few functions for color manipulation and color harmony.
 */
class FlxColor
{
	/**
	 * 0xffff0012
	 */
	static public inline var RED:Int = 0xffff0000;
	
	/**
	 * 0xffffff00
	 */
	static public inline var YELLOW:Int = 0xffffff00;
	
	/**
	 * 0xff00f225
	 */
	static public inline var GREEN:Int = 0xff008000;
	
	/**
	 * 0xff0090e9
	 */
	static public inline var BLUE:Int = 0xff0000ff;
	
	/**
	 * 0xfff01eff 
	 */
	static public inline var PINK:Int = 0xffffc0cb;
	
	/**
	 * 0xff800080
	 */
	static public inline var PURPLE:Int = 0xff800080;
	
	/**
	 * 0xffffffff
	 */
	static public inline var WHITE:Int = 0xffffffff;
	
	/**
	 * 0xff000000
	 */
	static public inline var BLACK:Int = 0xff000000;
	
	/**
	 * 0xff808080
	 */
	static public inline var GRAY:Int = 0xff808080;
	
	/**
	 * 0x00000000 
	 */
	static public inline var TRANSPARENT:Int = 0x00000000;
    
    /** 
     * Ivory is an off-white color that resembles ivory. 0xfffffff0
     */
    static public inline var IVORY:Int = 0xfffffff0;
	
    /** 
     * Beige is a very pale brown. 0xfff5f5dc
     */
    static public inline var BEIGE:Int = 0xfff5f5dc;
   
    /** 
     * Wheat is a color that resembles wheat. 0xfff5deb3
     */
    static public inline var WHEAT:Int = 0xfff5deb3;
	
    /** 
     * Tan is a pale tone of brown. 0xffd2b48c
     */
    static public inline var TAN:Int = 0xffd2b48c;
	
    /** 
     * Khaki is a light shade of yellow-brown similar to tan or beige. 0xffc3b091
     */
    static public inline var KHAKI:Int = 0xffc3b091;
	
    /** 
     * Silver is a metallic color tone resembling gray that is a representation of the color of polished silver. 0xffc0c0c0
     */
    static public inline var SILVER:Int = 0xffc0c0c0;
	
    /** 
     * Charcoal is a representation of the dark gray color of burned wood. 0xff464646
     */
    static public inline var CHARCOAL:Int = 0xff464646;
	
    /** 
     * Navy blue is a dark shade of the color blue. 0xff000080
     */
    static public inline var NAVY_BLUE:Int = 0xff000080;
	
    /** 
     * Royal blue is a dark shade of the color blue. 0xff084c9e
     */
    static public inline var ROYAL_BLUE:Int = 0xff084c9e;
	
    /** 
     * A medium blue tone. 0xff0000cd
     */
    static public inline var MEDIUM_BLUE:Int = 0xff0000cd;
	
    /** 
     * Azure is a color that is commonly compared to the color of the sky on a clear summer's day. 0xff007fff
     */
    static public inline var AZURE:Int = 0xff007fff;

    /** 
     * Cyan is a color between blue and green. 0xff00ffff
     */
    static public inline var CYAN:Int = 0xff00ffff;
	
    /** 
     * Aquamarine is a color that is a bluish tint of cerulean toned toward cyan. 0xff7fffd4
     */
    static public inline var AQUAMARINE:Int = 0xff7fffd4;
	
    /** 
     * Teal is a low-saturated color, a bluish-green to dark medium. 0xff008080
     */
    static public inline var TEAL:Int = 0xff008080;
	
    /** 
     * Forest green is a green color resembling trees and other plants in a forest. 0xff228b22
     */
    static public inline var FOREST_GREEN:Int = 0xff228b22;
	
    /** 
     * Olive is a dark yellowish green or greyish-green color like that of unripe or green olives. 0xff808000
     */
    static public inline var OLIVE:Int = 0xff808000;
	
    /** 
     * Chartreuse is a color halfway between yellow and green. 0xff7fff00
     */
    static public inline var CHARTREUSE:Int = 0xff7fff00;
	
    /** 
     * Lime is a color three-quarters of the way between yellow and green. 0xffbfff00
     */
    static public inline var LIME:Int = 0xffbfff00;

    /** 
     * Golden is one of a variety of yellow-brown color blends used to give the impression of the color of the element gold. 0xffffd700
     */
    static public inline var GOLDEN:Int = 0xffffd700;
	
    /** 
     * Goldenrod is a color that resembles the goldenrod plant. 0xffdaa520
     */
    static public inline var GOLDENROD:Int = 0xffdaa520;
	
    /** 
     * Coral is a pinkish-orange color. 0xffff7f50
     */
    static public inline var CORAL:Int = 0xffff7f50;
	
    /** 
     * Salmon is a pale pinkish-orange to light pink color, named after the color of salmon flesh. 0xfffa8072
     */
    static public inline var SALMON:Int = 0xfffa8072;
	
    /** 
     * Hot Pink is a more saturated version of the color pink. 0xfffc0fc0
     */
    static public inline var HOT_PINK:Int = 0xfffc0fc0;
	
    /** 
     * Fuchsia is a vivid reddish or pink color named after the flower of the fuchsia plant. 0xffff77ff
     */
    static public inline var FUCHSIA:Int = 0xffff77ff;
	
    /** 
     * Puce is a brownish-purple color. 0xffcc8899
     */
    static public inline var PUCE:Int = 0xffcc8899;
	
    /** 
     * Mauve is a pale lavender-lilac color. 0xffe0b0ff
     */
    static public inline var MAUVE:Int = 0xffe0b0ff;
	
    /** 
     * Lavenderis a pale tint of violet. 0xffb57edc
     */
    static public inline var LAVENDER:Int = 0xffb57edc;
	
    /** 
     * Plum is a deep purple color. 0xff843179
     */
    static public inline var PLUM:Int = 0xff843179;
	
    /** 
     * Indigo is a deep and bright shade of blue. 0xff4b0082
     */
    static public inline var INDIGO:Int = 0xff4b0082;
	
    /** 
     * Maroon is a dark brownish-red color. 0xff800000
     */
    static public inline var MAROON:Int = 0xff800000;
	
    /** 
     * Crimson is a strong, bright, deep red color. 0xffdc143c
     */
    static public inline var CRIMSON:Int = 0xffdc143c;
	
	
	/**
	 * Generate a Flash <code>uint</code> color from RGBA components.
	 * 
	 * @param   Red     The red component, between 0 and 255.
	 * @param   Green   The green component, between 0 and 255.
	 * @param   Blue    The blue component, between 0 and 255.
	 * @param   Alpha   How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * 
	 * @return  The color as a <code>uint</code>.
	 */
	inline static public function makeFromRGBA(Red:Int, Green:Int, Blue:Int, Alpha:Float = 1.0):Int
	{
		return (Std.int((Alpha > 1) ? Alpha : (Alpha * 255)) & 0xFF) << 24 | (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF);
	}
	
	/**
	 * Generate a Flash <code>uint</code> color from HSBA components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param   Alpha   	How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a <code>uint</code>.
	 */
	inline static public function makeFromHSBA(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1.0):Int
	{
		var red:Float;
		var green:Float;
		var blue:Float;
		if(Saturation == 0.0)
		{
			red   = Brightness;
			green = Brightness;        
			blue  = Brightness;
		}       
		else
		{
			if (Hue == 360)
			{
				Hue = 0;
			}
			var slice:Int = Std.int(Hue / 60);
			var hf:Float = Hue / 60 - slice;
			var aa:Float = Brightness*(1 - Saturation);
			var bb:Float = Brightness * (1 - Saturation * hf);
			var cc:Float = Brightness * (1 - Saturation * (1.0 - hf));
			switch (slice)
			{
				case 0: 
					red = Brightness; 
					green = cc;   
					blue = aa;  
				case 1: 
					red = bb;  
					green = Brightness;  
					blue = aa;
				case 2: 
					red = aa;  
					green = Brightness;  
					blue = cc;
				case 3: 
					red = aa;  
					green = bb;   
					blue = Brightness;
				case 4: 
					red = cc;  
					green = aa;   
					blue = Brightness;
				case 5: 
					red = Brightness; 
					green = aa;   
					blue = bb;
				default: 
					red = 0;  
					green = 0;    
					blue = 0;
			}
		}
		
		return (Std.int((Alpha > 1) ? Alpha :( Alpha * 255)) & 0xFF) << 24 | Std.int(red * 255) << 16 | Std.int(green * 255) << 8 | Std.int(blue * 255);
	}
	
	/**
	 * Loads an array with the RGBA values of a Flash <code>uint</code> color.
	 * RGB values are stored 0-255.  Alpha is stored as a floating point number between 0 and 1 rounded to 4 decimals.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an RGBA that already exists in memory to store the result.
	 * @return	An RGBA object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	inline static public function getRGBA(Color:Int, Results:RGBA = null):RGBA
	{
		var red:Int = (Color >> 16) & 0xFF;
		var green:Int = (Color >> 8) & 0xFF;
		var blue:Int = Color & 0xFF;
		var alpha:Float = FlxMath.roundDecimal(((Color >> 24) & 0xFF) / 255, 4);
		
		if (Results != null)
			Results = { red: red, green: green, blue: blue, alpha: alpha };
		return { red: red, green: green, blue: blue, alpha: alpha };
	}
	
	/**
	 * Loads an array with the HSB values of a Flash <code>uint</code> color.
	 * Hue is a value between 0 and 360. Saturation, Brightness and Alpha
	 * are as floating point numbers between 0 and 1 rounded to 4 decimals.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>HSBA</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	inline static public function getHSBA(Color:Int, Results:HSBA = null):HSBA
	{
		var hue:Float;
		var saturation:Float;
		var brightness:Float;
		var alpha:Float;
		
		var red:Float = ((Color >> 16) & 0xFF) / 255;
		var green:Float = ((Color >> 8) & 0xFF) / 255;
		var blue:Float = ((Color) & 0xFF) / 255;
		
		var m:Float = (red > green) ? red : green;
		var dmax:Float = (m > blue) ? m : blue;
		m = (red > green) ? green : red;
		var dmin:Float = (m > blue) ? blue : m;
		var range:Float = dmax - dmin;
		
		brightness = FlxMath.roundDecimal(dmax, 4);
		saturation = 0;
		hue = 0;
		
		if (dmax != 0)
		{
			saturation = FlxMath.roundDecimal(range / dmax, 4);
		}
		if(saturation != 0) 
		{
			if (red == dmax)
			{
				hue = (green - blue) / range;
			}
			else if (green == dmax)
			{
				hue = 2 + (blue - red) / range;
			}
			else if (blue == dmax)
			{
				hue = 4 + (red - green) / range;
			}
			hue *= 60;
			if (hue < 0)
			{
				hue += 360;
			}
		}
		
		alpha = FlxMath.roundDecimal(((Color >> 24) & 0xFF) / 255, 4);
		
		if (Results != null) 
			Results = { hue: Std.int(hue), brightness: brightness, saturation: saturation, alpha: alpha };
		return { hue: Std.int(hue), brightness: brightness, saturation: saturation, alpha: alpha };
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Alpha component, as a value between 0 and 255
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Alpha component of the color, will be between 0 and 255 (0 being no Alpha, 255 full Alpha)
	 */
	inline static public function getAlpha(color:Int):Int
	{
		//return color >>> 24;
		return (color >> 24) & 0xFF;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Alpha component as a value between 0 and 1
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Alpha component of the color, will be between 0 and 1 (0 being no Alpha (opaque), 1 full Alpha (transparent))
	 */
	inline static public function getAlphaFloat(color:Int):Float
	{
		//var f:Int = color >>> 24;
		var f:Int = (color >> 24) & 0xFF;
		return f / 255;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Red component, as a value between 0 and 255
	 * 
	 * @param	color	In the format 0xAARRGGBB
	 * 
	 * @return	The Red component of the color, will be between 0 and 255 (0 being no color, 255 full Red)
	 */
	inline static public function getRed(color:Int):Int
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
	inline static public function getGreen(color:Int):Int
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
	inline static public function getBlue(color:Int):Int
	{
		return color & 0xFF;
	}
	
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
	static public function getRandomColor(min:Int = 0, max:Int = 255, alpha:Int = 255):Int
	{
		//	Sanity checks
		if (max > 255)
		{
			FlxG.warn("FlxColor: getRandomColor - max value too high");
			return getColor24(255, 255, 255);
		}
		
		if (min > max)
		{
			FlxG.warn("FlxColor: getRandomColor - min value higher than max");
			return getColor24(255, 255, 255);
		}
		
		var red:Int = min + Std.int(Math.random() * (max - min));
		var green:Int = min + Std.int(Math.random() * (max - min));
		var blue:Int = min + Std.int(Math.random() * (max - min));
		
		return getColor32(alpha, red, green, blue);
	}
	
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
	inline static public function getColor32(alpha:Int, red:Int, green:Int, blue:Int):Int
	{
		return alpha << 24 | red << 16 | green << 8 | blue;
	}
	
	/**
	 * Given 3 color values this will return an integer representation of it
	 * 
	 * @param	red		The Red channel value (between 0 and 255)
	 * @param	green	The Green channel value (between 0 and 255)
	 * @param	blue	The Blue channel value (between 0 and 255)
	 * 
	 * @return	A native color value integer (format: 0xRRGGBB)
	 */
	inline static public function getColor24(red:Int, green:Int, blue:Int):Int
	{
		return red << 16 | green << 8 | blue;
	}
}

typedef RGBA = {
    var red:Int;
    var green:Int;
    var blue:Int;
	
	var alpha:Float;
}

typedef HSBA = {
	var hue:Int;
	
	var saturation:Float;
	var brightness:Float;
	var alpha:Float;
}