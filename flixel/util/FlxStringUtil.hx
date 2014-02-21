package flixel.util;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.Lib;
import flash.net.URLRequest;
import flixel.FlxG;
import flixel.system.FlxAssets;
using StringTools;

/**
 * A class primarily containing functions related 
 * to formatting different data types to strings.
 */
class FlxStringUtil
{
	/**
	 * Takes two "ticks" timestamps and formats them into the number of seconds that passed as a String.
	 * Useful for logging, debugging, the watch window, or whatever else.
	 * 
	 * @param	StartTicks	The first timestamp from the system.
	 * @param	EndTicks	The second timestamp from the system.
	 * @return	A String containing the formatted time elapsed information.
	 */
	public static inline function formatTicks(StartTicks:Int, EndTicks:Int):String
	{
		return (Math.abs(EndTicks - StartTicks) / 1000) + "s";
	}
	
	/**
	 * Format seconds as minutes with a colon, an optionally with milliseconds too.
	 * 
	 * @param	Seconds		The number of seconds (for example, time remaining, time spent, etc).
	 * @param	ShowMS		Whether to show milliseconds after a "." as well.  Default value is false.
	 * @return	A nicely formatted String, like "1:03".
	 */
	public static inline function formatTime(Seconds:Float, ShowMS:Bool = false):String
	{
		var timeString:String = Std.int(Seconds / 60) + ":";
		var timeStringHelper:Int = Std.int(Seconds) % 60;
		if (timeStringHelper < 10)
		{
			timeString += "0";
		}
		timeString += timeStringHelper;
		if (ShowMS)
		{
			timeString += ".";
			timeStringHelper = Std.int((Seconds - Std.int(Seconds)) * 100);
			if (timeStringHelper < 10)
			{
				timeString += "0";
			}
			timeString += timeStringHelper;
		}
		
		return timeString;
	}
	
	/**
	 * Generate a comma-separated string from an array.
	 * Especially useful for tracing or other debug output.
	 * 
	 * @param	AnyArray	Any Array object.
	 * @return	A comma-separated String containing the .toString() output of each element in the array.
	 */
	public static inline function formatArray(AnyArray:Array<Dynamic>):String
	{
		var string:String = "";
		if ((AnyArray != null) && (AnyArray.length > 0))
		{
			string = Std.string(AnyArray[0]);
			var i:Int = 1;
			var l:Int = AnyArray.length;
			while (i < l)
			{
				string += ", " + Std.string(AnyArray[i++]);
			}
		}
		return string;
	}

	 /**
	 * Generate a comma-seperated string representation of the keys of a StringMap.
	 * 
	 * @param  AnyMap    A StringMap object.
	 * @return  A String formatted like this: key1, key2, ..., keyX
	 */
	public static inline function formatStringMap(AnyMap:Map<String,Dynamic>):String
	{
		var string:String = "";
		for (key in AnyMap.keys()) {
			string += Std.string(key);
			string += ", ";
		}
		
		return string.substring(0, string.length - 2);
	} 
	
	/**
	 * Automatically commas and decimals in the right places for displaying money amounts.
	 * Does not include a dollar sign or anything, so doesn't really do much
	 * if you call say var results:String = FlxString.formatMoney(10,false);
	 * However, very handy for displaying large sums or decimal money values.
	 * 
	 * @param	Amount			How much moneys (in dollars, or the equivalent "main" currency - i.e. not cents).
	 * @param	ShowDecimal		Whether to show the decimals/cents component. Default value is true.
	 * @param	EnglishStyle	Major quantities (thousands, millions, etc) separated by commas, and decimal by a period.  Default value is true.
	 * @return	A nicely formatted String.  Does not include a dollar sign or anything!
	 */
	public static inline function formatMoney(Amount:Float, ShowDecimal:Bool = true, EnglishStyle:Bool = true):String
	{
		var helper:Int;
		var amount:Int = Math.floor(Amount);
		var string:String = "";
		var comma:String = "";
		var zeroes:String = "";
		while (amount > 0)
		{
			if((string.length > 0) && comma.length <= 0)
			{
				if (EnglishStyle)
				{
					comma = ",";
				}
				else
				{
					comma = ".";
				}
			}
			zeroes = "";
			helper = amount - Math.floor(amount / 1000) * 1000;
			amount = Math.floor(amount / 1000);
			if (amount > 0)
			{
				if (helper < 100)
				{
					zeroes += "0";
				}
				if (helper < 10)
				{
					zeroes += "0";
				}
			}
			string = zeroes + helper + comma + string;
		}
		if (ShowDecimal)
		{
			amount = Std.int(Amount * 100) - (Std.int(Amount) * 100);
			string += (EnglishStyle ? "." : ",") + amount;
			if (amount < 10)
			{
				string += "0";
			}
		}
		return string;
	}
	
	/** 
	 * Takes a string and filters out everything but the digits.
	 * 
	 * @param 	Input	The input string
	 * @return 	The output string, digits-only
	 */
	public static function filterDigits(Input:String):String
	{
		var output = new StringBuf();
		for (i in 0...Input.length) {
			var c = Input.charCodeAt(i);
			if (c >= '0'.code && c <= '9'.code) {
				output.addChar(c);
			}
		}
		return output.toString();
	}
	
