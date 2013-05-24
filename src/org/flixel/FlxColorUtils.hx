package org.flixel;

import nme.display.BitmapInt32;

/**
 * Class containing a set of useful color constants and 
 * a few color-related functions previously located in FlxU
 */
class FlxColorUtils 
{
	#if neko
	/**
	 * 0xffff0012
	 */
	static public inline var RED:BitmapInt32 = { rgb: 0xff0000, a: 0xff };
	#else
	/**
	 * 0xffff0012
	 */
	static public inline var RED:Int = 0xffff0000;
	#end
	
	#if neko
	/**
	 * 0xffffff00
	 */
	static public inline var YELLOW:BitmapInt32 = { rgb: 0xffff00, a: 0xff };
	#else
	/**
	 * 0xffffff00
	 */
	static public inline var YELLOW:Int = 0xffffff00;
	#end
	
	#if neko
	/**
	 * 0xff00f225
	 */
	static public inline var GREEN:BitmapInt32 = { rgb: 0x008000, a: 0xff };
	#else
	/**
	 * 0xff00f225
	 */
	static public inline var GREEN:Int = 0xff008000;
	#end
	
	#if neko
	/**
	 * 0xff0090e9
	 */
	static public inline var BLUE:BitmapInt32 = { rgb: 0x0000ff, a: 0xff };
	#else
	/**
	 * 0xff0090e9
	 */
	static public inline var BLUE:Int = 0xff0000ff;
	#end
	
	#if neko
	/**
	 * 0xfff01eff 
	 */
	static public inline var PINK:BitmapInt32 = { rgb: 0xffc0cb, a: 0xff };
	#else
	/**
	 * 0xfff01eff 
	 */
	static public inline var PINK:Int = 0xffffc0cb;
	#end
	
	#if neko
	/**
	 * 0xff800080
	 */
	static public inline var PURPLE:BitmapInt32 = { rgb: 0x800080, a: 0xff };
	#else
	/**
	 * 0xff800080
	 */
	static public inline var PURPLE:Int = 0xff800080;
	#end
	
	#if neko
	/**
	 * 0xffffffff
	 */
	static public inline var WHITE:BitmapInt32 = { rgb: 0xffffff, a: 0xff };
	#else
	/**
	 * 0xffffffff
	 */
	static public inline var WHITE:Int = 0xffffffff;
	#end
	
	#if neko
	/**
	 * 0xff000000
	 */
	static public inline var BLACK:BitmapInt32 = {rgb: 0x000000, a: 0xff};
	#else
	/**
	 * 0xff000000
	 */
	static public inline var BLACK:Int = 0xff000000;
	#end
	
	#if neko
	/**
	 * 0xff808080
	 */
	static public inline var GRAY:BitmapInt32 = {rgb: 0x808080, a: 0xff};
	#else
	/**
	 * 0xff808080
	 */
	static public inline var GRAY:Int = 0xff808080;
	#end
	
	#if neko
	/**
	 * 0x00000000 
	 */
	static public inline var TRANSPARENT:BitmapInt32 = {rgb: 0x000000, a: 0x00};
	#else
	/**
	 * 0x00000000 
	 */
	static public inline var TRANSPARENT:Int = 0x00000000;
	#end
    
    #if neko
	/** 
     * Ivory is an off-white color that resembles ivory. 0xfffffff0
     */
    static public inline var IVORY:BitmapInt32 = {rgb: 0xfffff0, a: 0xff};
    #else
	/** 
     * Ivory is an off-white color that resembles ivory. 0xfffffff0
     */
    static public inline var IVORY:Int = 0xfffffff0;
    #end
	
    #if neko
	/** 
     * Beige is a very pale brown. 0xfff5f5dc
     */
    static public inline var BEIGE:BitmapInt32 = {rgb: 0xf5f5dc, a: 0xff};
    #else
	/** 
     * Beige is a very pale brown. 0xfff5f5dc
     */
    static public inline var BEIGE:Int = 0xfff5f5dc;
    #end
   
    #if neko
	/** 
     * Wheat is a color that resembles wheat. 0xfff5deb3
     */
    static public inline var WHEAT:BitmapInt32 = {rgb: 0xf5deb3, a: 0xff};
    #else
	/** 
     * Wheat is a color that resembles wheat. 0xfff5deb3
     */
    static public inline var WHEAT:Int = 0xfff5deb3;
    #end	
	
