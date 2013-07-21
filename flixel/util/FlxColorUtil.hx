package flixel.util;

/**
 * Class containing a set of functions for color manipulation and color harmony.
 */
class FlxColorUtil
{
	/**
	 * Generate a Flash <code>uint</code> color from RGBA components.
	 * 
	 * @param   Red     The red component, between 0 and 255.
	 * @param   Green   The green component, between 0 and 255.
	 * @param   Blue    The blue component, between 0 and 255.
	 * @param   Alpha   How opaque the color should be, either between 0 and 1 or 0 and 255.
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
		
		if (Saturation == 0.0)
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
	 * 
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
	 * 
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
	 * @param	Color	In the format 0xAARRGGBB
	 * @return	The Alpha component of the color, will be between 0 and 255 (0 being no Alpha, 255 full Alpha)
	 */
	inline static public function getAlpha(Color:Int):Int
	{
		return (Color >> 24) & 0xFF;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Alpha component as a value between 0 and 1
	 * 
	 * @param	Color	In the format 0xAARRGGBB
	 * @return	The Alpha component of the color, will be between 0 and 1 (0 being no Alpha (opaque), 1 full Alpha (transparent))
	 */
	inline static public function getAlphaFloat(Color:Int):Float
	{
		var f:Int = (Color >> 24) & 0xFF;
		return f / 255;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Red component, as a value between 0 and 255
	 * 
	 * @param	Color	In the format 0xAARRGGBB
	 * @return	The Red component of the color, will be between 0 and 255 (0 being no color, 255 full Red)
	 */
	inline static public function getRed(Color:Int):Int
	{
		return Color >> 16 & 0xFF;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Green component, as a value between 0 and 255
	 * 
	 * @param	Color	In the format 0xAARRGGBB
	 * @return	The Green component of the color, will be between 0 and 255 (0 being no color, 255 full Green)
	 */
	inline static public function getGreen(Color:Int):Int
	{
		return Color >> 8 & 0xFF;
	}
	
	/**
	 * Given a native color value (in the format 0xAARRGGBB) this will return the Blue component, as a value between 0 and 255
	 * 
	 * @param	Color	In the format 0xAARRGGBB
	 * @return	The Blue component of the color, will be between 0 and 255 (0 being no color, 255 full Blue)
	 */
	inline static public function getBlue(Color:Int):Int
	{
		return Color & 0xFF;
	}
	
	/**
	 * Returns a random color value between black and white
	 * Set the min value to start each channel from the given offset.
	 * Set the max value to restrict the maximum color used per channel
	 * 
	 * @param	Min		The lowest value to use for the color
	 * @param	Max 	The highest value to use for the color
	 * @param	Alpha	The alpha value of the returning color (default 255 = fully opaque)
	 * @return	32-bit color value with alpha
	 */
	static public function getRandomColor(Min:Int = 0, Max:Int = 255, Alpha:Int = 255):Int
	{
		//	Sanity checks
		if (Max > 255)
		{
			FlxG.log.warn("FlxColor: getRandomColor - max value too high");
			return getColor24(255, 255, 255);
		}
		
		if (Min > Max)
		{
			FlxG.log.warn("FlxColor: getRandomColor - min value higher than max");
			return getColor24(255, 255, 255);
		}
		
		var red:Int = Min + Std.int(Math.random() * (Max - Min));
		var green:Int = Min + Std.int(Math.random() * (Max - Min));
		var blue:Int = Min + Std.int(Math.random() * (Max - Min));
		
		return getColor32(Alpha, red, green, blue);
	}
	
	/**
	 * Given an alpha and 3 color values this will return an integer representation of it
	 * 
	 * @param	Alpha	The Alpha value (between 0 and 255)
	 * @param	Red		The Red channel value (between 0 and 255)
	 * @param	Green	The Green channel value (between 0 and 255)
	 * @param	Blue	The Blue channel value (between 0 and 255)
	 * @return	A native color value integer (format: 0xAARRGGBB)
	 */
	inline static public function getColor32(Alpha:Int, Red:Int, Green:Int, Blue:Int):Int
	{
		return Alpha << 24 | Red << 16 | Green << 8 | Blue;
	}
	
	/**
	 * Given 3 color values this will return an integer representation of it
	 * 
	 * @param	Red		The Red channel value (between 0 and 255)
	 * @param	Green	The Green channel value (between 0 and 255)
	 * @param	Blue	The Blue channel value (between 0 and 255)
	 * @return	A native color value integer (format: 0xRRGGBB)
	 */
	inline static public function getColor24(Red:Int, Green:Int, Blue:Int):Int
	{
		return Red << 16 | Green << 8 | Blue;
	}
	
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
			colors[c] = HSVtoRGBA(c, 1.0, 1.0, Alpha);
		}
		
		return colors;
	}
	
	/**
	 * Returns a Complementary Color Harmony for the given color.
	 * A complementary hue is one directly opposite the color given on the color wheel
	 * Value returned in 0xAARRGGBB format with Alpha set to 255.
	 * 
	 * @param	Color	The color to base the harmony on
	 * @return	0xAARRGGBB format color value
	 */
	inline static public function getComplementHarmony(Color:Int):Int
	{
		var hsv:HSV = RGBtoHSV(Color);
		
		var opposite:Int = FlxMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		return HSVtoRGBA(opposite, 1.0, 1.0);
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
			FlxG.log.warn("FlxColor Warning: Invalid threshold given to getAnalogousHarmony()");
		}
		
		var warmer:Int = FlxMath.wrapValue(Std.int(hsv.hue), 359 - Threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hsv.hue), Threshold, 359);
		