	/**
	 * Format a text with html tags - useful for TextField.htmlText. 
	 * Used by the log window of the debugger.
	 * 
	 * @param	Text		The text to format
	 * @param	Size		The text size, using the font-size-tag
	 * @param	Color		The text color, using font-color-tag
	 * @param	Bold		Whether the text should be bold (b-tag)
	 * @param	Italic		Whether the text should be italic (i-tag)
	 * @param	Underlined 	Whether the text should be underlined (u-tag)
	 * @return	The html-formatted text.
	 */
	public static function htmlFormat(Text:String, Size:Int = 12, Color:String = "FFFFFF", Bold:Bool = false, Italic:Bool = false, Underlined:Bool = false):String
	{
		var prefix:String = "<font size='" + Size + "' color='#" + Color + "'>";
		var suffix:String = "</font>";
		
		if (Bold) 
		{
			prefix = "<b>" + prefix;
			suffix = suffix + "</b>";
		}
		if (Italic) 
		{
			prefix = "<i>" + prefix;
			suffix = suffix + "</i>";
		}
		if (Underlined) 
		{
			prefix = "<u>" + prefix;
			suffix = suffix + "</u>";
		}
		
		return prefix + Text + suffix;
	}
	
	/**
	 * Get the String name of any Object.
	 * 
	 * @param	Obj		The object in question.
	 * @param	Simple	Returns only the class name, not the package or packages.
	 * @return	The name of the Class as a String object.
	 */
	@:extern public static inline function getClassName(Obj:Dynamic, Simple:Bool = false):String
	{
		var cl:Class<Dynamic>;
		if (Std.is(Obj, Class))
		{
			cl = cast Obj;
		}
		else 
		{
			cl = Type.getClass(Obj);
		}
		
		var s:String = Type.getClassName(cl);
		if (s != null)
		{
			s = StringTools.replace(s, "::", ".");
			if (Simple)
			{
				s = s.substr(s.lastIndexOf(".") + 1);
			}
		}
		return s;
	}
	
	/**
	 * Returns the domain of a URL.
	 */
	public static function getDomain(url:String):String
	{
		var urlStart:Int = url.indexOf("://") + 3;
		var urlEnd:Int = url.indexOf("/", urlStart);
		var home:String = url.substring(urlStart, urlEnd);
		var LastDot:Int = home.lastIndexOf(".") - 1;
		var domEnd:Int = home.lastIndexOf(".", LastDot) + 1;
		home = home.substring(domEnd, home.length);
		home = home.split(":")[0];
		return (home == "") ? "local" : home;
	}
	
	/**
	 * Helper function that uses getClassName to compare two objects' class names.
	 * 
	 * @param	Obj1	The first object
	 * @param	Obj2	The second object
	 * @param	Simple 	Only uses the class name, not the package or packages.
	 * @return	Whether they have the same class name or not
	 */
	public static inline function sameClassName(Obj1:Dynamic, Obj2:Dynamic, Simple:Bool = true):Bool
	{
		return (getClassName(Obj1, Simple) == getClassName(Obj2, Simple));
	}
	
	
	/**
	 * Split a comma-separated string into an array of ints
	 * 
	 * @param	Data 	String formatted like this: "1, 2, 5, -10, 120, 27"
	 * @return	An array of ints
	 */
	public static function toIntArray(Data:String):Array<Int>
	{
		if ((Data != null) && (Data != "")) 
		{
			var strArray:Array<String> = Data.split(",");
			var iArray:Array<Int> = new Array<Int>();
			for (str in strArray) 
			{
				iArray.push(Std.parseInt(str));
			}
			return iArray;
		}
		return null;
	}
	
	/**
	 * Split a comma-separated string into an array of floats
	 * 
	 * @param	Data string formatted like this: "1.0,2.1,5.6,1245587.9, -0.00354"
	 * @return	An array of floats
	 */	
	public static function toFloatArray(Data:String):Array<Float>
	{
		if ((Data != null) && (Data != "")) 
		{
			var strArray:Array<String> = Data.split(",");
			var fArray:Array<Float> = new Array<Float>();
			for (str in strArray) 
			{
				fArray.push(Std.parseFloat(str));
			}
			return fArray;
		}
		return null;
	}
	