    #if neko
	/** 
     * Tan is a pale tone of brown. 0xffd2b48c
     */
    static public inline var TAN:BitmapInt32 = {rgb: 0xd2b48c, a: 0xff};
    #else
	/** 
     * Tan is a pale tone of brown. 0xffd2b48c
     */
    static public inline var TAN:Int = 0xffd2b48c;
    #end
	
    #if neko
	/** 
     * Khaki is a light shade of yellow-brown similar to tan or beige. 0xffc3b091
     */
    static public inline var KHAKI:BitmapInt32 = {rgb: 0xc3b091, a: 0xff};
    #else
	/** 
     * Khaki is a light shade of yellow-brown similar to tan or beige. 0xffc3b091
     */
    static public inline var KHAKI:Int = 0xffc3b091;
    #end
	
    #if neko
	/** 
     * Silver is a metallic color tone resembling gray that is a representation of the color of polished silver. 0xffc0c0c0
     */
    static public inline var SILVER:BitmapInt32 = {rgb: 0xc0c0c0, a: 0xff};
    #else
	/** 
     * Silver is a metallic color tone resembling gray that is a representation of the color of polished silver. 0xffc0c0c0
     */
    static public inline var SILVER:Int = 0xffc0c0c0;
    #end
	
    #if neko
	/** 
     * Charcoal is a representation of the dark gray color of burned wood. 0xff464646
     */
    static public inline var CHARCOAL:BitmapInt32 = {rgb: 0x464646, a: 0xff};
    #else
	/** 
     * Charcoal is a representation of the dark gray color of burned wood. 0xff464646
     */
    static public inline var CHARCOAL:Int = 0xff464646;
    #end
	
    #if neko
	/** 
     * Navy blue is a dark shade of the color blue. 0xff000080
     */
    static public inline var NAVY_BLUE:BitmapInt32 = {rgb: 0x000080, a: 0xff};
    #else
	/** 
     * Navy blue is a dark shade of the color blue. 0xff000080
     */
    static public inline var NAVY_BLUE:Int = 0xff000080;
    #end
	
    #if neko
	/** 
     * Royal blue is a dark shade of the color blue. 0xff084c9e
     */
    static public inline var ROYAL_BLUE:BitmapInt32 = {rgb: 0x084c9e, a: 0xff};
    #else
	/** 
     * Royal blue is a dark shade of the color blue. 0xff084c9e
     */
    static public inline var ROYAL_BLUE:Int = 0xff084c9e;
    #end
	
    #if neko
	/** 
     * A medium blue tone. 0xff0000cd
     */
    static public inline var MEDIUM_BLUE:BitmapInt32 = {rgb: 0x0000cd, a: 0xff};
    #else
	/** 
     * A medium blue tone. 0xff0000cd
     */
    static public inline var MEDIUM_BLUE:Int = 0xff0000cd;
    #end
	
    #if neko
	/** 
     * Azure is a color that is commonly compared to the color of the sky on a clear summer's day. 0xff007fff
     */
    static public inline var AZURE:BitmapInt32 = {rgb: 0x007fff, a: 0xff};
    #else
	/** 
     * Azure is a color that is commonly compared to the color of the sky on a clear summer's day. 0xff007fff
     */
    static public inline var AZURE:Int = 0xff007fff;
    #end

    #if neko
	/** 
     * Cyan is a color between blue and green. 0xff00ffff
     */
    static public inline var CYAN:BitmapInt32 = {rgb: 0x00ffff, a: 0xff};
    #else
	/** 
     * Cyan is a color between blue and green. 0xff00ffff
     */
    static public inline var CYAN:Int = 0xff00ffff;
    #end
	
    #if neko
	/** 
     * Aquamarine is a color that is a bluish tint of cerulean toned toward cyan. 0xff7fffd4
     */
    static public inline var AQUAMARINE:BitmapInt32 = {rgb: 0x7fffd4, a: 0xff};
    #else
	/** 
     * Aquamarine is a color that is a bluish tint of cerulean toned toward cyan. 0xff7fffd4
     */
    static public inline var AQUAMARINE:Int = 0xff7fffd4;
    #end
	