		return { color1: Color, color2: HSVtoRGBA(warmer, 1.0, 1.0), color3: HSVtoRGBA(colder, 1.0, 1.0), hue1: Std.int(hsv.hue), hue2: warmer, hue3: colder };
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
			FlxG.log.warn("FlxColor: Invalid threshold given to getSplitComplementHarmony()");
		}
		
		var opposite:Int = FlxMath.wrapValue(Std.int(hsv.hue), 180, 359);
		
		var warmer:Int = FlxMath.wrapValue(Std.int(hsv.hue), opposite - Threshold, 359);
		var colder:Int = FlxMath.wrapValue(Std.int(hsv.hue), opposite + Threshold, 359);
		
		FlxG.log.notice("hue: " + hsv.hue + " opposite: " + opposite + " warmer: " + warmer + " colder: " + colder);
		
		return { color1: Color, color2: HSVtoRGBA(warmer, hsv.saturation, hsv.value), color3: HSVtoRGBA(colder, hsv.saturation, hsv.value), hue1: Std.int(hsv.hue), hue2: warmer, hue3: colder };
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
		
		return { color1: Color, color2: HSVtoRGBA(triadic1, 1.0, 1.0), color3: HSVtoRGBA(triadic2, 1.0, 1.0) };
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
		var rgba:RGBA = getRGBA(Color);
		var hsl:HSV = RGBtoHSV(Color);
		
		//	Hex format
		var result:String = RGBAtoHexString(Color) + "\n";
		
		//	RGB format
		result += "Alpha: " + rgba.alpha + " Red: " + rgba.red + " Green: " + rgba.green + " Blue: " + rgba.blue + "\n";
		
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
	inline static public function RGBAtoHexString(Color:Int):String
	{
		var rgba:RGBA = getRGBA(Color);
		
		return "0x" + colorToHexString(Std.int(rgba.alpha)) + colorToHexString(rgba.red) + colorToHexString(rgba.green) + colorToHexString(rgba.blue);
	}
	
	/**
	 * Return a String representation of the color in the format #RRGGBB
	 * 
	 * @param	Color 	The color to get the String representation for
	 * @return	A string of length 10 characters in the format 0xAARRGGBB
	 */
	inline static public function RGBAtoWebString(Color:Int):String
	{
		var rgba:RGBA = getRGBA(Color);
		
		return "#" + colorToHexString(rgba.red) + colorToHexString(rgba.green) + colorToHexString(rgba.blue);
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
	 * @return	32-bit RGBA color value (0xAARRGGBB)
	 */
	static public function HSVtoRGBA(H:Float, S:Float, V:Float, Alpha:Int = 255):Int
	{
		var result = FlxColor.TRANSPARENT;
		
		if (S == 0.0)
		{
			result = getColor32(Alpha, Std.int(V * 255), Std.int(V * 255), Std.int(V * 255));
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
					result = getColor32(Alpha, Std.int(V * 255), Std.int(t * 255), Std.int(p * 255));
				case 1:
					result = getColor32(Alpha, Std.int(q * 255), Std.int(V * 255), Std.int(p * 255));
				case 2:
					result = getColor32(Alpha, Std.int(p * 255), Std.int(V * 255), Std.int(t * 255));
				case 3:
					result = getColor32(Alpha, Std.int(p * 255), Std.int(q * 255), Std.int(V * 255));
				case 4:
					result = getColor32(Alpha, Std.int(t * 255), Std.int(p * 255), Std.int(V * 255));
				case 5:
					result = getColor32(Alpha, Std.int(V * 255), Std.int(p * 255), Std.int(q * 255));
				default:
					FlxG.log.warn("FlxColor: HSVtoRGB: Unknown color");
			}
		}
		
		return result;
	}
	
	/**
	 * Convert an RGB color value to an object containing the HSV color space values: Hue, Saturation and Lightness
	 * 
	 * @param	Color 	The color in format 0xRRGGBB
	 * @return 	Object with the properties hue (from 0 to 360), saturation (from 0 to 1.0) and lightness (from 0 to 1.0, also available under .value)
	 */
	static public function RGBtoHSV(Color:Int):HSV
	{
		var rgb:RGBA = getRGBA(Color);
		
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
		
		return { hue: hue, saturation: saturation, lightness: lightness, value: lightness };
	}
	
	/**
	 * Turn a color with alpha and rgb values into a color without the alpha comoponent.
	 * Example: 0x55ff0000 becomes 0xff0000
	 * 
	 * @param	Color	The Color to convert
	 * @return	The color without its alpha component
	 */
	inline static public function RGBAtoRGB(Color:Int):Int
	{
		return getColor24(getRed(Color), getGreen(Color), getBlue(Color));
	}
	
	/**
	 * Get an interpolated color based on two different colors.
	 * 
	 * @param 	Color1			The first color
	 * @param 	Color2			The second color
	 * @param 	Steps			The amount of total steps
	 * @param 	CurrentStep		The step the interpolated color should be on
	 * @param	Alpha			The alpha value you want the interpolated color to have
	 * @return	The interpolated color
	 */
	inline static public function interpolateColor(Color1:Int, Color2:Int, Steps:Int, CurrentStep:Int, Alpha:Int = 255):Int
	{
		var src1:RGBA = getRGBA(Color1);
		var src2:RGBA = getRGBA(Color2);
		
		var r:Int = Std.int((((src2.red - src1.red) * CurrentStep) / Steps) + src1.red);
		var g:Int = Std.int((((src2.green - src1.green) * CurrentStep) / Steps) + src1.green);
		var b:Int = Std.int((((src2.blue - src1.blue) * CurrentStep) / Steps) + src1.blue);

		return getColor32(Alpha, r, g, b);
	}
	
	/**
	 * Get an interpolated color based on a color and the RGB value of a second color.
	 * 
	 * @param 	Color			The first color
	 * @param 	R2				The red value of the second color
	 * @param 	G2				The green value of the second color
	 * @param 	B2				The blue value of the second color
	 * @param 	Steps			The amount of total steps
	 * @param 	CurrentStep		The step the interpolated color should be on
	 * @param	Alpha			The alpha value you want the interpolated color to have
	 * @return	The interpolated color
	 */
	inline static public function interpolateColorWithRGB(Color:Int, R2:Int, G2:Int, B2:Int, Steps:Int, CurrentStep:Int):Int
	{
		var src:RGBA = getRGBA(Color);
		
		var r:Int = Std.int((((R2 - src.red) * CurrentStep) / Steps) + src.red);
		var g:Int = Std.int((((G2 - src.green) * CurrentStep) / Steps) + src.green);
		var b:Int = Std.int((((B2 - src.blue) * CurrentStep) / Steps) + src.blue);
	
		return getColor24(r, g, b);
	}
	
	/**
	 * Get an interpolated color based on the RGB values of two different colors.
	 * 
	 * @param 	R1				The red value of the first color
	 * @param 	G1				The green value of the first color
	 * @param 	B1				The blue value of the first color
	 * @param 	R2				The red value of the second color
	 * @param 	G2				The green value of the second color
	 * @param 	B2				The blue value of the second color
	 * @param 	Steps			The amount of total steps
	 * @param 	CurrentStep		The step the interpolated color should be on
	 * @param	Alpha			The alpha value you want the interpolated color to have
	 * @return	The interpolated color
	 */
	inline static public function interpolateRGB(R1:Int, G1:Int, B1:Int, R2:Int, G2:Int, B2:Int, Steps:Int, CurrentStep:Int):Int
	{
		var r:Int = Std.int((((R2 - R1) * CurrentStep) / Steps) + R1);
		var g:Int = Std.int((((G2 - G1) * CurrentStep) / Steps) + G1);
		var b:Int = Std.int((((B2 - B1) * CurrentStep) / Steps) + B1);
		
		return getColor24(r, g, b);
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

typedef HSV = {
    var hue:Float;
    var saturation:Float;
    var lightness:Float;
    var value:Float;
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