	/**
	 * Converts a one-dimensional array of tile data to a comma-separated string.
	 * 
	 * @param	Data		An array full of integer tile references.
	 * @param	Width		The number of tiles in each row.
	 * @param	Invert		Recommended only for 1-bit arrays - changes 0s to 1s and vice versa.
	 * @return	A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	public static function arrayToCSV(Data:Array<Int>, Width:Int, Invert:Bool = false):String
	{
		var row:Int = 0;
		var column:Int;
		var csv:String = "";
		var Height:Int = Std.int(Data.length / Width);
		var index:Int;
		var offset:Int = 0;
		
		while (row < Height)
		{
			column = 0;
			
			while (column < Width)
			{
				index = Data[offset];
				
				if (Invert)
				{
					if (index == 0)
					{
						index = 1;
					}
					else if (index == 1)
					{
						index = 0;
					}
				}
				
				if (column == 0)
				{
					if (row == 0)
					{
						csv += index;
					}
					else
					{
						csv += "\n" + index;
					}
				}
				else
				{
					csv += ", "+index;
				}
				
				column++;
				offset++;
			}
			
			row++;
		}
		
		return csv;
	}
	
	/**
	 * Converts a BitmapData object to a comma-separated string. Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding. Black pixels must be PURE BLACK.
	 * 
	 * @param	Bitmap		A Flash BitmapData object, preferably black and white.
	 * @param	Invert		Load white pixels as solid instead.
	 * @param	Scale		Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @param  	ColorMap  	An array of color values (0xAARRGGBB) in the order they're intended to be assigned as indices
	 * @return	A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	public static function bitmapToCSV(Bitmap:BitmapData, Invert:Bool = false, Scale:Int = 1, ?ColorMap:Array<Int>):String
	{
		if (Scale < 1) 
		{
			Scale = 1;
		}
		
		// Import and scale image if necessary
		if (Scale > 1)
		{
			var bd:BitmapData = Bitmap;
			Bitmap = new BitmapData(Bitmap.width * Scale, Bitmap.height * Scale);
			
			#if js
			var bdW:Int = bd.width;
			var bdH:Int = bd.height;
			var pCol:Int = 0;
			
			for (i in 0...bdW)
			{
				for (j in 0...bdH)
				{
					pCol = bd.getPixel(i, j);
					
					for (k in 0...Scale)
					{
						for (m in 0...Scale)
						{
							Bitmap.setPixel(i * Scale + k, j * Scale + m, pCol);
						}
					}
				}
			}
			#else
			var mtx = new Matrix();
			mtx.scale(Scale, Scale);
			Bitmap.draw(bd, mtx);
			#end
		}
		
		// Walk image and export pixel values
		var row:Int = 0;
		var column:Int;
		var pixel:Int;
		var csv:String = "";
		var bitmapWidth:Int = Bitmap.width;
		var bitmapHeight:Int = Bitmap.height;
		
		while (row < bitmapHeight)
		{
			column = 0;
			
			while (column < bitmapWidth)
			{
				// Decide if this pixel/tile is solid (1) or not (0)
				pixel = Bitmap.getPixel(column, row);
				
				if (ColorMap != null)
				{
					pixel = FlxArrayUtil.indexOf(ColorMap, pixel);
				}
				else if ((Invert && (pixel > 0)) || (!Invert && (pixel == 0)))
				{
					pixel = 1;
				}
				else
				{
					pixel = 0;
				}
				
				// Write the result to the string
				if (column == 0)
				{
					if (row == 0)
					{
						csv += pixel;
					}
					else
					{
						csv += "\n" + pixel;
					}
				}
				else
				{
					csv += ", " + pixel;
				}
				
				column++;
			}
			
			row++;
		}
		
		return csv;
	}
	
	/**
	 * Converts a resource image file to a comma-separated string. Black pixels are flagged as 'solid' by default,
	 * non-black pixels are set as non-colliding. Black pixels must be PURE BLACK.
	 * 
	 * @param	ImageFile	An embedded graphic, preferably black and white.
	 * @param	Invert		Load white pixels as solid instead.
	 * @param	Scale		Default is 1.  Scale of 2 means each pixel forms a 2x2 block of tiles, and so on.
	 * @return	A comma-separated string containing the level data in a FlxTilemap-friendly format.
	 */
	public static function imageToCSV(ImageFile:Dynamic, Invert:Bool = false, Scale:Int = 1):String
	{
		var tempBitmapData:BitmapData;
		
		if (Std.is(ImageFile, String))
		{
			tempBitmapData = FlxAssets.getBitmapData(ImageFile);
		}
		else
		{
			tempBitmapData = (Type.createInstance(ImageFile, [])).bitmapData;
		}
		
		return bitmapToCSV(tempBitmapData, Invert, Scale);
	}
	
	/**
	 * Helper function to create a string for toString() functions. Automatically rounds values according to FlxG.debugger.precision.
	 * Strings are formatted in the format: (x: 50 | y: 60 | visible: false)
	 * 
	 * @param	LabelValuePairs		Array with the data for the string
	 */
	public static function getDebugString(LabelValuePairs:Array<LabelValuePair>):String
	{
		var output:String = "(";
		for (pair in LabelValuePairs)
		{
			output += (pair.label + ": ");
			var value:Dynamic = pair.value;
			if (Std.is(value, Float))
			{
				value = FlxMath.roundDecimal(cast value, FlxG.debugger.precision);
			}
			output += (value + " | ");
		}
		// remove the | of the last item, we don't want that at the end
		output = output.substr(0, output.length - 2).trim();
		return (output + ")");
	}
}

typedef LabelValuePair = {
	label:String,
	value:Dynamic
}