    #if neko
	/** 
     * Teal is a low-saturated color, a bluish-green to dark medium. 0xff008080
     */
    static public inline var TEAL:BitmapInt32 = {rgb: 0x008080, a: 0xff};
    #else
	/** 
     * Teal is a low-saturated color, a bluish-green to dark medium. 0xff008080
     */
    static public inline var TEAL:Int = 0xff008080;
    #end
	
    #if neko
	/** 
     * Forest green is a green color resembling trees and other plants in a forest. 0xff228b22
     */
    static public inline var FOREST_GREEN:BitmapInt32 = {rgb: 0x228b22, a: 0xff};
    #else
	/** 
     * Forest green is a green color resembling trees and other plants in a forest. 0xff228b22
     */
    static public inline var FOREST_GREEN:Int = 0xff228b22;
    #end
	
    #if neko
	/** 
     * Olive is a dark yellowish green or greyish-green color like that of unripe or green olives. 0xff808000
     */
    static public inline var OLIVE:BitmapInt32 = {rgb: 0x808000, a: 0xff};
    #else
	/** 
     * Olive is a dark yellowish green or greyish-green color like that of unripe or green olives. 0xff808000
     */
    static public inline var OLIVE:Int = 0xff808000;
    #end
	
    #if neko
	/** 
     * Chartreuse is a color halfway between yellow and green. 0xff7fff00
     */
    static public inline var CHARTREUSE:BitmapInt32 = {rgb: 0x7fff00, a: 0xff};
    #else
	/** 
     * Chartreuse is a color halfway between yellow and green. 0xff7fff00
     */
    static public inline var CHARTREUSE:Int = 0xff7fff00;
    #end
	
    #if neko
	/** 
     * Lime is a color three-quarters of the way between yellow and green. 0xffbfff00
     */
    static public inline var LIME:BitmapInt32 = {rgb: 0xbfff00, a: 0xff};
    #else
	/** 
     * Lime is a color three-quarters of the way between yellow and green. 0xffbfff00
     */
    static public inline var LIME:Int = 0xffbfff00;
    #end

    #if neko
	/** 
     * Golden is one of a variety of yellow-brown color blends used to give the impression of the color of the element gold. 0xffffd700
     */
    static public inline var GOLDEN:BitmapInt32 = {rgb: 0xffd700, a: 0xff};
    #else
	/** 
     * Golden is one of a variety of yellow-brown color blends used to give the impression of the color of the element gold. 0xffffd700
     */
    static public inline var GOLDEN:Int = 0xffffd700;
    #end
	
    #if neko
	/** 
     * Goldenrod is a color that resembles the goldenrod plant. 0xffdaa520
     */
    static public inline var GOLDENROD:BitmapInt32 = {rgb: 0xdaa520, a: 0xff};
    #else
	/** 
     * Goldenrod is a color that resembles the goldenrod plant. 0xffdaa520
     */
    static public inline var GOLDENROD:Int = 0xffdaa520;
    #end
	
    #if neko
	/** 
     * Coral is a pinkish-orange color. 0xffff7f50
     */
    static public inline var CORAL:BitmapInt32 = {rgb: 0xff7f50, a: 0xff};
    #else
	/** 
     * Coral is a pinkish-orange color. 0xffff7f50
     */
    static public inline var CORAL:Int = 0xffff7f50;
    #end
	
    #if neko
	/** 
     * Salmon is a pale pinkish-orange to light pink color, named after the color of salmon flesh. 0xfffa8072
     */
    static public inline var SALMON:BitmapInt32 = {rgb: 0xfa8072, a: 0xff};
    #else
	/** 
     * Salmon is a pale pinkish-orange to light pink color, named after the color of salmon flesh. 0xfffa8072
     */
    static public inline var SALMON:Int = 0xfffa8072;
    #end
	
    #if neko
	/** 
     * Hot Pink is a more saturated version of the color pink. 0xfffc0fc0
     */
    static public inline var HOT_PINK:BitmapInt32 = {rgb: 0xfc0fc0, a: 0xff};
    #else
	/** 
     * Hot Pink is a more saturated version of the color pink. 0xfffc0fc0
     */
    static public inline var HOT_PINK:Int = 0xfffc0fc0;
    #end
	
    #if neko
	/** 
     * Fuchsia is a vivid reddish or pink color named after the flower of the fuchsia plant. 0xffff77ff
     */
    static public inline var FUCHSIA:BitmapInt32 = {rgb: 0xff77ff, a: 0xff};
    #else
	/** 
     * Fuchsia is a vivid reddish or pink color named after the flower of the fuchsia plant. 0xffff77ff
     */
    static public inline var FUCHSIA:Int = 0xffff77ff;
    #end
	
    #if neko
	/** 
     * Puce is a brownish-purple color. 0xffcc8899
     */
    static public inline var PUCE:BitmapInt32 = {rgb: 0xcc8899, a: 0xff};
    #else
	/** 
     * Puce is a brownish-purple color. 0xffcc8899
     */
    static public inline var PUCE:Int = 0xffcc8899;
    #end
	
    #if neko
	/** 
     * Mauve is a pale lavender-lilac color. 0xffe0b0ff
     */
    static public inline var MAUVE:BitmapInt32 = {rgb: 0xe0b0ff, a: 0xff};
    #else
	/** 
     * Mauve is a pale lavender-lilac color. 0xffe0b0ff
     */
    static public inline var MAUVE:Int = 0xffe0b0ff;
    #end
	
    #if neko
	/** 
     * Lavenderis a pale tint of violet. 0xffb57edc
     */
    static public inline var LAVENDER:BitmapInt32 = {rgb: 0xb57edc, a: 0xff};
    #else
	/** 
     * Lavenderis a pale tint of violet. 0xffb57edc
     */
    static public inline var LAVENDER:Int = 0xffb57edc;
    #end
	
    #if neko
	/** 
     * Plum is a deep purple color. 0xff843179
     */
    static public inline var PLUM:BitmapInt32 = {rgb: 0x843179, a: 0xff};
    #else
	/** 
     * Plum is a deep purple color. 0xff843179
     */
    static public inline var PLUM:Int = 0xff843179;
    #end
	
    #if neko
	/** 
     * Indigo is a deep and bright shade of blue. 0xff4b0082
     */
    static public inline var INDIGO:BitmapInt32 = {rgb: 0x4b0082, a: 0xff};
    #else
	/** 
     * Indigo is a deep and bright shade of blue. 0xff4b0082
     */
    static public inline var INDIGO:Int = 0xff4b0082;
    #end
	
    #if neko
	/** 
     * Maroon is a dark brownish-red color. 0xff800000
     */
    static public inline var MAROON:BitmapInt32 = {rgb: 0x800000, a: 0xff};
    #else
	/** 
     * Maroon is a dark brownish-red color. 0xff800000
     */
    static public inline var MAROON:Int = 0xff800000;
    #end
	
    #if neko
	/** 
     * Crimson is a strong, bright, deep red color. 0xffdc143c
     */
    static public inline var CRIMSON:BitmapInt32 = {rgb: 0xdc143c, a: 0xff};
    #else
	/** 
     * Crimson is a strong, bright, deep red color. 0xffdc143c
     */
    static public inline var CRIMSON:Int = 0xffdc143c;
    #end
	
	
	#if flash
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
	inline static public function makeColor(Red:UInt, Green:UInt, Blue:UInt, Alpha:Float = 1.0):UInt
	#else
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
	inline static public function makeColor(Red:Int, Green:Int, Blue:Int, Alpha:Float = 1.0):BitmapInt32
	#end
	{
		#if !neko
		return (Std.int((Alpha > 1) ? Alpha : (Alpha * 255)) & 0xFF) << 24 | (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF);
		#else
		return {rgb: (Red & 0xFF) << 16 | (Green & 0xFF) << 8 | (Blue & 0xFF), a: Std.int((Alpha > 1) ? Alpha : (Alpha * 255)) & 0xFF << 24 };
		#end
	}
	
	#if flash
	/**
	 * Generate a Flash <code>uint</code> color from HSB components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param   Alpha   	How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a <code>uint</code>.
	 */
	inline static public function makeColorFromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1.0):UInt
	#else
	/**
	 * Generate a Flash <code>uint</code> color from HSB components.
	 * 
	 * @param	Hue			A number between 0 and 360, indicating position on a color strip or wheel.
	 * @param	Saturation	A number between 0 and 1, indicating how colorful or gray the color should be.  0 is gray, 1 is vibrant.
	 * @param	Brightness	A number between 0 and 1, indicating how bright the color should be.  0 is black, 1 is full bright.
	 * @param   Alpha   	How opaque the color should be, either between 0 and 1 or 0 and 255.
	 * @return	The color as a <code>uint</code>.
	 */
	inline static public function makeColorFromHSB(Hue:Float, Saturation:Float, Brightness:Float, Alpha:Float = 1.0):BitmapInt32
	#end
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
		#if !neko
		return (Std.int((Alpha > 1) ? Alpha :( Alpha * 255)) & 0xFF) << 24 | Std.int(red * 255) << 16 | Std.int(green * 255) << 8 | Std.int(blue * 255);
		#else
		return { rgb: Std.int(red * 255) << 16 | Std.int(green * 255) << 8 | Std.int(blue * 255), a: (Std.int((Alpha > 1) ? Alpha :( Alpha * 255)) & 0xFF) << 24 };
		#end
	}
	
	#if flash
	/**
	 * Loads an array with the RGBA values of a Flash <code>uint</code> color.
	 * RGB values are stored 0-255.  Alpha is stored as a floating point number between 0 and 1.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	inline static public function getRGBA(Color:UInt, Results:Array<Float> = null):Array<Float>
	#else
	/**
	 * Loads an array with the RGBA values of a Flash <code>uint</code> color.
	 * RGB values are stored 0-255.  Alpha is stored as a floating point number between 0 and 1.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	inline static public function getRGBA(Color:BitmapInt32, Results:Array<Float> = null):Array<Float>
	#end
	{
		if (Results == null)
		{
			Results = new Array<Float>();
		}
		#if !neko
		Results[0] = (Color >> 16) & 0xFF;
		Results[1] = (Color >> 8) & 0xFF;
		Results[2] = Color & 0xFF;
		Results[3] = ((Color >> 24) & 0xFF) / 255;
		#else
		Results[0] = (Color.rgb >> 16) & 0xFF;
		Results[1] = (Color.rgb >> 8) & 0xFF;
		Results[2] = Color.rgb & 0xFF;
		Results[3] = Color.a / 255;
		#end
		return Results;
	}
	
	#if flash
	/**
	 * Loads an array with the HSB values of a Flash <code>uint</code> color.
	 * Hue is a value between 0 and 360.  Saturation, Brightness and Alpha
	 * are as floating point numbers between 0 and 1.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	inline static public function getHSB(Color:UInt, Results:Array<Float> = null):Array<Float>
	#else
	/**
	 * Loads an array with the HSB values of a Flash <code>uint</code> color.
	 * Hue is a value between 0 and 360.  Saturation, Brightness and Alpha
	 * are as floating point numbers between 0 and 1.
	 * @param	Color	The color you want to break into components.
	 * @param	Results	An optional parameter, allows you to use an array that already exists in memory to store the result.
	 * @return	An <code>Array</code> object containing the Red, Green, Blue and Alpha values of the given color.
	 */
	inline static public function getHSB(Color:Int, Results:Array<Float> = null):Array<Float>
	#end
	{
		if (Results == null)
		{
			Results = new Array<Float>();
		}
		
		var red:Float = ((Color >> 16) & 0xFF) / 255;
		var green:Float = ((Color >> 8) & 0xFF) / 255;
		var blue:Float = ((Color) & 0xFF) / 255;
		
		var m:Float = (red > green) ? red : green;
		var dmax:Float = (m > blue) ? m : blue;
		m = (red > green) ? green : red;
		var dmin:Float = (m > blue) ? blue : m;
		var range:Float = dmax - dmin;
		
		Results[2] = dmax;
		Results[1] = 0;
		Results[0] = 0;
		
		if (dmax != 0)
		{
			Results[1] = range / dmax;
		}
		if(Results[1] != 0) 
		{
			if (red == dmax)
			{
				Results[0] = (green - blue) / range;
			}
			else if (green == dmax)
			{
				Results[0] = 2 + (blue - red) / range;
			}
			else if (blue == dmax)
			{
				Results[0] = 4 + (red - green) / range;
			}
			Results[0] *= 60;
			if (Results[0] < 0)
			{
				Results[0] += 360;
			}
		}
		
		Results[3] = ((Color >> 24) & 0xFF) / 255;
		return Results;
	}
}